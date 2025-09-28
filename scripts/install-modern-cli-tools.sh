#!/bin/bash

# 现代 CLI 工具安装脚本
# 包含 Starship、McFly 和 Navi 的自动化安装和配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测系统类型
detect_system() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 检测包管理器
detect_package_manager() {
    if command -v brew &> /dev/null; then
        echo "brew"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "none"
    fi
}

# 安装 Starship
install_starship() {
    log_info "安装 Starship 跨 shell 提示符..."

    if command -v starship &> /dev/null; then
        log_warning "Starship 已安装，跳过安装步骤"
        return 0
    fi

    local system=$(detect_system)
    local package_manager=$(detect_package_manager)

    case "$package_manager" in
        "brew")
            brew install starship
            ;;
        "apt")
            # 对于 Debian/Ubuntu
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
        "yum")
            # 对于 RHEL/CentOS/Fedora
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
        "pacman")
            # 对于 Arch Linux
            sudo pacman -S starship --noconfirm
            ;;
        "zypper")
            # 对于 openSUSE
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
        *)
            # 通用安装方法
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
    esac

    log_success "Starship 安装完成"
}

# 安装 McFly
install_mcfly() {
    log_info "安装 McFly 智能 shell 历史..."

    if command -v mcfly &> /dev/null; then
        log_warning "McFly 已安装，跳过安装步骤"
        return 0
    fi

    local package_manager=$(detect_package_manager)

    case "$package_manager" in
        "brew")
            brew install mcfly
            ;;
        "apt")
            # 从 GitHub releases 安装
            install_mcfly_from_github
            ;;
        "yum")
            install_mcfly_from_github
            ;;
        "pacman")
            # Arch Linux AUR
            if command -v yay &> /dev/null; then
                yay -S mcfly --noconfirm
            elif command -v paru &> /dev/null; then
                paru -S mcfly --noconfirm
            else
                install_mcfly_from_github
            fi
            ;;
        *)
            install_mcfly_from_github
            ;;
    esac

    log_success "McFly 安装完成"
}

# 从 GitHub 安装 McFly
install_mcfly_from_github() {
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')

    # 映射架构名称
    case "$arch" in
        "x86_64") arch="x86_64" ;;
        "aarch64") arch="arm64" ;;
        "arm64") arch="arm64" ;;
        *) log_error "不支持的架构: $arch"; return 1 ;;
    esac

    # 获取最新版本
    local latest_version=$(curl -s https://api.github.com/repos/cantino/mcfly/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    local download_url="https://github.com/cantino/mcfly/releases/download/${latest_version}/mcfly-${latest_version}-${arch}-unknown-${os}-gnu.tar.gz"

    log_info "下载 McFly ${latest_version} for ${os}-${arch}..."

    # 创建临时目录
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # 下载并解压
    curl -L "$download_url" | tar xz

    # 安装到 /usr/local/bin
    sudo mv mcfly /usr/local/bin/
    sudo chmod +x /usr/local/bin/mcfly

    # 清理临时文件
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# 安装 Navi
install_navi() {
    log_info "安装 Navi 交互式命令行备忘单..."

    if command -v navi &> /dev/null; then
        log_warning "Navi 已安装，跳过安装步骤"
        return 0
    fi

    local package_manager=$(detect_package_manager)

    case "$package_manager" in
        "brew")
            brew install navi
            ;;
        "apt")
            install_navi_from_github
            ;;
        "yum")
            install_navi_from_github
            ;;
        "pacman")
            # Arch Linux
            sudo pacman -S navi --noconfirm
            ;;
        *)
            install_navi_from_github
            ;;
    esac

    log_success "Navi 安装完成"
}

