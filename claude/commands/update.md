请帮我更新 dotfiles：

1. 定位 dotfiles 根并拉取（不硬编码路径，从 symlink 反推）：
   `DOTFILES="$(cd "$(dirname "$(readlink ~/.claude/CLAUDE.md)")/.." && pwd)" && cd "$DOTFILES" && git pull --ff-only`
2. 如果 pull 失败（有本地未推送的 commit），提示用户先处理
3. `./install` 运行安装脚本
4. 如果安装过程中有问题，报告具体错误

$ARGUMENTS
