# 高级用户配置示例

为追求极致效率的高级用户设计，包含所有功能和高度定制化。

## 特点

- ✅ 完整功能集
- ✅ 高度定制化
- ✅ 性能优化
- ✅ 自动化工作流
- ✅ 高级键位绑定
- ✅ 脚本和函数库

## 包含内容

```
.zshrc         # 高级 Zsh 配置
.vimrc         # 专业 Vim 配置
.tmux.conf     # 高级 Tmux 配置
.gitconfig     # Git 工作流配置
自定义脚本      # 自动化工具
```

## 高级特性

### Shell 增强
- 自定义提示符（Powerlevel10k）
- 智能命令补全
- 模糊历史搜索
- 目录书签系统
- 自动跳转（zoxide）

### 编辑器增强
- LSP 集成
- DAP 调试器
- 代码片段管理
- 项目管理
- Git 工作流集成

### 工作流自动化
- 项目模板生成
- 代码审查工具
- 部署脚本
- 备份和同步
- 性能监控

## 性能优化

- 延迟加载插件
- 编译 zsh 脚本
- 缓存优化
- 异步操作

## 安装

```bash
cd ~/dotfiles
./install
# 选择 "专家模式"
# 启用所有功能
```

## 自定义配置

高级用户可以通过以下文件进一步定制：

- `~/.zshrc.local` - 本地 Zsh 配置
- `~/.vimrc.local` - 本地 Vim 配置
- `~/.tmux.local.conf` - 本地 Tmux 配置
- `~/.gitconfig.local` - 本地 Git 配置

## 键位绑定

### Vim 前导键
- `<Space>` - 主前导键
- `<Space>f` - 文件操作
- `<Space>g` - Git 操作
- `<Space>s` - 搜索操作

### Tmux 前缀
- `Ctrl-a` - 主前缀
- `Ctrl-a |` - 垂直分割
- `Ctrl-a -` - 水平分割
- `Ctrl-a r` - 重载配置
