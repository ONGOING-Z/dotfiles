# 🖱️ tmux 鼠标操作指南

## 快速使用

配置已启用鼠标支持，重新加载配置：
```bash
# 在 tmux 内执行
tmux source-file ~/.tmux.conf

# 或使用快捷键
Ctrl-a + :source-file ~/.tmux.conf
```

## 🎯 鼠标操作大全

### 基础操作

| 操作 | 功能 |
|------|------|
| **点击窗格** | 切换到该窗格 |
| **点击窗口** | 切换到该窗口（状态栏） |
| **拖动边框** | 调整窗格大小 |
| **滚轮上下** | 滚动内容/进入复制模式 |

### 文本选择和复制

| 操作 | 功能 | 说明 |
|------|------|------|
| **拖动选择** | 选择文本并复制 | 松开鼠标自动复制到剪贴板 |
| **双击** | 选择单词 | 快速选择当前单词 |
| **三击** | 选择整行 | 快速选择当前行 |
| **右键** | 粘贴 | 粘贴剪贴板内容 |
| **中键** | 粘贴 | Linux 系统粘贴 |

### 特殊技巧

| 操作 | 功能 | 使用场景 |
|------|------|----------|
| **Shift + 拖动** | 终端原生选择 | 绕过 tmux，使用终端自己的选择 |
| **Shift + 右键** | 终端菜单 | 显示终端的右键菜单 |
| **Option/Alt + 点击** | 矩形选择 | 某些终端支持 |

## 🔧 常见问题解决

### 1. 鼠标选择后无法复制到系统剪贴板

**macOS:**
```bash
# 确保安装了 reattach-to-user-namespace
brew install reattach-to-user-namespace
```

**Linux:**
```bash
# 安装 xclip 或 xsel
sudo apt-get install xclip
# 或
sudo apt-get install xsel
```

### 2. 想要临时禁用鼠标模式

```bash
# 在 tmux 中执行
:set -g mouse off  # 禁用
:set -g mouse on   # 启用

# 或绑定快捷键切换（添加到 tmux.conf）
bind m set -g mouse on \; display 'Mouse: ON'
bind M set -g mouse off \; display 'Mouse: OFF'
```

### 3. SSH 远程使用时鼠标不工作

确保：
1. 本地终端支持鼠标事件
2. SSH 没有禁用 X11 转发
3. 使用支持鼠标的终端（如 iTerm2, Terminal.app, gnome-terminal）

### 4. 需要选择多行文本

1. **方法一**：直接拖动选择（tmux 会自动滚动）
2. **方法二**：进入复制模式
   ```
   Ctrl-a + [     # 进入复制模式
   使用鼠标选择
   回车或 y       # 复制并退出
   ```
3. **方法三**：Shift + 拖动（使用终端选择）

## 📝 自定义配置

### 添加鼠标模式切换快捷键

在 `~/.tmux.conf` 中添加：
```bash
# 切换鼠标模式
bind-key m \
  set-option -g mouse on \;\
  display-message 'Mouse: ON'

bind-key M \
  set-option -g mouse off \;\
  display-message 'Mouse: OFF'
```

### 自定义复制行为

```bash
# 选择后留在复制模式（不自动退出）
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe

# 使用系统特定的复制命令
# Windows WSL
if-shell "grep -q Microsoft /proc/version" \
  "bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'clip.exe'"
```

## 🚀 推荐工作流

1. **快速复制粘贴**
   - 鼠标拖动选择文本（自动复制）
   - 右键粘贴

2. **精确选择**
   - 双击选择单词
   - 三击选择整行
   - Shift + 拖动进行跨窗格选择

3. **窗格管理**
   - 点击切换窗格
   - 拖动边框调整大小
   - 滚轮浏览历史

## 💡 专业提示

1. **混合使用键盘和鼠标**：鼠标用于快速导航和选择，键盘用于精确操作

2. **复制模式快捷键**：
   - `v` 开始选择
   - `V` 行选择
   - `Ctrl-v` 矩形选择
   - `y` 复制
   - `q` 退出

3. **保持灵活**：记住 Shift 键可以绕过 tmux 鼠标模式

## 🔗 相关资源

- [tmux 官方文档](https://github.com/tmux/tmux/wiki)
- [tmux-yank 插件](https://github.com/tmux-plugins/tmux-yank)（增强复制功能）
- [tmux-better-mouse-mode](https://github.com/NHDaly/tmux-better-mouse-mode)（更好的鼠标支持）