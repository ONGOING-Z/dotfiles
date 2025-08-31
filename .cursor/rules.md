# 仓库规范（Cursor Rules）

本文件用于在 Cursor 中固化协作规范与自动化约定，保证一致性与可维护性。

## 分支与 PR

- 分支命名：`<类型>-<简述>-<YYYY-MM-DD>`（日期为上海时区）
  - 类型：`feat`/`fix`/`docs`/`ci`/`chore`
  - 例：`feat-brew-install-improvement-2025-08-30`
- PR 标题：`<类型中文>: <简述> - <YYYY-MM-DD>`，例如：`功能: brew 安装优化 - 2025-08-30`
  - 工作流已自动按分支生成并在推送时更新；日期采用 Asia/Shanghai。
- PR 描述：需包含中文“变更要点”简述；工作流会自动追加最近提交摘要，可在页面按需补充。
- 不直接向默认分支推送工作流文件；以分支+PR 合并。

## 提交与检查

- 提交信息遵循 Conventional Commits（`feat: ...`、`fix: ...` 等），可使用中文描述。
- 提交信息不得包含显式的转义换行符（例如 `\n`）；多行正文请使用真实的换行分隔（标题行保持单行，正文空一行后展开）。
- 在提交前运行 `pre-commit run --all-files`，确保通过以下检查：
  - 基础 hooks（trailing-whitespace、end-of-file-fixer 等）
  - yamllint（行宽 140，文档头可选）
  - shellcheck（例如避免未加引号的变量分词/通配）
  - black（Python）、mdformat（Markdown）、codespell（拼写）

## 安装脚本（install）

- 默认仅建立链接；可通过参数/环境变量控制 Homebrew 行为：
  - `--brew`、`--brew-upgrade`、`--brew-cleanup`
  - `INSTALL_WITH_BREW`、`INSTALL_BREW_UPGRADE`、`INSTALL_BREW_CLEANUP`
- 网络可选：
  - 镜像：`BREW_MIRROR=ustc|tsinghua`
  - 代理：`BREW_PROXY=http://127.0.0.1:7890`
- CI 中不强制执行 brew；必要时以 `--only-links` 运行。

## Zsh

- 仅选择一个插件管理器：`ZSH_MANAGER=ohmyzsh|zplug|auto`（默认 auto）。
- 非交互 shell 跳过重型初始化（`case $- in *i*) ... esac`）。
- macOS 使用 Homebrew zsh 时，需在 `/etc/shells` 中登记并 `chsh -s`。

## Tmux

- 颜色：`default-terminal tmux-256color` 与 `terminal-overrides ',xterm-256color:RGB'`。
- Shell：`default-shell` 指向 zsh；`default-command` 使用 `zsh -l` 确保 login shell。
- 剪贴板：macOS 使用 `pbcopy`，Linux 优先 `xclip`，否则 `xsel`。
- 修改配置后需要 `tmux kill-server` 或重启会话生效。

## Dotbot 链接

- 不创建实际文件，仅建立符号链接；需要的目录通过 `create` 创建。
- 特权路径（如 `/usr/local/...`）需具备权限；`arthas.properties` 采用条件链接（目录存在时才链接）。

## YAML 与编辑器

- YAML：行宽 140、2 空格缩进、禁止使用文档头 `---`，键名如 `on` 需加引号（已在 `.yamllint.yaml` 配置）。
- 编辑器：遵循 `.editorconfig`（LF、UTF-8、2 空格缩进；Makefile 使用 tab）。

## Makefile（约定）

- `make install`：运行安装脚本（默认启用 brew）。
- `make lint` / `make fmt`：使用 pre-commit 全量检查与格式化。
- `make pre-commit`：安装并启用 pre-commit。

## 测试

- `std_my_dir` 提供 pytest 用例，CI 自动运行；新增脚本建议附带最小测试用例。

## 安全与权限

- 避免在默认分支直接改动工作流；通过 PR 合并。
- 涉及系统路径/特权操作需有条件检查与明确提示。
