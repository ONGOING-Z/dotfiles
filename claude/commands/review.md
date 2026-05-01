请审查当前分支的未提交变更（或已提交但未合并的变更）：

1. 查看 `git diff` 和 `git log` 相对于 base 分支的差异
2. 检查：
   - 安全漏洞（SQL 注入、XSS、命令注入、密钥泄露）
   - 逻辑错误、边界条件
   - 代码重复、不必要的抽象
   - Shell 合规（shellcheck 规则）
   - Python 合规（PEP8、类型安全）
3. 给出分级报告：严重/警告/建议

$ARGUMENTS
