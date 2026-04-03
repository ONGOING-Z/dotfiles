#!/usr/bin/env bash
# Shell 延迟加载配置 - 优化启动性能

# 延迟加载函数生成器
lazy_load() {
    local func_name="$1"
    local load_command="$2"
    
    # 创建占位函数
    eval "
    $func_name() {
        # 首次调用时加载真正的函数
        unset -f $func_name
        $load_command
        $func_name \"\$@\"
    }
    "
}

# NVM 延迟加载（与 zshrc 中 NVM_DIR 一致；首次调用 nvm/node/npm 等时再 source）
: "${NVM_DIR:=$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    _nvm_lazy_init="source '$NVM_DIR/nvm.sh' && [ -s '$NVM_DIR/bash_completion' ] && . '$NVM_DIR/bash_completion'"
    lazy_load nvm "$_nvm_lazy_init"
    lazy_load node "$_nvm_lazy_init"
    lazy_load npm "$_nvm_lazy_init"
    lazy_load npx "$_nvm_lazy_init"
    lazy_load yarn "$_nvm_lazy_init"
    unset _nvm_lazy_init
fi

# RVM 延迟加载
if [ -s "$HOME/.rvm/scripts/rvm" ]; then
    export PATH="$PATH:$HOME/.rvm/bin"
    
    lazy_load rvm "source '$HOME/.rvm/scripts/rvm'"
    lazy_load ruby "source '$HOME/.rvm/scripts/rvm'"
    lazy_load gem "source '$HOME/.rvm/scripts/rvm'"
    lazy_load bundle "source '$HOME/.rvm/scripts/rvm'"
fi

# pyenv 延迟加载
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    
    lazy_load pyenv 'eval "$(pyenv init -)"'
    lazy_load python 'eval "$(pyenv init -)"'
    lazy_load pip 'eval "$(pyenv init -)"'
fi

# rbenv 延迟加载
if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    
    lazy_load rbenv 'eval "$(rbenv init -)"'
fi

# Conda 延迟加载
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    lazy_load conda "source '$HOME/miniconda3/etc/profile.d/conda.sh'"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    lazy_load conda "source '$HOME/anaconda3/etc/profile.d/conda.sh'"
fi

# Docker 补全延迟加载（如果存在）
if command -v docker >/dev/null 2>&1; then
    lazy_load _docker_compose_completion 'source /usr/share/bash-completion/completions/docker 2>/dev/null || true'
fi

# kubectl 补全延迟加载
if command -v kubectl >/dev/null 2>&1; then
    lazy_load kubectl 'source <(kubectl completion bash 2>/dev/null || kubectl completion zsh 2>/dev/null)'
fi

# FZF 延迟加载
if [ -f ~/.fzf.bash ] || [ -f ~/.fzf.zsh ]; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    
    # FZF 函数延迟加载
    if [ -n "$BASH_VERSION" ]; then
        lazy_load _fzf_setup_completion 'source ~/.fzf.bash'
    elif [ -n "$ZSH_VERSION" ]; then
        lazy_load _fzf_setup_completion 'source ~/.fzf.zsh'
    fi
fi

# 重量级命令的别名优化
# 只在真正需要时才执行命令

# Git 状态优化
git_status_cached() {
    local cache_file="/tmp/.git_status_cache_$$"
    local cache_time=5  # 缓存5秒
    
    if [ -f "$cache_file" ]; then
        local age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)))
        if [ $age -lt $cache_time ]; then
            cat "$cache_file"
            return
        fi
    fi
    
    git status --porcelain 2>/dev/null | tee "$cache_file"
}

# 优化的提示符函数
git_prompt_info_fast() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        return
    fi
    
    local branch=$(git symbolic-ref -q --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo "detached")
    local status=$(git_status_cached | wc -l | tr -d ' ')
    
    if [ "$status" -gt 0 ]; then
        echo " ($branch *)"
    else
        echo " ($branch)"
    fi
}

# 性能监控函数
shell_startup_time() {
    local shell_name="${1:-$SHELL}"
    local iterations="${2:-10}"
    local total_time=0
    
    echo "测试 $shell_name 启动时间 ($iterations 次迭代)..."
    
    for i in $(seq 1 $iterations); do
        local start_time=$(date +%s%N)
        $shell_name -i -c exit 2>/dev/null
        local end_time=$(date +%s%N)
        local duration=$((($end_time - $start_time) / 1000000))
        total_time=$((total_time + duration))
        echo "  迭代 $i: ${duration}ms"
    done
    
    local avg_time=$((total_time / iterations))
    echo ""
    echo "平均启动时间: ${avg_time}ms"
    
    if [ $avg_time -lt 100 ]; then
        echo "性能: 优秀 ⚡"
    elif [ $avg_time -lt 300 ]; then
        echo "性能: 良好 ✓"
    elif [ $avg_time -lt 500 ]; then
        echo "性能: 一般 ⚠"
    else
        echo "性能: 需要优化 ✗"
    fi
}

# 调试函数 - 分析加载时间
debug_shell_startup() {
    echo "分析 Shell 启动时间..."
    echo "提示: 在 shell 配置文件开头添加以下内容进行详细分析:"
    echo ""
    echo "# Bash:"
    echo "PS4='+ \$(date \"+%s.%N\") \${BASH_SOURCE}:\${LINENO}: '"
    echo "set -x"
    echo ""
    echo "# Zsh:"
    echo "zmodload zsh/zprof"
    echo "# 在文件末尾添加: zprof"
}

# 导出延迟加载标记
export DOTFILES_LAZY_LOAD=1