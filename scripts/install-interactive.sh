#!/usr/bin/env bash
# 交互式安装增强脚本
# 提供更友好的用户界面和更多配置选项

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 图标定义
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="➜"
INFO="ℹ"
WARN="⚠"

# 配置变量
INSTALL_DIR="${HOME}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ============================================================================
# 辅助函数
# ============================================================================

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}                   Dotfiles 交互式安装器                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_info() {
    echo -e "${BLUE}${INFO}${NC} $1"
}

print_success() {
    echo -e "${GREEN}${CHECK_MARK}${NC} $1"
}

print_error() {
    echo -e "${RED}${CROSS_MARK}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${WARN}${NC} $1"
}

print_option() {
    echo -e "  ${WHITE}$1)${NC} $2"
}

confirm() {
    local prompt="${1:-确认操作?}"
    local default="${2:-n}"
    local response

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -rp "$(echo -e "${YELLOW}${ARROW}${NC} $prompt")" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    local choice

    echo -e "${YELLOW}${ARROW}${NC} $prompt"

    for i in "${!options[@]}"; do
        print_option "$((i+1))" "${options[$i]}"
    done

    while true; do
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择 [1-${#options[@]}]: ")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "$((choice-1))"
            return
        else
            print_error "无效选择，请重试"
        fi
    done
}

multi_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=()
    local choice

    echo -e "${YELLOW}${ARROW}${NC} $prompt (多选，空格分隔，如: 1 3 5)"

    for i in "${!options[@]}"; do
        print_option "$((i+1))" "${options[$i]}"
    done

    read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择: ")" -a choices

    for choice in "${choices[@]}"; do
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            selected+=("$((choice-1))")
        fi
    done

    echo "${selected[@]}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ============================================================================
# 系统检查
# ============================================================================

check_system() {
    print_section "系统环境检查"

    # 操作系统
    OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
    print_info "操作系统: $OS_NAME"

    # Shell
    CURRENT_SHELL="$(basename "$SHELL")"
    print_info "当前 Shell: $CURRENT_SHELL"

    # Git
    if command -v git &>/dev/null; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git 已安装 (v$GIT_VERSION)"
    else
        print_error "Git 未安装"
        exit 1
    fi

    # 检查必要工具
    local tools=("curl" "wget" "make")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            print_success "$tool 已安装"
        else
            print_warning "$tool 未安装（可选）"
        fi
    done
}

# ============================================================================
# 备份现有配置
# ============================================================================

backup_existing() {
    print_section "备份现有配置"

    local files_to_backup=(
        ".zshrc"
        ".bashrc"
        ".bash_aliases"
        ".tmux.conf"
        ".vimrc"
        ".gitconfig"
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
            mkdir -p "$BACKUP_DIR"
            for file in "${files_to_backup[@]}"; do
                if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
                    cp "$HOME/$file" "$BACKUP_DIR/"
                    print_success "已备份 $file"
                fi
            done
            print_info "备份保存在: $BACKUP_DIR"
        fi
    else
        print_info "未发现需要备份的配置文件"
    fi
}

# ============================================================================
# 主题选择
# ============================================================================

select_theme() {
    print_section "主题和外观"

    # Zsh 主题选择
    local zsh_themes=(
        "robbyrussell (默认，简洁)"
        "agnoster (强大的 Git 状态)"
        "powerlevel10k (高度可定制)"
        "spaceship (现代化)"
        "pure (极简主义)"
        "不更改"
    )

    local theme_idx=$(select_option "选择 Zsh 主题:" "${zsh_themes[@]}")
    case $theme_idx in
        0) export SELECTED_ZSH_THEME="robbyrussell" ;;
        1) export SELECTED_ZSH_THEME="agnoster" ;;
        2) export SELECTED_ZSH_THEME="powerlevel10k" ;;
        3) export SELECTED_ZSH_THEME="spaceship" ;;
        4) export SELECTED_ZSH_THEME="pure" ;;
        5) export SELECTED_ZSH_THEME="" ;;
    esac

    if [ -n "${SELECTED_ZSH_THEME:-}" ]; then
        print_success "已选择主题: $SELECTED_ZSH_THEME"
    fi
}

