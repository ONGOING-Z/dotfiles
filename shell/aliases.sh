#!/usr/bin/env bash
# ============================================================================
# Shell 别名定义 - 提升命令行效率
# ============================================================================

# -----------------------------------------------------------------------------
# 基础命令增强
# -----------------------------------------------------------------------------

# ls 系列
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -ltr'              # 按时间排序
alias lh='ls -lh'               # 人类可读大小
alias ld='ls -d */'             # 只显示目录

# 安全操作
alias rm='rm -i'                # 删除前确认
alias cp='cp -i'                # 覆盖前确认
alias mv='mv -i'                # 覆盖前确认

# 目录操作
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'               # 返回上一个目录

# 创建目录
alias mkdir='mkdir -p'          # 自动创建父目录
alias md='mkdir -p'

# -----------------------------------------------------------------------------
# Git 增强
# -----------------------------------------------------------------------------

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a -m'
alias gp='git push'
alias gpu='git push -u origin HEAD'
alias gl='git pull'
alias gd='git diff'
alias gdc='git diff --cached'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glog='git log --oneline --graph --decorate'
alias gloga='git log --oneline --graph --decorate --all'
alias greset='git reset --hard HEAD'
alias gclean='git clean -fd'
alias gstash='git stash'
alias gpop='git stash pop'

# Git 工作流
alias gflow='git flow'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gr='git rebase'
alias gri='git rebase -i'
alias grc='git rebase --continue'
alias gra='git rebase --abort'

# -----------------------------------------------------------------------------
# Docker 相关
# -----------------------------------------------------------------------------

alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -q)'
alias dprune='docker system prune -af'

# -----------------------------------------------------------------------------
# 系统管理
# -----------------------------------------------------------------------------

# 进程管理
alias psg='ps aux | grep -v grep | grep -i'
alias port='netstat -tulanp | grep'
alias killport='function _killport() { lsof -ti :$1 | xargs kill -9; }; _killport'

# 系统信息
alias meminfo='free -h'
alias cpuinfo='lscpu'
alias diskinfo='df -h'
alias myip='curl -s ifconfig.me'
alias localip='ifconfig | grep -Eo "inet (addr:)?([0-9]*\.){3}[0-9]*" | grep -Eo "([0-9]*\.){3}[0-9]*" | grep -v "127.0.0.1"'

# 服务管理 (systemd)
alias sysstart='sudo systemctl start'
alias sysstop='sudo systemctl stop'
alias sysrestart='sudo systemctl restart'
alias sysstatus='sudo systemctl status'
alias sysenable='sudo systemctl enable'
alias sysdisable='sudo systemctl disable'

# -----------------------------------------------------------------------------
# 开发工具
# -----------------------------------------------------------------------------

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias pipreq='pip freeze > requirements.txt'
alias pipinstall='pip install -r requirements.txt'

# Node.js
alias ni='npm install'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nrd='npm run dev'

# 通用构建
alias m='make'
alias mc='make clean'
alias mca='make clean all'

# -----------------------------------------------------------------------------
# 文件操作
# -----------------------------------------------------------------------------

# 快速编辑
alias v='vim'
alias vi='vim'
alias nv='nvim'
alias sv='sudo vim'
alias edit='${EDITOR:-vim}'

# 查找文件
alias ff='find . -type f -name'
alias fd='find . -type d -name'
alias fgrep='grep -r'

# 压缩解压
alias targz='tar -czf'
alias tarxz='tar -xzf'
alias zip='zip -r'

# -----------------------------------------------------------------------------
# 网络工具
# -----------------------------------------------------------------------------

alias ping='ping -c 5'
alias fastping='ping -c 100 -i 0.2'
alias ports='netstat -tulanp'
alias listen='lsof -P -i -n'
alias openports='netstat -nape --inet'

# HTTP 请求
alias get='curl -X GET'
alias post='curl -X POST'
alias put='curl -X PUT'
alias delete='curl -X DELETE'
alias headers='curl -I'

# -----------------------------------------------------------------------------
# macOS 专用
# -----------------------------------------------------------------------------

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Homebrew
    alias brewup='brew update && brew upgrade && brew cleanup'
    alias brewinfo='brew info'
    alias brewsearch='brew search'
    
    # macOS 工具
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
    alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'
    alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'
    
    # 应用管理
    alias ios='open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'
    alias watchos='open /Applications/Xcode.app/Contents/Developer/Applications/Simulator\ \(Watch\).app'
fi

# -----------------------------------------------------------------------------
# Linux 专用
# -----------------------------------------------------------------------------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # 包管理
    alias aptup='sudo apt update && sudo apt upgrade'
    alias aptsearch='apt search'
    alias aptinstall='sudo apt install'
    alias aptremove='sudo apt remove'
    alias aptclean='sudo apt autoremove && sudo apt autoclean'
    
    # 系统管理
    alias reboot='sudo reboot'
    alias poweroff='sudo poweroff'
    alias suspend='sudo pm-suspend'
fi

# -----------------------------------------------------------------------------
# 实用函数
# -----------------------------------------------------------------------------

# 创建目录并进入
mkcd() {
    mkdir -p "$@" && cd "$_"
}

# 解压任意压缩文件
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' 无法解压" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 快速备份文件
backup() {
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# 查看文件大小并排序
ducks() {
    du -cks * | sort -rn | head -11
}

# 计算文件数量
count() {
    find "${1:-.}" -type f | wc -l
}

# 显示 PATH 变量（每行一个）
path() {
    echo $PATH | tr ':' '\n'
}

# 快速查看 CSV
csv() {
    column -t -s ',' "$@" | less -S
}

# 天气查询
weather() {
    curl -s "wttr.in/${1:-Beijing}?lang=zh"
}

# 查看端口占用
whoport() {
    lsof -i :$1
}

# Git 仓库统计
gitstats() {
    git log --author="$1" --pretty=tformat: --numstat | \
    awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "增加行数: %s, 删除行数: %s, 总行数: %s\n", add, subs, loc }'
}

# 查找大文件
bigfiles() {
    find . -type f -size +${1:-100}M -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
}

# -----------------------------------------------------------------------------
# 快捷命令
# -----------------------------------------------------------------------------

# 重新加载配置
alias reload='source ~/.bashrc 2>/dev/null || source ~/.zshrc'
alias rl='reload'

# 清屏
alias c='clear'
alias cls='clear'

# 退出
alias q='exit'
alias quit='exit'

# 历史命令
alias h='history'
alias hgrep='history | grep'

# 时间日期
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias today='date +"%Y-%m-%d"'

# 编辑配置
alias zshrc='${EDITOR:-vim} ~/.zshrc'
alias bashrc='${EDITOR:-vim} ~/.bashrc'
alias vimrc='${EDITOR:-vim} ~/.vimrc'
alias tmuxconf='${EDITOR:-vim} ~/.tmux.conf'
alias gitconfig='${EDITOR:-vim} ~/.gitconfig'

# Dotfiles 管理
alias dotfiles='cd ~/dotfiles'
alias dotup='cd ~/dotfiles && git pull && ./install'
alias dothealth='cd ~/dotfiles && ./install --health-check'

# -----------------------------------------------------------------------------
# 加载本地别名（如果存在）
# -----------------------------------------------------------------------------

if [ -f ~/.aliases.local ]; then
    source ~/.aliases.local
fi