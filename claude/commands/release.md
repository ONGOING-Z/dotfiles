请帮我执行发布流程：

1. 查看 `git log` 确认要发布的 commit
2. 确认版本号（查看 VERSION 文件或 git tag）
3. 更新 CHANGELOG.md（如果项目有 changelog 机制）
4. 打 tag: `git tag -a vX.Y.Z -m "chore(release): vX.Y.Z"`
5. Push tag: `git push origin vX.Y.Z`

如果提供了具体版本号，直接使用；否则询问。

$ARGUMENTS
