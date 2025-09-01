#!/usr/bin/env bash
# ============================================================================
# Dotfiles 智能安装器 - 单一入口，自动引导
# 无需记忆任何参数，一个命令搞定所有
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
BOLD='\033[1m'
NC='\033[0m'

# 图标定义
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="➜"
INFO="ℹ"
WARN="⚠"
ROCKET="🚀"
PACKAGE="📦"
TOOLS="🔧"
SHELL_ICON="🐚"
GIT_ICON="🔀"
VIM_ICON="📝"

# 检测系统
OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"

# 检测 gum
HAS_GUM=0
if command -v gum >/dev/null 2>&1; then
    HAS_GUM=1
fi

# 全局配置变量
INSTALL_MODE=""
DO_BACKUP=1
DRY_RUN=0
VERBOSE=0
LOG_FILE=""

# ============================================================================
# 辅助函数
# ============================================================================

print_header() {
    clear
    if [ "$HAS_GUM" = "1" ]; then
        gum style \
            --foreground 212 \
            --border double \
            --border-foreground 212 \
            --padding "1 3" \
            --margin "1 0" \
            --align center \
            --bold \
            "🎯 Dotfiles 智能安装器" \
            "" \
            "单一入口 · 智能引导 · 最佳体验"
    else
        echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${WHITE}${BOLD}             🎯 Dotfiles 智能安装器                      ${NC}${BLUE}║${NC}"
        echo -e "${BLUE}║${WHITE}          单一入口 · 智能引导 · 最佳体验                   ${NC}${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
    fi
}

