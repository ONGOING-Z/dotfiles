#!/usr/bin/env bash
# 智能缓存系统 - 优化 Shell 启动性能

set -euo pipefail

# 缓存配置
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
CACHE_VERSION="1.0"
DEFAULT_TTL=3600  # 1小时默认过期时间

# 确保缓存目录存在
mkdir -p "$CACHE_DIR"

# 版本检查和清理
version_file="$CACHE_DIR/.version"
if [[ ! -f "$version_file" ]] || [[ "$(cat "$version_file" 2>/dev/null)" != "$CACHE_VERSION" ]]; then
    echo "清理旧版本缓存..."
    rm -rf "$CACHE_DIR"/*
    mkdir -p "$CACHE_DIR"
    echo "$CACHE_VERSION" > "$version_file"
fi

# 智能缓存函数
cache_command() {
    local cache_key="$1"
    local command="$2"
    local ttl="${3:-$DEFAULT_TTL}"
    local cache_file="$CACHE_DIR/${cache_key}.cache"
    local meta_file="$CACHE_DIR/${cache_key}.meta"

    # 检查缓存是否存在且未过期
    if [[ -f "$cache_file" ]] && [[ -f "$meta_file" ]]; then
        local cache_time
        cache_time=$(cat "$meta_file" 2>/dev/null || echo "0")
        local current_time
        current_time=$(date +%s)

        if (( current_time - cache_time < ttl )); then
            cat "$cache_file"
            return 0
        fi
    fi

    # 执行命令并缓存结果
    local temp_file
    temp_file=$(mktemp)

    if eval "$command" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$cache_file"
        date +%s > "$meta_file"
        cat "$cache_file"
    else
        rm -f "$temp_file"
        return 1
    fi
}

# 命令存在性检查缓存
declare -A COMMAND_CACHE
check_command() {
    local cmd="$1"

    if [[ -z "${COMMAND_CACHE[$cmd]:-}" ]]; then
        if command -v "$cmd" >/dev/null 2>&1; then
            COMMAND_CACHE[$cmd]="1"
        else
            COMMAND_CACHE[$cmd]="0"
        fi
    fi

    [[ "${COMMAND_CACHE[$cmd]}" == "1" ]]
}

# 批量检查命令
batch_check_commands() {
    local commands=("$@")
    local pids=()

    for cmd in "${commands[@]}"; do
        {
            if command -v "$cmd" >/dev/null 2>&1; then
                COMMAND_CACHE[$cmd]="1"
            else
                COMMAND_CACHE[$cmd]="0"
            fi
        } &
        pids+=($!)
    done

    # 等待所有检查完成
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# 预定义的缓存初始化函数
init_zoxide_cache() {
    if check_command "zoxide"; then
        cache_command "zoxide_init" "zoxide init zsh" 86400  # 24小时缓存
    fi
}

init_fzf_cache() {
    if check_command "fzf"; then
        cache_command "fzf_init" "fzf --zsh" 86400
    fi
}

init_pyenv_cache() {
    if [[ -d "$HOME/.pyenv" ]] && check_command "pyenv"; then
        cache_command "pyenv_init" 'pyenv init -' 86400
    fi
}

init_nvm_cache() {
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        cache_command "nvm_init" 'source "$HOME/.nvm/nvm.sh"' 86400
    fi
}

# 并行初始化所有缓存
parallel_cache_init() {
    echo "初始化智能缓存系统..." >&2

    local pids=()

    # 并行执行各种初始化
    init_zoxide_cache &
    pids+=($!)

    init_fzf_cache &
    pids+=($!)

    init_pyenv_cache &
    pids+=($!)

    init_nvm_cache &
    pids+=($!)

    # 等待所有任务完成
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done

    echo "缓存初始化完成" >&2
}

# 缓存清理函数
clean_cache() {
    local max_age="${1:-604800}"  # 默认7天
    local current_time
    current_time=$(date +%s)

    echo "清理过期缓存..." >&2

    for meta_file in "$CACHE_DIR"/*.meta; do
        [[ -f "$meta_file" ]] || continue

        local cache_time
        cache_time=$(cat "$meta_file" 2>/dev/null || echo "0")

        if (( current_time - cache_time > max_age )); then
            local cache_file="${meta_file%.meta}.cache"
            rm -f "$cache_file" "$meta_file"
            echo "已清理: $(basename "$cache_file")" >&2
        fi
    done
}

# 缓存统计信息
cache_stats() {
    echo "=== 缓存统计 ==="
    echo "缓存目录: $CACHE_DIR"
    echo "缓存版本: $CACHE_VERSION"
    echo "缓存文件数量: $(find "$CACHE_DIR" -name "*.cache" | wc -l)"
    echo "总缓存大小: $(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)"
    echo ""

    echo "=== 缓存列表 ==="
    for cache_file in "$CACHE_DIR"/*.cache; do
        [[ -f "$cache_file" ]] || continue

        local key
        key=$(basename "$cache_file" .cache)
        local meta_file="$CACHE_DIR/${key}.meta"
        local size
        size=$(du -h "$cache_file" 2>/dev/null | cut -f1)
        local age=""

        if [[ -f "$meta_file" ]]; then
            local cache_time
            cache_time=$(cat "$meta_file" 2>/dev/null || echo "0")
            local current_time
            current_time=$(date +%s)
            local age_seconds=$((current_time - cache_time))
            age=" (${age_seconds}s ago)"
        fi

        echo "  $key: $size$age"
    done
}

# 如果直接执行此脚本，显示帮助
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        "init")
            parallel_cache_init
            ;;
        "clean")
            clean_cache "${2:-}"
            ;;
        "stats")
            cache_stats
            ;;
        "help"|*)
            echo "用法: $0 {init|clean|stats|help}"
            echo "  init  - 初始化所有缓存"
            echo "  clean - 清理过期缓存"
            echo "  stats - 显示缓存统计"
            echo "  help  - 显示此帮助"
            ;;
    esac
fi

# 导出核心函数
export -f cache_command check_command batch_check_commands
