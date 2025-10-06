#!/usr/bin/env python3
"""
Dotfiles Web UI - 配置管理可视化界面
提供配置管理、依赖关系可视化和实时预览功能
"""

import os
import argparse
import socket
import json
import yaml
import subprocess
from pathlib import Path
from datetime import datetime
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import hashlib
import shutil

app = Flask(__name__, static_folder='static')
CORS(app)

# 配置路径
BASE_DIR = Path(__file__).parent.parent
CONFIG_DIR = Path.home() / '.dotfiles'
CONFIG_FILE = CONFIG_DIR / 'install-config.json'
HISTORY_FILE = CONFIG_DIR / 'install-history.log'
INSTALL_CONF = BASE_DIR / 'install.conf.yaml'


class ConfigChangeHandler(FileSystemEventHandler):
    """配置文件变更监听器"""

    def __init__(self):
        self.callbacks = []

    def on_modified(self, event):
        if not event.is_directory:
            for callback in self.callbacks:
                callback(event.src_path)


# 全局变量
config_watcher = ConfigChangeHandler()
observer = Observer()


def init_config_dir():
    """初始化配置目录"""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)

    if not CONFIG_FILE.exists():
        default_config = {
            "version": "1.0",
            "last_install": None,
            "preferences": {
                "shell": "zsh",
                "theme": "dracula",
                "plugins": []
            },
            "components": {
                "dotfiles": True,
                "homebrew": False,
                "zsh": False,
                "tmux": False,
                "vim": False,
                "git": False
            }
        }
        with open(CONFIG_FILE, 'w') as f:
            json.dump(default_config, f, indent=2)


def parse_install_conf():
    """解析 install.conf.yaml 获取依赖关系"""
    try:
        with open(INSTALL_CONF) as f:
            conf = yaml.safe_load(f)

        nodes = []
        edges = []

        # 解析 link 配置
        links = {}
        for item in conf:
            if isinstance(item, dict) and 'link' in item:
                links = item['link']
                break

        # 创建节点和边
        for target, source in links.items():
            target_name = os.path.basename(target)
            source_name = os.path.basename(str(source))

            # 添加节点
            if target_name not in [n['id'] for n in nodes]:
                nodes.append({
                    'id': target_name,
                    'label': target_name,
                    'type': 'target',
                    'path': target
                })

            if source_name not in [n['id'] for n in nodes]:
                nodes.append({
                    'id': source_name,
                    'label': source_name,
                    'type': 'source',
                    'path': str(source)
                })

            # 添加边
            edges.append({
                'from': source_name,
                'to': target_name,
                'label': 'links to'
            })

        return {'nodes': nodes, 'edges': edges}

    except Exception as e:
        return {'nodes': [], 'edges': [], 'error': str(e)}


def load_links_mapping():
    """解析 install.conf.yaml，返回 link 映射字典: target(str) -> source(str)。"""
    try:
        with open(INSTALL_CONF) as f:
            conf = yaml.safe_load(f)

        links = {}
        for item in conf:
            if isinstance(item, dict) and 'link' in item:
                raw_links = item['link']
                if isinstance(raw_links, dict):
                    for target, source in raw_links.items():
                        # Dotbot 支持更复杂的结构，这里仅处理最常见的字符串映射
                        if isinstance(source, (str, Path)):
                            links[str(target)] = str(source)
                        elif isinstance(source, dict) and 'path' in source:
                            links[str(target)] = str(source['path'])
                break
        return links
    except Exception:
        return {}


def file_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            h.update(chunk)
    return h.hexdigest()