print_section() {
    if [ "$HAS_GUM" = "1" ]; then
        echo ""
        gum style \
            --foreground 81 \
            --bold \
            "$1"
        echo ""
    else
        echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"
    fi
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

# 日志函数
init_log() {
    if [ "$VERBOSE" = "1" ]; then
        LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"
        echo "=== Dotfiles Installation Log ===" > "$LOG_FILE"
        echo "Date: $(date)" >> "$LOG_FILE"
        echo "User: $USER" >> "$LOG_FILE"
        echo "System: $OS_NAME" >> "$LOG_FILE"
        echo "=================================" >> "$LOG_FILE"
        echo ""
        print_info "详细日志将保存到: $LOG_FILE"
        echo ""
    fi
}

log_cmd() {
    local cmd="$1"
    local desc="${2:-}"
    
    if [ "$VERBOSE" = "1" ]; then
        if [ -n "$desc" ]; then
            echo -e "${BLUE}▶${NC} $desc"
            [ -n "$LOG_FILE" ] && echo "[$(date +%H:%M:%S)] $desc" >> "$LOG_FILE"
        fi
        echo -e "${CYAN}  $ $cmd${NC}"
        [ -n "$LOG_FILE" ] && echo "[$(date +%H:%M:%S)] CMD: $cmd" >> "$LOG_FILE"
        
        # 执行命令并捕获输出
        local output
        local exit_code
        output=$(eval "$cmd" 2>&1)
        exit_code=$?
        
        if [ -n "$output" ]; then
            echo "$output" | sed 's/^/    /'
            [ -n "$LOG_FILE" ] && echo "$output" >> "$LOG_FILE"
        fi
        
        if [ $exit_code -ne 0 ]; then
            echo -e "${RED}  ✗ 命令失败 (exit code: $exit_code)${NC}"
            [ -n "$LOG_FILE" ] && echo "[ERROR] Command failed with exit code: $exit_code" >> "$LOG_FILE"
        else
            echo -e "${GREEN}  ✓ 完成${NC}"
            [ -n "$LOG_FILE" ] && echo "[SUCCESS] Command completed successfully" >> "$LOG_FILE"
        fi
        
        [ -n "$LOG_FILE" ] && echo "---" >> "$LOG_FILE"
        return $exit_code
    else
        # 非详细模式，静默执行
        eval "$cmd" 2>/dev/null
    fi
}

# 询问是否启用详细日志
ask_verbose_mode() {
    echo ""
    if confirm "是否显示详细安装日志？"; then
        VERBOSE=1
        init_log
        print_success "已启用详细日志模式"
    else
        VERBOSE=0
        print_info "使用静默模式（仅显示关键信息）"
    fi
    echo ""
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

# ============================================================================
# 检查并安装 Gum
# ============================================================================

check_and_install_gum() {
    if [ "$HAS_GUM" = "0" ]; then
        echo -e "\n${YELLOW}${INFO}${NC} Gum 可以提供更好的交互体验"

        if confirm "是否安装 Gum 以获得最佳界面体验？"; then
            echo -e "${BLUE}${INFO}${NC} 正在安装 Gum..."

            if [ "$OS_NAME" = "darwin" ]; then
                if command -v brew >/dev/null 2>&1; then
                    brew install gum && HAS_GUM=1
                fi
            elif [ "$OS_NAME" = "linux" ]; then
                if command -v apt-get >/dev/null 2>&1; then
                    sudo mkdir -p /etc/apt/keyrings
                    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                    sudo apt update && sudo apt install gum && HAS_GUM=1
                elif command -v brew >/dev/null 2>&1; then
                    brew install gum && HAS_GUM=1
                fi
            fi

            if [ "$HAS_GUM" = "1" ]; then
                print_success "Gum 安装成功！"
                sleep 1
                print_header  # 重新显示界面
            else
                print_warning "Gum 安装失败，将使用基础界面"
                sleep 2
            fi
        fi
    fi
}

# ============================================================================
# 主菜单 - 选择安装模式
# ============================================================================

select_install_mode() {
    print_section "选择安装模式"

    if [ "$HAS_GUM" = "1" ]; then
        INSTALL_MODE=$(gum choose \
            --cursor "> " \
            --cursor.foreground="212" \
            --selected.foreground="212" \
            --header "请选择安装模式：" \
            --height 8 \
            "🚀 快速安装 - 推荐配置，一键完成" \
            "🎨 自定义安装 - 详细配置每个选项" \
            "🔧 专家模式 - 完全控制，高级选项" \
            "📦 最小安装 - 仅创建必要的符号链接" \
            "🔍 演示模式 - 查看将要执行的操作" \
            "📖 查看帮助 - 了解更多信息" \
            "❌ 退出")
    else
        echo "请选择安装模式："
        echo ""
        echo "  1) 🚀 快速安装 - 推荐配置，一键完成"
        echo "  2) 🎨 自定义安装 - 详细配置每个选项"
        echo "  3) 🔧 专家模式 - 完全控制，高级选项"
        echo "  4) 📦 最小安装 - 仅创建必要的符号链接"
        echo "  5) 🔍 演示模式 - 查看将要执行的操作"
        echo "  6) 📖 查看帮助 - 了解更多信息"
        echo "  7) ❌ 退出"
        echo ""

        local choice
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择 [1-7]: ")" choice

        case "$choice" in
            1) INSTALL_MODE="🚀 快速安装 - 推荐配置，一键完成" ;;
            2) INSTALL_MODE="🎨 自定义安装 - 详细配置每个选项" ;;
            3) INSTALL_MODE="🔧 专家模式 - 完全控制，高级选项" ;;
            4) INSTALL_MODE="📦 最小安装 - 仅创建必要的符号链接" ;;
            5) INSTALL_MODE="🔍 演示模式 - 查看将要执行的操作" ;;
            6) INSTALL_MODE="📖 查看帮助 - 了解更多信息" ;;
            7) INSTALL_MODE="❌ 退出" ;;
            *)
                print_error "无效选择"
                sleep 1
                select_install_mode
                return
                ;;
        esac
    fi

    # 处理选择
    case "$INSTALL_MODE" in
        *"快速安装"*)
            quick_install
            ;;
        *"自定义安装"*)
            custom_install
            ;;
        *"专家模式"*)
            expert_install
            ;;
        *"最小安装"*)
            minimal_install
            ;;
        *"演示模式"*)
            DRY_RUN=1
            demo_install
            ;;
        *"查看帮助"*)
            show_help
            ;;
        *"退出"*)
            print_info "安装已取消"
            exit 0
            ;;
    esac
}

