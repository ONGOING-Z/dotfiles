# 📦 Web UI 安装指南

详细的安装步骤和系统要求。

## 📋 系统要求

### 必需组件
- **Python**: 3.8 或更高版本
- **pip**: Python 包管理器
- **浏览器**: 现代浏览器（Chrome/Firefox/Safari/Edge）

### 可选组件
- **Docker**: 如果使用 Docker 部署
- **Git**: 克隆仓库时需要

### 操作系统支持
- ✅ Linux (Ubuntu, Debian, CentOS, Fedora 等)
- ✅ macOS (10.14+)
- ✅ Windows (WSL2)

## 🚀 安装方法

### 方法 1：使用启动脚本（推荐）

这是最简单的方式，适合所有用户。

```bash
# 1. 进入 webui 目录
cd dotfiles/webui

# 2. 运行启动脚本
./start.sh

# 脚本会自动：
# - 检查 Python 版本
# - 创建虚拟环境
# - 安装所有依赖
# - 启动 Web 服务器
```

**预期输出：**
```
🚀 Dotfiles Web UI 启动脚本
✓ Python 版本: 3.11.2
创建虚拟环境...
✓ 虚拟环境创建完成
激活虚拟环境...
安装依赖包...
✓ 依赖安装完成
✓ 配置目录已创建: /home/user/.dotfiles

═══════════════════════════════════════
  Dotfiles Web UI 正在启动...
═══════════════════════════════════════

  访问地址: http://localhost:5000

  按 Ctrl+C 停止服务器

 * Serving Flask app 'app'
 * Running on http://0.0.0.0:5000
```

### 方法 2：使用 Docker

适合喜欢容器化部署的用户。

#### 使用 Docker Compose（推荐）

```bash
# 1. 进入 webui 目录
cd dotfiles/webui

# 2. 启动容器
docker-compose up -d

# 3. 查看日志
docker-compose logs -f

# 4. 停止服务
docker-compose down
```

#### 使用 Docker CLI

```bash
# 1. 构建镜像
cd dotfiles/webui
docker build -t dotfiles-webui .

# 2. 运行容器
docker run -d \
  --name dotfiles-webui \
  -p 5000:5000 \
  -v $(pwd)/..:/dotfiles:ro \
  -v ~/.dotfiles:/root/.dotfiles \
  dotfiles-webui

# 3. 查看日志
docker logs -f dotfiles-webui

# 4. 停止容器
docker stop dotfiles-webui
docker rm dotfiles-webui
```

### 方法 3：手动安装

适合需要完全控制的高级用户。

```bash
# 1. 进入 webui 目录
cd dotfiles/webui

# 2. 创建虚拟环境
python3 -m venv venv

# 3. 激活虚拟环境
# Linux/macOS:
source venv/bin/activate
# Windows (WSL):
source venv/bin/activate

# 4. 升级 pip
pip install --upgrade pip

# 5. 安装依赖
pip install -r requirements.txt

# 6. 启动应用
python3 app.py
```

## 🔍 验证安装

### 1. 检查服务器状态

打开浏览器访问：
```
http://localhost:5000
```

你应该看到 Web UI 主页。

### 2. 运行测试

```bash
# 激活虚拟环境
source venv/bin/activate

# 运行测试
python3 -m pytest test_app.py -v

# 预期输出：
# test_app.py::test_index PASSED
# test_app.py::test_get_config PASSED
# test_app.py::test_save_config PASSED
# ...
```

### 3. 检查 API

使用 curl 测试 API：

```bash
# 测试配置 API
curl http://localhost:5000/api/config

# 测试统计 API
curl http://localhost:5000/api/stats

# 测试文件列表 API
curl http://localhost:5000/api/files
```

## 🛠️ 依赖说明

### Python 包

```txt
Flask>=3.0.0          # Web 框架
Flask-CORS>=4.0.0     # 跨域支持
PyYAML>=6.0           # YAML 解析
watchdog>=3.0.0       # 文件监控
python-dotenv>=1.0.0  # 环境变量管理
```

### 前端库（CDN）

```html
<!-- Vue.js 3 -->
<script src="https://cdn.jsdelivr.net/npm/vue@3/dist/vue.global.js"></script>

<!-- Vis.js -->
<script src="https://cdn.jsdelivr.net/npm/vis-network@9.1.2/dist/vis-network.min.js"></script>

<!-- Axios -->
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<!-- Font Awesome -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
```

## 🌐 网络配置

### 默认配置

- **主机**: 0.0.0.0 (监听所有接口)
- **端口**: 5000
- **调试模式**: 开发时启用

### 自定义端口

如果端口 5000 被占用：

```bash
# 方法 1: 修改 app.py
# 编辑最后一行：
app.run(host='0.0.0.0', port=8080, debug=True)

# 方法 2: 使用环境变量（计划功能）
export FLASK_PORT=8080
python3 app.py
```

### 远程访问

**⚠️ 警告**: 仅在可信网络中启用远程访问！

默认情况下，Web UI 绑定到所有接口（0.0.0.0），意味着可以从网络中的其他设备访问。

**推荐**: 使用 SSH 隧道进行远程访问：