def compute_diff(detail_hash: bool = False):
    """计算仓库源文件与目标链接的差异。"""
    links = load_links_mapping()
    results = {
        'total': len(links),
        'missing_source': [],      # 源文件缺失
        'missing_target': [],      # 目标不存在
        'not_symlink': [],         # 目标存在但不是符号链接
        'wrong_link': [],          # 符号链接但指向错误
        'content_diff': [],        # 内容不同（当目标是普通文件或错误链接时）
        'ok': []                   # 一切正常
    }

    for target, source in links.items():
        target_path = Path(os.path.expanduser(target))
        source_path = (BASE_DIR / source).resolve()

        if not source_path.exists():
            results['missing_source'].append({'target': target, 'source': str(source_path)})
            continue

        if not target_path.exists():
            results['missing_target'].append({'target': target, 'source': str(source_path)})
            continue

        if not target_path.is_symlink():
            entry = {'target': target, 'source': str(source_path)}
            if detail_hash and target_path.is_file() and source_path.is_file():
                try:
                    entry['target_hash'] = file_sha256(target_path)
                    entry['source_hash'] = file_sha256(source_path)
                    if entry['target_hash'] != entry['source_hash']:
                        results['content_diff'].append(entry)
                        continue
                except Exception:
                    pass
            results['not_symlink'].append(entry)
            continue

        # 符号链接，检查是否指向正确位置
        try:
            link_target = target_path.resolve()
        except Exception:
            link_target = None

        if link_target is None or link_target != source_path:
            results['wrong_link'].append({
                'target': target,
                'source': str(source_path),
                'current': str(link_target) if link_target else None
            })
            continue

        results['ok'].append({'target': target, 'source': str(source_path)})

    return results


@app.route('/')
def index():
    """主页"""
    return send_from_directory('static', 'index.html')


@app.route('/api/config', methods=['GET'])
def get_config():
    """获取当前配置"""
    init_config_dir()

    try:
        with open(CONFIG_FILE) as f:
            config = json.load(f)
        return jsonify(config)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/config', methods=['POST'])
def save_config():
    """保存配置"""
    init_config_dir()

    try:
        new_config = request.json
        new_config['last_install'] = datetime.now().isoformat()

        with open(CONFIG_FILE, 'w') as f:
            json.dump(new_config, f, indent=2)

        # 记录到历史
        with open(HISTORY_FILE, 'a') as f:
            f.write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] 更新配置 - Web UI\n")

        return jsonify({'status': 'success', 'config': new_config})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/dependencies', methods=['GET'])
def get_dependencies():
    """获取配置依赖关系图"""
    return jsonify(parse_install_conf())


@app.route('/api/files', methods=['GET'])
def list_files():
    """列出所有配置文件"""
    config_files = []

    # 主要配置目录
    config_dirs = [
        BASE_DIR / 'config',
        BASE_DIR / 'zsh',
        BASE_DIR / 'tmux',
        BASE_DIR / 'vim',
        BASE_DIR / 'git',
        BASE_DIR / 'themes',
        BASE_DIR / 'shell',
    ]

    for dir_path in config_dirs:
        if dir_path.exists():
            for file_path in dir_path.rglob('*'):
                if file_path.is_file() and not file_path.name.startswith('.'):
                    rel_path = file_path.relative_to(BASE_DIR)
                    config_files.append({
                        'name': file_path.name,
                        'path': str(rel_path),
                        'full_path': str(file_path),
                        'size': file_path.stat().st_size,
                        'modified': datetime.fromtimestamp(file_path.stat().st_mtime).isoformat()
                    })

    return jsonify(config_files)


