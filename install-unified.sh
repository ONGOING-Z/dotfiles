#!/usr/bin/env bash
# ============================================================================
# Unified Dotfiles Installer - 统一安装脚本
# 整合了 install 和 install-interactive 的所有功能
# 支持 Gum 增强界面和纯 Bash 降级
# ============================================================================

set -euo pipefail

# ============================================================================
# 基础配置
# ============================================================================

CONFIG="install.conf.yaml"
DOTBOT_DIR="dotbot"
DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# 图标定义
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="➜"
INFO="ℹ"
WARN="⚠"

# 检测系统
OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"

# 检测 gum
HAS_GUM=0
if command -v gum >/dev/null 2>&1; then
    HAS_GUM=1
fi

# ============================================================================
# 默认配置值
# ============================================================================

# Dotbot 相关
DO_LINKS=1

# Homebrew 相关
DO_BREW=${INSTALL_WITH_BREW:-0}
DO_BREW_UPGRADE=${INSTALL_BREW_UPGRADE:-0}
DO_BREW_CLEANUP=${INSTALL_BREW_CLEANUP:-0}
BREW_MIRROR=${BREW_MIRROR:-}
BREW_PROXY=${BREW_PROXY:-}

# 工具安装
DO_TPM=${INSTALL_WITH_TPM:-0}
DO_FZF_BINDS=${INSTALL_WITH_FZF_BINDS:-0}
DO_ZOXIDE=${INSTALL_WITH_ZOXIDE_SETUP:-0}

# Shell 配置
ZSH_THEME=""
ZSH_MANAGER=""
ZSH_PLUGINS=""

# 开发工具
CONFIGURE_VIM=0
CONFIGURE_NVIM=0
CONFIGURE_GIT=0
GIT_USER_NAME=""
GIT_USER_EMAIL=""

# 模式控制
DO_INTERACTIVE=0
GUM_INSTALL=${INSTALL_GUM:-0}
PROFILE_SAVE=""
PROFILE_LOAD=""
DRY_RUN=${DRY_RUN:-0}
FORWARD_ARGS=()

# 备份
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DO_BACKUP=1

# ============================================================================
# 辅助函数
# ============================================================================

print_header() {
    if [ "$HAS_GUM" = "1" ]; then
        gum style \
            --foreground 212 \
            --border double \
            --border-foreground 212 \
            --padding "1 2" \
            --margin "1 0" \
            --align center \
            "Unified Dotfiles Installer" \
            "统一安装脚本 v2.0"
    else
        echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${WHITE}              Unified Dotfiles Installer v2.0               ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
    fi
}

print_section() {
    if [ "$HAS_GUM" = "1" ]; then
        gum style \
            --foreground 81 \
            --bold \
            --margin "1 0" \
            "━━━ $1 ━━━"
    else
        echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}  $1${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    fi
}

print_info() {
    if [ "$HAS_GUM" = "1" ]; then
        gum style --foreground 81 "${INFO} $1"
    else
        echo -e "${BLUE}${INFO}${NC} $1"
    fi
}

print_success() {
    if [ "$HAS_GUM" = "1" ]; then
        gum style --foreground 82 "${CHECK_MARK} $1"
    else
        echo -e "${GREEN}${CHECK_MARK}${NC} $1"
    fi
}

print_error() {
    if [ "$HAS_GUM" = "1" ]; then
        gum style --foreground 196 "${CROSS_MARK} $1"
    else
        echo -e "${RED}${CROSS_MARK}${NC} $1"
    fi
}

print_warning() {
    if [ "$HAS_GUM" = "1" ]; then
        gum style --foreground 214 "${WARN} $1"
    else
        echo -e "${YELLOW}${WARN}${NC} $1"
    fi
}

