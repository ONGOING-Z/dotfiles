# Zsh 配置优化指南

本目录包含优化的 Zsh 配置文件和性能分析工具。

## 文件说明

- `startup-profiling.zsh` - 启动性能分析工具
- `optimized-zshrc` - 优化版 zshrc 配置示例

## 性能优化要点

### 1. 测量当前启动时间

```bash
# 方法一：使用 time 命令
time zsh -i -c exit

# 方法二：启用内置分析
ZSH_PROFILE=1 zsh
```

### 2. 优化策略

#### 选择单一插件管理器

设置环境变量选择插件管理器：

```bash
export ZSH_MANAGER=ohmyzsh  # 使用 Oh-My-Zsh
export ZSH_MANAGER=zplug    # 使用 zplug
export ZSH_MANAGER=zinit    # 使用 zinit
export ZSH_MANAGER=none     # 不使用插件管理器
```

#### 延迟加载

对于不常用的工具，使用延迟加载：

```bash
# 示例：延迟加载 nvm
lazy_load "$HOME/.nvm/nvm.sh" nvm node npm npx
```

#### 减少插件数量

只保留必要的插件：
- git（版本控制）
- z 或 zoxide（目录跳转）
- extract（解压工具）

### 3. 应用优化配置

#### 备份当前配置

```bash
cp ~/.zshrc ~/.zshrc.backup
```

#### 使用优化版配置

```bash
# 选项 1：直接替换
cp ~/dotfiles/zsh/optimized-zshrc ~/.zshrc

# 选项 2：在现有配置基础上优化
source ~/dotfiles/zsh/startup-profiling.zsh
```

### 4. 性能基准

优化前后的典型启动时间对比：

| 配置 | 启动时间 | 说明 |
|------|---------|------|
| 完整配置（oh-my-zsh + zplug） | 800-1200ms | 加载所有插件 |
| 单一管理器（oh-my-zsh） | 300-500ms | 精简插件列表 |
| 单一管理器 + 延迟加载 | 150-250ms | 延迟加载重型组件 |
| 最小配置 | 50-100ms | 仅基础功能 |

### 5. 故障排查

如果优化后出现问题：

```bash
# 恢复备份
mv ~/.zshrc.backup ~/.zshrc

# 调试模式启动
zsh -xvf

# 检查特定插件加载时间
time source ~/.oh-my-zsh/plugins/git/git.plugin.zsh
```

### 6. 进阶优化

#### 编译 zsh 脚本

```bash
# 编译 .zshrc 提升加载速度
zcompile ~/.zshrc
```

#### 使用 Turbo 模式（zinit）

```bash
zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions
```

## 推荐配置

对于大多数用户，推荐：

1. 使用单一插件管理器（oh-my-zsh 或 zinit）
2. 只启用 3-5 个核心插件
3. 对版本管理工具使用延迟加载
4. 定期清理不用的配置

## 参考资料

- [Zsh 启动速度优化](https://htr3n.github.io/2018/07/faster-zsh/)
- [Oh-My-Zsh 性能问题](https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-make-oh-my-zsh-start-faster)
- [Zinit Turbo 模式](https://github.com/zdharma-continuum/zinit#turbo-mode)