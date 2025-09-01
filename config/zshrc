# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# bash aliases
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# shell functions
if [ -f "$HOME/dotfiles/shell/functions.sh" ]; then
    . "$HOME/dotfiles/shell/functions.sh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export TERM="xterm-256color"

# Skip heavy init for non-interactive shells
case $- in
  *i*) ;; # interactive
  *) return ;; # non-interactive
esac
if [ -f "$HOME/.zplug/init.zsh" ]; then
  . "$HOME/.zplug/init.zsh"
fi

# Optional: quick profiling (enable with ZSH_PROFILE=1)
if [ "${ZSH_PROFILE:-0}" = "1" ]; then
  zmodload zsh/zprof 2>/dev/null || true
fi

# Light lazy-load example: defer loading k and git-open until used
_lazy_source() {
  emulate -L zsh
  setopt extended_glob
  local plugin="$1"
  shift
  for cmd in "$@"; do
    eval "${cmd}() { unfunction $cmd; source $plugin; $cmd \"$@\" }"
  done
}

# Detect OS
OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Options
setopt correct                                                  # Auto correct mistakes
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# if you enable the autosuggestions, turn it on.
DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

ZSH_MANAGER=${ZSH_MANAGER:-auto} # auto|ohmyzsh|zplug

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    zsh-autosuggestions
    extract
    # z (replaced by zoxide if available)
    colored-man-pages # 彩版man page
    web-search # open search engine in cli by key words
    #git-open # open remote repo address
    fzf
    fzf-tab
)
# use x to unpack the package

if [ "$ZSH_MANAGER" = "ohmyzsh" ] || { [ "$ZSH_MANAGER" = "auto" ] && [ -d "$ZSH" ]; }; then
  source $ZSH/oh-my-zsh.sh
fi

# Prefer zoxide over z if available
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  z() { local dest; dest="$(zoxide query -i "$@")" || return; [ -n "$dest" ] && builtin cd -- "$dest"; }
  alias zi='zoxide query -i'
  alias za='zoxide add'
  alias cd='zoxide cd'
else
  # Fallback: prompt to install zoxide on first use of z/zi when brew is available
  _Z_FALLBACK_PROMPTED=0
  unalias z 2>/dev/null || true
  unalias zi 2>/dev/null || true
  unalias za 2>/dev/null || true
  z() {
    if command -v zoxide >/dev/null 2>&1; then
      local dest; dest="$(zoxide query -i "$@")" || return; [ -n "$dest" ] && builtin cd -- "$dest"; return
    fi
    if [ "${_Z_FALLBACK_PROMPTED:-0}" = "0" ] && command -v brew >/dev/null 2>&1; then
      printf 'zoxide is not installed. Install via Homebrew now? [y/N]: '
      if read -q; then
        echo; brew install zoxide || true
      else
        echo
      fi
      _Z_FALLBACK_PROMPTED=1
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
        local dest; dest="$(zoxide query -i "$@")" || return; [ -n "$dest" ] && builtin cd -- "$dest"; return
      fi
    fi
    echo 'zoxide is not installed. Hint: brew install zoxide'
    return 1
  }
  alias zi=z
  __z_no_zoxide_za() { echo 'zoxide is not installed. Hint: brew install zoxide'; return 1; }
  alias za=__z_no_zoxide_za
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

######## Plugin ###### by zplug (enabled when manager=zplug or auto with zplug present)
if [ "$ZSH_MANAGER" = "zplug" ] || { [ "$ZSH_MANAGER" = "auto" ] && [ -f "$HOME/.zplug/init.zsh" ]; }; then
  zplug "zsh-users/zsh-syntax-highlighting", defer:2
  zplug "b4b4r07/enhancd", use:init.sh  # codespell: ignore plugin name
  zplug "zsh-users/zsh-history-substring-search"
fi

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#source ~/.bash_profile # 继承本机.bash_profile

#alias vim='gvim -v'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"




# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

################ Aliases ###################
# tail log
alias tail="_tail_log"
_tail_log() {
  "tail" $@ | perl -pe 's/(INFO)/\e[0;32m$1\e[0m/g,s/(WARN)/\e[0;33m$1\e[0m/g,s/(ERROR)/\e[1;31m$1\e[0m/g'
}

# tool - mat: it can check harmful info of pictures
# -c: check
# -d: display
alias clean_pic="mat"

alias bfg="java -jar /media/$USER/New_Disk/test6/bfg-1.14.0.jar"
alias gbook="gitbook"
alias mj="makejava"


############################################

################ self defined functions ###################
#
# 有道词典cli查询
# pre condition: sudo apt install w3m
youdao() {
if [ -z "$1" ]
then
echo 'Usage youdao <word>'
else
    w3m -dump "http://dict.youdao.com/search?q=$1"
fi
}

###########################################################

# Set java environment (guarded by existence)
if [ -d "/Library/Java/JavaVirtualMachines" ]; then
  JAVA_HOME=${JAVA_HOME:-"/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"}
elif [ -d "/usr/lib/jvm" ]; then
  JAVA_HOME=${JAVA_HOME:-"/usr/lib/jvm/default-java"}
fi
if [ -n "$JAVA_HOME" ] && [ -d "$JAVA_HOME" ]; then
  CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
  export JAVA_HOME CLASSPATH
fi

