#!/usr/bin/env bash
# ============================================================================
# Shell 函数库 - 实用工具函数
# ============================================================================

# -----------------------------------------------------------------------------
# 文件和目录操作
# -----------------------------------------------------------------------------

# 创建并进入目录
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 向上跳转多级目录
up() {
    local d=""
    limit=$1
    for ((i=1; i <= limit; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

# 交换两个文件
swap() {
    local TMPFILE=tmp.$$
    [ $# -ne 2 ] && echo "用法: swap 文件1 文件2" && return 1
    [ ! -e $1 ] && echo "错误: $1 不存在" && return 1
    [ ! -e $2 ] && echo "错误: $2 不存在" && return 1
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

# 移动文件到回收站而不是删除
trash() {
    local trash_dir="${HOME}/.Trash"
    mkdir -p "$trash_dir"
    for item in "$@"; do
        echo "移动 $item 到回收站"
        mv "$item" "${trash_dir}/$(basename $item).$(date +%Y%m%d-%H%M%S)"
    done
}

# 查看并选择性恢复回收站文件
untrash() {
    local trash_dir="${HOME}/.Trash"
    if [ ! -d "$trash_dir" ]; then
        echo "回收站为空"
        return 1
    fi
    
    echo "回收站内容:"
    ls -la "$trash_dir"
    echo ""
    echo "输入要恢复的文件名（包含时间戳）:"
    read filename
    
    if [ -f "$trash_dir/$filename" ]; then
        # 去除时间戳
        local original_name=$(echo $filename | sed 's/\.[0-9]\{8\}-[0-9]\{6\}$//')
        mv "$trash_dir/$filename" "./$original_name"
        echo "已恢复: $original_name"
    else
        echo "文件不存在: $filename"
    fi
}

# -----------------------------------------------------------------------------
# Git 辅助函数
# -----------------------------------------------------------------------------

# Git 初始化并首次提交
ginit() {
    git init
    git add .
    git commit -m "Initial commit"
}

# 创建 .gitignore
gignore() {
    if [ $# -eq 0 ]; then
        echo "用法: gignore <语言/框架>"
        echo "例如: gignore python node java"
        return 1
    fi
    
    for lang in "$@"; do
        curl -sL "https://www.gitignore.io/api/$lang" >> .gitignore
    done
    echo "已创建 .gitignore"
}

# 快速提交并推送
gquick() {
    local message="${1:-Quick commit}"
    git add .
    git commit -m "$message"
    git push
}

# 撤销最后的提交
gundo() {
    git reset --soft HEAD~1
}

# 查看 Git 仓库大小
gsize() {
    git rev-list --objects --all | 
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
    sed -n 's/^blob //p' |
    sort --numeric-sort --key=2 |
    cut -c 1-12,41- |
    numfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}

# 清理 Git 仓库
gcleanup() {
    git remote prune origin
    git gc --aggressive --prune=now
    git repack -a -d --depth=250 --window=250
}

# -----------------------------------------------------------------------------
# 开发工具函数
# -----------------------------------------------------------------------------

# Python 虚拟环境管理
pyenv() {
    case "$1" in
        create)
            python3 -m venv "${2:-venv}"
            echo "虚拟环境已创建: ${2:-venv}"
            ;;
        activate)
            source "${2:-venv}/bin/activate"
            ;;
        deactivate)
            deactivate 2>/dev/null || echo "没有激活的虚拟环境"
            ;;
        delete)
            rm -rf "${2:-venv}"
            echo "虚拟环境已删除: ${2:-venv}"
            ;;
        *)
            echo "用法: pyenv [create|activate|deactivate|delete] [环境名]"
            ;;
    esac
}

# 快速创建项目模板
project() {
    local project_type=$1
    local project_name=$2
    
    if [ -z "$project_name" ]; then
        echo "用法: project <类型> <项目名>"
        echo "支持的类型: python, node, go, rust"
        return 1
    fi
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    case "$project_type" in
        python)
            touch README.md requirements.txt .gitignore
            mkdir -p src tests docs
            echo "# $project_name" > README.md
            echo "pytest\npytest-cov\nblack\nflake8" > requirements-dev.txt
            gignore python > .gitignore
            ;;
        node)
            npm init -y
            touch README.md .gitignore
            mkdir -p src tests docs
            echo "# $project_name" > README.md
            gignore node > .gitignore
            ;;
        go)
            go mod init "$project_name"
            touch README.md .gitignore
            mkdir -p cmd pkg internal
            echo "# $project_name" > README.md
            gignore go > .gitignore
            ;;
        rust)
            cargo init
            touch README.md
            echo "# $project_name" > README.md
            ;;
        *)
            echo "不支持的项目类型: $project_type"
            cd ..
            rmdir "$project_name"
            return 1
            ;;
    esac
    
    git init
    echo "项目已创建: $project_name (类型: $project_type)"
}

