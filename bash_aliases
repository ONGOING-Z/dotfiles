# Git
alias gs="git status"
alias ga="git add"
alias gd="git diff"
alias gb="git branch"
alias gl="git log"
alias gcm="git commit -m "
alias undo="git reset --soft head^" # 让头指针指向上次的提交，并且不改变暂存区和工作区。

# Application
alias gdb='gdb -q'
# at macos system, pbcopy/pbpaste are builtin tools.
#alias pbcopy='xclip -selection clipboard'
#alias pbpaste='xclip -selection clipboard -o'
alias dr='docker'
alias dri='docker images'
alias pmanim='python3 -m manim'
alias pc='proxychains'
alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
alias pycharm="/Applications/PyCharm\ CE.app/Contents/MacOS/pycharm"
alias ideace="/Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea"

# brew install m-cli
alias wof="m wifi off"
alias won="m wifi on"

# tar
alias untar='tar -zxvf'

# 当前文件夹大小
alias cds='du -hs .' # cds: current directory size

# localdate 2021-06-23
alias localdate='date +%Y-%m-%d'
# localtime, 12:50
alias localtime='date +%H:%M'

alias tree='tree -aC' # a: all files, C: color
