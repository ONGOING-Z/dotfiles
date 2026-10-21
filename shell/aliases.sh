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
alias gl='git log'
alias gd='git diff'
alias gdc='git diff --cached'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
# 重命名分支；可选同步远端（推新名、删旧名）
#   gren <new>              # 重命名当前分支
#   gren <old> <new>        # 重命名指定分支
#   gren -r <new>           # 当前分支 + 同步远端
#   gren -r <old> <new>     # 指定分支 + 同步远端
gren() {
  local sync_remote=0 old new current upstream_remote
  if [ "$1" = "-r" ] || [ "$1" = "--remote" ]; then
    sync_remote=1
    shift
  fi
  case $# in
    1)
      new="$1"
      old=$(git branch --show-current 2>/dev/null) || {
        echo "gren: not on a branch" >&2
        return 1
      }
      ;;
    2)
      old="$1"
      new="$2"
      ;;
    *)
      echo "用法: gren [-r|--remote] <new> | gren [-r|--remote] <old> <new>" >&2
      return 1
      ;;
  esac
  if [ -z "$old" ] || [ -z "$new" ]; then
    echo "gren: old/new branch name required" >&2
    return 1
  fi
  if [ "$old" = "$new" ]; then
    echo "gren: old and new names are identical" >&2
    return 1
  fi
  git rev-parse --verify --quiet "refs/heads/${old}" >/dev/null || {
    echo "gren: local branch '${old}' not found" >&2
    return 1
  }
  if git rev-parse --verify --quiet "refs/heads/${new}" >/dev/null; then
    echo "gren: local branch '${new}' already exists" >&2
    return 1
  fi

  current=$(git branch --show-current 2>/dev/null || true)
  upstream_remote=$(git config --get "branch.${old}.remote" 2>/dev/null || true)

  git branch -m "$old" "$new" || return 1
  echo "gren: ${old} -> ${new}"

  if [ "$sync_remote" -eq 1 ]; then
    local remote="${upstream_remote:-origin}"
    echo "gren: syncing remote '${remote}'..."
    git push -u "$remote" "$new" || return 1
    git push "$remote" --delete "$old" 2>/dev/null || \
      echo "gren: remote branch '${old}' not found or already deleted (ok)"
  elif [ -n "$upstream_remote" ]; then
    echo "gren: tip — had upstream ${upstream_remote}/${old}; sync with:"
    echo "         git push -u ${upstream_remote} ${new} && git push ${upstream_remote} --delete ${old}"
  fi

  # 若改的是当前分支，提示已生效
  if [ "$current" = "$old" ] || [ "$current" = "$new" ]; then
    echo "gren: now on $(git branch --show-current)"
  fi
}

# gren tab 补全：本地分支 + -r/--remote
if [ -n "${ZSH_VERSION:-}" ]; then
  _gren() {
    local -a branches pos
    local w
    # shellcheck disable=SC2296
    branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)"})

    # words[1]=命令；补全到 CURRENT 之前的参数
    for w in "${(@)words[2,CURRENT-1]}"; do
      case "$w" in
        -r|--remote) ;;
        *) pos+=("$w") ;;
      esac
    done

    if (( $#pos == 0 )); then
      compadd -- -r --remote
      compadd -a -- branches
    elif (( $#pos == 1 )); then
      # 新分支名可自由输入；列出已有分支作参考
      compadd -a -- branches
    fi
  }
  if (( $+functions[compdef] )); then
    compdef _gren gren
  fi
elif [ -n "${BASH_VERSION:-}" ]; then
  _gren() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local branches pos_count=0
    local i w
    branches=$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)

    for ((i = 1; i < COMP_CWORD; i++)); do
      w="${COMP_WORDS[i]}"
      case "$w" in
        -r|--remote) ;;
        *) pos_count=$((pos_count + 1)) ;;
      esac
    done

    if [ "$pos_count" -eq 0 ]; then
      COMPREPLY=( $(compgen -W "-r --remote $branches" -- "$cur") )
    elif [ "$pos_count" -eq 1 ]; then
      COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
    else
      COMPREPLY=()
    fi
  }
  complete -F _gren gren
fi