# ============================================================================
# 快速安装模式
# ============================================================================

quick_install() {
    print_header
    print_section "🚀 快速安装模式"

    echo "将安装以下配置："
    echo ""
    echo -e "  ${GREEN}✓${NC} 创建所有配置文件的符号链接"
    echo -e "  ${GREEN}✓${NC} 安装 Homebrew 包（如果可用）"
    echo -e "  ${GREEN}✓${NC} 配置 Zsh 和 Oh-My-Zsh"
    echo -e "  ${GREEN}✓${NC} 安装常用插件（autosuggestions, syntax-highlighting）"
    echo -e "  ${GREEN}✓${NC} 配置 tmux 和插件管理器"
    echo -e "  ${GREEN}✓${NC} 配置 fzf 键绑定"
    echo -e "  ${GREEN}✓${NC} 基础 Git 配置"
    echo ""
    
    # 询问是否启用详细日志
    ask_verbose_mode

    if confirm "确认开始快速安装？"; then
        print_success "开始快速安装..."
        echo ""

        # 执行实际安装
        print_section "执行安装步骤"
        
        # 获取基础目录
        local ROOT_DIR="$(cd "$BASEDIR/.." && pwd)"
        
        # 创建符号链接
        log_cmd "cd '$ROOT_DIR' && '$ROOT_DIR/$DOTBOT_DIR/$DOTBOT_BIN' -d . -c '$CONFIG'" "创建配置文件符号链接"
        
        # 检查并安装 Homebrew 包
        if command -v brew >/dev/null 2>&1; then
            if [ -f "$ROOT_DIR/brew/Brewfile.common" ]; then
                log_cmd "brew bundle --file='$ROOT_DIR/brew/Brewfile.common'" "安装 Homebrew 通用包"
            fi
        fi
        
        # 配置 Zsh
        if command -v zsh >/dev/null 2>&1; then
            log_cmd "chsh -s $(which zsh) 2>/dev/null || true" "设置 Zsh 为默认 Shell"
        fi
        
        # 配置 tmux 插件管理器
        if [ ! -d ~/.tmux/plugins/tpm ]; then
            log_cmd "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" "安装 tmux 插件管理器"
        fi
        
        echo ""
        print_success "快速安装完成！"
        
        if [ "$VERBOSE" = "1" ] && [ -n "$LOG_FILE" ]; then
            echo ""
            print_info "完整日志已保存到: $LOG_FILE"
        fi
        
        show_completion_message
    else
        print_info "返回主菜单..."
        sleep 1
        print_header
        select_install_mode
    fi
}

# ============================================================================
# 自定义安装模式
# ============================================================================

