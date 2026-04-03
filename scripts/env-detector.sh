#!/usr/bin/env bash
# 环境检测和配置推荐工具

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检测结果
DETECTED_OS=""
DETECTED_DISTRO=""
DETECTED_VERSION=""
DETECTED_ARCH=""
DETECTED_SHELL=""
DETECTED_PACKAGE_MANAGER=""
USER_TYPE=""
RECOMMENDATIONS=()

# 检测操作系统
detect_os() {
    echo -e "${BLUE}检测操作系统...${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        DETECTED_OS="macOS"
        DETECTED_VERSION=$(sw_vers -productVersion)
        DETECTED_ARCH=$(uname -m)
        DETECTED_PACKAGE_MANAGER="brew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        DETECTED_OS="Linux"
        DETECTED_ARCH=$(uname -m)

        # 检测发行版
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DETECTED_DISTRO="$NAME"
            DETECTED_VERSION="$VERSION_ID"

            case "$ID" in
                ubuntu|debian)
                    DETECTED_PACKAGE_MANAGER="apt"
                    ;;
                fedora|rhel|centos)
                    DETECTED_PACKAGE_MANAGER="dnf"
                    ;;
                arch|manjaro)
                    DETECTED_PACKAGE_MANAGER="pacman"
                    ;;
                opensuse*)
                    DETECTED_PACKAGE_MANAGER="zypper"
                    ;;
                *)
                    DETECTED_PACKAGE_MANAGER="unknown"
                    ;;
            esac
        fi
    else
        DETECTED_OS="Unknown"
    fi

    echo -e "  ${GREEN}✓${NC} 操作系统: $DETECTED_OS $DETECTED_VERSION ($DETECTED_ARCH)"
    [ -n "$DETECTED_DISTRO" ] && echo -e "  ${GREEN}✓${NC} 发行版: $DETECTED_DISTRO"
    echo -e "  ${GREEN}✓${NC} 包管理器: $DETECTED_PACKAGE_MANAGER"
}

# 检测 Shell 环境
detect_shell() {
    echo -e "\n${BLUE}检测 Shell 环境...${NC}"

    DETECTED_SHELL=$(basename "$SHELL")
    local shell_version=""

    case "$DETECTED_SHELL" in
        bash)
            shell_version=$($SHELL --version | head -1)
            ;;
        zsh)
            shell_version=$($SHELL --version)
            ;;
        fish)
            shell_version=$($SHELL --version)
            ;;
    esac

    echo -e "  ${GREEN}✓${NC} 当前 Shell: $DETECTED_SHELL"
    [ -n "$shell_version" ] && echo -e "  ${GREEN}✓${NC} 版本: $shell_version"

    # 检测已安装的 Shell
    echo -e "  ${GREEN}✓${NC} 可用 Shell:"
    for shell in bash zsh fish; do
        if command -v "$shell" >/dev/null 2>&1; then
            echo -e "    - $shell"
        fi
    done
}

