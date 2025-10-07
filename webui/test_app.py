#!/usr/bin/env python3
"""
Web UI 基础测试
"""

import pytest
import json
import tempfile
import os
from pathlib import Path
import sys

# 添加父目录到路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, init_config_dir


@pytest.fixture
def client():
    """创建测试客户端"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


@pytest.fixture
def temp_config_dir(monkeypatch, tmp_path):
    """创建临时配置目录"""
    config_dir = tmp_path / ".dotfiles"
    config_dir.mkdir()
    
    # 修改配置路径
    import app as app_module
    monkeypatch.setattr(app_module, 'CONFIG_DIR', config_dir)
    monkeypatch.setattr(app_module, 'CONFIG_FILE', config_dir / 'install-config.json')
    monkeypatch.setattr(app_module, 'HISTORY_FILE', config_dir / 'install-history.log')
    
    return config_dir


def test_index(client):
    """测试首页"""
    response = client.get('/')
    assert response.status_code == 200


def test_get_config(client, temp_config_dir):
    """测试获取配置"""
    init_config_dir()
    response = client.get('/api/config')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'version' in data
    assert 'preferences' in data
    assert 'components' in data


def test_save_config(client, temp_config_dir):
    """测试保存配置"""
    init_config_dir()
    
    new_config = {
        'version': '1.0',
        'preferences': {
            'shell': 'bash',
            'theme': 'nord'
        },
        'components': {
            'zsh': True,
            'vim': False
        }
    }
    
    response = client.post('/api/config', 
                          data=json.dumps(new_config),
                          content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'success'
    assert data['config']['preferences']['shell'] == 'bash'


def test_get_dependencies(client):
    """测试获取依赖关系"""
    response = client.get('/api/dependencies')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'nodes' in data
    assert 'edges' in data


def test_list_files(client):
    """测试列出文件"""
    response = client.get('/api/files')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert isinstance(data, list)


def test_list_themes(client):
    """测试列出主题"""
    response = client.get('/api/themes')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert isinstance(data, list)


def test_get_stats(client):
    """测试获取统计信息"""
    response = client.get('/api/stats')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'total_files' in data
    assert 'total_size' in data


def test_list_snapshots(client, temp_config_dir):
    """测试列出快照"""
    # 创建备份目录
    (temp_config_dir / 'backups').mkdir()
    
    response = client.get('/api/snapshots')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert isinstance(data, list)


def test_get_history(client, temp_config_dir):
    """测试获取历史"""
    init_config_dir()
    
    response = client.get('/api/history')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert isinstance(data, list)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
