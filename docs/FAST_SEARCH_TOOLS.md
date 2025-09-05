# 🔍 高性能搜索工具对比

## 📊 性能对比概览

| 工具 | 速度 | 特点 | 适用场景 |
|------|------|------|----------|
| **ripgrep (rg)** | ⚡⚡⚡⚡⚡ | 综合性能最佳 | 通用代码搜索 |
| **ugrep** | ⚡⚡⚡⚡⚡ | 支持更多格式 | 二进制/压缩文件搜索 |
| **hypergrep** | ⚡⚡⚡⚡⚡⚡ | 极致并行 | 超大代码库 |
| **ast-grep** | ⚡⚡⚡⚡ | 语法感知 | 代码重构/AST搜索 |
| **silver searcher (ag)** | ⚡⚡⚡⚡ | 经典工具 | 一般搜索 |
| **grep** | ⚡⚡ | 标准工具 | 简单搜索 |

## 🚀 比 ripgrep 更快的工具

### 1. **Hypergrep** - 极致并行搜索
```bash
# 安装
cargo install hypergrep

# 使用 - 在超大代码库中更快
hgrep "pattern" /path/to/large/codebase

# 特点
- 使用 SIMD 指令集加速
- 更激进的并行策略
- 内存映射优化
```

### 2. **ugrep** - 通用 grep
```bash
# 安装
brew install ugrep  # macOS
sudo apt install ugrep  # Ubuntu

# 特点
- 支持搜索压缩文件（.gz, .bz2, .xz, .zip）
- 支持搜索二进制文件
- 在某些场景下比 rg 快 10-20%

# 示例
ugrep -z "pattern" .  # 搜索包括压缩文件
ugrep --binary "pattern" .  # 搜索二进制文件
```

### 3. **GNU grep with optimizations**
```bash
# 使用 GNU grep 的优化选项
export LC_ALL=C  # 禁用 UTF-8，大幅提速
grep -E --mmap "pattern" files  # 使用内存映射

# 对于简单模式，优化后的 grep 可能更快
```

## 🎯 特定场景的更快选择

### 语法感知搜索：**ast-grep**
```bash
# 安装
npm install -g @ast-grep/cli
# 或
cargo install ast-grep

# 搜索特定的代码模式（比正则更快更准）
ast-grep --pattern 'console.log($ARGS)'

# 优势：理解代码结构，避免误匹配
```

### 索引搜索：**csearch (codesearch)**
```bash
# Google 的代码搜索工具
go install github.com/google/codesearch/cmd/...@latest

# 建立索引（一次性）
cindex /path/to/code

# 搜索（极快）
csearch "pattern"

# 适合：频繁搜索同一代码库
```

### 实时索引：**livegrep**
```bash
# Dropbox 开发的实时代码搜索
# 需要预先建立索引，但搜索延迟 <100ms

# 适合：超大型代码库的 Web 搜索界面
```

## ⚡ 性能优化技巧

### 1. 并行度调优
```bash
# ripgrep 线程数
rg -j 8 "pattern"  # 8 线程

# 自动检测最优线程数
rg -j 0 "pattern"  # 0 = 自动
```

### 2. 忽略文件优化
```bash
# 使用 .ignore 文件
echo "node_modules/" > .ignore
echo "*.log" >> .ignore

# 或命令行指定
rg --glob '!*.log' --glob '!node_modules' "pattern"
```

### 3. 内存映射
```bash
# ripgrep 自动使用 mmap
# ugrep 强制使用
ugrep --mmap "pattern"
```

### 4. 预热文件系统缓存
```bash
# 预读文件到缓存
find . -type f -exec cat {} \; > /dev/null 2>&1
# 然后搜索会更快
```

## 📈 基准测试结果

在 Linux 内核源码（~70k 文件）中搜索：

```bash
# 测试命令
hyperfine --warmup 3 \
  'rg -n "TODO" .' \
  'ugrep -n "TODO" .' \
  'ag -n "TODO" .' \
  'grep -rn "TODO" .'

# 典型结果
rg:     ~95ms
ugrep:  ~88ms (特定场景)
ag:     ~340ms
grep:   ~1800ms
```

## 🔧 集成到 dotfiles

```bash
# 添加到 shell/aliases.sh
alias s='rg'  # 默认搜索
alias sz='ugrep -z'  # 搜索压缩文件
alias sc='csearch'  # 索引搜索
alias sa='ast-grep --pattern'  # AST 搜索

# 智能选择搜索工具
search() {
    local pattern="$1"
    shift

    # 如果有索引，用 csearch
    if [ -f ~/.csearchindex ]; then
        csearch "$pattern" "$@"
    # 如果需要搜索压缩文件
    elif find . -name "*.gz" -o -name "*.zip" | head -1 | grep -q .; then
        ugrep -z "$pattern" "$@"
    # 默认用 ripgrep
    else
        rg "$pattern" "$@"
    fi
}
```

## 💡 选择建议

1. **一般情况**：`ripgrep` 仍是最佳选择
   - 综合性能优秀
   - 功能完整
   - 生态系统成熟

2. **超大代码库**：`hypergrep` 或索引工具
   - 数百万文件级别
   - 需要极致性能

3. **特殊文件**：`ugrep`
   - 需要搜索压缩文件
   - 二进制文件搜索

4. **代码重构**：`ast-grep`
   - 需要语法感知
   - 复杂的代码模式匹配

5. **频繁搜索**：索引工具
   - `csearch`：离线索引
   - `livegrep`：实时索引

## 🎭 实际使用示例

```bash
# 1. 在大型 monorepo 中查找 TODO
hypergrep "TODO|FIXME|XXX" --threads 16

# 2. 在日志文件（包括压缩的）中搜索错误
ugrep -z "ERROR|FATAL" logs/

# 3. 查找所有未使用的函数
ast-grep --pattern 'function $NAME() { $$$ }' | \
  xargs -I {} sh -c 'name=$(echo {} | ...) && rg -q "$name\(" || echo "Unused: $name"'

# 4. 实时监控日志
tail -f app.log | ugrep --color=always "ERROR|WARN"
```

## 🔗 相关资源

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [ugrep](https://github.com/Genivia/ugrep)
- [ast-grep](https://ast-grep.github.io/)
- [codesearch](https://github.com/google/codesearch)
- [搜索工具基准测试](https://blog.burntsushi.net/ripgrep/)

---

💡 **提示**：虽然存在比 rg 更快的工具，但 ripgrep 在速度、功能和易用性之间达到了最佳平衡。只有在特定场景下，其他工具才会显著更快。
