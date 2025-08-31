# dotfiles

> 规范速览（详细见 `.cursor/rules.md`）

- 分支命名：`<类型>-<简述>-<YYYY-MM-DD>`（上海时区），如 `feat-brew-install-2025-08-30`
- PR 标题：`<类型中文>: <简述> - <YYYY-MM-DD>`，自动生成并随推送更新
- 提交规范：Conventional Commits（可中文），提交前跑 `pre-commit run --all-files`
- 安装脚本：默认仅建链接；可用 `--brew/--brew-upgrade/--brew-cleanup` 与 `BREW_MIRROR/ BREW_PROXY`
- Zsh：仅选一个管理器（oh-my-zsh 或 zplug），非交互 shell 跳过重型初始化
- Tmux：`tmux-256color` + `RGB`，`default-command` 使用 `zsh -l`
- Dotbot：特权路径链接有条件执行（如 `arthas.properties`）
- CI/PR：自动 PR（中文标题+摘要）、pre-commit、pytest（`std_my_dir`）

### 可选增强

- 一键安装 tmux 插件（TPM）：

```bash
./install --tpm   # 或环境变量：INSTALL_WITH_TPM=1 ./install
```

- Makefile 常用命令：

```bash
make install     # 安装（默认启用 brew）
make lint        # 运行 pre-commit 检查
make fmt         # 运行 pre-commit 全量格式化
make pre-commit  # 安装并启用 pre-commit
make test        # 运行 pytest
```

最好在家目录下建立的配置文件都是link类型的，放引用在家目录下，让引用指向你dotfiles文件夹下真正的配置文件。

存放文本三巨头[zsh][1]、[vim][2]、[tmux][3]的设置文件.

[Shell生产力环境恢复][4]

## 主要配置一览

下表展示本仓库维护的常用工具配置（路径为仓库内相对路径）：