# 单选函数
select_option() {
    local prompt="$1"
    shift
    local options=("$@")

    if [ "$HAS_GUM" = "1" ]; then
        local choice
        choice=$(printf '%s\n' "${options[@]}" | gum choose \
            --header "$prompt" \
            --cursor "> " \
            --cursor.foreground="212" \
            --selected.foreground="212" \
            --height 10)

        for i in "${!options[@]}"; do
            if [ "${options[$i]}" = "$choice" ]; then
                echo "$i"
                return
            fi
        done
    else
        echo -e "${YELLOW}${ARROW}${NC} $prompt"
        for i in "${!options[@]}"; do
            echo -e "  ${WHITE}$((i+1)))${NC} ${options[$i]}"
        done

        local choice
        while true; do
            read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择 [1-${#options[@]}]: ")" choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
                echo "$((choice-1))"
                return
            else
                print_error "无效选择，请重试"
            fi
        done
    fi
}

# 多选函数
multi_select() {
    local prompt="$1"
    shift
    local options=("$@")

    if [ "$HAS_GUM" = "1" ]; then
        local choices
        choices=$(printf '%s\n' "${options[@]}" | gum choose \
            --no-limit \
            --header "$prompt (空格选择，回车确认)" \
            --cursor "> " \
            --cursor.foreground="212" \
            --selected.foreground="82" \
            --height 12)

        local selected=()
        while IFS= read -r choice; do
            [ -z "$choice" ] && continue
            for i in "${!options[@]}"; do
                if [ "${options[$i]}" = "$choice" ]; then
                    selected+=("$i")
                    break
                fi
            done
        done <<< "$choices"

        echo "${selected[@]}"
    else
        echo -e "${YELLOW}${ARROW}${NC} $prompt (多选，空格分隔，如: 1 3 5)"
        for i in "${!options[@]}"; do
            echo -e "  ${WHITE}$((i+1)))${NC} ${options[$i]}"
        done

        local choices selected=()
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择: ")" -a choices

        for choice in "${choices[@]}"; do
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
                selected+=("$((choice-1))")
            fi
        done

        echo "${selected[@]}"
    fi
}

# 确认函数
confirm() {
    local prompt="${1:-确认操作?}"
    local default="${2:-y}"

    if [ "$HAS_GUM" = "1" ]; then
        if [ "$default" = "y" ]; then
            gum confirm --default "$prompt" && return 0 || return 1
        else
            gum confirm "$prompt" && return 0 || return 1
        fi
    else
        local response
        if [ "$default" = "y" ]; then
            read -rp "$(echo -e "${YELLOW}${ARROW}${NC} $prompt [Y/n]: ")" response
            [[ -z "$response" || "$response" =~ ^[Yy]$ ]]
        else
            read -rp "$(echo -e "${YELLOW}${ARROW}${NC} $prompt [y/N]: ")" response
            [[ "$response" =~ ^[Yy]$ ]]
        fi
    fi
}

# 输入函数
input_text() {
    local prompt="$1"
    local placeholder="${2:-}"

    if [ "$HAS_GUM" = "1" ]; then
        gum input \
            --prompt "$prompt: " \
            --placeholder "$placeholder" \
            --cursor.foreground="212"
    else
        local input
        if [ -n "$placeholder" ]; then
            read -rp "$(echo -e "${YELLOW}${ARROW}${NC} $prompt [$placeholder]: ")" input
            echo "${input:-$placeholder}"
        else
            read -rp "$(echo -e "${YELLOW}${ARROW}${NC} $prompt: ")" input
            echo "$input"
        fi
    fi
}

# ============================================================================
# 命令行参数解析
# ============================================================================

show_help() {
    cat <<'USAGE'
Usage: ./install-unified.sh [options]

模式选项:
  --interactive          交互式配置向导（推荐）
  --quick                快速安装（使用默认配置）
  --minimal              最小安装（仅创建符号链接）

功能选项:
  --only-links           仅创建符号链接
  --brew                 启用 Homebrew 安装
  --brew-upgrade         升级现有 Homebrew 包
  --brew-cleanup         清理 Homebrew 缓存
  --brew-mirror=NAME     设置镜像 (ustc|tsinghua)
  --brew-proxy=URL       设置 HTTP/HTTPS 代理
  --tpm                  安装 tmux TPM 插件
  --fzf-bindings         配置 fzf 键绑定
  --zoxide-setup         安装配置 zoxide

界面选项:
  --gum-install          自动安装 gum（更好的界面）
  --no-gum               禁用 gum（使用纯 bash）

配置选项:
  --profile-save=FILE    保存配置到文件
  --profile-load=FILE    从文件加载配置
  --no-backup            不备份现有配置

其他选项:
  --dry-run              演示模式（不实际执行）
  -h, --help             显示帮助信息
  -v, --version          显示版本信息

示例:
  ./install-unified.sh --interactive        # 交互式安装（推荐）
  ./install-unified.sh --quick              # 快速安装
  ./install-unified.sh --minimal            # 最小安装
  ./install-unified.sh --brew --tpm         # 指定功能安装

更多信息请访问: https://github.com/ONGOING-Z/dotfiles
USAGE
    exit 0
}

# 解析命令行参数
while (( "$#" )); do
    case "$1" in
        -h|--help)
            show_help ;;
        -v|--version)
            echo "Unified Dotfiles Installer v2.0"
            exit 0 ;;
        --interactive)
            DO_INTERACTIVE=1; shift ;;
        --quick)
            DO_BREW=1; DO_TPM=1; DO_FZF_BINDS=1; shift ;;
        --minimal)
            DO_BREW=0; DO_TPM=0; DO_FZF_BINDS=0; shift ;;
        --only-links)
            DO_BREW=0; shift ;;
        --brew)
            DO_BREW=1; shift ;;
        --brew-upgrade)
            DO_BREW_UPGRADE=1; shift ;;
        --brew-cleanup)
            DO_BREW_CLEANUP=1; shift ;;
        --brew-mirror=*)
            BREW_MIRROR="${1#*=}"; shift ;;
        --brew-proxy=*)
            BREW_PROXY="${1#*=}"; shift ;;
        --tpm)
            DO_TPM=1; shift ;;
        --fzf-bindings)
            DO_FZF_BINDS=1; shift ;;
        --zoxide-setup)
            DO_ZOXIDE=1; shift ;;
        --gum-install)
            GUM_INSTALL=1; shift ;;
        --no-gum)
            HAS_GUM=0; GUM_INSTALL=0; shift ;;
        --profile-save=*)
            PROFILE_SAVE="${1#*=}"; shift ;;
        --profile-load=*)
            PROFILE_LOAD="${1#*=}"; shift ;;
        --no-backup)
            DO_BACKUP=0; shift ;;
        --dry-run)
            DRY_RUN=1; shift ;;
        *)
            FORWARD_ARGS+=("$1"); shift ;;
    esac