# 检测已安装的工具
detect_tools() {
    echo -e "\n${BLUE}检测已安装的工具...${NC}"

    local tools=(
        "git:版本控制"
        "vim:文本编辑器"
        "nvim:Neovim 编辑器"
        "tmux:终端复用器"
        "docker:容器平台"
        "python3:Python 3"
        "node:Node.js"
        "go:Go 语言"
        "rust:Rust 语言"
        "brew:Homebrew 包管理器"
        "fzf:模糊搜索"
        "rg:ripgrep 搜索"
        "htop:系统监控"
        "curl:网络工具"
        "wget:下载工具"
    )

    local installed_count=0
    local missing_tools=()

    for tool_desc in "${tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_desc"
        if command -v "$tool" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $desc ($tool)"
            ((installed_count++))
        else
            echo -e "  ${RED}✗${NC} $desc ($tool)"
            missing_tools+=("$tool")
        fi
    done

    echo -e "\n  已安装: $installed_count/${#tools[@]} 个工具"

    # 根据缺失的工具给出建议
    if [ ${#missing_tools[@]} -gt 0 ]; then
        RECOMMENDATIONS+=("建议安装缺失的工具: ${missing_tools[*]}")
    fi
}

# 检测开发环境
detect_dev_env() {
    echo -e "\n${BLUE}检测开发环境...${NC}"

    local dev_score=0
    local dev_tools=()

    # Python 开发
    if command -v python3 >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Python $(python3 --version 2>&1 | cut -d' ' -f2)"
        ((dev_score++))
        dev_tools+=("Python")

        if command -v pip3 >/dev/null 2>&1; then
            echo -e "    - pip $(pip3 --version | cut -d' ' -f2)"
        fi

        if command -v virtualenv >/dev/null 2>&1; then
            echo -e "    - virtualenv"
        fi
    fi

    # Node.js 开发
    if command -v node >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Node.js $(node --version)"
        ((dev_score++))
        dev_tools+=("Node.js")

        if command -v npm >/dev/null 2>&1; then
            echo -e "    - npm $(npm --version)"
        fi
    fi

    # Go 开发
    if command -v go >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Go $(go version | cut -d' ' -f3)"
        ((dev_score++))
        dev_tools+=("Go")
    fi

    # Rust 开发
    if command -v rustc >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Rust $(rustc --version | cut -d' ' -f2)"
        ((dev_score++))
        dev_tools+=("Rust")
    fi

    # Docker
    if command -v docker >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
        ((dev_score++))
        dev_tools+=("Docker")
    fi

    # 判断用户类型
    if [ $dev_score -ge 3 ]; then
        USER_TYPE="developer"
        echo -e "\n  ${MAGENTA}用户类型: 开发者${NC}"
    elif [ $dev_score -ge 1 ]; then
        USER_TYPE="casual_dev"
        echo -e "\n  ${MAGENTA}用户类型: 轻度开发者${NC}"
    else
        USER_TYPE="general"
        echo -e "\n  ${MAGENTA}用户类型: 普通用户${NC}"
    fi
}

# 生成推荐配置
generate_recommendations() {
    echo -e "\n${BLUE}=== 配置建议 ===${NC}\n"

    # 基于操作系统的建议
    case "$DETECTED_OS" in
        macOS)
            if ! command -v brew >/dev/null 2>&1; then
                RECOMMENDATIONS+=("强烈建议安装 Homebrew 包管理器")
            fi
            RECOMMENDATIONS+=("推荐使用 iTerm2 作为终端")
            ;;
        Linux)
            RECOMMENDATIONS+=("确保系统包管理器是最新的")
            if [[ "$DETECTED_SHELL" != "zsh" ]]; then
                RECOMMENDATIONS+=("考虑切换到 Zsh 以获得更好的体验")
            fi
            ;;
    esac

    # 基于用户类型的建议
    case "$USER_TYPE" in
        developer)
            echo -e "${GREEN}推荐配置方案: 开发者套装${NC}"
            echo "  - 完整的开发工具链"
            echo "  - 强大的 Vim/Neovim 配置"
            echo "  - Tmux 多窗口管理"
            echo "  - Git 工作流优化"
            echo "  - 各种语言的开发环境"
            echo ""
            echo -e "${CYAN}建议运行:${NC} ./install --developer"
            ;;
        casual_dev)
            echo -e "${GREEN}推荐配置方案: 轻量开发配置${NC}"
            echo "  - 基础开发工具"
            echo "  - 简单的 Vim 配置"
            echo "  - Git 基础配置"
            echo "  - 常用工具集成"
            echo ""
            echo -e "${CYAN}建议运行:${NC} ./install --quick"
            ;;
        general)
            echo -e "${GREEN}推荐配置方案: 基础配置${NC}"
            echo "  - 基本的 Shell 增强"
            echo "  - 常用别名和函数"
            echo "  - 简单的工具配置"
            echo ""
            echo -e "${CYAN}建议运行:${NC} ./install --minimal"
            ;;
    esac

    # 显示其他建议
    if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}其他建议:${NC}"
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo "  • $rec"
        done
    fi
}

# 生成环境报告
generate_report() {
    local report_file="environment-report.txt"

    {
        echo "=== 环境检测报告 ==="
        echo "生成时间: $(date)"
        echo ""
        echo "操作系统: $DETECTED_OS $DETECTED_VERSION"
        [ -n "$DETECTED_DISTRO" ] && echo "发行版: $DETECTED_DISTRO"
        echo "架构: $DETECTED_ARCH"
        echo "Shell: $DETECTED_SHELL"
        echo "包管理器: $DETECTED_PACKAGE_MANAGER"
        echo "用户类型: $USER_TYPE"
        echo ""
        echo "=== 推荐配置 ==="
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo "- $rec"
        done
    } > "$report_file"

    echo -e "\n${GREEN}报告已保存到: $report_file${NC}"
}

# 主函数
main() {
    echo -e "${MAGENTA}╔═══════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        环境检测和配置推荐工具         ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════╝${NC}"
    echo ""

    detect_os
    detect_shell
    detect_tools
    detect_dev_env
    generate_recommendations

    # 询问是否保存报告
    echo ""
    read -rp "是否保存检测报告? [y/N] " save_report
    if [[ "$save_report" =~ ^[Yy]$ ]]; then
        generate_report
    fi

    echo -e "\n${GREEN}检测完成！${NC}"
}

# 运行主函数
main "$@"
