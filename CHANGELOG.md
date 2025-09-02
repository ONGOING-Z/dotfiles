# 📋 更新日志

所有重要更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [3.0.0] - 2024-01-20

### ✨ 新功能

- 添加智能交互式安装向导
- 实现健康检查功能
- 创建主题系统（支持 Dracula、Nord 等）
- 添加配置持久化和快照管理
- 实现 Shell 性能优化和延迟加载
- 添加环境检测和个性化推荐
- 创建一键安装脚本
- 添加配置回滚功能

### 🐛 错误修复

- 修复 `unbound variable` 错误
- 修复 `gum choose` 多行输出解析
- 修复 dotbot 执行和符号链接创建
- 解决颜色代码显示问题

### 📝 文档更新

- 添加中文文档 (README_CN.md)
- 创建故障排除指南
- 编写自定义指南
- 添加贡献指南
- 创建快速开始文档

### ♻️ 代码重构

- 重新组织根目录结构
- 将配置文件移至 `config/` 目录
- 将脚本移至 `scripts/` 目录

### ✅ 测试

- 添加 BATS 测试框架
- 创建集成测试套件
- 配置 pre-commit hooks

### 👷 持续集成

- 添加多平台测试支持
- 创建 ShellCheck 工作流
- 优化 GitHub Actions 配置

## [2.0.0] - 2023-12-01

### ✨ 新功能

- 基础 dotfiles 框架
- Vim/Neovim 配置
- Tmux 配置
- Git 配置
- Shell 增强

### 📝 文档更新

- 初始 README
- 基础安装说明