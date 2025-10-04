# Doctoc 使用指南

本仓库使用 [doctoc](https://github.com/thlorenz/doctoc) 自动为 Markdown 文件生成目录。

## 自动化方式

### GitHub Action（推荐）

当你推送包含 Markdown 文件的更改到 `main` 或 `master` 分支时，GitHub Action 会自动：
1. 检测所有 `.md` 文件
2. 生成或更新目录
3. 自动提交更新

**Workflow 文件**: `.github/workflows/doctoc.yml`

### Pull Request 检查

在 Pull Request 中，如果检测到 Markdown 文件缺少目录，GitHub Action 会添加评论提醒你。

## 本地使用

### 使用 Makefile（最简单）

```bash
# 自动为所有 markdown 文件生成目录
make doctoc
```

### 手动安装和使用

1. **安装 doctoc**:
```bash
npm install -g doctoc
```

2. **生成单个文件的目录**:
```bash
doctoc path/to/your/file.md
```

3. **生成所有 markdown 文件的目录**:
```bash
find . -name "*.md" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/vendor/*" \
  -not -path "*/vim/plugged/*" \
  -exec doctoc --github --notitle {} \;
```

## 配置选项

仓库根目录的 `.doctocrc` 文件包含 doctoc 的默认配置：

- `mode: github` - 使用 GitHub 风格的链接
- `notitle` - 不显示 "Table of Contents" 标题
- `maxlevel: 3` - 最多显示 3 级标题
- `entryprefix: -` - 使用 `-` 作为列表项前缀

## Markdown 文件中的目录格式

Doctoc 会在你的 Markdown 文件中查找以下标记：

```markdown
<!-- START doctoc -->
<!-- END doctoc -->
```

或者自动在文件顶部（第一个标题之前）生成目录。

## 排除某些文件

如果你不想为某个 Markdown 文件生成目录，可以在文件中添加：

```markdown
<!-- DOCTOC SKIP -->
```

## 常用命令

```bash
# 为特定目录生成目录
doctoc docs/

# 更新所有已有目录
doctoc . --update-only

# 使用自定义标题
doctoc README.md --title "## 📑 目录"

# 指定最大层级
doctoc README.md --maxlevel 4
```

## 提交规范

当 GitHub Action 自动提交目录更新时，会使用以下提交信息格式：

```
docs: auto-generate table of contents with doctoc [skip ci]
```

`[skip ci]` 标记会防止触发额外的 CI 构建。
