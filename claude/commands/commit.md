请帮我执行提交流程：

1. 运行 `git status` 和 `git diff` 查看当前变更
2. 分析变更内容，生成符合 [Conventional Commits](https://www.conventionalcommits.org/) 规范的 commit message（type 如 feat/fix/chore/docs/refactor/ci/test）
3. 确认后执行 `git add <具体文件>` 和 `git commit`

注意：
- 不要用 `git add -A`，指定具体文件
- commit message 用英文，简洁有力
- 如果 pre-commit hook 失败，修复问题后重新提交

$ARGUMENTS
