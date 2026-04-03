# 🔒 安全最佳实践

本文档提供 Dotfiles 安全配置和使用的最佳实践。

## 🛡️ 基础安全原则

### 1. 敏感信息管理

**永远不要提交到 Git**：
- 密码和 API 密钥
- SSH 私钥
- 数据库连接字符串
- 个人访问令牌 (PAT)
- 任何包含敏感数据的文件

**使用环境变量**：
```bash
# ❌ 错误：硬编码密钥
export API_KEY="sk-1234567890abcdef"

# ✅ 正确：从安全存储读取
export API_KEY="$(security find-generic-password -s 'my-api-key' -w)"
```

### 2. 文件权限

**设置正确的权限**：
```bash
# SSH 配置
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/authorized_keys

# Git 配置
chmod 600 ~/.gitconfig
chmod 600 ~/.netrc

# Shell 配置
chmod 600 ~/.bashrc ~/.zshrc
```

**自动权限检查**：
```bash
# 运行安全审计
./scripts/security-audit.sh
```

## 🔑 SSH 密钥管理

### 生成安全的 SSH 密钥

```bash
# 推荐：Ed25519 算法
ssh-keygen -t ed25519 -C "your-email@example.com"

# 备选：RSA 4096 位
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

### SSH 配置加固

创建 `~/.ssh/config`：
```ssh
# 全局设置
Host *
    # 使用 SSH 协议版本 2
    Protocol 2
    # 启用压缩
    Compression yes
    # 保持连接
    ServerAliveInterval 60
    ServerAliveCountMax 3
    # 禁用不安全的算法
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
    # 严格主机密钥检查
    StrictHostKeyChecking ask
    # 禁用 X11 转发（除非需要）
    ForwardX11 no
    # 使用密钥认证
    PasswordAuthentication no
```

### SSH 代理转发

```bash
# 仅在需要时启用
Host trusted-server
    HostName example.com
    ForwardAgent yes

# 默认禁用
Host *
    ForwardAgent no
```

## 🔐 密钥和密码管理

### 使用密钥管理器

1. **macOS Keychain**：
```bash
# 存储密码
security add-generic-password -s 'service-name' -a 'username' -w 'password'

# 读取密码
security find-generic-password -s 'service-name' -w
```

2. **使用密钥管理脚本**：
```bash
# 存储密钥
./scripts/secrets-manager.sh add API_KEY "your-secret-key"

# 使用密钥
export API_KEY=$(./scripts/secrets-manager.sh get API_KEY)
```

3. **Linux 密钥环**：
```bash
# 使用 secret-tool (GNOME)
echo -n "password" | secret-tool store --label='My Password' service my-service username my-user

# 读取
secret-tool lookup service my-service username my-user
```

## 📝 Git 安全配置

### 签名提交

```bash
# 生成 GPG 密钥
gpg --full-generate-key

# 配置 Git 使用 GPG
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true

# 或使用 SSH 签名 (Git 2.34+)
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
```

### Git 凭据存储

```bash
# macOS: 使用 Keychain
git config --global credential.helper osxkeychain

# Linux: 使用加密存储
git config --global credential.helper store
git config --global credential.credentialStore ~/.git-credentials-encrypted

# 缓存凭据（临时）
git config --global credential.helper 'cache --timeout=3600'
```

### 防止敏感信息泄露

1. **使用 .gitignore**：
```gitignore
# 敏感文件
.env
.env.local
*.key
*.pem
secrets/
credentials/

# 个人配置
.personal
.work
*.local
```

2. **预提交检查**：
```bash
# 启用 detect-secrets
pre-commit install
```

## 🌐 网络安全

### 安全的包管理器配置

```bash
# npm - 使用官方注册表
npm config set registry https://registry.npmjs.org/

# pip - 使用 HTTPS
pip config set global.index-url https://pypi.org/simple

# 验证包签名
npm install --verify-signatures
```

### 代理配置

```bash
# 仅通过 HTTPS 代理
export https_proxy="https://proxy.example.com:8080"
export no_proxy="localhost,127.0.0.1,*.local"

# Git 代理
git config --global http.proxy "https://proxy.example.com:8080"
git config --global https.proxy "https://proxy.example.com:8080"
```

## 🔍 审计和监控

### 定期安全检查

```bash
# 1. 检查文件权限
find ~ -type f -perm 0777 -ls

# 2. 查找包含密码的文件
grep -r "password\|passwd\|pwd" ~/dotfiles/ --exclude-dir=.git

# 3. 检查 SSH 授权密钥
cat ~/.ssh/authorized_keys

# 4. 审计 Git 历史
git log --all --full-history -- "*password*" "*secret*" "*key*"
```

### 使用安全审计工具

```bash
# 运行完整审计
./scripts/security-audit.sh

# 检查特定方面
./scripts/security-audit.sh --check-permissions
./scripts/security-audit.sh --check-secrets
./scripts/security-audit.sh --check-git-history
```

## 🚨 应急响应

### 如果密钥泄露

1. **立即撤销**：
   - 更改所有相关密码
   - 撤销 API 密钥和令牌
   - 生成新的 SSH 密钥

2. **清理 Git 历史**：
```bash
# 使用 BFG Repo-Cleaner
bfg --delete-files "*.key" --delete-folders secrets
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 或使用 git filter-branch
git filter-branch --tree-filter 'rm -f path/to/secret' HEAD
```

3. **通知相关方**：
   - 如果是工作相关，通知安全团队
   - 更新所有使用该密钥的服务

## 📋 安全检查清单

定期执行以下检查：

- [ ] 所有 SSH 密钥都有密码保护
- [ ] ~/.ssh 目录权限为 700
- [ ] 没有硬编码的密码或密钥
- [ ] Git 历史中没有敏感信息
- [ ] 使用密钥管理器存储凭据
- [ ] 启用了 Git 提交签名
- [ ] 配置了 pre-commit hooks
- [ ] 定期更新依赖包
- [ ] 审查 shell 历史记录
- [ ] 检查环境变量中的敏感信息

## 🛠️ 安全工具推荐

1. **密码管理**：
   - 1Password CLI
   - Bitwarden CLI
   - pass (Unix)

2. **加密工具**：
   - age (简单加密)
   - GPG (通用加密)
   - git-crypt (Git 仓库加密)

3. **审计工具**：
   - lynis (系统审计)
   - chkrootkit (rootkit 检测)
   - rkhunter (rootkit hunter)

## 💡 额外建议

1. **使用多因素认证 (MFA)**
2. **定期轮换密钥和密码**
3. **最小权限原则**
4. **保持软件更新**
5. **使用 VPN 在公共网络**
6. **备份重要配置（加密存储）**
7. **审查第三方脚本和插件**

---

🔒 **记住**：安全是一个持续的过程，而不是一次性的设置。定期审查和更新您的安全实践！
