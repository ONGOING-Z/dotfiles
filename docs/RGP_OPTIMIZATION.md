# 🚀 rgp 性能优化指南

## 问题分析

`rgp` 慢的主要原因：
1. **实时搜索** - 每次按键都触发新的 ripgrep 进程
2. **大型项目** - 搜索范围过大
3. **预览开销** - bat 预览大文件时消耗资源
4. **无缓存** - 重复搜索相同内容

## 优化方案

### 1. 已实施的优化

在 `zshrc` 中更新了 `rgp` 函数：
- 添加了 200ms 延迟，减少搜索频率
- 支持初始查询参数：`rgp "search term"`
- 优化了预览命令，添加 fallback

### 2. 新增的快速搜索命令

#### `rgpf` - 快速版（先搜索后选择）
```bash
# 适合大项目，知道要搜什么
rgpf "TODO"  # 先搜索所有 TODO，再选择

# 优势：只执行一次搜索，速度快
# 缺点：需要先输入搜索词
```

### 3. 其他性能优化技巧

#### 限制搜索范围
```bash
# 只搜索特定目录
cd src && rgp

# 或使用自定义函数搜索当前目录
alias rgp.='cd . && rgp'
```

#### 使用 .ignore 文件
```bash
# 创建项目级 .ignore 文件
cat > .ignore << EOF
node_modules/
dist/
build/
*.log
*.tmp
.git/
EOF
```

#### 配置 ripgrep
```bash
# ~/.config/ripgrep/config
--max-columns=150
--max-columns-preview
--smart-case
--hidden
--glob=!.git/
--glob=!node_modules/
--glob=!*.min.js
--glob=!*.map
```

### 4. 高级优化

#### 使用搜索缓存
```bash
# 将这个函数添加到 zshrc
rgpc() {
  local cache_file="/tmp/rgp_cache_$(pwd | md5sum | cut -d' ' -f1)"
  local query="${1:-}"
  
  if [ -n "$query" ]; then
    # 新搜索，保存到缓存
    rg --line-number --no-heading --hidden --smart-case --color=always "$query" > "$cache_file"
  fi
  
  # 从缓存选择
  [ -f "$cache_file" ] && cat "$cache_file" | fzf --ansi --delimiter : --nth=3.. \
    --preview 'bat --color=always --highlight-line {2} {1}' | {
    read -r sel
    [ -n "$sel" ] && ${EDITOR:-vim} +"$(echo "$sel" | cut -d: -f2)" "$(echo "$sel" | cut -d: -f1)"
  }
}
```

#### 使用索引搜索
```bash
# 安装 codesearch
go install github.com/google/codesearch/cmd/...@latest

# 建立索引（在项目根目录）
cindex .

# 使用索引搜索（极快）
csearch "pattern"
```

### 5. 性能对比

| 方法 | 速度 | 适用场景 |
|------|------|----------|
| `rgp` (优化后) | 中等 | 探索性搜索 |
| `rgpf` | 快 | 明确的搜索目标 |
| `rgpc` | 很快 | 重复搜索 |
| `csearch` | 极快 | 大型项目 |

### 6. 推荐使用模式

```bash
# 小项目（<1000 文件）
rgp  # 直接使用交互式搜索

# 中型项目（1000-10000 文件）
rgp "initial search"  # 带初始搜索词
# 或
rgpf "search term"   # 快速搜索

# 大型项目（>10000 文件）
# 先建立索引
cindex .
# 然后使用索引搜索
csearch "pattern" | fzf

# 或限制搜索范围
cd src && rgp
```

### 7. 调试性能

```bash
# 测试 ripgrep 性能
time rg "test" > /dev/null

# 查看搜索的文件数
rg --files | wc -l

# 查看哪些文件拖慢了速度
rg --debug "pattern" 2>&1 | grep "^rg: "
```

## 总结

- 对于日常使用，优化后的 `rgp` 应该足够快
- 大项目建议使用 `rgpf` 或索引搜索
- 合理配置 `.ignore` 文件很重要
- 考虑项目特点选择合适的搜索策略