done

# ============================================================================
# 加载配置文件（如果指定）
# ============================================================================

load_profile() {
    local profile_file="$1"
    if [ -f "$profile_file" ]; then
        print_info "加载配置文件: $profile_file"
        while IFS= read -r line || [ -n "$line" ]; do
            case "$line" in
                \#*|'') continue ;;
                DO_*=*|BREW_*=*|ZSH_*=*|CONFIGURE_*=*|GIT_*=*)
                    eval "$line"
                    ;;
            esac
        done < "$profile_file"
        print_success "配置加载成功"
    else
        print_error "配置文件不存在: $profile_file"
        exit 1
    fi
}

if [ -n "${PROFILE_LOAD:-}" ]; then
    load_profile "$PROFILE_LOAD"
fi

# ============================================================================
# 安装 Gum（如果需要）
# ============================================================================

install_gum() {
    if [ "$HAS_GUM" = "0" ] && [ "$GUM_INSTALL" = "1" ]; then
        print_section "Gum 安装"
        print_info "Gum 可以提供更好的交互体验"

        if confirm "是否安装 Gum 以获得更好的界面体验？"; then
            if command -v brew >/dev/null 2>&1; then
                print_info "通过 Homebrew 安装 Gum..."
                if [ "$DRY_RUN" = "1" ]; then
                    print_info "[DRY-RUN] brew install gum"
                else
                    if brew install gum; then
                        HAS_GUM=1
                        print_success "Gum 安装成功！"
                        # 重新显示界面
                        clear
                        print_header
                    else
                        print_warning "Gum 安装失败，将使用基础界面"
                    fi
                fi
            elif command -v apt-get >/dev/null 2>&1; then
                print_info "通过 apt 安装 Gum..."
                if [ "$DRY_RUN" = "1" ]; then
                    print_info "[DRY-RUN] sudo apt-get install gum"
                else
                    if sudo apt-get update && sudo apt-get install -y gum; then
                        HAS_GUM=1
                        print_success "Gum 安装成功！"
                        clear
                        print_header
                    else
                        print_warning "Gum 安装失败，将使用基础界面"
                    fi
                fi
            else
                print_warning "未找到合适的包管理器，将使用基础界面"
            fi
        fi
    fi
}

