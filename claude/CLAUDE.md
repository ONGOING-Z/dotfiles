# 个人 Claude Code 配置

## 环境
- 系统: macOS (Darwin)
- Shell: zsh
- 编辑器: vim/neovim
- 中文优先回复

## 编码偏好
- 编辑现有文件而非新建，除非必要
- 不写注释，除非逻辑非显而易见
- 不过度抽象——三个相似的写法好过一个过早的抽象
- 不需要写文档/README/CHANGELOG 除非明确要求
- 不添加没发生过的场景的错误处理

## 常用工作流
- 提交: 遵循 conventional commits，message 用英文
- PR: 标题简洁（<70字符），描述用 bullet points
- 测试: 用 pytest（Python）、bats（Shell）

## 项目上下文
- dotfiles 在 ~/dotfiles，用 dotbot 管理 symlink
- 本地敏感配置放 ~/.zshrc.local（不提交 git）
- Homebrew mirror: ustc

## 语言/框架
- Python: pytest, black 格式化
- Shell: bash/zsh, shellcheck 检查
- Java: Maven, SDKMAN 管理 JDK
- Go: GOPATH=~/Documents/github/go

## 禁止
- 不要往 ~/.zshrc 写 API key 等敏感信息（用 ~/.zshrc.local）
- 不要用 `git add -A`，指定具体文件
- 不要在 main/master 上 force push
