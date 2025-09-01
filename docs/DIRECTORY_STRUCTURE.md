# 📁 目录结构说明

## 目录组织

```
dotfiles/
├── 📂 config/          # 配置文件
│   ├── bashrc          # Bash 配置
│   ├── bash_aliases    # Bash 别名
│   ├── zshrc           # Zsh 配置
│   ├── fzf             # FZF 配置
│   ├── gdbinit         # GDB 配置
│   └── ripgreprc       # Ripgrep 配置
│
├── 📂 scripts/         # 安装和工具脚本
│   ├── install-new.sh              # 智能安装向导
│   ├── install-unified.sh          # 统一安装脚本
│   ├── install-interactive.sh      # 交互式安装
│   ├── install-interactive-enhanced.sh # 增强版交互式安装
│   ├── install.original.sh         # 原始安装脚本
│   ├── uninstall.sh                # 卸载脚本
│   └── demo_comparison.sh          # 演示对比脚本
│
├── 📂 shell/           # Shell 相关配置
│   └── ...
│
├── 📂 vim/             # Vim 配置
│   ├── vimrc
│   └── ...
│
├── 📂 nvim/            # Neovim 配置
│   └── init.vim
│
├── 📂 tmux/            # Tmux 配置
│   ├── tmux.conf
│   └── ...
│
├── 📂 git/             # Git 配置
│   └── gitconfig
│
├── 📂 zsh/             # Zsh 插件和主题
│   └── ...
│
├── 📂 brew/            # Homebrew 配置
│   ├── Brewfile.common
│   ├── Brewfile.macos
│   └── Brewfile.linux
│
├── 📂 ssh/             # SSH 配置模板
│   └── ...
│
├── 📂 vscode/          # VS Code 配置
│   └── ...
│
├── 📂 docs/            # 文档
│   ├── DIRECTORY_STRUCTURE.md
│   ├── GUM_VS_BASH_COMPARISON.md
│   └── ...
│
├── 📂 tests/           # 测试文件
│   └── ...
│
├── 📂 std_my_dir/      # 标准化目录工具
│   └── ...
│
├── 📂 examples/        # 示例配置
│   └── ...
│
├── 📂 .github/         # GitHub Actions 配置
│   └── workflows/
│
├── 📂 dotbot/          # Dotbot 子模块
│   └── ...
│
├── 📄 install          # 主入口脚本
├── 📄 install.conf.yaml # Dotbot 配置
├── 📄 README.md        # 项目说明
├── 📄 INSTALL_GUIDE.md # 安装指南
├── 📄 CHANGELOG.md     # 更新日志
├── 📄 Makefile         # Make 命令
│
├── 📄 .gitignore       # Git 忽略文件
├── 📄 .gitmodules      # Git 子模块
├── 📄 .editorconfig    # 编辑器配置
├── 📄 .pre-commit-config.yaml # Pre-commit 配置
├── 📄 .yamllint.yaml   # YAML 检查配置
├── 📄 .coveragerc      # 测试覆盖率配置
├── 📄 pytest.ini       # Pytest 配置
├── 📄 requirements-dev.txt # Python 开发依赖
├── 📄 cliff.toml       # Git Cliff 配置
└── 📄 codecov.yml      # Codecov 配置
```

## 主要目录说明

### 🔧 config/

存放所有的配置文件，这些文件会被链接到用户的 home 目录。

### 📜 scripts/

包含所有的安装、卸载和工具脚本。用户不需要直接访问这个目录，通过根目录的 `install` 入口即可。

### 📚 docs/

项目文档和指南。

### 🧪 tests/

测试文件和测试脚本。

### 🔌 应用配置目录

- `vim/` - Vim 编辑器配置
- `nvim/` - Neovim 编辑器配置
- `tmux/` - 终端复用器配置
- `git/` - Git 版本控制配置
- `zsh/` - Zsh Shell 配置
- `brew/` - Homebrew 包管理器配置
- `ssh/` - SSH 客户端配置
- `vscode/` - Visual Studio Code 配置

## 使用方式

### 安装

```bash
./install  # 启动交互式安装向导
```

### 卸载

```bash
./scripts/uninstall.sh
```

### 查看帮助

```bash
./install --help
```

## 文件命名规范

- 配置文件：去掉前导点号（如 `.zshrc` → `zshrc`）
- 脚本文件：使用连字符分隔（如 `install-new.sh`）
- 文档文件：使用大写字母和下划线（如 `INSTALL_GUIDE.md`）

## 维护建议

1. 新的配置文件应该放在 `config/` 或对应的应用目录
1. 新的脚本应该放在 `scripts/`
1. 文档应该放在 `docs/`
1. 保持根目录简洁，只放置入口文件和必要的配置文件
