请帮我执行发布流程：

1. 定位 dotfiles 根（从 `readlink ~/.claude/CLAUDE.md` 反推）
2. 运行统一发布脚本（自动：前置检查 → 探测仓类型 → CHANGELOG → bump → tag → push）：
   `bash "$DOTFILES/scripts/release.sh" <版本号>`
3. 版本号缺省时脚本用 git-cliff --bumped-version 自动计算；用户指定则直接用
4. 脚本失败（working tree 不干净 / dev 分支 / tag 已存在）时报告原因，不要绕过检查

注意：业务 Worker 部署由 Release PR → CF Builds 负责，发布脚本只负责版本标记与 CHANGELOG；
framework_sdk_worker 与 Java SDK 仓的 tag push 会触发 CI 自动 publish。

$ARGUMENTS
