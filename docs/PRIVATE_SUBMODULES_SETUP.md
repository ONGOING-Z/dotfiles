# 配置私有 Submodule 访问

本仓库包含私有 submodule `rime-config`，需要额外配置才能在 GitHub Actions 中正常访问。

## 配置步骤

### 1. 创建 Personal Access Token (PAT)

1. 访问 GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 点击 "Generate new token (classic)"
3. 设置 token 名称，例如：`dotfiles-submodule-access`
4. 选择以下权限：
   - `repo` (完整的仓库访问权限)
5. 生成并复制 token（注意：token 只会显示一次）

### 2. 添加 Secret 到仓库

1. 访问本仓库的 Settings → Secrets and variables → Actions
2. 点击 "New repository secret"
3. 名称：`PAT_FOR_PRIVATE_SUBMODULES`
4. 值：粘贴刚才复制的 PAT
5. 点击 "Add secret"

## 工作原理

GitHub Actions workflow 文件已配置为使用此 token：

```yaml
- uses: actions/checkout@v4
  with:
    submodules: recursive
    token: ${{ secrets.PAT_FOR_PRIVATE_SUBMODULES || secrets.GITHUB_TOKEN }}
```

- 如果配置了 `PAT_FOR_PRIVATE_SUBMODULES`，将使用它来访问私有 submodules
- 如果没有配置，将回退到默认的 `GITHUB_TOKEN`（只能访问公开仓库）

## 本地开发

本地克隆时，如果需要包含私有 submodule：

```bash
# 克隆主仓库
git clone https://github.com/ONGOING-Z/dotfiles.git

# 初始化并更新 submodules
cd dotfiles
git submodule update --init --recursive
```

如果 `rime-config` 是私有仓库，Git 会提示输入 GitHub 用户名和密码/token。

## 注意事项

1. PAT 需要定期更新（根据设置的过期时间）
2. 确保 PAT 只授予必要的最小权限
3. 不要在代码中硬编码 token
4. 如果不需要私有 submodule，可以使用 `--ignore-submodules` 选项

## 故障排查

如果 GitHub Actions 在 checkout 步骤失败：

1. 检查 PAT 是否已过期
2. 确认 PAT 有访问私有仓库的权限
3. 验证 secret 名称是否正确（`PAT_FOR_PRIVATE_SUBMODULES`）
4. 查看 Actions 日志获取详细错误信息