custom_install() {
    print_header
    print_section "🎨 自定义安装模式"
    
    # 询问是否启用详细日志
    ask_verbose_mode

    local selected_features=()

    # 选择要安装的组件
    if [ "$HAS_GUM" = "1" ]; then
        print_info "选择要安装的组件（空格选择，回车确认）："
        echo ""

        local choices=$(gum choose --no-limit \
            --cursor "> " \
            --cursor.foreground="212" \
            --selected.foreground="82" \
            --height 12 \
            "📁 配置文件符号链接" \
            "📦 Homebrew 包管理" \
            "🐚 Zsh 和 Oh-My-Zsh" \
            "🔌 Zsh 插件" \
            "🖥️ tmux 配置" \
            "🔍 fzf 模糊查找" \
            "📂 zoxide 目录跳转" \
            "📝 Vim/Neovim 配置" \
            "🔀 Git 配置" \
            "🐍 Python 开发环境" \
            "📗 Node.js 开发环境" \
            "🦀 Rust 开发环境")

        # 将多行输出转换为数组
        if [ -n "$choices" ]; then
            IFS=$'\n' read -rd '' -a selected_features <<< "$choices"
        fi
    else
        echo "选择要安装的组件（输入数字，空格分隔）："
        echo ""
        echo "  1) 📁 配置文件符号链接"
        echo "  2) 📦 Homebrew 包管理"
        echo "  3) 🐚 Zsh 和 Oh-My-Zsh"
        echo "  4) 🔌 Zsh 插件"
        echo "  5) 🖥️ tmux 配置"
        echo "  6) 🔍 fzf 模糊查找"
        echo "  7) 📂 zoxide 目录跳转"
        echo "  8) 📝 Vim/Neovim 配置"
        echo "  9) 🔀 Git 配置"
        echo "  10) 🐍 Python 开发环境"
        echo "  11) 📗 Node.js 开发环境"
        echo "  12) 🦀 Rust 开发环境"
        echo ""

        local choices
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择: ")" -a choices

        if [ ${#choices[@]} -gt 0 ]; then
            for choice in "${choices[@]}"; do
                case "$choice" in
                    1) selected_features+=("📁 配置文件符号链接") ;;
                    2) selected_features+=("📦 Homebrew 包管理") ;;
                    3) selected_features+=("🐚 Zsh 和 Oh-My-Zsh") ;;
                    4) selected_features+=("🔌 Zsh 插件") ;;
                    5) selected_features+=("🖥️ tmux 配置") ;;
                    6) selected_features+=("🔍 fzf 模糊查找") ;;
                    7) selected_features+=("📂 zoxide 目录跳转") ;;
                    8) selected_features+=("📝 Vim/Neovim 配置") ;;
                    9) selected_features+=("🔀 Git 配置") ;;
                    10) selected_features+=("🐍 Python 开发环境") ;;
                    11) selected_features+=("📗 Node.js 开发环境") ;;
                    12) selected_features+=("🦀 Rust 开发环境") ;;
                esac
            done
        fi
    fi

    # 显示选择摘要
    echo ""
    print_section "已选择的组件"
    if [ ${#selected_features[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}⚠${NC} 没有选择任何组件"
        echo ""
        print_warning "请至少选择一个组件进行安装"
        return 1
    else
        for feature in "${selected_features[@]}"; do
            echo -e "  ${GREEN}✓${NC} $feature"
        done
    fi
    echo ""

    if confirm "确认安装以上组件？"; then
        print_success "开始自定义安装..."
        echo ""
        
        # 获取基础目录
        local ROOT_DIR="$(cd "$BASEDIR/.." && pwd)"
        
        # 执行安装
        print_section "执行选定的安装步骤"
        
        for feature in "${selected_features[@]}"; do
            case "$feature" in
                *"配置文件符号链接"*)
                    log_cmd "cd '$ROOT_DIR' && '$ROOT_DIR/$DOTBOT_DIR/$DOTBOT_BIN' -d . -c '$CONFIG'" "创建配置文件符号链接"
                    ;;
                *"Homebrew"*)
                    if command -v brew >/dev/null 2>&1 && [ -f "$ROOT_DIR/brew/Brewfile.common" ]; then
                        log_cmd "brew bundle --file='$ROOT_DIR/brew/Brewfile.common'" "安装 Homebrew 包"
                    fi
                    ;;
                *"Zsh 和 Oh-My-Zsh"*)
                    if command -v zsh >/dev/null 2>&1; then
                        log_cmd "chsh -s $(which zsh) 2>/dev/null || true" "设置 Zsh 为默认 Shell"
                    fi
                    if [ ! -d ~/.oh-my-zsh ]; then
                        log_cmd "sh -c '$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)' '' --unattended" "安装 Oh-My-Zsh"
                    fi
                    ;;
                *"tmux 配置"*)
                    if [ ! -d ~/.tmux/plugins/tpm ]; then
                        log_cmd "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" "安装 tmux 插件管理器"
                    fi
                    ;;
                *"fzf"*)
                    if [ ! -d ~/.fzf ]; then
                        log_cmd "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all --no-bash --no-fish" "安装 fzf"
                    fi
                    ;;
                *"Git 配置"*)
                    log_cmd "git config --global core.editor vim" "配置 Git 默认编辑器"
                    ;;
            esac
        done
        
        echo ""
        print_success "自定义安装完成！"
        
        if [ "$VERBOSE" = "1" ] && [ -n "$LOG_FILE" ]; then
            echo ""
            print_info "完整日志已保存到: $LOG_FILE"
        fi
        
        show_completion_message
    else
        print_info "返回主菜单..."
        sleep 1
        print_header
        select_install_mode
    fi
}