# -----------------------------------------------------------------------------
# 系统管理函数
# -----------------------------------------------------------------------------

# 查看占用最多内存的进程
topmem() {
    ps aux | sort -nk 4 | tail -${1:-10}
}

# 查看占用最多 CPU 的进程
topcpu() {
    ps aux | sort -nk 3 | tail -${1:-10}
}

# 监控日志文件
tailf() {
    tail -f "$@" | awk '
        /ERROR/ {print "\033[31m" $0 "\033[0m"; next}
        /WARN/  {print "\033[33m" $0 "\033[0m"; next}
        /INFO/  {print "\033[32m" $0 "\033[0m"; next}
        {print $0}
    '
}

# 查找并杀死进程
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# 系统信息概览
sysinfo() {
    echo "=== 系统信息 ==="
    echo "主机名: $(hostname)"
    echo "系统: $(uname -s) $(uname -r)"
    echo "发行版: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'N/A')"
    echo ""
    echo "=== CPU 信息 ==="
    echo "CPU: $(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 || sysctl -n machdep.cpu.brand_string)"
    echo "核心数: $(nproc 2>/dev/null || sysctl -n hw.ncpu)"
    echo ""
    echo "=== 内存信息 ==="
    free -h 2>/dev/null || vm_stat | grep -E '^(Pages (free|active|inactive|speculative|wired)|File-backed)'
    echo ""
    echo "=== 磁盘信息 ==="
    df -h | grep -E '^/dev/'
    echo ""
    echo "=== 网络信息 ==="
    echo "本地 IP: $(ip -4 addr 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1 || ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1)"
    echo "公网 IP: $(curl -s ifconfig.me)"
}

# -----------------------------------------------------------------------------
# 网络工具函数
# -----------------------------------------------------------------------------

# 测试网站响应时间
pingweb() {
    curl -o /dev/null -s -w "DNS查询: %{time_namelookup}s\n连接时间: %{time_connect}s\n传输时间: %{time_total}s\n" "$1"
}

# 获取网站 SSL 证书信息
sslinfo() {
    echo | openssl s_client -showcerts -servername "$1" -connect "$1:443" 2>/dev/null | openssl x509 -inform pem -noout -text
}

# 简单的端口扫描
portscan() {
    local host=$1
    local start_port=${2:-1}
    local end_port=${3:-1000}
    
    echo "扫描 $host 端口 $start_port-$end_port..."
    for port in $(seq $start_port $end_port); do
        (echo >/dev/tcp/$host/$port) &>/dev/null && echo "端口 $port 开放"
    done
}

# 下载整个网站
dlweb() {
    wget --recursive --no-clobber --page-requisites --html-extension --convert-links --restrict-file-names=windows --domains "$1" --no-parent "$1"
}

# -----------------------------------------------------------------------------
# 实用工具函数
# -----------------------------------------------------------------------------

# 计算器
calc() {
    echo "$*" | bc -l
}

# 生成随机密码
genpass() {
    local length=${1:-16}
    openssl rand -base64 48 | tr -d "=+/" | cut -c1-$length
}