| 工具        | 配置路径                                  | 项目链接                                                     |
| ----------- | ----------------------------------------- | ------------------------------------------------------------ |
| Zsh         | `zshrc`                                   | [oh-my-zsh](https://ohmyz.sh)                                |
| Tmux        | `tmux/tmux.conf`                          | [tmux](https://github.com/tmux/tmux)                         |
| Vim         | `vim/vimrc`                               | [Vim](https://www.vim.org/)                                  |
| Neovim      | `nvim/init.vim`                           | [Neovim](https://neovim.io)                                  |
| Git         | `git/gitconfig`                           | [Git](https://git-scm.com)                                   |
| Homebrew    | `brew/`                                   | [Homebrew](https://brew.sh)                                  |
| fzf         | `.fzf`                                    | [fzf](https://github.com/junegunn/fzf)                       |
| GDB         | `.gdbinit`, `.gdb/`                       | [GDB](https://www.gnu.org/software/gdb/)                     |
| Pip         | `.pip/pip.conf`                           | [pip](https://pip.pypa.io/)                                  |
| Rime 输入法 | `rime-config`                             | [Rime](https://rime.im/) <!-- codespell:ignore Rime rime --> |
| Dotbot      | `install`, `install.conf.yaml`, `dotbot/` | [Dotbot](https://github.com/anishathalye/dotbot)             |

## 快速开始（推荐）

```bash
# 克隆
git clone --recursive https://github.com/ONGOING-Z/dotfiles ~/dotfiles
cd ~/dotfiles

# 使用 dotbot 建立符号链接
./install

# 重新加载 tmux/zsh（可选）
tmux source ~/.tmux.conf || true
exec $SHELL -l
```

> 注意：`install.conf.yaml` 会在需要时自动创建目录并建立链接；macOS 与 Linux 均可使用。

### 安装器参数

```bash
# 仅建立链接（跳过 Homebrew）
./install --only-links

# 启用 Homebrew 安装；可选升级与清理
INSTALL_WITH_BREW=1 ./install --brew --brew-upgrade --brew-cleanup

# 环境变量开关（与参数等效）
INSTALL_WITH_BREW=0 ./install
INSTALL_BREW_UPGRADE=1 INSTALL_BREW_CLEANUP=1 ./install

# 镜像与代理（可选）
# 镜像：ustc 或 tsinghua
BREW_MIRROR=ustc ./install --brew

# 代理：如 http://127.0.0.1:7890
BREW_PROXY=http://127.0.0.1:7890 ./install --brew
```

## dotfiles管理方法1

1. 新建一个`dotfiles/`文件夹

```bash
$ mkdir dotfiles; cd dotfiles; git init
```

2. 将本机家目录下的需要备份的dotfiles移入上边新建的`dotfiles/`文件夹

```bash
$ cd # 回到家目录
$ mv .vimrc dotfiles/vimrc
$ mv .zshrc dotfiles/zshrc
$ mv .tmux.conf dotfiles/tmux.conf
```

3. 将系统下的dotfile链接到新建dotfiles文件夹里的文件

```bash
$ ln -s dotfiles/vimrc .vimrc
$ ln -s dotfiles/zshrc .zshrc
$ ln -s dotfiles/tmux.conf .tmux.conf
```

4. 换电脑后，需要恢复自己的配置
1. 首先删除原机上的.vimrc/.zshrc...
1. 链接到自己的dotfiles

## dotfiles管理方法2(*推荐*)

使用[dotbot][7]

### 跨平台说明

- tmux
  - 统一启用 256 色与剪贴板支持；macOS 自动使用 `pbcopy`，Linux 优先使用 `xclip`，否则回退 `xsel`。
  - 可以使用前缀 `C-a` + `I` 安装插件（tpm）。
- zsh
  - Homebrew/Java/Maven/Tomcat 路径按操作系统与存在性条件加载；可覆盖 `JAVA_HOME`、`M2_HOME`、`TOMCAT_PATH`。
  - 同时存在 oh-my-zsh 与 zplug，若需提速可改用单一插件管理器。

## Zsh

### 1. 安装

- 查看shell列表

  ```bash
  cat /etc/shells
  ```

- 查看当前shell: `echo $SHELL`

- 安装zsh

  ```bash
  $ sudo apt-get install zsh  # ubuntu installation
  ```

之后使用`chsh -s /bin/zsh`将默认的shell改为zsh

### 2. 安装oh-my-zsh

第一种方法: 通过`curl`

```bash
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

第二种方法: 通过`wget`

```bash
$ sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Tmux

#### 在ubuntu下的安装

```bash
$ sudo apt install tmux
```

#### tmux的升级

当前以`tmux 3.1c`版本为例

1. 首先到[tmux release页面][5]下载自己的版本,这里下载的是[tmux 3.1c][6]
1. 解压这个`.tar.gz`包
1. `cd tmux-3.1c`
1. 运行`./configure`
1. 这时可能会出现`error: libevent not found`的错误,因为这个没有安装
   解决: `sudo apt-get install libevent-dev`
   安装完成后重新执行`./configure`
1. 运行`make`
1. `sudo make install`
1. 重启终端后输入`tmux -V`检查版本是否正确.

更新tmux.conf: `tmux source ~/.tmux.conf`

## Git

#### git diff美化工具[diff-so-fancy][8]

在命令行中对于用户更加友好.

安装: `npm install -g diff-so-fancy`

## Homebrew（可选）

根据平台选择对应的 Brewfile：

```bash
# 公共依赖
brew bundle --file brew/Brewfile.common

# macOS 特定依赖
brew bundle --file brew/Brewfile.macos

# Linux 特定依赖
brew bundle --file brew/Brewfile.linux
```

## 开发与 CI

- 预提交检查：

```bash
pip install pre-commit
pre-commit install

# 本地全量检查
pre-commit run --all-files
```

- CI：push/PR 将自动运行 pre-commit；非默认分支 push 会自动创建 PR（见 `.github/workflows/`）。

## 故障排查（Troubleshooting）

- tmux 进入后不是 zsh
  - 运行 `tmux kill-server` 后重启；检查 `tmux/tmux.conf` 的 `default-shell` 与 `default-command`。
  - macOS 确认 `/opt/homebrew/bin/zsh` 在 `/etc/shells` 中，必要时 `chsh -s /opt/homebrew/bin/zsh`。
- 剪贴板复制无效
  - macOS 需要 `pbcopy`；Linux 安装 `xclip` 或 `xsel`。
- Homebrew 太慢或报错
  - 可使用 `--only-links` 跳过，或启用 `--brew-upgrade/--brew-cleanup` 控制行为。
- 自动 PR 权限问题
  - 使用侧分支 + PR 由网页合并；或给使用的令牌开启 Workflows 权限，或改用 SSH 推送。

## 参考

1. [为初学者准备的 ln 命令教程（5 个示例）](https://linux.cn/article-9501-1.html)
1. [文本三巨头：zsh、tmux 和 vim](https://linux.cn/article-5399-1.html)

[1]: http://www.zsh.org/
[2]: http://www.vim.org/
[3]: https://github.com/tmux/tmux
[4]: https://ongoing-z.github.io/blog/posts/2020/07/recover-the-shell-production-environment.html
[5]: https://github.com/tmux/tmux/releases/
[6]: https://github.com/tmux/tmux/releases/tag/3.1c
[7]: https://github.com/anishathalye/dotbot/
[8]: https://github.com/so-fancy/diff-so-fancy