# ============================================================================
# 交互式配置
# ============================================================================

interactive_setup() {
    print_section "交互式配置向导"

    # 基础选项
    if confirm "启用 Homebrew 包管理？" "y"; then
        DO_BREW=1

        if confirm "  └─ 升级现有包？" "n"; then
            DO_BREW_UPGRADE=1
        fi

        if confirm "  └─ 清理缓存？" "n"; then
            DO_BREW_CLEANUP=1
        fi

        # 镜像选择
        local mirrors=(
            "不使用镜像"
            "USTC 镜像（中科大）"
            "Tsinghua 镜像（清华）"
        )
        local mirror_idx=$(select_option "选择 Homebrew 镜像:" "${mirrors[@]}")
        case $mirror_idx in
            1) BREW_MIRROR="ustc" ;;
            2) BREW_MIRROR="tsinghua" ;;
        esac

        # 代理设置
        local proxy=$(input_text "HTTP 代理（可选）" "http://127.0.0.1:7890")
        [ "$proxy" != "http://127.0.0.1:7890" ] && [ -n "$proxy" ] && BREW_PROXY="$proxy"
    fi

    # Zsh 主题
    print_section "Shell 配置"
    local themes=(
        "robbyrussell - 默认主题，简洁高效"
        "agnoster - Git 状态显示，需要 Powerline 字体"
        "powerlevel10k - 高度可定制，功能丰富"
        "spaceship - 现代化设计，信息丰富"
        "pure - 极简主义，快速轻量"
        "不更改"
    )

    local theme_idx=$(select_option "选择 Zsh 主题:" "${themes[@]}")
    case $theme_idx in
        0) ZSH_THEME="robbyrussell" ;;
        1) ZSH_THEME="agnoster" ;;
        2) ZSH_THEME="powerlevel10k" ;;
        3) ZSH_THEME="spaceship" ;;
        4) ZSH_THEME="pure" ;;
    esac

    # 插件管理器
    local managers=(
        "Oh-My-Zsh - 最流行，插件丰富"
        "Zinit - 高性能，Turbo 模式"
        "不使用"
    )

    local manager_idx=$(select_option "选择插件管理器:" "${managers[@]}")
    case $manager_idx in
        0) ZSH_MANAGER="ohmyzsh" ;;
        1) ZSH_MANAGER="zinit" ;;
    esac

    # 插件选择
    if [ -n "$ZSH_MANAGER" ] && [ "$ZSH_MANAGER" != "none" ]; then
        local plugins=(
            "zsh-autosuggestions - 命令自动建议"
            "zsh-syntax-highlighting - 语法高亮"
            "git - Git 别名和函数"
            "docker - Docker 补全"
            "fzf - 模糊查找"
            "z - 目录跳转"
        )

        local selected=$(multi_select "选择插件:" "${plugins[@]}")
        ZSH_PLUGINS="$selected"
    fi

    # 开发工具
    print_section "开发工具"

    if confirm "配置 tmux TPM 插件管理器？" "n"; then
        DO_TPM=1
    fi

    if confirm "配置 fzf 键绑定和补全？" "n"; then
        DO_FZF_BINDS=1
    fi

    if confirm "安装配置 zoxide（更好的目录跳转）？" "n"; then
        DO_ZOXIDE=1
    fi

    # 编辑器
    local editors=(
        "Vim - 经典编辑器"
        "Neovim - 现代化 Vim"
        "两者都配置"
        "跳过"
    )

    local editor_idx=$(select_option "配置编辑器:" "${editors[@]}")
    case $editor_idx in
        0) CONFIGURE_VIM=1 ;;
        1) CONFIGURE_NVIM=1 ;;
        2) CONFIGURE_VIM=1; CONFIGURE_NVIM=1 ;;
    esac

    # Git 配置
    if confirm "配置 Git？" "y"; then
        CONFIGURE_GIT=1
        GIT_USER_NAME=$(input_text "Git 用户名" "Your Name")
        GIT_USER_EMAIL=$(input_text "Git 邮箱" "you@example.com")
    fi
}

