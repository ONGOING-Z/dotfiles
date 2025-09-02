#!/usr/bin/env bash
# Shell 性能优化配置

# 历史记录优化
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:cd:pwd:exit:clear:history"

# 命令缓存
if [ -n "$BASH_VERSION" ]; then
    # Bash 特定优化
    shopt -s histappend
    shopt -s cmdhist
    shopt -s lithist
    
    # 禁用邮件检查
    unset MAILCHECK
    
    # 命令哈希表优化
    set +h
    hash -r
fi

if [ -n "$ZSH_VERSION" ]; then
    # Zsh 特定优化
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt HIST_FIND_NO_DUPS
    setopt HIST_SAVE_NO_DUPS
    
    # 禁用自动更正
    unsetopt CORRECT
    unsetopt CORRECT_ALL
    
    # 补全系统优化
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path ~/.zsh/cache
    zstyle ':completion:*' accept-exact '*(N)'
    zstyle ':completion:*' squeeze-slashes true
    
    # 限制补全列表大小
    zstyle ':completion:*' list-max-items 20
fi

# PATH 去重和优化
optimize_path() {
    local new_path=""
    local IFS=':'
    local seen=""
    
    for dir in $PATH; do
        # 跳过不存在的目录
        [ ! -d "$dir" ] && continue
        
        # 跳过重复的目录
        case ":$seen:" in
            *":$dir:"*) continue ;;
        esac
        
        seen="$seen:$dir"
        new_path="${new_path:+$new_path:}$dir"
    done
    
    export PATH="$new_path"
}

# 仅在 PATH 变化时优化
if [ "$_LAST_PATH" != "$PATH" ]; then
    optimize_path
    export _LAST_PATH="$PATH"
fi

# 减少 ls 颜色计算开销
if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls --color=auto --group-directories-first'
    export LS_COLORS='di=34:ln=35:ex=32'  # 简化的颜色方案
fi

# Git 性能优化
export GIT_OPTIONAL_LOCKS=0  # 禁用可选的文件锁
export GIT_DIFF_OPTS=-M      # 启用移动检测

# 大型仓库优化
git_optimize_large_repo() {
    git config core.preloadindex true
    git config core.fscache true
    git config gc.auto 256
    git config feature.manyFiles true
}

# 禁用不必要的 Git 功能
if [ -d .git ] || git rev-parse --git-dir >/dev/null 2>&1; then
    # 在大型仓库中禁用某些功能
    local file_count=$(find . -type f 2>/dev/null | head -10000 | wc -l)
    if [ "$file_count" -gt 5000 ]; then
        export GIT_PS1_SHOWDIRTYSTATE=0
        export GIT_PS1_SHOWUNTRACKEDFILES=0
    fi
fi

# 终端优化
if [ -t 1 ]; then
    # 减少终端更新频率
    export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"
    
    # 优化终端大小检测
    shopt -s checkwinsize 2>/dev/null || true
fi

# 编译优化的配置加载器
compile_configs() {
    local config_dir="$HOME/.config/dotfiles/compiled"
    mkdir -p "$config_dir"
    
    # 编译 Zsh 配置
    if [ -n "$ZSH_VERSION" ] && command -v zcompile >/dev/null 2>&1; then
        for file in ~/.zshrc ~/.zprofile ~/.zshenv; do
            [ -f "$file" ] && zcompile "$file" 2>/dev/null
        done
    fi
}

# 性能基准测试
benchmark_shell() {
    local test_file="/tmp/shell_benchmark_$$"
    
    cat > "$test_file" << 'EOF'
# 基准测试脚本
for i in {1..100}; do
    echo "Line $i" >/dev/null
done

# 数组操作测试
arr=()
for i in {1..1000}; do
    arr+=($i)
done

# 字符串操作测试
str=""
for i in {1..100}; do
    str="${str}x"
done

# 函数调用测试
test_func() { echo "$1" >/dev/null; }
for i in {1..100}; do
    test_func "$i"
done
EOF
    
    echo "运行 Shell 性能基准测试..."
    local start_time=$(date +%s%N)
    source "$test_file"
    local end_time=$(date +%s%N)
    local duration=$((($end_time - $start_time) / 1000000))
    
    rm -f "$test_file"
    echo "基准测试完成: ${duration}ms"
    
    if [ $duration -lt 50 ]; then
        echo "Shell 性能: 优秀"
    elif [ $duration -lt 100 ]; then
        echo "Shell 性能: 良好"
    else
        echo "Shell 性能: 需要优化"
    fi
}

# 清理函数 - 移除不需要的环境变量和函数
cleanup_environment() {
    # 移除临时变量
    unset i dir
    
    # 移除一次性函数
    unset -f compile_configs 2>/dev/null || true
    
    # 清理完成标记
    export _DOTFILES_OPTIMIZED=1
}

# 如果还未优化过，执行清理
if [ -z "$_DOTFILES_OPTIMIZED" ]; then
    cleanup_environment
fi