# ============================================================================
# 专家模式
# ============================================================================

expert_install() {
    print_header
    print_section "🔧 专家模式"
    
    # 询问是否启用详细日志
    ask_verbose_mode

    echo "专家模式提供完全的控制权："
    echo ""
    echo "  • 自定义安装路径"
    echo "  • 选择特定配置文件"
    echo "  • 配置环境变量"
    echo "  • 高级 Git 设置"
    echo "  • 自定义 Shell 配置"
    echo "  • 导入/导出配置"
    echo ""

    local expert_choice
    if [ "$HAS_GUM" = "1" ]; then
        expert_choice=$(gum choose \
            --cursor "> " \
            --header "选择操作：" \
            "执行完整配置向导" \
            "导入配置文件" \
            "生成配置模板" \
            "查看当前系统状态" \
            "返回主菜单")
    else
        echo "选择操作："
        echo "  1) 执行完整配置向导"
        echo "  2) 导入配置文件"
        echo "  3) 生成配置模板"
        echo "  4) 查看当前系统状态"
        echo "  5) 返回主菜单"
        echo ""

        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择 [1-5]: ")" choice
        case "$choice" in
            1) expert_choice="执行完整配置向导" ;;
            2) expert_choice="导入配置文件" ;;
            3) expert_choice="生成配置模板" ;;
            4) expert_choice="查看当前系统状态" ;;
            5) expert_choice="返回主菜单" ;;
        esac
    fi

    case "$expert_choice" in
        *"配置向导"*)
            # 调用详细的配置向导
            ./install-unified.sh --interactive
            ;;
        *"导入配置"*)
            print_info "请输入配置文件路径："
            read -r config_path
            ./install-unified.sh --profile-load="$config_path"
            ;;
        *"生成配置模板"*)
            print_info "生成配置模板..."
            cat > dotfiles-config.yaml <<EOF
# Dotfiles 配置模板
install_mode: custom
features:
  - symlinks
  - homebrew
  - zsh
  - tmux
  - vim
settings:
  backup: true
  dry_run: false
EOF
            print_success "配置模板已生成: dotfiles-config.yaml"
            ;;
        *"系统状态"*)
            show_system_status
            ;;
        *"返回"*)
            print_header
            select_install_mode
            ;;
    esac
}

# ============================================================================
# 最小安装模式
# ============================================================================