```bash
# 在远程机器上启动 Web UI
cd dotfiles/webui
./start.sh

# 在本地机器上创建 SSH 隧道
ssh -L 5000:localhost:5000 user@remote-host

# 在本地浏览器访问
http://localhost:5000
```

## 📂 目录结构

安装后的目录结构：

```
webui/
├── venv/                   # Python 虚拟环境（自动创建）
│   ├── bin/
│   ├── lib/
│   └── .installed          # 标记文件
├── static/                 # 静态文件
│   ├── index.html
│   ├── style.css
│   └── app.js
├── app.py                  # Flask 应用
├── requirements.txt        # Python 依赖
├── start.sh               # 启动脚本
├── test_app.py            # 测试文件
├── Dockerfile             # Docker 镜像
├── docker-compose.yml     # Docker Compose
└── *.md                   # 文档文件
```

## 🔧 故障排查

### 问题 1: Python 版本过低

**症状**:
```
Error: Python 3.8 or higher is required
```

**解决**:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.11

# macOS
brew install python@3.11

# 验证版本
python3 --version
```

### 问题 2: pip 找不到

**症状**:
```
bash: pip: command not found
```

**解决**:
```bash
# Ubuntu/Debian
sudo apt install python3-pip

# macOS
# pip 随 Python 一起安装

# 验证
pip3 --version
```

### 问题 3: 虚拟环境创建失败

**症状**:
```
Error: Unable to create virtual environment
```

**解决**:
```bash
# Ubuntu/Debian
sudo apt install python3-venv

# 然后重试
python3 -m venv venv
```

### 问题 4: 端口被占用

**症状**:
```
OSError: [Errno 98] Address already in use
```

**解决**:
```bash
# 查找占用进程
lsof -i :5000

# 杀死进程
kill -9 <PID>

# 或使用其他端口
# 修改 app.py 中的端口号
```

### 问题 5: 权限错误

**症状**:
```
PermissionError: [Errno 13] Permission denied
```

**解决**:
```bash
# 检查文件权限
ls -la webui/

# 修复权限
chmod +x start.sh

# 检查配置目录权限
ls -la ~/.dotfiles/
```

### 问题 6: 依赖安装失败

**症状**:
```
ERROR: Could not find a version that satisfies the requirement
```

**解决**:
```bash
# 升级 pip
pip install --upgrade pip

# 使用国内镜像（中国用户）
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 或清华镜像
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 问题 7: 无法访问界面

**症状**:
浏览器无法打开 http://localhost:5000

**诊断步骤**:

1. 检查服务器是否运行：
```bash
ps aux | grep python
```

2. 检查端口是否监听：
```bash
netstat -tuln | grep 5000
# 或
ss -tuln | grep 5000
```

3. 检查防火墙：
```bash
# Ubuntu/Debian
sudo ufw status

# CentOS/RHEL
sudo firewall-cmd --list-all
```

4. 尝试不同的地址：
```
http://127.0.0.1:5000
http://localhost:5000
http://<your-ip>:5000
```

## 🐳 Docker 故障排查

### 问题 1: Docker 找不到

```bash
# 安装 Docker
# Ubuntu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# macOS
brew install --cask docker
```

### 问题 2: Docker Compose 找不到

```bash
# 安装 Docker Compose
sudo apt install docker-compose

# 或使用 pip
pip3 install docker-compose
```

### 问题 3: 权限错误

```bash
# 将用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录
logout
# 然后重新登录
```

## 📝 配置文件

### 应用配置

配置文件位置：`~/.dotfiles/install-config.json`

```json
{
  "version": "1.0",
  "last_install": null,
  "preferences": {
    "shell": "zsh",
    "theme": "dracula",
    "plugins": []
  },
  "components": {
    "dotfiles": true,
    "homebrew": false,
    "zsh": false,
    "tmux": false,
    "vim": false,
    "git": false
  }
}
```

### 环境变量

可选的环境变量配置：

```bash
# .env 文件（计划功能）
FLASK_ENV=development
FLASK_PORT=5000
FLASK_DEBUG=True
```

## 🔄 更新和维护

### 更新依赖

```bash
# 激活虚拟环境
source venv/bin/activate

# 更新所有包
pip install --upgrade -r requirements.txt
```

### 清理虚拟环境

```bash
# 删除虚拟环境
rm -rf venv/

# 重新创建
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 重置配置

```bash
# 备份当前配置
cp ~/.dotfiles/install-config.json ~/.dotfiles/install-config.json.backup

# 删除配置文件（重启时自动重建）
rm ~/.dotfiles/install-config.json
```

## 📚 下一步

安装完成后，请查看：

1. [快速开始指南](QUICKSTART.md) - 5 分钟上手
2. [使用指南](USAGE.md) - 详细功能说明
3. [功能特性](FEATURES.md) - 深入了解功能

## 🆘 获取帮助

如果遇到问题：

1. 查看 [故障排查](#-故障排查) 章节
2. 检查 [主项目文档](../docs/TROUBLESHOOTING.md)
3. 提交 [GitHub Issue](https://github.com/ONGOING-Z/dotfiles/issues)

---

祝你安装顺利！🎉
