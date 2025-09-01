#!/usr/bin/env bash
# 增强版交互式安装脚本 - 支持 Gum 和纯 Bash 双模式
# 提供最佳用户体验，同时保证兼容性

set -euo pipefail

# ============================================================================
# 配置和常量
# ============================================================================

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

# 检测 gum 是否可用
HAS_GUM=0
if command -v gum >/dev/null 2>&1; then
    HAS_GUM=1
fi

# 配置变量
INSTALL_DIR="${HOME}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ============================================================================
# 通用辅助函数
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
            "Dotfiles 交互式安装器" \
            "Enhanced Edition with Gum Support"
    else
        echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${WHITE}                   Dotfiles 交互式安装器                    ${BLUE}║${NC}"
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

# ============================================================================
# 统一的选择函数（支持 Gum 和 Bash）
# ============================================================================

# 单选函数
select_option() {
    local prompt="$1"
    shift
    local options=("$@")

    if [ "$HAS_GUM" = "1" ]; then
        # Gum 模式：优雅的选择界面
        local choice
        choice=$(printf '%s\n' "${options[@]}" | gum choose \
            --header "$prompt" \
            --cursor "> " \
            --cursor.foreground="212" \
            --selected.foreground="212" \
            --height 10)

        # 返回选择的索引
        for i in "${!options[@]}"; do
            if [ "${options[$i]}" = "$choice" ]; then
                echo "$i"
                return
            fi
        done
    else
        # Bash 模式：传统数字选择
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
        # Gum 模式：支持空格多选
        local choices
        choices=$(printf '%s\n' "${options[@]}" | gum choose \
            --no-limit \
            --header "$prompt (空格选择，回车确认)" \
            --cursor "> " \
            --cursor.foreground="212" \
            --selected.foreground="82" \
            --height 12)

        # 返回选择的索引列表
        local selected=()
        while IFS= read -r choice; do
            for i in "${!options[@]}"; do
                if [ "${options[$i]}" = "$choice" ]; then
                    selected+=("$i")
                    break
                fi
            done
        done <<< "$choices"

        echo "${selected[@]}"
    else
        # Bash 模式：输入数字列表
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

    if [ "$HAS_GUM" = "1" ]; then
        gum confirm "$prompt"
        return $?
    else
        local response
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} $prompt [Y/n]: ")" response
        [[ "$response" =~ ^[Yy]?$ ]]
        return $?
    fi
}

# 输入函数
input_text() {
    local prompt="$1"
    local placeholder="${2:-}"

    if [ "$HAS_GUM" = "1" ]; then
        gum input \
            --prompt "$prompt " \
            --placeholder "$placeholder" \
            --cursor.foreground="212"
    else
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} $prompt: ")" input
        echo "$input"
    fi
}

# ============================================================================
# 安装 Gum（如果需要）
# ============================================================================

install_gum() {
    if [ "$HAS_GUM" = "0" ]; then
        print_section "Gum 安装"
        print_info "Gum 可以提供更好的交互体验"

        if confirm "是否安装 Gum 以获得更好的界面体验？"; then
            if command -v brew >/dev/null 2>&1; then
                print_info "通过 Homebrew 安装 Gum..."
                if brew install gum; then
                    HAS_GUM=1
                    print_success "Gum 安装成功！"
                else
                    print_warning "Gum 安装失败，将使用基础界面"
                fi
            elif command -v go >/dev/null 2>&1; then
                print_info "通过 Go 安装 Gum..."
                if go install github.com/charmbracelet/gum@latest; then
                    HAS_GUM=1
                    print_success "Gum 安装成功！"
                else
                    print_warning "Gum 安装失败，将使用基础界面"
                fi
            else
                print_warning "未找到合适的包管理器，将使用基础界面"
                print_info "您可以稍后通过以下方式安装 Gum："
                print_info "  brew install gum"
                print_info "  或访问: https://github.com/charmbracelet/gum"
            fi
        else
            print_info "跳过 Gum 安装，使用基础界面"
        fi
    else
        print_success "检测到 Gum 已安装，将使用增强界面"
    fi
}

# ============================================================================
# 主题选择（改进版）
# ============================================================================