# ============================================================================
# 显示配置摘要
# ============================================================================

show_summary() {
    print_section "配置摘要"

    if [ "$HAS_GUM" = "1" ]; then
        gum style \
            --border rounded \
            --border-foreground 212 \
            --padding "1 2" \
            --margin "1 0" \
            "$(cat <<EOF
基础配置
  操作系统:              $OS_NAME
  创建符号链接:          $([ "$DO_LINKS" = "1" ] && echo "是" || echo "否")
  备份现有配置:          $([ "$DO_BACKUP" = "1" ] && echo "是" || echo "否")

Homebrew 配置
  启用 Homebrew:         $([ "$DO_BREW" = "1" ] && echo "是" || echo "否")
  升级包:                $([ "$DO_BREW_UPGRADE" = "1" ] && echo "是" || echo "否")
  清理缓存:              $([ "$DO_BREW_CLEANUP" = "1" ] && echo "是" || echo "否")
  镜像:                  ${BREW_MIRROR:-无}
  代理:                  ${BREW_PROXY:-无}

Shell 配置
  Zsh 主题:              ${ZSH_THEME:-不更改}
  插件管理器:            ${ZSH_MANAGER:-无}
  插件数量:              $(echo ${ZSH_PLUGINS:-} | wc -w)

开发工具
  tmux TPM:              $([ "$DO_TPM" = "1" ] && echo "是" || echo "否")
  fzf 绑定:              $([ "$DO_FZF_BINDS" = "1" ] && echo "是" || echo "否")
  zoxide:                $([ "$DO_ZOXIDE" = "1" ] && echo "是" || echo "否")
  配置 Vim:              $([ "$CONFIGURE_VIM" = "1" ] && echo "是" || echo "否")
  配置 Neovim:           $([ "$CONFIGURE_NVIM" = "1" ] && echo "是" || echo "否")
  配置 Git:              $([ "$CONFIGURE_GIT" = "1" ] && echo "是" || echo "否")
EOF
        )"
    else
        cat <<EOF
基础配置
  操作系统:              $OS_NAME
  创建符号链接:          $([ "$DO_LINKS" = "1" ] && echo "是" || echo "否")
  备份现有配置:          $([ "$DO_BACKUP" = "1" ] && echo "是" || echo "否")

Homebrew 配置
  启用 Homebrew:         $([ "$DO_BREW" = "1" ] && echo "是" || echo "否")
  升级包:                $([ "$DO_BREW_UPGRADE" = "1" ] && echo "是" || echo "否")
  清理缓存:              $([ "$DO_BREW_CLEANUP" = "1" ] && echo "是" || echo "否")
  镜像:                  ${BREW_MIRROR:-无}
  代理:                  ${BREW_PROXY:-无}

Shell 配置
  Zsh 主题:              ${ZSH_THEME:-不更改}
  插件管理器:            ${ZSH_MANAGER:-无}
  插件数量:              $(echo ${ZSH_PLUGINS:-} | wc -w)

开发工具
  tmux TPM:              $([ "$DO_TPM" = "1" ] && echo "是" || echo "否")
  fzf 绑定:              $([ "$DO_FZF_BINDS" = "1" ] && echo "是" || echo "否")
  zoxide:                $([ "$DO_ZOXIDE" = "1" ] && echo "是" || echo "否")
  配置 Vim:              $([ "$CONFIGURE_VIM" = "1" ] && echo "是" || echo "否")
  配置 Neovim:           $([ "$CONFIGURE_NVIM" = "1" ] && echo "是" || echo "否")
  配置 Git:              $([ "$CONFIGURE_GIT" = "1" ] && echo "是" || echo "否")