# ============================================================================
# 插件选择
# ============================================================================

select_plugins() {
    print_section "插件和扩展"

    # Zsh 插件管理器
    local managers=(
        "Oh-My-Zsh (最流行，插件丰富)"
        "Zplug (现代化，并行加载)"
        "Zinit (高性能，Turbo 模式)"
        "不使用插件管理器"
    )

    local manager_idx=$(select_option "选择 Zsh 插件管理器:" "${managers[@]}")
    case $manager_idx in
        0) export ZSH_MANAGER="ohmyzsh" ;;
        1) export ZSH_MANAGER="zplug" ;;
        2) export ZSH_MANAGER="zinit" ;;
        3) export ZSH_MANAGER="none" ;;
    esac

    print_success "已选择: ${managers[$manager_idx]}"

    # 选择要安装的插件
    if [ "$ZSH_MANAGER" != "none" ]; then
        local plugins=(
            "zsh-autosuggestions (命令自动建议)"
            "zsh-syntax-highlighting (语法高亮)"
            "zsh-completions (增强补全)"
            "git (Git 别名和函数)"
            "docker (Docker 补全)"
            "kubectl (Kubernetes 补全)"
            "fzf (模糊查找)"
            "z/zoxide (智能目录跳转)"
        )

        local selected_plugins=$(multi_select "选择要安装的插件:" "${plugins[@]}")
        export SELECTED_PLUGINS="$selected_plugins"

        if [ -n "$SELECTED_PLUGINS" ]; then
            print_success "已选择 $(echo $SELECTED_PLUGINS | wc -w) 个插件"
        fi
    fi
}

# ============================================================================
# 开发工具配置
# ============================================================================

configure_dev_tools() {
    print_section "开发工具配置"

    # 编辑器选择
    local editors=(
        "Vim (经典编辑器)"
        "Neovim (现代化 Vim)"
        "两者都配置"
        "跳过"
    )

    local editor_idx=$(select_option "配置编辑器:" "${editors[@]}")
    case $editor_idx in
        0) export CONFIGURE_VIM=1 ;;
        1) export CONFIGURE_NVIM=1 ;;
        2) export CONFIGURE_VIM=1; export CONFIGURE_NVIM=1 ;;
        3) ;;
    esac

    # Git 配置
    if confirm "是否配置 Git？" "y"; then
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} Git 用户名: ")" git_name
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} Git 邮箱: ")" git_email

        if [ -n "$git_name" ] && [ -n "$git_email" ]; then
            export GIT_USER_NAME="$git_name"
            export GIT_USER_EMAIL="$git_email"
            print_success "Git 配置已保存"
        fi
    fi

    # 包管理器
    if [ "$OS_NAME" = "darwin" ] || [ "$OS_NAME" = "linux" ]; then
        if confirm "是否安装/更新 Homebrew 包？" "n"; then
            export INSTALL_WITH_BREW=1

            if confirm "  - 升级现有包？" "n"; then
                export INSTALL_BREW_UPGRADE=1
            fi

            if confirm "  - 清理旧版本？" "n"; then
                export INSTALL_BREW_CLEANUP=1
            fi
        fi
    fi
}

# ============================================================================
# 网络配置
# ============================================================================

configure_network() {
    print_section "网络配置（可选）"

    if confirm "是否需要配置镜像/代理？" "n"; then
        # 镜像选择
        local mirrors=(
            "USTC (中科大)"
            "Tsinghua (清华)"
            "不使用镜像"
        )

        local mirror_idx=$(select_option "选择 Homebrew 镜像:" "${mirrors[@]}")
        case $mirror_idx in
            0) export BREW_MIRROR="ustc" ;;
            1) export BREW_MIRROR="tsinghua" ;;
            2) ;;
        esac

        # 代理配置
        if confirm "是否配置代理？" "n"; then
            read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 代理地址 (如 http://127.0.0.1:7890): ")" proxy
            if [ -n "$proxy" ]; then
                export BREW_PROXY="$proxy"
                print_success "代理已配置: $proxy"
            fi
        fi
    fi
}

