# 🤝 贡献指南

感谢您有兴趣为 Dotfiles 项目做出贡献！本文档将指导您完成贡献流程。

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发流程](#开发流程)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [测试要求](#测试要求)

## 行为准则

参与本项目即表示您同意遵守我们的行为准则：

- 🤝 尊重所有贡献者
- 💬 保持友善和专业的交流
- 🌍 欢迎来自不同背景的贡献者
- 🚫 不容忍骚扰或歧视行为

## 如何贡献

### 🐛 报告 Bug

1. 确保 bug 尚未被报告（搜索 Issues）
2. 使用 Bug 报告模板创建 Issue
3. 提供详细的复现步骤
4. 包含环境信息和错误日志

### 💡 提出新功能

1. 先在 Discussions 中讨论您的想法
2. 获得正面反馈后，创建功能请求 Issue
3. 等待维护者的回复

### 📝 改进文档

文档改进总是受欢迎的！包括：
- 修正拼写错误
- 改进说明清晰度
- 添加示例
- 翻译文档

## 开发流程

### 1. Fork 和克隆

```bash
# Fork 项目到您的账户
# 然后克隆
git clone https://github.com/YOUR-USERNAME/dotfiles.git
cd dotfiles
git remote add upstream https://github.com/ONGOING-Z/dotfiles.git
```

### 2. 创建分支

```bash
# 从最新的主分支创建
git checkout macos
git pull upstream macos
git checkout -b feat/your-feature-name
```

分支命名规范：
- `feat/` - 新功能
- `fix/` - Bug 修复
- `docs/` - 文档更新
- `refactor/` - 代码重构
- `test/` - 测试相关
- `ci/` - CI/CD 相关

### 3. 开发

```bash
# 进行您的修改
# 运行测试
./tests/run_tests.sh

# 运行健康检查
./install --health-check
```

### 4. 提交

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```bash
git add .
git commit -m "type: 简短描述

详细说明（可选）

Closes #123"
```

提交类型：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具
- `ci`: CI 相关

### 5. 推送和 PR

```bash
git push origin feat/your-feature-name
```

然后在 GitHub 上创建 Pull Request。

## 代码规范

### Shell 脚本规范

1. **使用 ShellCheck**
   ```bash
   shellcheck your-script.sh
   ```

2. **文件头部**
   ```bash
   #!/usr/bin/env bash
   # 脚本描述
   
   set -euo pipefail
   ```

3. **变量命名**
   - 全局变量：`UPPER_CASE`
   - 局部变量：`lower_case`
   - 函数名：`snake_case`

4. **错误处理**
   ```bash
   if ! command; then
       echo "错误: 命令失败" >&2
       exit 1
   fi
   ```

5. **函数定义**
   ```bash
   # 函数描述
   function_name() {
       local param1="$1"
       local param2="${2:-default}"
       
       # 函数体
   }
   ```

### 文档规范

1. 使用 Markdown 格式
2. 包含目录（对于长文档）
3. 提供代码示例
4. 保持语言简洁清晰

## 测试要求

### 运行测试

```bash
# 运行所有测试
./tests/run_tests.sh

# 运行特定测试
cd tests
bats bats/install.bats
```

### 添加测试

为新功能添加相应的测试：

```bash
# tests/bats/my-feature.bats
@test "my feature works correctly" {
    run my_function
    assert_success
    assert_output "expected output"
}
```

### 测试覆盖率

确保您的代码有适当的测试覆盖：
- Shell 脚本：关键功能必须有测试
- Python 代码：覆盖率 > 80%

## 🏷️ Issue 和 PR 标签

### Issue 标签
- `bug` - 错误报告
- `enhancement` - 功能请求
- `documentation` - 文档相关
- `question` - 问题
- `help wanted` - 需要帮助
- `good first issue` - 适合新贡献者

### PR 标签
- `ready for review` - 准备审查
- `work in progress` - 仍在开发
- `needs update` - 需要更新
- `breaking change` - 破坏性变更

## 📚 资源

- [Shell 脚本最佳实践](https://google.github.io/styleguide/shellguide.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## 🙏 感谢

感谢所有贡献者！您的贡献使这个项目变得更好。

如有任何问题，请随时：
- 在 Discussions 中提问
- 创建 Issue
- 联系维护者

Happy Contributing! 🎉