EOF
    fi

    # 生成可重用的命令
    print_info "可重用命令:"
    local cmd="./install-unified.sh"
    [ "$DO_BREW" = "1" ] && cmd="$cmd --brew" || cmd="$cmd --only-links"
    [ "$DO_BREW_UPGRADE" = "1" ] && cmd="$cmd --brew-upgrade"
    [ "$DO_BREW_CLEANUP" = "1" ] && cmd="$cmd --brew-cleanup"
    [ -n "$BREW_MIRROR" ] && cmd="$cmd --brew-mirror=$BREW_MIRROR"
    [ -n "$BREW_PROXY" ] && cmd="$cmd --brew-proxy=$BREW_PROXY"
    [ "$DO_TPM" = "1" ] && cmd="$cmd --tpm"
    [ "$DO_FZF_BINDS" = "1" ] && cmd="$cmd --fzf-bindings"
    [ "$DO_ZOXIDE" = "1" ] && cmd="$cmd --zoxide-setup"
    echo "  $cmd"
}

# ============================================================================
# 保存配置
# ============================================================================

save_profile() {
    local profile_file="$1"
    print_info "保存配置到: $profile_file"

    cat > "$profile_file" <<EOF
# Dotfiles 安装配置
# 生成时间: $(date)

# Homebrew
DO_BREW=$DO_BREW
DO_BREW_UPGRADE=$DO_BREW_UPGRADE
DO_BREW_CLEANUP=$DO_BREW_CLEANUP
BREW_MIRROR=$BREW_MIRROR
BREW_PROXY=$BREW_PROXY

# 工具
DO_TPM=$DO_TPM
DO_FZF_BINDS=$DO_FZF_BINDS
DO_ZOXIDE=$DO_ZOXIDE

# Shell
ZSH_THEME=$ZSH_THEME
ZSH_MANAGER=$ZSH_MANAGER
ZSH_PLUGINS="$ZSH_PLUGINS"

# 开发工具
CONFIGURE_VIM=$CONFIGURE_VIM
CONFIGURE_NVIM=$CONFIGURE_NVIM
CONFIGURE_GIT=$CONFIGURE_GIT
GIT_USER_NAME="$GIT_USER_NAME"
GIT_USER_EMAIL="$GIT_USER_EMAIL"
EOF

    print_success "配置已保存"
}

# ============================================================================
# 备份现有配置
# ============================================================================

backup_existing() {
    if [ "$DO_BACKUP" = "0" ]; then
        return
    fi

    print_section "备份现有配置"

    local files_to_backup=(
        ".zshrc" ".bashrc" ".bash_aliases"
        ".tmux.conf" ".vimrc" ".gitconfig"
    )

    local need_backup=false
    for file in "${files_to_backup[@]}"; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            need_backup=true
            break
        fi
    done

    if [ "$need_backup" = true ]; then
        if confirm "发现现有配置文件，是否备份？" "y"; then
            [ "$DRY_RUN" = "1" ] && print_info "[DRY-RUN] 创建备份目录: $BACKUP_DIR" || mkdir -p "$BACKUP_DIR"

            for file in "${files_to_backup[@]}"; do
                if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
                    if [ "$DRY_RUN" = "1" ]; then
                        print_info "[DRY-RUN] 备份 $file"
                    else
                        cp "$HOME/$file" "$BACKUP_DIR/"
                        print_success "已备份: $file"
                    fi
                fi
            done

            print_success "备份完成: $BACKUP_DIR"
        fi
    else
        print_info "无需备份（文件不存在或已是符号链接）"
    fi
}

# ============================================================================
# 执行 Dotbot
# ============================================================================

run_dotbot() {
    print_section "创建符号链接"

    cd "${BASEDIR}"

    # 初始化 dotbot submodule
    if [ "$DRY_RUN" = "1" ]; then
        print_info "[DRY-RUN] git submodule update --init --recursive"
    else
        git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
        git submodule update --init --recursive "${DOTBOT_DIR}"
    fi

    # 运行 dotbot
    if [ "$DRY_RUN" = "1" ]; then
        print_info "[DRY-RUN] 运行 Dotbot 创建符号链接"
    else
        "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" ${FORWARD_ARGS+"${FORWARD_ARGS[@]}"}
    fi
}

# ============================================================================
# Homebrew 安装
# ============================================================================

