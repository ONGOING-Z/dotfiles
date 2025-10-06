# Dotfiles Web UI - 配置管理可视化界面

一个现代化的 Web 界面，用于管理和可视化 Dotfiles 配置。

## ✨ 功能特性

### 🎯 核心功能

- **📊 仪表盘** - 配置统计、系统概览、健康检查
- **⚙️ 配置管理** - 图形化配置编辑、组件开关控制
- **🔗 依赖关系可视化** - 交互式依赖关系图（类似 Heimdall）
- **📁 文件浏览** - 浏览所有配置文件、实时搜索
- **👁️ 实时预览** - 在线编辑和预览配置文件
- **💾 快照管理** - 创建和管理配置快照
- **📜 操作历史** - 查看所有配置变更历史

### 🎨 界面特性

- 现代化暗色主题设计
- 响应式布局，支持移动端
- 实时数据更新
- 交互式图表和可视化
- 直观的用户体验

## 🚀 快速开始

### 安装依赖

```bash
cd webui
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 启动服务器

使用启动脚本（推荐）：

```bash
./start.sh
```

或手动启动：

```bash
source venv/bin/activate
python3 app.py
```

### 访问界面

打开浏览器访问：[http://localhost:5000](http://localhost:5000)

## 📖 使用指南

### 仪表盘

仪表盘提供系统概览：

- **统计卡片**：显示配置文件数量、总大小、最后修改时间等
- **组件统计**：各个组件的文件数量和大小
- **健康检查**：一键运行系统健康检查

### 配置管理

在配置管理页面，你可以：

1. 选择默认 Shell（Zsh/Bash）
2. 切换主题
3. 启用/禁用各个组件（Homebrew、Tmux、Vim 等）
4. 保存配置到 `~/.dotfiles/install-config.json`

### 依赖关系可视化

依赖关系页面展示配置文件之间的链接关系：

- **蓝色节点**：源文件（仓库中的文件）
- **绿色节点**：目标文件（家目录中的符号链接）
- **箭头**：表示链接方向

你可以：
- 拖拽节点调整布局
- 悬停查看完整路径
- 点击节点查看详情

### 文件浏览与预览

1. 在文件浏览页面搜索和选择文件
2. 点击文件进入实时预览
3. 在预览页面可以：
   - 查看文件内容
   - 切换到编辑模式
   - 保存修改（自动创建备份）

### 快照管理

快照功能允许你：

1. 创建配置快照（包含所有重要配置文件）
2. 查看所有历史快照
3. 快照自动压缩存储在 `~/.dotfiles/backups/`

### 操作历史

查看所有配置变更的时间线，包括：
- 配置保存
- 快照创建
- 文件修改

## 🛠️ API 接口

Web UI 提供完整的 RESTful API：

### 配置相关

- `GET /api/config` - 获取当前配置
- `POST /api/config` - 保存配置

### 文件相关

- `GET /api/files` - 列出所有配置文件
- `GET /api/files/<path>` - 获取文件内容
- `PUT /api/files/<path>` - 保存文件内容

### 依赖关系

- `GET /api/dependencies` - 获取依赖关系图数据

### 快照相关

- `GET /api/snapshots` - 列出所有快照
- `POST /api/snapshots` - 创建新快照

### 其他

- `GET /api/stats` - 获取统计信息
- `GET /api/history` - 获取操作历史
- `GET /api/themes` - 列出可用主题
- `GET /api/health` - 运行健康检查

## 🎨 技术栈

### 后端

- **Flask** - Python Web 框架
- **Flask-CORS** - 跨域支持
- **PyYAML** - YAML 配置解析
- **Watchdog** - 文件监控

### 前端

- **Vue 3** - 渐进式 JavaScript 框架
- **Vis.js** - 网络图可视化库
- **Axios** - HTTP 客户端
- **Font Awesome** - 图标库

## 🔧 配置

### 环境变量

可以通过环境变量自定义配置：

```bash
export FLASK_ENV=development  # 开发模式
export FLASK_PORT=5000        # 端口号
```

### 配置文件位置

- 用户配置：`~/.dotfiles/install-config.json`
- 操作历史：`~/.dotfiles/install-history.log`
- 快照目录：`~/.dotfiles/backups/`

## 🔐 安全性

- Web UI 仅监听本地地址（127.0.0.1）
- 文件编辑前自动创建备份
- 限制文件大小（1MB）防止内存溢出
- 路径验证防止目录遍历攻击

## 📝 开发

### 开发模式

```bash
export FLASK_ENV=development
python3 app.py
```

### 修改前端代码

前端代码位于 `static/` 目录：

- `index.html` - 主页面结构
- `style.css` - 样式文件
- `app.js` - Vue.js 应用逻辑

修改后刷新浏览器即可看到变化。

### 添加新功能

1. 在 `app.py` 中添加新的 API 端点
2. 在 `app.js` 中添加对应的方法
3. 在 `index.html` 中添加 UI 元素
4. 在 `style.css` 中添加样式

## 🐛 故障排查

### 端口被占用

```bash
# 查找占用端口的进程
lsof -i :5000

# 或使用其他端口
python3 app.py --port 8080
```

### 依赖安装失败

```bash
# 升级 pip
pip install --upgrade pip

# 使用国内镜像
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 无法访问界面

1. 检查防火墙设置
2. 确认服务器正在运行
3. 尝试访问 `http://127.0.0.1:5000`

## 📄 许可证

与主项目保持一致

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📚 相关文档

- [主项目 README](../README.md)
- [安装指南](../INSTALL_GUIDE.md)
- [故障排查](../docs/TROUBLESHOOTING.md)
