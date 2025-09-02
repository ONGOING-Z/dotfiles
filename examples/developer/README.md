# 开发者配置示例

为软件开发者优化的配置，包含常用开发工具和效率插件。

## 特点

- ✅ Zsh + Oh-My-Zsh
- ✅ 丰富的 Git 集成
- ✅ 强大的 Vim 配置
- ✅ Tmux 多窗口管理
- ✅ 开发语言支持
- ✅ 代码补全和语法高亮

## 包含内容

```
.zshrc         # Zsh 配置 + 插件
.vimrc         # Vim 配置 + 插件
.tmux.conf     # Tmux 配置
.gitconfig     # 高级 Git 配置
```

## 推荐工具

- **Shell**: Zsh + Oh-My-Zsh
- **编辑器**: Vim/Neovim + vim-plug
- **终端复用**: Tmux + TPM
- **版本控制**: Git + tig
- **模糊搜索**: fzf + ripgrep
- **目录跳转**: zoxide

## 安装

```bash
cd ~/dotfiles
./install
# 选择 "自定义安装"
# 选择开发相关组件
```

## 主要插件

### Zsh 插件
- git
- docker
- kubectl
- npm
- python
- zsh-autosuggestions
- zsh-syntax-highlighting

### Vim 插件
- NERDTree - 文件浏览
- vim-airline - 状态栏
- vim-fugitive - Git 集成
- coc.nvim - 代码补全
- vim-polyglot - 语法高亮

### Tmux 插件
- tmux-resurrect - 会话保存
- tmux-continuum - 自动保存
- tmux-prefix-highlight - 前缀提示