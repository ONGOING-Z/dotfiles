source ~/.zplug/init.zsh
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# bash aliases
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# Path to your oh-my-zsh installation.
export ZSH="/home/${USER}/.oh-my-zsh"
export TERM="xterm-256color"

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

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    zsh-autosuggestions
    extract
    z
    colored-man-pages # 彩版man page
    web-search # open search engine in cli by key words
    git-open # open remote repo address
    fzf
)
# use x to unpack the package

source $ZSH/oh-my-zsh.sh

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

######## Plugin ###### by zplug
zplug "zsh-users/zsh-syntax-highlighting", defer:2
#  a zsh plugin to make listing directory more readable
zplug "supercrabtree/k"
# enhaced cd 
zplug "b4b4r07/enhancd", use:init.sh

zplug "zsh-users/zsh-history-substring-search"
#zplug "paulirish/git-open", as:plugin

######## Plugin ######

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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion




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
alias vim="~/nvim.appimage"


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

# Set java environment
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:/home/${USER}/Desktop/jdbc/mysql-connector-java_8.0.22-1ubuntu16.04_all/usr/share/java/mysql-connector-java-8.0.22.jar
export JAVA_HOME PATH CLASSPATH

# Set maven environment
# M2_HOME指向Maven的安装目录
export M2_HOME=/usr/local/apache-maven-3.3.9

export PATH=$PATH:/usr/local/git/bin:${M2_HOME}/bin

# This prevents duplicates of PATH variables.
typeset -U PATH

# Q: How to share PATHs in .zshrc, .bashrc, .bash_profile?
# A: One way is to source the ~/.bashrc in your ~/.zshrc file.
# 下面这句加进去之后新起一个终端会出问题！！！
#. ~/.bashrc

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# 21-9-5 Sun the sdkman is a tool that install softwares like apache tomcat.
export SDKMAN_DIR="/home/${USER}/.sdkman"
[[ -s "/home/${USER}/.sdkman/bin/sdkman-init.sh" ]] && source "/home/${USER}/.sdkman/bin/sdkman-init.sh"

###################################################################################################
# place this the end of file. !!!
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load
