请帮我创建 Pull Request：

1. 确认当前分支和远程状态 `git branch -vv`、`git status`
2. 查看相对于 base 分支的完整 diff 和 commit 历史
3. 生成 PR 标题（<70 字符）和描述（bullet points 概括变更）
4. 确认后 push 并执行 `gh pr create`

注意：
- PR 标题简洁，描述用中文 bullet points
- 如果 remote 没有当前分支，用 `git push -u origin HEAD`
- 包含测试计划 checklist

$ARGUMENTS
