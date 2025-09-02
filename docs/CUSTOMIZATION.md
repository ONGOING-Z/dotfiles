# 🎨 自定义指南

本指南帮助您根据个人需求定制 Dotfiles 配置。

## 📋 目录

- [基础自定义](#基础自定义)
- [Shell 配置](#shell-配置)
- [编辑器配置](#编辑器配置)
- [主题定制](#主题定制)
- [添加新工具](#添加新工具)
- [创建本地覆盖](#创建本地覆盖)
- [高级定制](#高级定制)

## 基础自定义

### 修改默认设置

1. **修改安装配置**

编辑 `install.conf.yaml` 来控制哪些配置文件被链接：

```yaml
- link:
    ~/.custom-config: config/custom-config  # 添加新配置
    # ~/.unwanted-config: null             # 注释掉不需要的配置
```

2. **选择性安装**

使用自定义安装模式只安装需要的组件：

```bash
./install
# 选择 "自定义安装"
# 勾选需要的组件
```

## Shell 配置

### 自定义别名

创建 `~/.aliases.local` 文件：

```bash
# 我的自定义别名
alias myproject='cd ~/projects/myproject'
alias deploy='./scripts/deploy.sh'
alias vpn='sudo openconnect vpn.company.com'
```

### 自定义函数

创建 `~/.functions.local` 文件：

```bash
# 快速创建并进入项目
mkproject() {
    mkdir -p ~/projects/"$1"
    cd ~/projects/"$1"
    git init
    echo "# $1" > README.md
}

# 个人备份函数
backup_work() {
    rsync -av ~/work/ /backup/work/
}
```

### 自定义提示符

#### Bash 提示符

在 `~/.bashrc.local` 中：

```bash
# 自定义 PS1
export PS1='\[\e[36m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\]:\[\e[33m\]\w\[\e[m\]\$ '
```

#### Zsh 主题

在 `~/.zshrc.local` 中：

```bash
# 使用不同的主题
ZSH_THEME="agnoster"

# 或自定义提示符
PROMPT='%F{cyan}%n%f@%F{green}%m%f:%F{yellow}%~%f$ '
```

## 编辑器配置

### Vim 自定义

创建 `~/.vimrc.local`：

```vim
" 我的 Vim 设置
set relativenumber  " 相对行号
set cursorline      " 高亮当前行

" 自定义键映射
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" 自定义插件
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
```

### Neovim 配置

创建 `~/.config/nvim/init.local.vim`：

```vim
" Neovim 特定设置
set inccommand=split  " 实时预览替换

" LSP 配置
lua << EOF
require'lspconfig'.pyright.setup{}
require'lspconfig'.tsserver.setup{}
EOF
```

## 主题定制

### 创建自定义主题

1. **复制现有主题作为基础**：

```bash
cp -r themes/dracula themes/custom/my-theme
```

2. **编辑颜色定义**：

编辑 `themes/custom/my-theme/colors.sh`：

```bash
# 我的自定义颜色
export MY_BACKGROUND="#1a1a1a"
export MY_FOREGROUND="#e0e0e0"
export MY_ACCENT="#00ff88"
# ... 更多颜色
```

3. **应用主题**：

```bash
./scripts/theme-switcher.sh set my-theme
```

### 终端配色

#### iTerm2 (macOS)

1. 导出当前配色：Preferences → Profiles → Colors → Export
2. 编辑 JSON 文件修改颜色
3. 重新导入

#### Terminal.app (macOS)

1. 创建新的配置文件
2. 自定义颜色
3. 导出为 `.terminal` 文件

## 添加新工具

### 1. 添加配置文件

将配置文件放在适当的目录：

```bash
# 例如添加 alacritty 配置
mkdir -p alacritty
cp ~/.config/alacritty/alacritty.yml alacritty/
```

### 2. 更新安装配置

编辑 `install.conf.yaml`：

```yaml
- link:
    ~/.config/alacritty/alacritty.yml: alacritty/alacritty.yml
```

### 3. 添加到安装脚本

如需特殊安装步骤，编辑 `scripts/install-unified.sh` 添加：

```bash
# 安装 Alacritty
if [[ "$DO_ALACRITTY" == "1" ]]; then
    install_alacritty
fi
```

## 创建本地覆盖

### 本地配置文件

Dotfiles 支持以下本地覆盖文件（不会被 Git 跟踪）：

- `~/.zshrc.local` - Zsh 本地配置
- `~/.bashrc.local` - Bash 本地配置
- `~/.vimrc.local` - Vim 本地配置
- `~/.gitconfig.local` - Git 本地配置
- `~/.aliases.local` - 本地别名
- `~/.functions.local` - 本地函数

### Git 本地配置

在 `~/.gitconfig.local` 中设置工作相关的 Git 配置：

```ini
[user]
    email = me@company.com  # 工作邮箱
    
[core]
    sshCommand = ssh -i ~/.ssh/work_rsa  # 工作 SSH 密钥
```

## 高级定制

### 条件加载

根据环境加载不同配置：

```bash
# 在 ~/.zshrc.local 中
if [[ "$HOST" == "work-laptop" ]]; then
    source ~/.work-config
elif [[ "$HOST" == "home-pc" ]]; then
    source ~/.home-config
fi
```

### 机器特定配置

创建机器特定的配置目录：

```bash
mkdir -p ~/.config/dotfiles/machines/$(hostname)
```

然后在配置中加载：

```bash
MACHINE_CONFIG="$HOME/.config/dotfiles/machines/$(hostname)/config.sh"
[ -f "$MACHINE_CONFIG" ] && source "$MACHINE_CONFIG"
```

### 私密配置管理

对于敏感信息：

1. **使用环境变量**：

```bash
# ~/.secrets (不要提交到 Git)
export API_KEY="secret-key"
export DB_PASSWORD="secret-password"
```

2. **在 shell 配置中加载**：

```bash
# ~/.zshrc.local
[ -f ~/.secrets ] && source ~/.secrets
```

3. **使用加密工具**：

```bash
# 使用 gpg 加密
gpg -c ~/.secrets
# 解密时
gpg -d ~/.secrets.gpg > ~/.secrets
```

### 插件系统

创建自定义插件：

1. **创建插件目录**：

```bash
mkdir -p ~/.config/dotfiles/plugins/my-plugin
```

2. **创建插件脚本**：

```bash
# ~/.config/dotfiles/plugins/my-plugin/init.sh
echo "Loading my-plugin..."

# 插件功能
my_plugin_function() {
    echo "This is my plugin!"
}
```

3. **自动加载插件**：

```bash
# 在 ~/.zshrc.local 中
for plugin in ~/.config/dotfiles/plugins/*/init.sh; do
    [ -f "$plugin" ] && source "$plugin"
done
```

## 最佳实践

1. **保持模块化**：将配置分成小的、可管理的部分
2. **使用版本控制**：为自定义配置创建单独的 Git 仓库
3. **文档化**：记录您的自定义设置
4. **测试变更**：在应用到主系统前先测试
5. **定期备份**：使用配置管理器创建快照

```bash
./scripts/config-manager.sh snapshot before-customization
```

## 分享您的定制

如果您创建了有用的定制，考虑：

1. 提交 Pull Request
2. 在 Discussions 分享
3. 创建主题或插件供他人使用

---

💡 **提示**：始终在 `.local` 文件中进行个人定制，这样可以轻松更新主配置而不丢失您的更改。