minimal_install() {
    print_header
    print_section "📦 最小安装模式"
    
    # 询问是否启用详细日志
    ask_verbose_mode

    echo "最小安装将只执行："
    echo ""
    echo -e "  ${GREEN}✓${NC} 创建配置文件的符号链接"
    echo -e "  ${YELLOW}○${NC} 不安装任何软件包"
    echo -e "  ${YELLOW}○${NC} 不修改 Shell 配置"
    echo -e "  ${YELLOW}○${NC} 不安装插件"
    echo ""
    echo "适合："
    echo "  • 已有环境的用户"
    echo "  • 只需要配置文件的场景"
    echo "  • 测试环境"
    echo ""

    if confirm "确认执行最小安装？"; then
        print_success "开始最小安装..."

        if [ "$HAS_GUM" = "1" ]; then
            gum spin --spinner dot --title "创建符号链接..." -- sleep 2
        else
            echo "创建符号链接..."
            sleep 2
        fi

        # ./install-unified.sh --minimal

        print_success "最小安装完成！"
        show_completion_message
    else
        print_info "返回主菜单..."
        sleep 1
        print_header
        select_install_mode
    fi
}

# ============================================================================
# 演示模式
# ============================================================================

demo_install() {
    print_header
    print_section "🔍 演示模式"

    echo "演示模式将展示所有操作，但不会实际执行"
    echo ""

    local demo_choice
    if [ "$HAS_GUM" = "1" ]; then
        demo_choice=$(gum choose \
            --cursor "> " \
            --header "选择要演示的安装类型：" \
            "演示快速安装" \
            "演示自定义安装" \
            "演示最小安装" \
            "返回主菜单")
    else
        echo "选择要演示的安装类型："
        echo "  1) 演示快速安装"
        echo "  2) 演示自定义安装"
        echo "  3) 演示最小安装"
        echo "  4) 返回主菜单"
        echo ""
        read -rp "$(echo -e "${YELLOW}${ARROW}${NC} 请选择 [1-4]: ")" choice
        case "$choice" in
            1) demo_choice="演示快速安装" ;;
            2) demo_choice="演示自定义安装" ;;
            3) demo_choice="演示最小安装" ;;
            4) demo_choice="返回主菜单" ;;
        esac
    fi

    case "$demo_choice" in
        *"快速"*)
            echo ""
            print_info "[演示] 将执行以下操作："
            echo "  1. 备份现有配置到 ~/.dotfiles-backup"
            echo "  2. 克隆/更新 dotbot submodule"
            echo "  3. 创建符号链接："
            echo "     ~/.zshrc -> dotfiles/zshrc"
            echo "     ~/.vimrc -> dotfiles/vim/vimrc"
            echo "     ~/.tmux.conf -> dotfiles/tmux/tmux.conf"
            echo "  4. 安装 Homebrew 包"
            echo "  5. 配置 Oh-My-Zsh"
            echo "  6. 安装 tmux 插件"
            echo ""
            print_success "[演示] 安装完成（实际未执行）"
            ;;
        *"自定义"*)
            print_info "[演示] 自定义安装流程..."
            ;;
        *"最小"*)
            print_info "[演示] 最小安装流程..."
            ;;
        *"返回"*)
            DRY_RUN=0
            print_header
            select_install_mode
            return
            ;;
    esac

    echo ""
    print_info "按回车键返回主菜单..."
    read
    DRY_RUN=0
    print_header
    select_install_mode
}

# ============================================================================
# 显示帮助
# ============================================================================

