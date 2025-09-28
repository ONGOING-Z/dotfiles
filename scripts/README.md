# 现代 CLI 工具集成脚本

本目录包含用于安装和配置现代 CLI 工具的脚本集合。

## 🚀 快速开始

### 1. 安装工具

运行自动化安装脚本：

```bash
./scripts/install-modern-cli-tools.sh
```

此脚本将：
- 自动检测系统类型和包管理器
- 安装 Starship、McFly 和 Navi
- 配置 shell 集成
- 复制配置文件和备忘单

### 2. 测试安装

运行测试脚本验证安装：

```bash
./scripts/test-modern-cli-tools.sh
```

此脚本将检查：
- 工具是否正确安装
- 配置文件是否存在
- Shell 集成是否配置
- 功能是否正常工作

### 3. 体验演示

运行交互式演示：

```bash
./scripts/demo-modern-cli-tools.sh
```

此脚本提供：
- 各工具功能演示
- 使用方法说明
- 集成使用场景
- 安装状态检查

## 📁 脚本说明

### install-modern-cli-tools.sh
- **功能**: 自动化安装和配置三个现代 CLI 工具
- **支持**: Linux (多种发行版)、macOS
- **特性**: 智能检测系统环境，自动选择最佳安装方式

### test-modern-cli-tools.sh
- **功能**: 全面测试安装结果
- **检查项**: 工具安装、配置文件、目录结构、功能测试
- **输出**: 详细的测试报告和故障排除建议

### demo-modern-cli-tools.sh
- **功能**: 交互式演示和教学
- **内容**: 工具介绍、使用方法、最佳实践
- **界面**: 美观的菜单系统，逐步引导

## 🛠️ 工具介绍

### Starship 🚀
- 跨 shell 的现代提示符
- 快速响应，高度可定制
- 智能显示项目状态和系统信息

### McFly 🧠
- 智能 shell 历史搜索
- 使用神经网络学习使用模式
- 提供上下文感知的命令建议

### Navi 📚
- 交互式命令行备忘单
- 支持参数化命令和自动补全
- 丰富的内置备忘单库

## 📋 使用流程

1. **安装**: `./install-modern-cli-tools.sh`
2. **测试**: `./test-modern-cli-tools.sh`
3. **学习**: `./demo-modern-cli-tools.sh`
4. **重启** shell 或运行 `source ~/.bashrc`
5. **开始使用**:
   - `Ctrl+R` - McFly 智能历史搜索
   - `Ctrl+G` - Navi 备忘单搜索
   - 观察 Starship 美化的提示符

## 🔧 故障排除

如果遇到问题：

1. **检查系统要求**:
   - 支持的操作系统
   - 必要的依赖包

2. **重新安装**:
   ```bash
   ./scripts/install-modern-cli-tools.sh
   ```

3. **查看测试结果**:
   ```bash
   ./scripts/test-modern-cli-tools.sh
   ```

4. **参考文档**:
   - `docs/MODERN_CLI_TOOLS.md` - 详细使用指南
   - 各工具官方文档

## 📚 更多资源

- [完整使用指南](../docs/MODERN_CLI_TOOLS.md)
- [Starship 官方文档](https://starship.rs/)
- [McFly GitHub](https://github.com/cantino/mcfly)
- [Navi GitHub](https://github.com/denisidoro/navi)

---

*享受现代化的命令行体验！* ✨