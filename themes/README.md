# 🎨 Dotfiles 主题系统

本目录包含各种终端和编辑器的配色主题。

## 📂 目录结构

```
themes/
├── dracula/      # Dracula 主题
├── nord/         # Nord 主题
├── gruvbox/      # Gruvbox 主题
├── solarized/    # Solarized 主题
└── custom/       # 自定义主题
```

## 🎯 支持的应用

每个主题目录包含以下应用的配色文件：

- **终端** - Terminal/iTerm2/Alacritty 配色
- **Vim/Neovim** - 编辑器配色方案
- **Tmux** - 状态栏主题
- **Zsh** - Oh-My-Zsh/Powerlevel10k 主题
- **Git** - diff 和 log 配色

## 🚀 使用方法

### 自动安装（推荐）

运行安装脚本时选择主题：

```bash
./install
# 选择 "自定义安装" -> "主题和外观"
```

### 手动安装

1. **终端主题**
   ```bash
   # iTerm2 (macOS)
   # 打开 iTerm2 -> Preferences -> Profiles -> Colors -> Import
   # 选择 themes/<主题名>/iterm2.itermcolors

   # Terminal.app (macOS)
   # 双击 themes/<主题名>/terminal.terminal

   # Alacritty
   cp themes/<主题名>/alacritty.yml ~/.config/alacritty/theme.yml
   ```

2. **Vim 主题**
   ```vim
   " 在 ~/.vimrc 中添加
   colorscheme <主题名>
   ```

3. **Tmux 主题**
   ```bash
   # 在 ~/.tmux.conf 中添加
   source-file ~/dotfiles/themes/<主题名>/tmux.conf
   ```

## 🎨 主题预览

### Dracula
深色主题，紫色调为主，对比度高，适合长时间编码。

### Nord
极地风格的冷色调主题，蓝灰色为主，护眼舒适。

### Gruvbox
复古风格主题，暖色调，有深色和浅色两种模式。

### Solarized
精心设计的配色方案，有深色和浅色模式，科学护眼。

## 🛠️ 创建自定义主题

1. 复制现有主题作为模板：
   ```bash
   cp -r themes/dracula themes/custom/my-theme
   ```

2. 修改配色值

3. 测试主题

4. 分享你的主题！

## 📝 主题文件说明

每个主题目录包含：

- `colors.sh` - 终端颜色定义
- `vim.vim` - Vim 配色文件
- `tmux.conf` - Tmux 主题配置
- `iterm2.itermcolors` - iTerm2 配色（macOS）
- `terminal.terminal` - Terminal.app 配色（macOS）
- `alacritty.yml` - Alacritty 配色
- `README.md` - 主题说明和预览
