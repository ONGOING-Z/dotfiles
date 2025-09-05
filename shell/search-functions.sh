#!/usr/bin/env bash
# 高性能搜索函数集合

# -----------------------------------------------------------------------------
# 优化的 rgp - 交互式搜索（性能优化版）
# -----------------------------------------------------------------------------

# 快速版 rgp - 使用缓存和延迟搜索
rgpf() {
    local RG_PREFIX="rg --line-number --no-heading --hidden --smart-case --color=always"
    local INITIAL_QUERY="${1:-}"
    local sel file line
    
    # 性能优化选项
    local FZF_OPTS=(
        --ansi
        --disabled
        --query "$INITIAL_QUERY"
        --delimiter :
        --nth=3..
        --preview-window=right,60%:wrap
        # 性能优化：减少实时搜索频率
        --bind "change:reload:sleep 0.3; $RG_PREFIX -- {q} || true"
        # 使用更轻量的预览
        --preview 'head -n 500 {1} | sed -n "$((({2}-10)<1?1:({2}-10))),$(({2}+10))p" | grep -n . | grep --color=always "^{2}:" || true'
    )
    
    # 如果在 tmux 中，使用弹窗
    if [ -n "$TMUX" ] && command -v fzf-tmux >/dev/null 2>&1; then
        sel="$(FZF_DEFAULT_COMMAND='' fzf-tmux -p 80%,80% "${FZF_OPTS[@]}")" || return
    else
        sel="$(FZF_DEFAULT_COMMAND='' fzf "${FZF_OPTS[@]}")" || return
    fi
    
    file="$(printf "%s" "$sel" | cut -d: -f1)"
    line="$(printf "%s" "$sel" | cut -d: -f2)"
    [ -n "$file" ] && ${EDITOR:-vim} +"$line" "$file"
}

# 超快版 rgp - 先搜索后选择
rgpu() {
    local query="${1:-}"
    if [ -z "$query" ]; then
        echo "用法: rgpu <搜索词>"
        return 1
    fi
    
    # 先执行搜索，再用 fzf 选择
    local results
    results=$(rg --line-number --no-heading --hidden --smart-case --color=always "$query" 2>/dev/null)
    
    if [ -z "$results" ]; then
        echo "未找到匹配项"
        return 1
    fi
    
    local sel file line
    sel=$(echo "$results" | fzf --ansi --delimiter : --nth=3.. \
          --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1} 2>/dev/null || cat {1}' \
          --preview-window=right,60%:wrap) || return
    
    file="$(printf "%s" "$sel" | cut -d: -f1)"
    line="$(printf "%s" "$sel" | cut -d: -f2)"
    [ -n "$file" ] && ${EDITOR:-vim} +"$line" "$file"
}

# 智能搜索 - 根据文件数量自动选择策略
rgs() {
    local query="${1:-}"
    
    # 估算项目大小
    local file_count=$(find . -type f -name "*.${2:-*}" 2>/dev/null | head -1000 | wc -l)
    
    if [ "$file_count" -lt 100 ]; then
        # 小项目：使用原始 rgp（实时搜索）
        rgp "$query"
    elif [ -n "$query" ]; then
        # 大项目且有查询词：使用 rgpu（先搜索后选择）
        rgpu "$query"
    else
        # 大项目无查询词：使用优化版 rgpf
        rgpf "$query"
    fi
}

# 使用索引的超快搜索（需要先建立索引）
rgpi() {
    local query="${1:-}"
    
    # 检查是否有索引
    if [ ! -f ~/.csearchindex ]; then
        echo "建立搜索索引..."
        cindex . || {
            echo "需要安装 codesearch: go install github.com/google/codesearch/cmd/...@latest"
            return 1
        }
    fi
    
    # 使用索引搜索
    if [ -n "$query" ]; then
        csearch -n "$query" | fzf --ansi --delimiter : \
            --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1} 2>/dev/null || cat {1}' \
            --preview-window=right,60%:wrap | {
            read -r sel
            if [ -n "$sel" ]; then
                file="$(printf "%s" "$sel" | cut -d: -f1)"
                line="$(printf "%s" "$sel" | cut -d: -f2)"
                ${EDITOR:-vim} +"$line" "$file"
            fi
        }
    else
        echo "用法: rgpi <搜索词>"
    fi
}

# 限定范围的快速搜索
rgpl() {
    local path="${1:-.}"
    local query="${2:-}"
    
    # 使用更严格的文件过滤
    rg --line-number --no-heading --smart-case --color=always \
       --glob '!*.log' --glob '!*.tmp' --glob '!dist/' --glob '!build/' \
       "$query" "$path" | \
    fzf --ansi --delimiter : --nth=3.. \
        --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1} 2>/dev/null || cat {1}' \
        --preview-window=right,60%:wrap | {
        read -r sel
        if [ -n "$sel" ]; then
            file="$(printf "%s" "$sel" | cut -d: -f1)"
            line="$(printf "%s" "$sel" | cut -d: -f2)"
            ${EDITOR:-vim} +"$line" "$file"
        fi
    }
}

# 缓存搜索结果
rgpc() {
    local cache_dir="$HOME/.cache/rgp"
    local cache_file="$cache_dir/last_search"
    mkdir -p "$cache_dir"
    
    local query="${1:-}"
    
    if [ -n "$query" ]; then
        # 新搜索，保存到缓存
        rg --line-number --no-heading --hidden --smart-case --color=always "$query" > "$cache_file"
    fi
    
    # 从缓存读取并选择
    if [ -f "$cache_file" ]; then
        cat "$cache_file" | fzf --ansi --delimiter : --nth=3.. \
            --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1} 2>/dev/null || cat {1}' \
            --preview-window=right,60%:wrap | {
            read -r sel
            if [ -n "$sel" ]; then
                file="$(printf "%s" "$sel" | cut -d: -f1)"
                line="$(printf "%s" "$sel" | cut -d: -f2)"
                ${EDITOR:-vim} +"$line" "$file"
            fi
        }
    else
        echo "没有缓存的搜索结果"
    fi
}

# 并行搜索（适合超大项目）
rgpp() {
    local query="${1:-}"
    if [ -z "$query" ]; then
        echo "用法: rgpp <搜索词>"
        return 1
    fi
    
    # 使用 GNU parallel 或 xargs 并行搜索
    if command -v parallel >/dev/null 2>&1; then
        find . -type f -name "*.${2:-*}" 2>/dev/null | \
        parallel -j+0 --block 10M --pipe \
        "xargs rg --line-number --no-heading --color=always '$query' 2>/dev/null" | \
        fzf --ansi --delimiter : --nth=3.. \
            --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1} 2>/dev/null || cat {1}' \
            --preview-window=right,60%:wrap
    else
        # 使用 xargs 的并行功能
        find . -type f -name "*.${2:-*}" 2>/dev/null | \
        xargs -P $(nproc) -I {} rg --line-number --no-heading --color=always "$query" {} 2>/dev/null | \
        fzf --ansi --delimiter : --nth=3.. \
            --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1} 2>/dev/null || cat {1}' \
            --preview-window=right,60%:wrap
    fi | {
        read -r sel
        if [ -n "$sel" ]; then
            file="$(printf "%s" "$sel" | cut -d: -f1)"
            line="$(printf "%s" "$sel" | cut -d: -f2)"
            ${EDITOR:-vim} +"$line" "$file"
        fi
    }
}