install_homebrew() {
    if [ "$DO_BREW" = "0" ] || ! command -v brew >/dev/null 2>&1; then
        return
    fi

    print_section "Homebrew 包管理"

    # 设置镜像
    if [ -n "$BREW_MIRROR" ]; then
        case "$BREW_MIRROR" in
            ustc)
                export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
                print_info "使用 USTC 镜像"
                ;;
            tsinghua)
                export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
                print_info "使用清华镜像"
                ;;
        esac
    fi

    # 设置代理
    if [ -n "$BREW_PROXY" ]; then
        export ALL_PROXY="$BREW_PROXY"
        export HTTPS_PROXY="$BREW_PROXY"
        export HTTP_PROXY="$BREW_PROXY"
        print_info "使用代理: $BREW_PROXY"
    fi

    # Brewfile 路径
    local BREWFILES=("brew/Brewfile.common")
    if [ "$OS_NAME" = "darwin" ]; then
        BREWFILES+=("brew/Brewfile.macos")
    else
        BREWFILES+=("brew/Brewfile.linux")
    fi

    # 更新 Homebrew
    if [ "$DRY_RUN" = "1" ]; then
        print_info "[DRY-RUN] brew update"
    else
        print_info "更新 Homebrew..."
        brew update || true
    fi

    # 升级包
    if [ "$DO_BREW_UPGRADE" = "1" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            print_info "[DRY-RUN] brew upgrade"
        else
            print_info "升级 Homebrew 包..."
            brew upgrade || true
        fi
    fi

    # 安装 Brewfile
    for bf in "${BREWFILES[@]}"; do
        if [ -f "$bf" ]; then
            if [ "$DRY_RUN" = "1" ]; then
                print_info "[DRY-RUN] brew bundle --file $bf"
            else
                print_info "安装 $bf..."
                brew bundle --file "$bf" --no-lock || true
            fi
        fi
    done

    # 清理
    if [ "$DO_BREW_CLEANUP" = "1" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            print_info "[DRY-RUN] brew cleanup && brew autoremove"
        else
            print_info "清理 Homebrew..."
            brew cleanup -s || true
            brew autoremove || true
        fi
    fi
}

# ============================================================================
# 安装其他工具
# ============================================================================

install_tools() {
    # tmux TPM
    if [ "$DO_TPM" = "1" ]; then
        print_section "tmux 插件管理器"
        local TPM_DIR="$HOME/.tmux/plugins/tpm"

        if [ "$DRY_RUN" = "1" ]; then
            print_info "[DRY-RUN] 安装 tmux TPM"
        else
            if [ ! -d "$TPM_DIR" ]; then
                print_info "克隆 TPM..."
                git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
            else
                print_info "更新 TPM..."
                git -C "$TPM_DIR" pull
            fi

            if command -v tmux >/dev/null 2>&1; then
                print_info "安装 tmux 插件..."
                "$TPM_DIR/bin/install_plugins" || true
            fi
        fi
    fi

    # fzf
    if [ "$DO_FZF_BINDS" = "1" ]; then
        print_section "fzf 配置"

        if [ "$DRY_RUN" = "1" ]; then
            print_info "[DRY-RUN] 配置 fzf 键绑定"
        else
            if command -v fzf >/dev/null 2>&1; then
                local fzf_base
                if command -v brew >/dev/null 2>&1; then
                    fzf_base="$(brew --prefix)/opt/fzf"
                else
                    fzf_base="$HOME/.fzf"
                fi

                if [ -f "$fzf_base/install" ]; then
                    print_info "配置 fzf..."
                    "$fzf_base/install" --key-bindings --completion --no-update-rc || true
                fi
            else
                print_warning "fzf 未安装"
            fi
        fi
    fi

    # zoxide
    if [ "$DO_ZOXIDE" = "1" ]; then
        print_section "zoxide 配置"

        if [ "$DRY_RUN" = "1" ]; then
            print_info "[DRY-RUN] 安装配置 zoxide"
        else
            if ! command -v zoxide >/dev/null 2>&1; then
                if command -v brew >/dev/null 2>&1; then
                    print_info "安装 zoxide..."
                    brew install zoxide
                else
                    print_warning "无法安装 zoxide（需要 Homebrew）"
                fi
            else
                print_success "zoxide 已安装"
            fi
        fi
    fi
}

# ============================================================================
# 配置 Shell
# ============================================================================

configure_shell() {
    if [ -z "$ZSH_THEME" ] && [ -z "$ZSH_MANAGER" ]; then
        return
    fi

    print_section "Shell 配置"

    # 配置 Zsh 主题
    if [ -n "$ZSH_THEME" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            print_info "[DRY-RUN] 设置 Zsh 主题: $ZSH_THEME"
        else
            # 这里添加实际的主题配置逻辑
            print_info "配置 Zsh 主题: $ZSH_THEME"
        fi
    fi

    # 配置插件管理器
    if [ -n "$ZSH_MANAGER" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            print_info "[DRY-RUN] 安装插件管理器: $ZSH_MANAGER"
        else
            # 这里添加实际的插件管理器安装逻辑
            print_info "安装插件管理器: $ZSH_MANAGER"
        fi
    fi
}

# ============================================================================
# 配置 Git
# ============================================================================

configure_git_settings() {
    if [ "$CONFIGURE_GIT" = "0" ]; then
        return
    fi

    print_section "Git 配置"

    if [ "$DRY_RUN" = "1" ]; then
        print_info "[DRY-RUN] 配置 Git 用户信息"
        [ -n "$GIT_USER_NAME" ] && print_info "  用户名: $GIT_USER_NAME"
        [ -n "$GIT_USER_EMAIL" ] && print_info "  邮箱: $GIT_USER_EMAIL"
    else
        if [ -n "$GIT_USER_NAME" ]; then
            git config --global user.name "$GIT_USER_NAME"
            print_success "设置 Git 用户名: $GIT_USER_NAME"
        fi

        if [ -n "$GIT_USER_EMAIL" ]; then
            git config --global user.email "$GIT_USER_EMAIL"
            print_success "设置 Git 邮箱: $GIT_USER_EMAIL"
        fi
    fi
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    # 显示欢迎界面
    print_header

    # 系统检测
    print_info "检测到系统: $OS_NAME"

    # 安装 Gum（如果请求）
    if [ "$DO_INTERACTIVE" = "1" ] || [ "$GUM_INSTALL" = "1" ]; then
        install_gum
    fi

    # 交互式配置
    if [ "$DO_INTERACTIVE" = "1" ]; then
        interactive_setup
    fi

    # 显示配置摘要
    show_summary

    # 确认执行
    if [ "$DRY_RUN" = "0" ]; then
        if ! confirm "确认以上配置并开始安装？" "y"; then
            print_warning "安装已取消"
            exit 0
        fi
    fi

    # 保存配置（如果指定）
    if [ -n "${PROFILE_SAVE:-}" ]; then
        save_profile "$PROFILE_SAVE"
    fi

    # 执行安装步骤
    if [ "$HAS_GUM" = "1" ] && [ "$DRY_RUN" = "0" ]; then
        # 使用 gum 显示进度
        gum spin --spinner dot --title "正在安装..." -- bash -c "
            $(declare -f backup_existing)
            $(declare -f run_dotbot)
            $(declare -f install_homebrew)
            $(declare -f install_tools)
            $(declare -f configure_shell)
            $(declare -f configure_git_settings)

            backup_existing
            run_dotbot
            install_homebrew
            install_tools
            configure_shell
            configure_git_settings
        "
    else
        # 常规执行
        backup_existing
        run_dotbot
        install_homebrew
        install_tools
        configure_shell
        configure_git_settings
    fi

    # 完成
    print_success "安装完成！"

    # 后续提示
    print_section "后续步骤"
    echo "1. 重新加载 shell 配置: source ~/.zshrc 或 source ~/.bashrc"
    echo "2. 安装 Vim/Neovim 插件: 打开编辑器运行 :PlugInstall"
    echo "3. 配置 tmux 插件: 按 prefix + I 安装插件"

    if [ -n "${PROFILE_SAVE:-}" ]; then
        echo ""
        print_info "配置已保存到 $PROFILE_SAVE"
        print_info "下次可以使用: ./install-unified.sh --profile-load=$PROFILE_SAVE"
    fi
}

# 运行主函数
main "$@"