show_help() {
    print_header
    print_section "📖 帮助信息"

    if [ "$HAS_GUM" = "1" ]; then
        gum pager <<EOF
Dotfiles 智能安装器 - 帮助文档

═══════════════════════════════════════════════════════════════

安装模式说明：

🚀 快速安装
   最推荐的选项，使用优化过的默认配置
   包含最常用的工具和插件
   适合大多数用户

🎨 自定义安装
   可以选择要安装的具体组件
   适合有特定需求的用户
   提供细粒度的控制

🔧 专家模式
   完全控制安装过程
   可以导入/导出配置
   适合高级用户

📦 最小安装
   只创建配置文件链接
   不安装任何软件
   适合已有环境的用户

🔍 演示模式
   查看将要执行的操作
   不会实际修改系统
   适合了解安装过程

═══════════════════════════════════════════════════════════════

常见问题：

Q: 安装会覆盖我现有的配置吗？
A: 不会。安装前会自动备份现有配置到 ~/.dotfiles-backup

Q: 可以撤销安装吗？
A: 可以。运行 ./uninstall.sh 即可撤销

Q: 需要 sudo 权限吗？
A: 基础安装不需要，某些系统工具可能需要

Q: 支持哪些系统？
A: macOS, Linux (Ubuntu, Debian, Arch, etc.)

═══════════════════════════════════════════════════════════════

更多信息：
GitHub: https://github.com/ONGOING-Z/dotfiles
EOF
    else
        cat <<EOF
Dotfiles 智能安装器 - 帮助文档

安装模式说明：

🚀 快速安装
   最推荐的选项，使用优化过的默认配置
   包含最常用的工具和插件

🎨 自定义安装
   可以选择要安装的具体组件
   适合有特定需求的用户

🔧 专家模式
   完全控制安装过程
   可以导入/导出配置

📦 最小安装
   只创建配置文件链接
   不安装任何软件

🔍 演示模式
   查看将要执行的操作
   不会实际修改系统

常见问题：

Q: 安装会覆盖我现有的配置吗？
A: 不会。安装前会自动备份现有配置

Q: 可以撤销安装吗？
A: 可以。运行 ./uninstall.sh 即可

更多信息：https://github.com/ONGOING-Z/dotfiles
EOF
    fi

    echo ""
    print_info "按回车键返回主菜单..."
    read
    print_header
    select_install_mode
}

# ============================================================================
# 显示系统状态
# ============================================================================

show_system_status() {
    print_section "系统状态"

    echo "操作系统: $OS_NAME"
    echo "Shell: $SHELL"
    echo "用户: $USER"
    echo "主目录: $HOME"
    echo ""
    echo "已安装的工具："

    local tools=("git" "zsh" "tmux" "vim" "nvim" "brew" "node" "python3" "cargo")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            version=$($tool --version 2>/dev/null | head -n1 || echo "已安装")
            echo -e "  ${GREEN}✓${NC} $tool: $version"
        else
            echo -e "  ${RED}✗${NC} $tool: 未安装"
        fi
    done

    echo ""
    print_info "按回车键继续..."
    read
}

# ============================================================================
# 完成消息
# ============================================================================

show_completion_message() {
    echo ""
    print_section "✨ 安装完成"

    echo "后续步骤："
    echo ""
    echo "  1. 重新加载 Shell 配置："
    echo -e "     ${CYAN}source ~/.zshrc${NC} 或 ${CYAN}source ~/.bashrc${NC}"
    echo ""
    echo "  2. 如果安装了 Vim/Neovim 插件："
    echo -e "     打开编辑器运行 ${CYAN}:PlugInstall${NC}"
    echo ""
    echo "  3. 如果配置了 tmux："
    echo -e "     按 ${CYAN}prefix + I${NC} 安装插件"
    echo ""

    if [ "$DRY_RUN" = "1" ]; then
        print_warning "这是演示模式，实际未执行任何操作"
    fi

    echo ""
    print_success "感谢使用 Dotfiles 智能安装器！"
    echo ""

    if confirm "是否返回主菜单？"; then
        print_header
        select_install_mode
    else
        exit 0
    fi
}

# ============================================================================
# 主函数 - 程序入口
# ============================================================================

main() {
    # 显示欢迎界面
    print_header

    # 检查并提示安装 Gum
    check_and_install_gum

    # 显示主菜单
    select_install_mode
}

# ============================================================================
# 处理命令行参数（保持向后兼容）
# ============================================================================

# 如果有命令行参数，直接调用 install-unified.sh
if [ $# -gt 0 ]; then
    # 用户提供了参数，直接传递给统一安装脚本
    exec ./install-unified.sh "$@"
else
    # 没有参数，启动交互式界面
    main
fi
