# 🔧 故障排除指南

本文档帮助您解决使用 Dotfiles 时可能遇到的常见问题。

## 📋 目录

- [安装问题](#安装问题)
- [符号链接问题](#符号链接问题)
- [Shell 配置问题](#shell-配置问题)
- [性能问题](#性能问题)
- [权限问题](#权限问题)
- [工具相关问题](#工具相关问题)

## 安装问题

### 问题：安装脚本无法执行

**症状**：
```bash
bash: ./install: Permission denied
```

**解决方案**：
```bash
chmod +x install
./install
```

### 问题：找不到 dotbot

**症状**：
```
错误: dotbot 子模块未初始化
```

**解决方案**：
```bash
git submodule update --init --recursive
```

### 问题：安装过程中断

**症状**：
安装过程意外终止

**解决方案**：
1. 检查错误日志：
   ```bash
   ls /tmp/dotfiles_install_*.log
   cat /tmp/dotfiles_install_*.log
   ```

2. 运行健康检查：
   ```bash
   ./install --health-check
   ```

3. 重新运行安装：
   ```bash
   ./install
   ```

## 符号链接问题

### 问题：符号链接创建失败

**症状**：
```
~/.bashrc already exists but is a regular file
```

**解决方案**：

1. **自动备份（推荐）**：
   安装器会自动备份冲突文件

2. **手动备份**：
   ```bash
   mv ~/.bashrc ~/.bashrc.backup
   ./install
   ```

3. **强制覆盖**（谨慎使用）：
   ```bash
   rm ~/.bashrc
   ./install
   ```

### 问题：符号链接指向错误位置

**症状**：
配置文件不生效或报错

**解决方案**：
```bash
# 检查符号链接
ls -la ~/.bashrc
# 应该显示类似: ~/.bashrc -> /path/to/dotfiles/config/bashrc

# 修复链接
rm ~/.bashrc
./install
```

## Shell 配置问题

### 问题：Zsh 启动缓慢

**症状**：
打开新终端窗口需要很长时间

**解决方案**：

1. **检查启动时间**：
   ```bash
   time zsh -i -c exit
   ```

2. **分析插件加载**：
   ```bash
   # 在 ~/.zshrc 开头添加
   zmodload zsh/zprof
   
   # 在 ~/.zshrc 结尾添加
   zprof
   ```

3. **优化建议**：
   - 减少不必要的插件
   - 使用延迟加载
   - 检查 PATH 设置

### 问题：命令未找到

**症状**：
```bash
zsh: command not found: xxx
```

**解决方案**：

1. **检查 PATH**：
   ```bash
   echo $PATH
   ```

2. **重新加载配置**：
   ```bash
   source ~/.zshrc
   ```

3. **安装缺失工具**：
   ```bash
   # macOS
   brew install xxx
   
   # Linux
   sudo apt install xxx
   ```

### 问题：Oh-My-Zsh 主题不显示

**症状**：
主题显示异常或乱码

**解决方案**：

1. **检查字体**：
   安装 Powerline 字体或 Nerd Fonts

2. **检查终端设置**：
   - 确保终端支持 256 色
   - 设置正确的字符编码（UTF-8）

3. **更换主题**：
   ```bash
   # 编辑 ~/.zshrc
   ZSH_THEME="robbyrussell"  # 使用简单主题
   ```

## 性能问题

### 问题：Git 状态显示缓慢

**症状**：
在大型仓库中命令行响应缓慢

**解决方案**：

1. **禁用 Git 状态**：
   ```bash
   # 在 ~/.zshrc 中添加
   DISABLE_UNTRACKED_FILES_DIRTY="true"
   ```

2. **使用更快的 Git 状态工具**：
   ```bash
   brew install git-delta
   ```

### 问题：自动补全缓慢

**症状**：
按 Tab 键后需要等待很久

**解决方案**：

1. **限制补全缓存**：
   ```bash
   # 在 ~/.zshrc 中添加
   zstyle ':completion:*' use-cache on
   zstyle ':completion:*' cache-path ~/.zsh/cache
   ```

2. **减少补全选项**：
   ```bash
   zstyle ':completion:*' menu select=5
   ```

## 权限问题

### 问题：SSH 配置权限错误

**症状**：
```
Permissions 0644 for '/home/user/.ssh/config' are too open
```

**解决方案**：
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

### 问题：无法修改系统文件

**症状**：
```
Permission denied
```

**解决方案**：

1. **检查文件所有者**：
   ```bash
   ls -la /path/to/file
   ```

2. **使用正确权限**：
   ```bash
   sudo chown $USER:$USER /path/to/file
   ```

## 工具相关问题

### 问题：Homebrew 安装失败

**症状**：
连接超时或下载失败

**解决方案**：

1. **使用国内镜像**：
   ```bash
   export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
   ```

2. **使用代理**：
   ```bash
   export https_proxy=http://127.0.0.1:7890
   export http_proxy=http://127.0.0.1:7890
   ```

### 问题：Tmux 插件不工作

**症状**：
TPM 插件管理器无法安装插件

**解决方案**：

1. **手动安装 TPM**：
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

2. **重新加载配置**：
   ```bash
   tmux source ~/.tmux.conf
   ```

3. **安装插件**：
   在 tmux 中按 `prefix + I`（默认 prefix 是 `Ctrl-a`）

### 问题：Vim 插件安装失败

**症状**：
vim-plug 无法下载插件

**解决方案**：

1. **安装 vim-plug**：
   ```bash
   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   ```

2. **在 Vim 中安装插件**：
   ```vim
   :PlugInstall
   ```

## 🆘 获取更多帮助

如果以上方案无法解决您的问题：

1. **运行诊断**：
   ```bash
   ./install --health-check > health-report.txt
   ```

2. **收集日志**：
   ```bash
   tar -czf dotfiles-debug.tar.gz \
       /tmp/dotfiles_install_*.log \
       health-report.txt \
       ~/.zshrc \
       ~/.bashrc
   ```

3. **提交 Issue**：
   访问 [GitHub Issues](https://github.com/ONGOING-Z/dotfiles/issues) 并附上：
   - 问题描述
   - 错误信息
   - 系统信息（`uname -a`）
   - 调试包（如果需要）

## 📝 预防措施

为避免问题发生：

1. **定期更新**：
   ```bash
   cd ~/dotfiles && git pull
   ```

2. **定期检查**：
   ```bash
   ./install --health-check
   ```

3. **备份重要配置**：
   ```bash
   cp ~/.zshrc ~/.zshrc.backup-$(date +%Y%m%d)
   ```

4. **测试新配置**：
   在应用到主系统前，先在虚拟机或 Docker 中测试

---

💡 **提示**：大多数问题都可以通过运行 `./install --health-check` 发现并获得解决建议。