# 从 GitHub 安装 Navi
install_navi_from_github() {
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')

    # 映射架构名称
    case "$arch" in
        "x86_64") arch="x86_64" ;;
        "aarch64") arch="aarch64" ;;
        "arm64") arch="aarch64" ;;
        *) log_error "不支持的架构: $arch"; return 1 ;;
    esac

    # 获取最新版本
    local latest_version=$(curl -s https://api.github.com/repos/denisidoro/navi/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    local download_url="https://github.com/denisidoro/navi/releases/download/${latest_version}/navi-${latest_version}-${arch}-unknown-${os}-musl.tar.gz"

    log_info "下载 Navi ${latest_version} for ${os}-${arch}..."

    # 创建临时目录
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # 下载并解压
    curl -L "$download_url" | tar xz

    # 安装到 /usr/local/bin
    sudo mv navi /usr/local/bin/
    sudo chmod +x /usr/local/bin/navi

    # 清理临时文件
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# 配置 shell 集成
configure_shell_integration() {
    log_info "配置 shell 集成..."

    local config_dir="$HOME/.config"
    local shell_config_dir="$(dirname "$0")/../config"

    # 确保配置目录存在
    mkdir -p "$config_dir"
    mkdir -p "$HOME/.local/share/navi/cheats"

    # 配置 Starship
    if command -v starship &> /dev/null; then
        log_info "配置 Starship..."

        # 复制 Starship 配置文件
        if [[ -f "$shell_config_dir/starship.toml" ]]; then
            cp "$shell_config_dir/starship.toml" "$config_dir/starship.toml"
            log_success "Starship 配置文件已复制"
        fi

        # 添加到 shell 配置
        add_starship_to_shell_config
    fi

    # 配置 McFly
    if command -v mcfly &> /dev/null; then
        log_info "配置 McFly..."

        # 复制 McFly 配置
        if [[ -f "$shell_config_dir/mcfly.sh" ]]; then
            cp "$shell_config_dir/mcfly.sh" "$HOME/.mcfly.sh"
            log_success "McFly 配置文件已复制"
        fi

        add_mcfly_to_shell_config
    fi

    # 配置 Navi
    if command -v navi &> /dev/null; then
        log_info "配置 Navi..."

        # 复制 Navi 配置文件
        if [[ -f "$shell_config_dir/navi-config.yaml" ]]; then
            mkdir -p "$HOME/.config/navi"
            cp "$shell_config_dir/navi-config.yaml" "$HOME/.config/navi/config.yaml"
            log_success "Navi 配置文件已复制"
        fi

        # 复制 Navi 脚本
        if [[ -f "$shell_config_dir/navi.sh" ]]; then
            cp "$shell_config_dir/navi.sh" "$HOME/.navi.sh"
            log_success "Navi 脚本已复制"
        fi

        # 复制备忘单文件
        if [[ -d "$shell_config_dir/navi-cheats" ]]; then
            cp -r "$shell_config_dir/navi-cheats"/* "$HOME/.local/share/navi/cheats/"
            log_success "Navi 备忘单已复制"
        fi

        add_navi_to_shell_config
    fi
}

# 添加 Starship 到 shell 配置
add_starship_to_shell_config() {
    local bashrc="$HOME/.bashrc"
    local zshrc="$HOME/.zshrc"

    # Bash 配置
    if [[ -f "$bashrc" ]]; then
        if ! grep -q "starship init bash" "$bashrc"; then
            echo 'eval "$(starship init bash)"' >> "$bashrc"
            log_success "Starship 已添加到 .bashrc"
        fi
    fi

    # Zsh 配置
    if [[ -f "$zshrc" ]]; then
        if ! grep -q "starship init zsh" "$zshrc"; then
            echo 'eval "$(starship init zsh)"' >> "$zshrc"
            log_success "Starship 已添加到 .zshrc"
        fi
    fi
}

# 添加 McFly 到 shell 配置
add_mcfly_to_shell_config() {
    local bashrc="$HOME/.bashrc"
    local zshrc="$HOME/.zshrc"

    # Bash 配置
    if [[ -f "$bashrc" ]]; then
        if ! grep -q "source.*\.mcfly\.sh" "$bashrc"; then
            echo '# McFly 智能 shell 历史' >> "$bashrc"
            echo '[[ -f "$HOME/.mcfly.sh" ]] && source "$HOME/.mcfly.sh"' >> "$bashrc"
            log_success "McFly 已添加到 .bashrc"
        fi
    fi

    # Zsh 配置
    if [[ -f "$zshrc" ]]; then
        if ! grep -q "source.*\.mcfly\.sh" "$zshrc"; then
            echo '# McFly 智能 shell 历史' >> "$zshrc"
            echo '[[ -f "$HOME/.mcfly.sh" ]] && source "$HOME/.mcfly.sh"' >> "$zshrc"
            log_success "McFly 已添加到 .zshrc"
        fi
    fi
}

# 添加 Navi 到 shell 配置
add_navi_to_shell_config() {
    local bashrc="$HOME/.bashrc"
    local zshrc="$HOME/.zshrc"

    # Bash 配置
    if [[ -f "$bashrc" ]]; then
        if ! grep -q "source.*\.navi\.sh" "$bashrc"; then
            echo '# Navi 交互式命令行备忘单' >> "$bashrc"
            echo '[[ -f "$HOME/.navi.sh" ]] && source "$HOME/.navi.sh"' >> "$bashrc"
            log_success "Navi 已添加到 .bashrc"
        fi
    fi

    # Zsh 配置
    if [[ -f "$zshrc" ]]; then
        if ! grep -q "source.*\.navi\.sh" "$zshrc"; then
            echo '# Navi 交互式命令行备忘单' >> "$zshrc"
            echo '[[ -f "$HOME/.navi.sh" ]] && source "$HOME/.navi.sh"' >> "$zshrc"
            log_success "Navi 已添加到 .zshrc"
        fi
    fi
}

# 主函数
main() {
    log_info "开始安装现代 CLI 工具..."

    # 检查权限
    if [[ $EUID -eq 0 ]]; then
        log_warning "检测到以 root 用户运行，某些配置可能不会正确应用"
    fi

    # 安装工具
    install_starship
    install_mcfly
    install_navi

    # 配置集成
    configure_shell_integration

    log_success "所有现代 CLI 工具安装和配置完成！"
    log_info "请重新启动 shell 或运行 'source ~/.bashrc' (或 ~/.zshrc) 来应用更改"

    # 显示版本信息
    echo
    log_info "已安装的工具版本："
    command -v starship &> /dev/null && echo "  Starship: $(starship --version)"
    command -v mcfly &> /dev/null && echo "  McFly: $(mcfly --version)"
    command -v navi &> /dev/null && echo "  Navi: $(navi --version)"
}

# 运行主函数
main "$@"
