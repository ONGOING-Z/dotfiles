# 现代 CLI 工具集成指南

本指南介绍如何安装和使用三个现代化的 CLI 工具：Starship、McFly 和 Navi，以提升命令行体验。

## 🚀 快速开始

### 自动化安装

运行自动化安装脚本：

```bash
./scripts/install-modern-cli-tools.sh
```

脚本将自动：
- 检测系统类型和包管理器
- 安装 Starship、McFly 和 Navi
- 配置 shell 集成
- 复制配置文件和备忘单

### 手动安装

如果需要手动安装，请参考各工具的官方文档。

## 🛠️ 工具介绍

### 1. Starship - 跨 shell 提示符

Starship 是一个快速、可定制的跨 shell 提示符，支持多种编程语言和工具的状态显示。

#### 特性
- ⚡ 快速响应
- 🎨 高度可定制
- 🌐 跨平台支持
- 📊 智能状态显示

#### 配置文件
配置文件位置：`~/.config/starship.toml`

#### 常用功能
- Git 状态显示
- 编程语言版本显示
- 目录路径美化
- 命令执行时间显示
- 系统状态监控

### 2. McFly - 智能 shell 历史

McFly 使用神经网络来学习您的命令使用模式，提供智能的历史搜索建议。

#### 特性
- 🧠 智能搜索算法
- ⚡ 快速响应
- 🔍 模糊匹配
- 📈 使用统计

#### 配置
配置文件：`~/.mcfly.sh`

#### 快捷键
- `Ctrl+R`: 智能历史搜索
- `Ctrl+N`: 下一个建议
- `Ctrl+P`: 上一个建议

#### 常用命令
```bash
# 搜索历史
mf "search_term"

# 查看历史分析
mfa

# 清理重复历史
mfc

# 导出历史
mfe [输出文件]

# 导入历史
mfi <历史文件>

# 查看配置
mfcfg
```

### 3. Navi - 交互式命令行备忘单

Navi 提供交互式的命令行备忘单，帮助您快速查找和执行复杂命令。

#### 特性
- 📚 丰富的备忘单库
- 🔍 交互式搜索
- 🏷️ 标签分类
- ⚡ 快速执行

#### 配置
- 配置文件：`~/.config/navi/config.yaml`
- 备忘单目录：`~/.local/share/navi/cheats/`
- 脚本文件：`~/.navi.sh`

#### 快捷键
- `Ctrl+G`: 打开 Navi 搜索
- `Enter`: 执行选中的命令
- `Ctrl+Y`: 复制命令到剪贴板
- `Esc`: 退出

#### 常用命令
```bash
# 打开交互式搜索
navi
# 或使用别名
n

# 搜索特定内容
navi_search "docker"
# 或使用别名
ns "docker"

# 按标签搜索
navi_tag "git"
# 或使用别名
nt "git"

# 打开特定备忘单
navi_cheat "git"
# 或使用别名
nc "git"

# 添加新备忘单
navi_add "my-commands"
# 或使用别名
na "my-commands"

# 列出所有备忘单
navi_list
# 或使用别名
nl

# 备份备忘单
navi_backup
# 或使用别名
nb

# 同步官方备忘单
navi_sync
# 或使用别名
nsync

# 搜索备忘单内容
navi_grep "docker run"
# 或使用别名
ng "docker run"

# 查看统计信息
navi_stats
# 或使用别名
nstats
```

## 📋 内置备忘单

安装完成后，您将获得以下预置备忘单：

### Git 备忘单 (`git.cheat`)
包含常用的 Git 命令，如：
- 基本操作（add, commit, push, pull）
- 分支管理
- 历史查看
- 标签管理
- 配置设置

### Docker 备忘单 (`docker.cheat`)
包含 Docker 相关命令，如：
- 容器管理
- 镜像操作
- 网络管理
- 卷管理
- 系统清理

### Linux 系统管理备忘单 (`linux.cheat`)
包含 Linux 系统管理命令，如：
- 文件操作
- 进程管理
- 系统监控
- 用户管理
- 服务管理

