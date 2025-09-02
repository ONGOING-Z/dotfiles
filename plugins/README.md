# 🔌 Dotfiles 插件系统

插件系统允许您轻松扩展 Dotfiles 的功能。

## 📁 目录结构

```
plugins/
├── README.md          # 本文档
├── core/              # 核心插件
├── community/         # 社区插件
├── personal/          # 个人插件（gitignored）
└── template/          # 插件模板
```

## 🚀 快速开始

### 使用现有插件

```bash
# 列出所有插件
./scripts/plugin-manager.sh list

# 安装插件
./scripts/plugin-manager.sh install <plugin-name>

# 启用插件
./scripts/plugin-manager.sh enable <plugin-name>

# 禁用插件
./scripts/plugin-manager.sh disable <plugin-name>
```

### 创建新插件

```bash
# 使用模板创建新插件
./scripts/plugin-manager.sh create my-plugin

# 编辑插件
cd plugins/personal/my-plugin
vim init.sh
```

## 📝 插件结构

每个插件应包含以下文件：

```
my-plugin/
├── init.sh         # 插件初始化脚本（必需）
├── config.yml      # 插件配置（可选）
├── README.md       # 插件文档（推荐）
├── install.sh      # 安装脚本（可选）
├── uninstall.sh    # 卸载脚本（可选）
└── lib/            # 插件库文件（可选）
```

## 🔧 插件 API

### init.sh 示例

```bash
#!/usr/bin/env bash
# 插件初始化脚本

# 插件元数据
PLUGIN_NAME="my-plugin"
PLUGIN_VERSION="1.0.0"
PLUGIN_DESCRIPTION="我的自定义插件"

# 插件初始化函数
plugin_init() {
    # 添加别名
    alias mycommand='echo "Hello from my plugin!"'
    
    # 导出函数
    my_plugin_function() {
        echo "This is a function from $PLUGIN_NAME"
    }
    
    # 设置环境变量
    export MY_PLUGIN_VAR="some value"
    
    # 注册钩子
    register_hook "shell_startup" "my_plugin_startup"
}

# 启动钩子
my_plugin_startup() {
    echo "My plugin is starting..."
}

# 插件卸载函数
plugin_unload() {
    unalias mycommand 2>/dev/null || true
    unset -f my_plugin_function
    unset MY_PLUGIN_VAR
}

# 运行初始化
plugin_init
```

## 🎯 核心插件

### git-extras
增强的 Git 命令和工作流

### docker-aliases
Docker 和 Docker Compose 快捷命令

### dev-tools
开发工具集成（nvm、pyenv、rbenv）

### productivity
生产力工具（笔记、待办事项、时间跟踪）

## 🌟 创建插件指南

1. **确定插件范围**
   - 单一职责
   - 避免与其他插件冲突
   
2. **遵循命名约定**
   - 使用小写字母和连字符
   - 前缀避免冲突
   
3. **提供文档**
   - README.md 说明用法
   - 内联注释解释复杂逻辑
   
4. **处理依赖**
   - 检查必需的工具
   - 提供安装说明
   
5. **实现钩子**
   - shell_startup - Shell 启动时
   - shell_exit - Shell 退出时
   - pre_command - 命令执行前
   - post_command - 命令执行后

## 🤝 贡献插件

1. Fork 仓库
2. 在 `plugins/community/` 创建插件
3. 提交 Pull Request
4. 等待审核

## 📜 插件规范

- 不修改核心文件
- 使用命名空间避免冲突
- 提供卸载方法
- 遵循 Shell 最佳实践
- 支持多平台（Linux/macOS）