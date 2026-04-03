# 🏠 Dotfiles - 我的开发环境配置

[![Tests with Coverage](https://github.com/ONGOING-Z/dotfiles/actions/workflows/tests-with-coverage.yml/badge.svg)](https://github.com/ONGOING-Z/dotfiles/actions/workflows/tests-with-coverage.yml)
[![codecov](https://codecov.io/gh/ONGOING-Z/dotfiles/branch/macos/graph/badge.svg)](https://codecov.io/gh/ONGOING-Z/dotfiles)
[![Pre-commit](https://github.com/ONGOING-Z/dotfiles/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/ONGOING-Z/dotfiles/actions/workflows/pre-commit.yml)

> 🎯 一键配置你的开发环境，让每台新电脑都像家一样舒适！

## ✨ 特性

- 🚀 **智能安装向导** - 无需记忆命令，交互式配置
- 🎨 **多种安装模式** - 快速、自定义、专家、最小化
- 📦 **自动化管理** - Homebrew、Zsh、Vim、Tmux 等工具链
- 🔧 **灵活配置** - 支持 macOS 和 Linux
- 📝 **详细日志** - 可选的安装过程记录
- 🏥 **健康检查** - 一键诊断配置问题
- 🔄 **版本控制** - Git 管理，轻松同步更新

## 🚀 快速开始

### 一键安装（推荐）

```bash
git clone https://github.com/ONGOING-Z/dotfiles.git
cd dotfiles
./install
```

就这么简单！安装向导会引导你完成所有配置。

### 高级用法

```bash
# 快速安装（使用推荐配置）
./install --quick

# 最小安装（仅创建符号链接）
./install --minimal

# 健康检查
./install --health-check

# 查看帮助
./install --help
```

## 🎯 安装模式说明

### 🚀 快速安装
适合大多数用户，包含：
- 所有配置文件符号链接
- Homebrew 包管理
- Zsh 和 Oh-My-Zsh
- 常用插件和主题
- Git、Vim、Tmux 配置

### 🎨 自定义安装
根据需求选择组件：
- 可选每个配置模块
- 灵活的插件选择
- 自定义主题方案
- 按需安装工具

### 🔧 专家模式
完全控制安装过程：
- 详细的配置选项
- 自定义安装路径
- 高级功能设置
- 开发工具集成

### 📦 最小安装
仅创建必要的符号链接，适合：
- 已有环境的用户
- 测试配置
- 轻量级部署

## 📁 项目结构

```
dotfiles/
├── 📂 config/          # 配置文件
│   ├── bashrc          # Bash 配置
│   ├── zshrc           # Zsh 配置
│   └── ...
├── 📂 scripts/         # 脚本文件
│   ├── install-*.sh    # 安装脚本
│   └── health-check.sh # 健康检查
├── 📂 vim/             # Vim 配置
├── 📂 tmux/            # Tmux 配置
├── 📂 git/             # Git 配置
└── 📄 install          # 主入口
```

## 🛠️ 包含的工具

### Shell 环境
- **Zsh** - 现代化 Shell
- **Oh-My-Zsh** - Zsh 框架
- **自动补全** - 智能命令建议
- **语法高亮** - 实时语法检查

### 开发工具
- **Vim/Neovim** - 强大的编辑器
- **Tmux** - 终端复用器
- **Git** - 版本控制
- **FZF** - 模糊搜索

### 包管理
- **Homebrew** - macOS/Linux 包管理器
- **自动更新** - 保持工具最新

## 🏥 健康检查

定期运行健康检查，确保配置正常：

```bash
./install --health-check
```

检查项目包括：
- ✅ 文件完整性
- ✅ 符号链接状态
- ✅ 依赖工具版本
- ✅ 权限设置
- ✅ 性能指标

## 📝 自定义配置

### 添加自己的配置

1. 在相应目录添加配置文件
2. 更新 `install.conf.yaml`
3. 运行 `./install` 应用更改

### 本地覆盖

创建本地配置文件（不会被 Git 跟踪）：
- `~/.zshrc.local` - Zsh 本地配置
- `~/.gitconfig.local` - Git 本地配置
- `~/.vimrc.local` - Vim 本地配置

## 🔄 更新

保持配置最新：

```bash
cd ~/dotfiles
git pull
./install
```

## 🐛 故障排除

### 常见问题

**Q: 安装失败怎么办？**
A: 运行 `./install --health-check` 查看问题，或查看日志文件

**Q: 如何卸载？**
A: 运行 `./scripts/uninstall.sh`

**Q: 配置冲突怎么办？**
A: 安装器会自动备份现有配置为 `.backup.时间戳`

### 获取帮助

- 查看 [Wiki](https://github.com/ONGOING-Z/dotfiles/wiki)
- 提交 [Issue](https://github.com/ONGOING-Z/dotfiles/issues)
- 查看 [讨论区](https://github.com/ONGOING-Z/dotfiles/discussions)

## 🤝 贡献

欢迎贡献！请查看 [贡献指南](CONTRIBUTING.md)。

### 开发流程

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

MIT License - 详见 [LICENSE](../LICENSE) 文件

## 🙏 致谢

感谢所有贡献者和以下项目的启发：
- [dotbot](https://github.com/anishathalye/dotbot)
- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- [tmux](https://github.com/tmux/tmux)

---

⭐ 如果这个项目对你有帮助，请给个星标支持一下！