alias glog='git log --oneline --graph --decorate'
alias gloga='git log --oneline --graph --decorate --all'
# 当前分支 vs 指定分支的对称差异（left-right graph）
#   gld <other>     # 例：在 02 上执行 gld 01 → git log --left-right 01...HEAD
# < = 对方有、当前没有；> = 当前有、对方没有
gld() {
  local other current ahead behind
  if [ $# -ne 1 ]; then
    echo "用法: gld <other-branch>" >&2
    return 1
  fi
  other="$1"
  current=$(git branch --show-current 2>/dev/null) || {
    echo "gld: not on a branch" >&2
    return 1
  }
  git rev-parse --verify --quiet "${other}^{commit}" >/dev/null || {
    echo "gld: ref '${other}' not found" >&2
    return 1
  }
  if [ "$other" = "$current" ] || [ "$other" = "HEAD" ]; then
    echo "gld: '${other}' is the current branch" >&2
    return 1
  fi
  ahead=$(git rev-list --count "${other}..HEAD" 2>/dev/null)
  behind=$(git rev-list --count "HEAD..${other}" 2>/dev/null)
  echo "gld: ${other}...${current}  ahead ${ahead} / behind ${behind}"
  echo "     < = only in ${other}   > = only in ${current}"
  if [ "${ahead}" -eq 0 ] && [ "${behind}" -eq 0 ]; then
    echo "(identical)"
    return 0
  fi
  echo ""
  git --no-pager log --oneline --left-right --graph --decorate "${other}...HEAD"
}

# gld tab 补全：本地 + 远端分支
if [ -n "${ZSH_VERSION:-}" ]; then
  _gld() {
    local -a branches
    # shellcheck disable=SC2296
    branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null)"})
    compadd -a -- branches
  }
  if (( $+functions[compdef] )); then
    compdef _gld gld
  fi
elif [ -n "${BASH_VERSION:-}" ]; then
  _gld() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local branches
    branches=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null)
    COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
  }
  complete -F _gld gld
fi

# 当前分支与远端（upstream / origin/<branch>）的差距：commits + 文件 + diff
# < = 本地有、远端没有；> = 远端有、本地没有
glr() {
  local base branch ahead behind
  branch=$(git branch --show-current 2>/dev/null) || {
    echo "glr: not on a branch" >&2
    return 1
  }
  if base=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null); then
    :
  elif git rev-parse --verify --quiet "origin/${branch}" >/dev/null; then
    base="origin/${branch}"
  else
    echo "glr: no remote tracking branch for '${branch}' (try: git fetch && git push -u origin HEAD)" >&2
    return 1
  fi
  ahead=$(git rev-list --count "${base}..HEAD" 2>/dev/null)
  behind=$(git rev-list --count "HEAD..${base}" 2>/dev/null)
  echo "glr: ${branch}...${base}  ahead ${ahead} / behind ${behind}"
  if [ "${ahead}" -eq 0 ] && [ "${behind}" -eq 0 ]; then
    echo "(synced)"
    return 0
  fi
  echo ""
  echo "=== commits ==="
  git --no-pager log --left-right --graph --oneline --decorate "HEAD...${base}"
  if [ "${ahead}" -gt 0 ]; then
    echo ""
    echo "=== local ahead: files ==="
    git --no-pager diff --stat "${base}...HEAD"
    echo ""
    echo "=== local ahead: diff ==="
    git diff "${base}...HEAD"
  fi
  if [ "${behind}" -gt 0 ]; then
    echo ""
    echo "=== remote ahead: files ==="
    git --no-pager diff --stat "HEAD...${base}"
    echo ""
    echo "=== remote ahead: diff ==="
    git diff "HEAD...${base}"
  fi
}
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
killport() {
    if [ -z "${1:-}" ]; then
        echo "Usage: killport <port>" >&2
        return 1
    fi
    lsof -ti ":$1" | xargs kill -9 2>/dev/null || true
}

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

# 天气查询（覆盖 bash_aliases 里的 weather 别名）
unalias weather 2>/dev/null || true
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

# Claude Code
alias cc='claude'
alias cl='claude'
alias cr='claude --resume'
alias cp='claude --print'
alias cpr='claude --project'

# -----------------------------------------------------------------------------
# 加载本地别名（如果存在）
# -----------------------------------------------------------------------------

if [ -f ~/.aliases.local ]; then
    source ~/.aliases.local
fi