select_theme() {
    print_section "主题和外观"

    # Zsh 主题选择 - 带完整描述
    local zsh_themes=(
        "robbyrussell - 默认主题，简洁高效"
        "agnoster - 强大的 Git 状态显示，需要 Powerline 字体"
        "powerlevel10k - 高度可定制，功能丰富"
        "spaceship - 现代化设计，信息丰富"
        "pure - 极简主义，快速轻量"
        "不更改现有主题"
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

        # 特殊主题的额外配置
        if [ "$SELECTED_ZSH_THEME" = "powerlevel10k" ]; then
            if confirm "是否运行 Powerlevel10k 配置向导？"; then
                export RUN_P10K_CONFIG=1
            fi
        elif [ "$SELECTED_ZSH_THEME" = "agnoster" ]; then
            print_warning "Agnoster 主题需要 Powerline 字体"
            if confirm "是否安装 Powerline 字体？"; then
                export INSTALL_POWERLINE_FONTS=1
            fi
        fi
    fi
}

# ============================================================================
# 插件选择（改进版）
# ============================================================================

select_plugins() {
    print_section "插件和扩展"

    # Zsh 插件管理器 - 带详细说明
    local managers=(
        "Oh-My-Zsh - 最流行，插件生态丰富，适合新手"
        "Zplug - 现代化设计，支持并行加载"
        "Zinit - 高性能，支持 Turbo 模式，适合高级用户"
        "Antigen - 简单易用，类似 Vundle"
        "不使用插件管理器"
    )

    local manager_idx=$(select_option "选择 Zsh 插件管理器:" "${managers[@]}")

    case $manager_idx in
        0) export ZSH_MANAGER="ohmyzsh" ;;
        1) export ZSH_MANAGER="zplug" ;;
        2) export ZSH_MANAGER="zinit" ;;
        3) export ZSH_MANAGER="antigen" ;;
        4) export ZSH_MANAGER="none" ;;
    esac

    print_success "已选择: $(echo "${managers[$manager_idx]}" | cut -d' ' -f1)"

    # 选择要安装的插件 - 带详细描述
    if [ "$ZSH_MANAGER" != "none" ]; then
        local plugins=(
            "zsh-autosuggestions - 基于历史的命令自动建议"
            "zsh-syntax-highlighting - 实时语法高亮显示"
            "zsh-completions - 额外的自动补全定义"
            "git - Git 命令别名和有用函数"
            "docker - Docker 命令补全和别名"
            "kubectl - Kubernetes 命令补全"
            "fzf - 模糊查找集成"
            "z/zoxide - 智能目录跳转"
            "nvm - Node 版本管理器集成"
            "pyenv - Python 版本管理器集成"
            "thefuck - 命令纠错工具"
            "autojump - 另一个目录跳转工具"
        )

        local selected_plugins=$(multi_select "选择要安装的插件:" "${plugins[@]}")
        export SELECTED_PLUGINS="$selected_plugins"

        if [ -n "$SELECTED_PLUGINS" ]; then
            local count=$(echo $SELECTED_PLUGINS | wc -w)
            print_success "已选择 $count 个插件"

            # 显示选中的插件
            for idx in $SELECTED_PLUGINS; do
                print_info "  • $(echo "${plugins[$idx]}" | cut -d' ' -f1)"
            done
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
        "Vim - 经典编辑器，轻量高效"
        "Neovim - 现代化 Vim，支持 LSP"
        "两者都配置"
        "跳过编辑器配置"
    )

    local editor_idx=$(select_option "选择要配置的编辑器:" "${editors[@]}")

    case $editor_idx in
        0) export CONFIGURE_VIM=1 ;;
        1) export CONFIGURE_NVIM=1 ;;
        2) export CONFIGURE_VIM=1; export CONFIGURE_NVIM=1 ;;
        3) ;;
    esac

    # Git 配置
    if confirm "是否配置 Git（用户名、邮箱、别名等）？"; then
        export CONFIGURE_GIT=1

        local git_name=$(input_text "Git 用户名" "Your Name")
        local git_email=$(input_text "Git 邮箱" "you@example.com")

        export GIT_USER_NAME="$git_name"
        export GIT_USER_EMAIL="$git_email"

        print_success "Git 配置已保存"
    fi

    # 开发语言环境
    local languages=(
        "Node.js/JavaScript - nvm, npm 配置"
        "Python - pyenv, pip 配置"
        "Go - GOPATH, modules 配置"
        "Rust - rustup, cargo 配置"
        "Ruby - rbenv, gem 配置"
        "Java - JAVA_HOME, Maven 配置"
    )

    local selected_langs=$(multi_select "选择要配置的开发语言环境:" "${languages[@]}")
    export SELECTED_LANGUAGES="$selected_langs"
}

# ============================================================================
# 显示配置摘要
# ============================================================================

show_summary() {
    print_section "配置摘要"

    if [ "$HAS_GUM" = "1" ]; then
        # 使用 Gum 创建漂亮的表格
        gum style \
            --border rounded \
            --border-foreground 212 \
            --padding "1 2" \
            --margin "1 0" \
            "$(cat <<EOF
配置项目                设置值
────────────────────────────────
Zsh 主题               ${SELECTED_ZSH_THEME:-未选择}
插件管理器              ${ZSH_MANAGER:-未选择}
已选插件数              $(echo ${SELECTED_PLUGINS:-} | wc -w)
配置 Vim               ${CONFIGURE_VIM:-否}
配置 Neovim            ${CONFIGURE_NVIM:-否}
配置 Git               ${CONFIGURE_GIT:-否}
EOF
        )"
    else
        echo "配置项目                设置值"
        echo "────────────────────────────────"
        echo "Zsh 主题               ${SELECTED_ZSH_THEME:-未选择}"
        echo "插件管理器              ${ZSH_MANAGER:-未选择}"
        echo "已选插件数              $(echo ${SELECTED_PLUGINS:-} | wc -w)"
        echo "配置 Vim               ${CONFIGURE_VIM:-否}"
        echo "配置 Neovim            ${CONFIGURE_NVIM:-否}"
        echo "配置 Git               ${CONFIGURE_GIT:-否}"
    fi
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    # 显示欢迎界面
    print_header

    # 提供安装 Gum 的选项
    install_gum

    # 如果成功安装了 Gum，重新显示欢迎界面
    if [ "$HAS_GUM" = "1" ]; then
        clear
        print_header
    fi

    # 运行配置步骤
    select_theme
    select_plugins
    configure_dev_tools

    # 显示摘要
    show_summary

    # 确认安装
    if confirm "确认以上配置并开始安装？"; then
        print_success "开始安装..."

        # 这里调用实际的安装脚本
        # ./install --only-links ...

        if [ "$HAS_GUM" = "1" ]; then
            gum spin --spinner dot --title "正在安装..." -- sleep 2
        else
            echo "正在安装..."
            sleep 2
        fi

        print_success "安装完成！"
    else
        print_warning "安装已取消"
    fi
}

# 运行主函数
main "$@"