# ============================================================================
# 执行安装
# ============================================================================

execute_install() {
    print_section "执行安装"

    # 构建安装命令
    local install_cmd="./install"
    local install_args=()

    # 添加参数
    [ "${INSTALL_WITH_BREW:-0}" = "1" ] && install_args+=("--brew")
    [ "${INSTALL_BREW_UPGRADE:-0}" = "1" ] && install_args+=("--brew-upgrade")
    [ "${INSTALL_BREW_CLEANUP:-0}" = "1" ] && install_args+=("--brew-cleanup")
    [ -n "${BREW_MIRROR:-}" ] && install_args+=("--brew-mirror=$BREW_MIRROR")
    [ -n "${BREW_PROXY:-}" ] && install_args+=("--brew-proxy=$BREW_PROXY")

    # 保存配置
    if confirm "是否保存本次配置以便将来使用？" "y"; then
        local profile_name
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 配置名称: ")" profile_name
        profile_name="${profile_name:-my-profile}"
        install_args+=("--profile-save=examples/profile.$profile_name")
        print_success "配置将保存为: examples/profile.$profile_name"
    fi

    # 显示最终命令
    echo -e "\n${CYAN}将执行以下命令:${NC}"
    echo -e "${WHITE}$install_cmd ${install_args[*]}${NC}\n"

    if confirm "开始安装？" "y"; then
        print_info "正在安装..."

        # 执行安装
        if $install_cmd "${install_args[@]}"; then
            print_success "安装完成！"
        else
            print_error "安装过程中出现错误"
            return 1
        fi
    else
        print_warning "安装已取消"
        return 1
    fi
}

# ============================================================================
# 安装后配置
# ============================================================================

post_install() {
    print_section "安装后配置"

    # Git 用户配置
    if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
        git config --global user.name "$GIT_USER_NAME"
        git config --global user.email "$GIT_USER_EMAIL"
        print_success "Git 用户信息已配置"
    fi

    # Zsh 主题配置
    if [ -n "${SELECTED_ZSH_THEME:-}" ] && [ -f "$HOME/.zshrc" ]; then
        sed -i.bak "s/^ZSH_THEME=.*/ZSH_THEME=\"$SELECTED_ZSH_THEME\"/" "$HOME/.zshrc"
        print_success "Zsh 主题已更新"
    fi

    # 默认 Shell
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        if confirm "是否将 Zsh 设为默认 Shell？" "y"; then
            if [ "$OS_NAME" = "darwin" ] && [ -f "/opt/homebrew/bin/zsh" ]; then
                if ! grep -q "/opt/homebrew/bin/zsh" /etc/shells; then
                    print_info "添加 Homebrew zsh 到 /etc/shells (需要权限)"
                    echo "/opt/homebrew/bin/zsh" | sudo tee -a /etc/shells
                fi
                chsh -s /opt/homebrew/bin/zsh
            else
                chsh -s "$(which zsh)"
            fi
            print_success "默认 Shell 已更改为 Zsh"
        fi
    fi

    # 显示下一步
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                      安装完成！                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"

    print_info "下一步操作:"
    echo -e "  1. 重启终端或运行: ${WHITE}exec \$SHELL -l${NC}"
    echo -e "  2. 如使用 tmux，运行: ${WHITE}tmux source ~/.tmux.conf${NC}"
    echo -e "  3. 查看自定义命令: ${WHITE}alias${NC}"

    if [ -d "$BACKUP_DIR" ]; then
        echo -e "\n  ${YELLOW}${INFO}${NC} 原配置备份在: $BACKUP_DIR"
    fi
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    # 清屏
    clear

    # 显示头部
    print_header

    # 系统检查
    check_system

    # 备份现有配置
    backup_existing

    # 配置选择
    select_theme
    select_plugins
    configure_dev_tools
    configure_network

    # 执行安装
    if execute_install; then
        post_install
    fi
}

# 运行主函数
main "$@"
