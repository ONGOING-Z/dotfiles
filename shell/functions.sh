#!/usr/bin/env bash
# Shell 函数集合
# 提供常用的 shell 函数，可在 bashrc 或 zshrc 中 source

# ============================================================================
# Docker 辅助函数
# ============================================================================

# 快速进入容器
denter() {
    local container="${1:-}"
    if [ -z "$container" ]; then
        echo "用法: denter <容器名或ID>"
        echo "可用容器:"
        docker ps --format "table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Status}}"
        return 1
    fi

    # 尝试使用 bash，如果失败则使用 sh
    docker exec -it "$container" /bin/bash 2>/dev/null || \
    docker exec -it "$container" /bin/sh
}

# 清理 Docker 资源
dclean() {
    echo "清理停止的容器..."
    docker container prune -f
    echo "清理未使用的镜像..."
    docker image prune -f
    echo "清理未使用的网络..."
    docker network prune -f
    echo "清理未使用的卷..."
    docker volume prune -f
}

# 查看容器资源使用
dstats() {
    docker stats --no-stream
}

# 停止所有容器
dstopall() {
    local containers=$(docker ps -q)
    if [ -n "$containers" ]; then
        echo "停止所有运行中的容器..."
        docker stop $containers
    else
        echo "没有运行中的容器"
    fi
}

# ============================================================================
# Git 辅助函数
# ============================================================================

# 快速提交
gquick() {
    local message="${1:-Quick commit}"
    git add -A && git commit -m "$message" && git push
}

# 切换到最近的分支
grecent() {
    git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | head -10
}

# 删除合并的分支
gclean() {
    git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
}

# ============================================================================
# 文件和目录操作
# ============================================================================

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 备份文件
backup() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup.$(date +%Y%m%d-%H%M%S)"
        echo "已备份: $1"
    else
        echo "文件不存在: $1"
    fi
}

# 解压任意压缩文件
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.tar.xz) tar xJf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar e "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' 无法解压" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# ============================================================================
# 网络和系统
# ============================================================================

# 查看端口占用
port() {
    local port="${1:-}"
    if [ -z "$port" ]; then
        echo "用法: port <端口号>"
        return 1
    fi

    if command -v lsof &>/dev/null; then
        sudo lsof -i :"$port"
    elif command -v netstat &>/dev/null; then
        sudo netstat -tlnp | grep :"$port"
    else
        echo "需要安装 lsof 或 netstat"
    fi
}

# 查看公网 IP
myip() {
    echo "内网 IP:"
    if command -v ip &>/dev/null; then
        ip addr show | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+' | grep -v 127.0.0.1
    elif command -v ifconfig &>/dev/null; then
        ifconfig | grep -oE 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -oE '([0-9]*\.){3}[0-9]*' | grep -v 127.0.0.1
    fi

    echo -e "\n公网 IP:"
    curl -s ifconfig.me || curl -s icanhazip.com || curl -s ipinfo.io/ip
    echo
}

# ============================================================================
# 开发工具
# ============================================================================

# Python 虚拟环境
venv() {
    local name="${1:-venv}"
    if [ ! -d "$name" ]; then
        python3 -m venv "$name"
        echo "虚拟环境已创建: $name"
    fi
    source "$name/bin/activate"
}

# 查找并删除 Python 缓存
pyclean() {
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
    find . -type f -name "*.pyc" -delete 2>/dev/null
    find . -type f -name "*.pyo" -delete 2>/dev/null
    echo "Python 缓存已清理"
}

# Node.js 清理
nodeclean() {
    find . -name "node_modules" -type d -prune -exec rm -rf {} + 2>/dev/null
    find . -name "package-lock.json" -type f -delete 2>/dev/null
    echo "Node.js 依赖已清理"
}

# ============================================================================
# 实用工具
# ============================================================================

# 彩色输出 man 页面
man() {
    env \
        LESS_TERMCAP_mb=$'\e[1;31m' \
        LESS_TERMCAP_md=$'\e[1;31m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[1;44;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[1;32m' \
        man "$@"
}

# 计算器
calc() {
    echo "$*" | bc -l
}

# 生成随机密码
genpass() {
    local length="${1:-16}"
    openssl rand -base64 "$length" | head -c "$length"
    echo
}

# 显示文件树（带颜色和忽略）
tree() {
    command tree -aC -I 'node_modules|.git|__pycache__|*.pyc' "$@"
}

# ============================================================================
# 加载提示
# ============================================================================

# 显示可用函数
show_functions() {
    echo "可用的 Shell 函数:"
    echo ""
    echo "Docker:"
    echo "  denter <容器>  - 快速进入容器"
    echo "  dclean        - 清理 Docker 资源"
    echo "  dstats        - 查看容器资源使用"
    echo "  dstopall      - 停止所有容器"
    echo ""
    echo "Git:"
    echo "  gquick <消息> - 快速提交并推送"
    echo "  grecent       - 显示最近的分支"
    echo "  gclean        - 删除已合并的分支"
    echo ""
    echo "文件操作:"
    echo "  mkcd <目录>   - 创建并进入目录"
    echo "  backup <文件> - 备份文件"
    echo "  extract <文件> - 解压文件"
    echo ""
    echo "网络:"
    echo "  port <端口>   - 查看端口占用"
    echo "  myip          - 显示 IP 地址"
    echo ""
    echo "开发:"
    echo "  venv [名称]   - 创建/激活 Python 虚拟环境"
    echo "  pyclean       - 清理 Python 缓存"
    echo "  nodeclean     - 清理 Node.js 依赖"
    echo ""
    echo "其他:"
    echo "  calc <表达式> - 计算器"
    echo "  genpass [长度] - 生成随机密码"
}

# 如果直接运行脚本，显示帮助
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    show_functions
fi