### 网络诊断备忘单 (`network.cheat`)
包含网络相关命令，如：
- 网络接口管理
- 路由配置
- 连接诊断
- 防火墙设置
- 流量监控

## ⚙️ 配置说明

### Starship 配置

编辑 `~/.config/starship.toml` 来自定义提示符：

```toml
# 示例配置
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[directory]
style = "bold cyan"
truncation_length = 3

[git_branch]
symbol = "🌱 "
style = "bold purple"
```

### McFly 配置

编辑 `~/.mcfly.sh` 来调整 McFly 行为：

```bash
export MCFLY_FUZZY=2                    # 启用完全模糊搜索
export MCFLY_RESULTS=50                 # 显示 50 个结果
export MCFLY_INTERFACE_VIEW=TOP         # 界面显示在顶部
export MCFLY_KEY_SCHEME=vim            # 使用 vim 键绑定
```

### Navi 配置

编辑 `~/.config/navi/config.yaml` 来配置 Navi：

```yaml
search:
  finder: fzf
  preview: true

ui:
  color_scheme: dark
  show_tags: true

keybindings:
  open: "ctrl-g"
  execute: "enter"
```

## 🔧 自定义备忘单

### 创建新备忘单

使用 `navi_add` 命令创建新的备忘单：

```bash
navi_add "my-custom-commands"
```

### 备忘单格式

备忘单使用特定的格式：

```
# 备忘单标题

% 标签1, 标签2

# 命令描述
command_example

# 带参数的命令
command_with_param <parameter>

# 变量定义
$ parameter: echo -e "option1\noption2\noption3"
```

### 示例备忘单

```
# 我的自定义命令

% custom, personal

# 查看系统负载
htop

# 创建目录并进入
mkdir <dir_name> && cd <dir_name>

# 查找大文件
find <path> -type f -size +<size>

$ dir_name: echo -e "projects\ndocs\ntmp"
$ path: echo -e "/home\n/var\n/tmp"
$ size: echo -e "100M\n500M\n1G"
```

## 🚀 使用技巧

### 1. 组合使用
- 使用 Starship 美化提示符
- 用 McFly 智能搜索历史命令
- 通过 Navi 快速查找复杂命令

### 2. 快捷键组合
- `Ctrl+R` (McFly) + `Ctrl+G` (Navi) 实现全面的命令搜索
- 使用 Starship 的状态显示来了解当前环境

### 3. 自定义工作流
- 为常用项目创建专门的备忘单
- 使用标签系统组织命令
- 定期备份和同步配置

## 🔍 故障排除

### 常见问题

1. **工具未正确加载**
   - 检查 shell 配置文件是否正确添加了初始化代码
   - 重新启动 shell 或运行 `source ~/.bashrc`

2. **Starship 提示符不显示**
   - 确认字体支持 Unicode 字符
   - 检查配置文件语法是否正确

3. **McFly 搜索不工作**
   - 确认历史文件路径配置正确
   - 检查 McFly 数据库是否损坏

4. **Navi 找不到备忘单**
   - 检查备忘单路径配置
   - 确认备忘单文件格式正确

### 重置配置

如果遇到问题，可以重置配置：

```bash
# 备份当前配置
cp ~/.config/starship.toml ~/.config/starship.toml.backup
cp ~/.mcfly.sh ~/.mcfly.sh.backup
cp ~/.navi.sh ~/.navi.sh.backup

# 重新运行安装脚本
./scripts/install-modern-cli-tools.sh
```

## 📚 更多资源

- [Starship 官方文档](https://starship.rs/)
- [McFly GitHub 仓库](https://github.com/cantino/mcfly)
- [Navi GitHub 仓库](https://github.com/denisidoro/navi)

## 🤝 贡献

欢迎贡献新的备忘单、配置优化或功能改进！请提交 Pull Request 或创建 Issue。

---

*享受您的现代化命令行体验！* ✨