# Set maven environment
# M2_HOME指向Maven的安装目录
export M2_HOME=${M2_HOME:-/usr/local/apache-maven-3.8.4}
if [ -d "$M2_HOME" ]; then
  export PATH=$PATH:${M2_HOME}/bin
fi
if command -v git >/dev/null 2>&1; then
  : # git already in PATH
elif [ -d "/usr/local/git/bin" ]; then
  export PATH=$PATH:/usr/local/git/bin
fi

# This prevents duplicates of PATH variables.
typeset -U PATH

# ban auto correct
unsetopt correct_all

# Q: How to share PATHs in .zshrc, .bashrc, .bash_profile?
# A: One way is to source the ~/.bashrc in your ~/.zshrc file.
# 下面这句加进去之后新起一个终端会出问题！！！
#. ~/.bashrc

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# 21-9-5 Sun the sdkman is a tool that installs software like apache tomcat.
export SDKMAN_DIR="/home/${USER}/.sdkman"
[[ -s "/home/${USER}/.sdkman/bin/sdkman-init.sh" ]] && source "/home/${USER}/.sdkman/bin/sdkman-init.sh"

###################################################################################################
# place this the end of file. !!!
# Install plugins if there are plugins that have not been installed
if [ "$ZSH_MANAGER" = "zplug" ] || { [ "$ZSH_MANAGER" = "auto" ] && [ -f "$HOME/.zplug/init.zsh" ]; }; then
  if ! zplug check --verbose; then
      printf "Install? [y/N]: "
      if read -q; then
          echo; zplug install
      fi
  fi
  zplug load
fi

# 使用国内二进制包镜像
if [ "$OS_NAME" = "darwin" ]; then
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
  export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
  export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
fi

export GOPATH=$HOME/Documents/github/go


export TOMCAT_PATH=${TOMCAT_PATH:-/usr/local/apache-tomcat-10.1.18}
if [ -d "$TOMCAT_PATH/bin" ]; then
  export PATH=$PATH:$TOMCAT_PATH/bin
fi

alias cat="bat"

#docker
alias dms="docker images"
alias dm="docker image"
alias dcl="docker container ls -a"

# Search helpers
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g !.git'
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*"'
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --preview-window=right,60%:wrap'

# High-contrast preview for bat
if command -v bat >/dev/null 2>&1; then
  if [ -z "${BAT_THEME:-}" ]; then
    if bat --list-themes 2>/dev/null | grep -qx "TwoDark"; then
      export BAT_THEME="TwoDark"
    else
      export BAT_THEME="GitHub"
    fi
  fi
fi

_fzf_preview() {
  local file="$1"
  if command -v bat >/dev/null 2>&1; then
    bat --style=numbers,grid --paging=never --color=always --line-range=:500 "$file"
  else
    sed -n '1,500p' "$file"
  fi
}

ff() {
  local file
  local filter="${1:-}"
  local base_cmd="${FZF_DEFAULT_COMMAND:-fd --type f --hidden --follow --exclude .git}"
  if [ -n "$filter" ]; then
    base_cmd="$base_cmd --extension $filter"
  fi
  file="$(eval "$base_cmd" | fzf --preview '_fzf_preview {}')" || return
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

f() {
  local query="$1"
  local type_filter="${2:-}"
  local sel file line
  local rg_cmd="rg --line-number --no-heading --hidden --smart-case"
  if [ -n "$type_filter" ]; then
    rg_cmd="$rg_cmd --type $type_filter"
  fi
  sel="$(eval "$rg_cmd \"$query\"" | fzf --delimiter : --nth=3.. \
            --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1}' \
            --preview-window=right,60%:wrap)" || return
  file="$(printf "%s" "$sel" | cut -d: -f1)"
  line="$(printf "%s" "$sel" | cut -d: -f2)"
  [ -n "$file" ] && ${EDITOR:-vim} +"$line" "$file"
}

alias rgc='rg --smart-case --hidden'
alias rgi='rg --ignore-case --hidden'
alias rgt='rg --type-add web:*.{js,ts,jsx,tsx,vue} --type web --hidden'

# IDE-like ripgrep popup (live reload)
rgp() {
  local RG_PREFIX="rg --line-number --no-heading --hidden --smart-case --color=always"
  local sel file line
  if [ -n "$TMUX" ] && command -v fzf-tmux >/dev/null 2>&1; then
    sel="$(FZF_DEFAULT_COMMAND='' fzf-tmux -p 80%,80% --ansi --disabled --query '' \
            --bind "change:reload:$RG_PREFIX -- {q} || true" \
            --delimiter : --nth=3.. \
            --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1}' \
            --preview-window=right,60%:wrap)" || return
  else
    sel="$(FZF_DEFAULT_COMMAND='' fzf --ansi --disabled --query '' \
            --bind "change:reload:$RG_PREFIX -- {q} || true" \
            --delimiter : --nth=3.. \
            --preview 'bat --color=always --paging=never --style=numbers,grid --highlight-line {2} {1}' \
            --preview-window=right,60%:wrap)" || return
  fi
  file="$(printf "%s" "$sel" | cut -d: -f1)"
  line="$(printf "%s" "$sel" | cut -d: -f2)"
  [ -n "$file" ] && ${EDITOR:-vim} +"$line" "$file"
}

export GPG_TTY=$(tty)
if [ "$OS_NAME" = "darwin" ] && [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# enable homebrew auto upgrade(each week)
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_AUTO_UPDATE_SECS=604800
