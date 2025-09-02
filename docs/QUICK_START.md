# 🚀 快速开始

## 一键安装

### 使用 curl（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/ONGOING-Z/dotfiles/macos/scripts/quick-setup.sh | bash
```

### 使用 wget

```bash
wget -qO- https://raw.githubusercontent.com/ONGOING-Z/dotfiles/macos/scripts/quick-setup.sh | bash
```

### 自定义安装

如果您想要更多控制，可以设置环境变量：

```bash
# 自定义安装目录
export DOTFILES_DIR="$HOME/.dotfiles"

# 使用不同的分支
export DOTFILES_BRANCH="develop"

# 运行安装
curl -fsSL https://raw.githubusercontent.com/ONGOING-Z/dotfiles/macos/scripts/quick-setup.sh | bash
```

## 手动安装

如果您更喜欢手动控制每一步：

### 1. 克隆仓库

```bash
git clone --recursive https://github.com/ONGOING-Z/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. 运行安装向导

```bash
./install
```

### 3. 选择安装模式

安装向导会引导您选择：
- 🚀 **快速安装** - 推荐配置，适合大多数用户
- 🎯 **最小安装** - 仅核心配置
- 🎨 **自定义安装** - 选择组件
- 💻 **开发者模式** - 完整开发环境

## 安装后

### 1. 重启 Shell

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc
```

### 2. 验证安装

```bash
# 运行健康检查
~/dotfiles/install --health-check

# 查看已安装的功能
~/dotfiles/scripts/env-detector.sh
```

### 3. 个性化设置

```bash
# 切换主题
~/dotfiles/scripts/theme-switcher.sh

# 查看自定义指南
cat ~/dotfiles/docs/CUSTOMIZATION.md
```

## 常见问题

### 权限错误

如果遇到权限错误：

```bash
cd ~/dotfiles
chmod +x install
chmod +x scripts/*.sh
```

### 私有子模块

如果您 fork 了这个仓库并有私有子模块，请参考：
[私有子模块设置指南](PRIVATE_SUBMODULES_SETUP.md)

### 更多帮助

- 查看 [故障排除指南](TROUBLESHOOTING.md)
- 提交 [Issue](https://github.com/ONGOING-Z/dotfiles/issues)
- 加入 [Discussions](https://github.com/ONGOING-Z/dotfiles/discussions)

## 卸载

如需完全卸载：

```bash
~/dotfiles/scripts/uninstall.sh
```

这会：
- 移除所有符号链接
- 恢复备份的配置
- 保留 dotfiles 目录（需手动删除）

---

💡 **提示**: 安装前会自动备份您的现有配置，可以随时恢复。