@app.route('/api/files/<path:filepath>', methods=['GET'])
def get_file_content(filepath):
    """获取文件内容"""
    try:
        file_path = BASE_DIR / filepath

        if not file_path.exists():
            return jsonify({'error': 'File not found'}), 404

        # 检查文件大小，避免读取过大文件
        if file_path.stat().st_size > 1024 * 1024:  # 1MB
            return jsonify({'error': 'File too large'}), 400

        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        return jsonify({
            'path': filepath,
            'content': content,
            'size': file_path.stat().st_size,
            'modified': datetime.fromtimestamp(file_path.stat().st_mtime).isoformat()
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/files/<path:filepath>', methods=['PUT'])
def save_file_content(filepath):
    """保存文件内容"""
    try:
        file_path = BASE_DIR / filepath

        if not file_path.exists():
            return jsonify({'error': 'File not found'}), 404

        content = request.json.get('content', '')

        # 创建备份
        backup_path = file_path.with_suffix(file_path.suffix + '.backup')
        if file_path.exists():
            import shutil
            shutil.copy2(file_path, backup_path)

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)

        return jsonify({
            'status': 'success',
            'path': filepath,
            'backup': str(backup_path)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/history', methods=['GET'])
def get_history():
    """获取操作历史"""
    init_config_dir()

    try:
        if not HISTORY_FILE.exists():
            return jsonify([])

        with open(HISTORY_FILE) as f:
            lines = f.readlines()

        history = []
        for line in lines:
            line = line.strip()
            if line and line.startswith('['):
                history.append(line)

        # 返回最近20条
        return jsonify(history[-20:])
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/snapshots', methods=['GET'])
def list_snapshots():
    """列出所有快照"""
    backup_dir = CONFIG_DIR / 'backups'

    if not backup_dir.exists():
        return jsonify([])

    snapshots = []
    for snapshot_file in backup_dir.glob('*.tar.gz'):
        stat = snapshot_file.stat()
        snapshots.append({
            'name': snapshot_file.name,
            'path': str(snapshot_file),
            'size': stat.st_size,
            'created': datetime.fromtimestamp(stat.st_ctime).isoformat()
        })

    # 按创建时间倒序排列
    snapshots.sort(key=lambda x: x['created'], reverse=True)

    return jsonify(snapshots)


@app.route('/api/snapshots', methods=['POST'])
def create_snapshot():
    """创建快照"""
    try:
        snapshot_name = request.json.get('name', 'snapshot')

        # 调用 config-manager.sh 创建快照
        result = subprocess.run(
            [str(BASE_DIR / 'scripts' / 'config-manager.sh'), 'snapshot', snapshot_name],
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            return jsonify({'status': 'success', 'message': result.stdout})
        else:
            return jsonify({'error': result.stderr}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/themes', methods=['GET'])
def list_themes():
    """列出可用主题"""
    themes_dir = BASE_DIR / 'themes'

    if not themes_dir.exists():
        return jsonify([])

    themes = []
    for theme_dir in themes_dir.iterdir():
        if theme_dir.is_dir() and not theme_dir.name.startswith('.'):
            theme_info = {
                'name': theme_dir.name,
                'path': str(theme_dir.relative_to(BASE_DIR)),
                'files': []
            }

            # 列出主题文件
            for file in theme_dir.iterdir():
                if file.is_file():
                    theme_info['files'].append(file.name)

            themes.append(theme_info)

    return jsonify(themes)


@app.route('/api/health', methods=['GET'])
def health_check():
    """健康检查"""
    try:
        # 调用 health-check.sh
        result = subprocess.run(
            [str(BASE_DIR / 'scripts' / 'health-check.sh')],
            capture_output=True,
            text=True,
            timeout=10
        )

        return jsonify({
            'status': 'healthy' if result.returncode == 0 else 'unhealthy',
            'output': result.stdout,
            'errors': result.stderr
        })
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)}), 500


@app.route('/api/stats', methods=['GET'])
def get_stats():
    """获取统计信息"""
    stats = {
        'total_files': 0,
        'total_size': 0,
        'last_modified': None,
        'components': {},
    }

    # 统计配置文件
    config_dirs = [
        BASE_DIR / 'config',
        BASE_DIR / 'zsh',
        BASE_DIR / 'tmux',
        BASE_DIR / 'vim',
        BASE_DIR / 'git',
    ]

    for dir_path in config_dirs:
        if dir_path.exists():
            component_name = dir_path.name
            file_count = 0
            total_size = 0

            for file_path in dir_path.rglob('*'):
                if file_path.is_file():
                    file_count += 1
                    total_size += file_path.stat().st_size

                    # 更新最后修改时间
                    mtime = datetime.fromtimestamp(file_path.stat().st_mtime)
                    if stats['last_modified'] is None or mtime > datetime.fromisoformat(stats['last_modified']):
                        stats['last_modified'] = mtime.isoformat()

            stats['components'][component_name] = {
                'files': file_count,
                'size': total_size
            }
            stats['total_files'] += file_count
            stats['total_size'] += total_size

    return jsonify(stats)


@app.route('/api/diff', methods=['GET'])
def api_diff():
    """获取源-目标差异。query: detail_hash=1 可返回文件哈希对比。"""
    detail_hash = request.args.get('detail_hash') in ('1', 'true', 'True')
    try:
        diff = compute_diff(detail_hash=detail_hash)
        return jsonify(diff)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def ensure_parent_dir(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)


def safe_backup(path: Path):
    if path.exists() and not path.is_symlink():
        backup = path.with_suffix(path.suffix + '.backup')
        try:
            shutil.copy2(path, backup)
            return str(backup)
        except Exception:
            return None
    return None


@app.route('/api/sync', methods=['POST'])
def api_sync():
    """执行修复/同步：创建缺失目标、修正错误链接，必要时备份普通文件。支持可选字段 allow_overwrite。"""
    body = request.json or {}
    allow_overwrite = bool(body.get('allow_overwrite', False))
    try:
        links = load_links_mapping()
        actions = []

        for target, source in links.items():
            target_path = Path(os.path.expanduser(target))
            source_path = (BASE_DIR / source).resolve()

            if not source_path.exists():
                actions.append({'target': target, 'source': str(source_path), 'status': 'skip', 'reason': 'missing_source'})
                continue

            ensure_parent_dir(target_path)

            # 目标不存在：直接创建符号链接
            if not target_path.exists():
                try:
                    if target_path.is_symlink():
                        target_path.unlink()
                    target_path.symlink_to(source_path)
                    actions.append({'target': target, 'action': 'link', 'status': 'ok'})
                except Exception as e:
                    actions.append({'target': target, 'action': 'link', 'status': 'error', 'error': str(e)})
                continue

            # 目标存在但不是符号链接
            if not target_path.is_symlink():
                if not allow_overwrite:
                    actions.append({'target': target, 'status': 'skip', 'reason': 'exists_not_symlink'})
                    continue
                backup = safe_backup(target_path)
                try:
                    target_path.unlink()
                    target_path.symlink_to(source_path)
                    actions.append({'target': target, 'action': 'replace_with_link', 'status': 'ok', 'backup': backup})
                except Exception as e:
                    actions.append({'target': target, 'action': 'replace_with_link', 'status': 'error', 'error': str(e), 'backup': backup})
                continue

            # 是符号链接但指向错误
            try:
                link_target = target_path.resolve()
            except Exception:
                link_target = None

            if link_target != source_path:
                try:
                    target_path.unlink()
                    target_path.symlink_to(source_path)
                    actions.append({'target': target, 'action': 'relink', 'status': 'ok', 'from': str(link_target) if link_target else None})
                except Exception as e:
                    actions.append({'target': target, 'action': 'relink', 'status': 'error', 'error': str(e)})
            else:
                actions.append({'target': target, 'status': 'ok'})

        return jsonify({'actions': actions})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    init_config_dir()

    # 启动文件监听（可选）
    # observer.schedule(config_watcher, str(CONFIG_DIR), recursive=True)
    # observer.start()

    # 端口优先级：命令行 --port > 环境变量 FLASK_PORT > 默认 5000
    env_port = os.getenv('FLASK_PORT')
    default_port = int(env_port) if env_port and env_port.isdigit() else 5000

    parser = argparse.ArgumentParser(description='Dotfiles Web UI')
    parser.add_argument('--port', type=int, default=default_port, help='端口号，默认 5000 或环境变量 FLASK_PORT')
    args = parser.parse_args()

    def is_port_in_use(port: int, host: str = "127.0.0.1") -> bool:
        """检查端口是否被占用（非占用式，仅尝试连接）。"""
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(0.2)
            return sock.connect_ex((host, port)) == 0

    def find_available_port(start_port: int, max_tries: int = 20) -> int:
        """从 start_port 起寻找可用端口，返回第一个可用端口。"""
        for candidate in range(start_port, start_port + max_tries):
            if not is_port_in_use(candidate):
                return candidate
        return start_port

    # 在带自动重载的模式下，确保父子进程使用同一端口
    env_selected = os.getenv('DFWUI_SELECTED_PORT')
    if env_selected and env_selected.isdigit():
        selected_port = int(env_selected)
    else:
        selected_port = find_available_port(args.port)
        os.environ['DFWUI_SELECTED_PORT'] = str(selected_port)

    print("🚀 Dotfiles Web UI 启动中...")
    print(f"📁 配置目录: {CONFIG_DIR}")
    if selected_port != args.port:
        print(f"⚠️ 端口 {args.port} 已被占用，使用 {selected_port}")
    print(f"🌐 访问地址: http://localhost:{selected_port}")

    app.run(host='0.0.0.0', port=selected_port, debug=True)
