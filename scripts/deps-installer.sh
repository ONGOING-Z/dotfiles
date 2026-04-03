#!/usr/bin/env bash
# 依赖检查和自动安装工具

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

OS_TYPE=$(detect_os)

# 必需的依赖
REQUIRED_DEPS=(
    "git:版本控制"
    "curl:网络下载"
    "bash:Shell 环境"
)

# 推荐的依赖
RECOMMENDED_DEPS=(
    "zsh:Z Shell"
    "tmux:终端复用器"
    "vim:文本编辑器"
    "fzf:模糊搜索"
    "rg:ripgrep 搜索"
    "fd:文件查找"
    "bat:更好的 cat"
    "eza:更好的 ls"
    "zoxide:智能目录跳转"
    "gum:交互式 UI"
)

# 开发依赖
DEV_DEPS=(
    "python3:Python 3"
    "node:Node.js"
    "go:Go 语言"
    "rust:Rust 语言"
    "docker:容器化"
)

# 检查单个依赖
check_dependency() {
    local dep="$1"
    local name="${dep%%:*}"
    local desc="${dep#*:}"

    if command -v "$name" >/dev/null 2>&1; then
        local version=$($name --version 2>/dev/null | head -1 || echo "已安装")
        echo -e "${GREEN}✓${NC} $desc ($name): $version"
        return 0
    else
        echo -e "${RED}✗${NC} $desc ($name): 未安装"
        return 1
    fi
}

# 安装依赖
install_dependency() {
    local dep="$1"
    local name="${dep%%:*}"

    echo -e "${BLUE}安装 $name...${NC}"

    case "$OS_TYPE" in
        macos)
            if command -v brew >/dev/null 2>&1; then
                brew install "$name"
            else
                echo -e "${RED}需要先安装 Homebrew${NC}"
                return 1
            fi
            ;;
        debian)
            sudo apt-get update -qq
            sudo apt-get install -y "$name"
            ;;
        redhat)
            sudo dnf install -y "$name"
            ;;
        arch)
            sudo pacman -S --noconfirm "$name"
            ;;
        *)
            echo -e "${RED}不支持的操作系统${NC}"
            return 1
            ;;
    esac
}

# 特殊安装函数
install_special() {
    local name="$1"

    case "$name" in
        fzf)
            if [ ! -d ~/.fzf ]; then
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --all --no-bash --no-fish
            fi
            ;;
        zoxide)
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            ;;
        gum)
            if [ "$OS_TYPE" = "macos" ]; then
                brew install gum
            else
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                sudo apt update && sudo apt install gum
            fi
            ;;
        rust)
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            ;;
        *)
            return 1
            ;;
    esac
}

# 检查所有依赖
check_all_deps() {
    local category="$1"
    shift
    local deps=("$@")
    local missing=()

    echo -e "\n${BLUE}=== $category ===${NC}"

    for dep in "${deps[@]}"; do
        if ! check_dependency "$dep"; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}缺少 ${#missing[@]} 个依赖${NC}"
        return 1
    else
        echo -e "\n${GREEN}所有依赖已安装${NC}"
        return 0
    fi
}

# 交互式安装
interactive_install() {
    local missing_deps=("$@")

    echo -e "\n${YELLOW}发现缺失的依赖:${NC}"
    for dep in "${missing_deps[@]}"; do
        local name="${dep%%:*}"
        local desc="${dep#*:}"
        echo "  - $desc ($name)"
    done

    echo ""
    read -rp "是否自动安装这些依赖? [Y/n] " response

    if [[ "$response" =~ ^[Yy]?$ ]]; then
        for dep in "${missing_deps[@]}"; do
            local name="${dep%%:*}"

            # 尝试特殊安装方法
            if ! install_special "$name" 2>/dev/null; then
                # 使用包管理器安装
                install_dependency "$dep" || {
                    echo -e "${RED}安装 $name 失败${NC}"
                }
            fi
        done
    fi
}

# 主函数
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         依赖检查和安装工具            ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"

    echo -e "\n操作系统: $OS_TYPE"

    # 检查必需依赖
    local all_missing=()

    if ! check_all_deps "必需依赖" "${REQUIRED_DEPS[@]}"; then
        for dep in "${REQUIRED_DEPS[@]}"; do
            local name="${dep%%:*}"
            if ! command -v "$name" >/dev/null 2>&1; then
                all_missing+=("$dep")
            fi
        done
    fi

    # 检查推荐依赖
    if ! check_all_deps "推荐依赖" "${RECOMMENDED_DEPS[@]}"; then
        for dep in "${RECOMMENDED_DEPS[@]}"; do
            local name="${dep%%:*}"
            if ! command -v "$name" >/dev/null 2>&1; then
                all_missing+=("$dep")
            fi
        done
    fi

    # 检查开发依赖
    if [ "${CHECK_DEV_DEPS:-0}" = "1" ]; then
        if ! check_all_deps "开发依赖" "${DEV_DEPS[@]}"; then
            for dep in "${DEV_DEPS[@]}"; do
                local name="${dep%%:*}"
                if ! command -v "$name" >/dev/null 2>&1; then
                    all_missing+=("$dep")
                fi
            done
        fi
    fi

    # 如果有缺失的依赖，询问是否安装
    if [ ${#all_missing[@]} -gt 0 ]; then
        interactive_install "${all_missing[@]}"
    else
        echo -e "\n${GREEN}所有依赖都已安装！${NC}"
    fi
}

# 运行主函数
main "$@"
