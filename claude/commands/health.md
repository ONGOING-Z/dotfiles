请运行健康检查：

1. 定位 dotfiles 根（从 `readlink ~/.claude/CLAUDE.md` 反推），运行：
   `DOTFILES="$(cd "$(dirname "$(readlink ~/.claude/CLAUDE.md)")/.." && pwd)" && bash "$DOTFILES/scripts/health-check.sh"`
2. 脚本已覆盖：symlink 完整性、必要工具、git submodule、SSH 权限、Claude 配置（rules/ 链接、settings 治理状态）
3. 如检出问题，给出修复建议并询问是否修复

$ARGUMENTS