# 生成二维码
qrcode() {
    if command -v qrencode >/dev/null 2>&1; then
        qrencode -o - -t UTF8 "$1"
    else
        echo "请先安装 qrencode: brew install qrencode 或 apt install qrencode"
    fi
}

# 查看 JSON 格式化
jsonview() {
    if [ -f "$1" ]; then
        cat "$1" | python -m json.tool | less
    else
        echo "$1" | python -m json.tool | less
    fi
}

# 简单的笔记系统
note() {
    local note_dir="${HOME}/.notes"
    mkdir -p "$note_dir"
    
    case "$1" in
        add|a)
            shift
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$note_dir/notes.txt"
            echo "笔记已添加"
            ;;
        list|l)
            if [ -f "$note_dir/notes.txt" ]; then
                cat "$note_dir/notes.txt" | less
            else
                echo "没有笔记"
            fi
            ;;
        search|s)
            shift
            grep -i "$*" "$note_dir/notes.txt"
            ;;
        edit|e)
            ${EDITOR:-vim} "$note_dir/notes.txt"
            ;;
        *)
            echo "用法: note [add|list|search|edit] [内容]"
            ;;
    esac
}

# 番茄工作法计时器
pomodoro() {
    local work_time=${1:-25}
    local break_time=${2:-5}
    
    echo "开始 $work_time 分钟工作时间..."
    sleep $((work_time * 60))
    
    # 播放提示音（如果可能）
    if command -v afplay >/dev/null 2>&1; then
        afplay /System/Library/Sounds/Glass.aiff
    elif command -v paplay >/dev/null 2>&1; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga
    fi
    
    echo "工作时间结束！开始 $break_time 分钟休息..."
    sleep $((break_time * 60))
    
    echo "休息结束！"
}

# -----------------------------------------------------------------------------
# 帮助函数
# -----------------------------------------------------------------------------

# 显示所有自定义函数
functions_help() {
    echo "=== 文件和目录操作 ==="
    echo "mkcd <目录>         - 创建并进入目录"
    echo "up <层数>           - 向上跳转多级目录"
    echo "swap <文件1> <文件2> - 交换两个文件"
    echo "trash <文件>        - 移动到回收站"
    echo "untrash             - 恢复回收站文件"
    echo ""
    echo "=== Git 辅助 ==="
    echo "ginit               - Git 初始化并首次提交"
    echo "gignore <语言>      - 创建 .gitignore"
    echo "gquick <消息>       - 快速提交并推送"
    echo "gundo               - 撤销最后的提交"
    echo "gsize               - 查看仓库大小"
    echo "gcleanup            - 清理仓库"
    echo ""
    echo "=== 开发工具 ==="
    echo "pyenv <操作>        - Python 虚拟环境管理"
    echo "project <类型> <名> - 创建项目模板"
    echo ""
    echo "=== 系统管理 ==="
    echo "topmem [数量]       - 查看占用内存最多的进程"
    echo "topcpu [数量]       - 查看占用 CPU 最多的进程"
    echo "tailf <文件>        - 彩色监控日志"
    echo "fkill               - 查找并杀死进程"
    echo "sysinfo             - 系统信息概览"
    echo ""
    echo "=== 网络工具 ==="
    echo "pingweb <网址>      - 测试网站响应时间"
    echo "sslinfo <域名>      - 查看 SSL 证书信息"
    echo "portscan <主机>     - 端口扫描"
    echo ""
    echo "=== 实用工具 ==="
    echo "calc <表达式>       - 计算器"
    echo "genpass [长度]      - 生成随机密码"
    echo "qrcode <文本>       - 生成二维码"
    echo "jsonview <文件/文本> - 查看格式化 JSON"
    echo "note <操作>         - 简单笔记系统"
    echo "pomodoro [工作] [休息] - 番茄工作法计时器"
}

# -----------------------------------------------------------------------------
# 加载本地函数（如果存在）
# -----------------------------------------------------------------------------

if [ -f ~/.functions.local ]; then
    source ~/.functions.local
fi