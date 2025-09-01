## 🐛 问题修复

### 修复的问题：
1. **vim 插件目录的 git submodule 错误**
   - vim/vim/plugged/ 目录被错误地作为 git submodules 跟踪
   - 导致 GitHub Actions checkout 步骤失败

2. **私有 submodule 访问问题**
   - rime-config 是私有仓库，需要特殊配置才能访问

### 🔧 解决方案：

1. **移除错误的 submodule 跟踪**
   - 从 git 索引中移除 vim 插件目录
   - 添加 vim/vim/plugged/ 到 .gitignore
   - 这些插件应由 vim-plug 管理

2. **支持私有 submodule**
   - 修改 submodule URL 格式（SSH -> HTTPS）
   - 在 workflow 中添加 PAT token 支持
   - 添加详细的配置文档

### 📝 配置说明：

要使 GitHub Actions 能访问私有 submodule：
1. 创建 Personal Access Token (PAT)
2. 添加到仓库 Secrets: `PAT_FOR_PRIVATE_SUBMODULES`
3. workflow 将自动使用该 token

详见：`docs/PRIVATE_SUBMODULES_SETUP.md`

### ✅ 测试结果：
- pre-commit: ✅ 成功
- PR Labeler: ✅ 成功
- checkout 步骤: ✅ 修复成功（之前失败）

### 📋 Checklist：
- [x] 修复 vim 插件目录问题
- [x] 支持私有 submodule 访问
- [x] 添加配置文档
- [x] 测试 GitHub Actions