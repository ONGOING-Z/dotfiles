#!/usr/bin/env bash
# 快速设置脚本 - 一键部署 Dotfiles

set -euo pipefail

# 配置
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/ONGOING-Z/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-macos}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $*"
}

error() {
    echo -e "${RED}[错误]${NC} $*" >&2
}

success() {
    echo -e "${GREEN}[成功]${NC} $*"
}

warning() {
    echo -e "${YELLOW}[警告]${NC} $*"
}

# 显示欢迎信息
show_banner() {
    echo -e "${MAGENTA}"
    echo "╔═══════════════════════════════════════╗"
    echo "║       Dotfiles 快速安装脚本           ║"
    echo "║   https://github.com/ONGOING-Z        ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查系统要求
check_requirements() {
    log "检查系统要求..."

    # 检查 Git
    if ! command -v git >/dev/null 2>&1; then
        error "Git 未安装"

        # 尝试自动安装
        if [[ "$OSTYPE" == "darwin"* ]] && command -v brew >/dev/null 2>&1; then
            log "使用 Homebrew 安装 Git..."
            brew install git
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get >/dev/null 2>&1; then
                log "使用 apt-get 安装 Git..."
                sudo apt-get update && sudo apt-get install -y git
            elif command -v dnf >/dev/null 2>&1; then
                log "使用 dnf 安装 Git..."
                sudo dnf install -y git
            else
                error "请手动安装 Git"
                exit 1
            fi
        else
            error "请手动安装 Git"
            exit 1
        fi
    fi

    success "系统要求检查通过"
}

# 备份现有配置
backup_existing_configs() {
    log "备份现有配置..."

    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local files_to_backup=(
        .bashrc .bash_profile .bash_aliases
        .zshrc .zprofile
        .vimrc .vim
        .tmux.conf
        .gitconfig
        .config/nvim
    )

    local need_backup=false
    for file in "${files_to_backup[@]}"; do
        if [ -e "$HOME/$file" ]; then
            need_backup=true
            break
        fi
    done

    if [ "$need_backup" = true ]; then
        mkdir -p "$backup_dir"

        for file in "${files_to_backup[@]}"; do
            if [ -e "$HOME/$file" ]; then
                log "备份 $file"
                cp -r "$HOME/$file" "$backup_dir/" 2>/dev/null || true
            fi
        done

        success "配置已备份到: $backup_dir"
    else
        log "没有需要备份的配置"
    fi
}

# 克隆仓库
clone_repository() {
    log "克隆 Dotfiles 仓库..."

    if [ -d "$DOTFILES_DIR" ]; then
        warning "目录 $DOTFILES_DIR 已存在"
        read -rp "是否删除并重新克隆? [y/N] " -n 1
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$DOTFILES_DIR"
        else
            log "进入现有目录并更新..."
            cd "$DOTFILES_DIR"
            git pull origin "$DOTFILES_BRANCH"
            return
        fi
    fi

    # 克隆仓库
    if git clone --recursive -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        success "仓库克隆成功"
    else
        error "仓库克隆失败"
        exit 1
    fi

    cd "$DOTFILES_DIR"
}

# 设置权限
setup_permissions() {
    log "设置文件权限..."

    # 设置脚本执行权限
    find . -name "*.sh" -type f -exec chmod +x {} \;
    chmod +x install

    success "权限设置完成"
}

# 选择安装模式
select_install_mode() {
    echo -e "\n${CYAN}选择安装模式:${NC}"
    echo "1) 🚀 快速安装 - 推荐配置，适合大多数用户"
    echo "2) 🎯 最小安装 - 仅安装核心配置"
    echo "3) 🎨 自定义安装 - 选择要安装的组件"
    echo "4) 💻 开发者安装 - 完整的开发环境"
    echo "5) 🔧 专家模式 - 完全控制安装过程"
    echo ""

    read -rp "请选择 (1-5) [默认: 1]: " mode
    mode=${mode:-1}

    case $mode in
        1) INSTALL_MODE="--quick" ;;
        2) INSTALL_MODE="--minimal" ;;
        3) INSTALL_MODE="" ;;  # 默认交互模式
        4) INSTALL_MODE="--developer" ;;
        5) INSTALL_MODE="--expert" ;;
        *)
            warning "无效选择，使用快速安装"
            INSTALL_MODE="--quick"
            ;;
    esac
}

# 运行安装
run_installation() {
    log "开始安装..."

    if [ -n "$INSTALL_MODE" ]; then
        ./install $INSTALL_MODE
    else
        ./install
    fi

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        success "安装完成!"
    else
        error "安装过程中出现错误 (退出码: $exit_code)"
        exit $exit_code
    fi
}

# 后续设置
post_install_setup() {
    log "执行安装后设置..."

    # 运行健康检查
    if [ -f ./install ]; then
        log "运行健康检查..."
        ./install --health-check || true
    fi

    # 提示用户
    echo ""
    echo -e "${GREEN}🎉 Dotfiles 安装完成！${NC}"
    echo ""
    echo "下一步:"
    echo "1. 重新启动终端或运行: source ~/.bashrc (或 ~/.zshrc)"
    echo "2. 运行健康检查: ~/dotfiles/install --health-check"
    echo "3. 查看自定义指南: ~/dotfiles/docs/CUSTOMIZATION.md"
    echo ""
    echo "有问题? 查看故障排除指南:"
    echo "  ~/dotfiles/docs/TROUBLESHOOTING.md"
}

# 错误处理
handle_error() {
    local exit_code=$?
    error "脚本执行失败 (退出码: $exit_code)"

    echo ""
    echo "调试信息:"
    echo "- 工作目录: $(pwd)"
    echo "- 用户: $(whoami)"
    echo "- Shell: $SHELL"
    echo "- 系统: $(uname -a)"

    exit $exit_code
}

# 主函数
main() {
    # 设置错误处理
    trap handle_error ERR

    # 显示欢迎信息
    show_banner

    # 确认安装
    echo "此脚本将:"
    echo "  • 备份您的现有配置"
    echo "  • 克隆 Dotfiles 仓库到 $DOTFILES_DIR"
    echo "  • 运行交互式安装程序"
    echo ""

    read -rp "是否继续? [Y/n] " -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        echo "安装已取消"
        exit 0
    fi

    # 执行安装步骤
    check_requirements
    backup_existing_configs
    clone_repository
    setup_permissions
    select_install_mode
    run_installation
    post_install_setup
}

# 支持通过 curl/wget 管道执行
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
