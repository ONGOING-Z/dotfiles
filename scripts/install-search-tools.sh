#!/usr/bin/env bash
# 安装高性能搜索工具

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

# 安装 ripgrep
install_ripgrep() {
    echo -e "${BLUE}安装 ripgrep...${NC}"

    if command -v rg >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ripgrep 已安装${NC}"
        return
    fi

    case "$OS_TYPE" in
        macos)
            brew install ripgrep
            ;;
        debian)
            sudo apt-get update && sudo apt-get install -y ripgrep
            ;;
        arch)
            sudo pacman -S ripgrep
            ;;
        *)
            # 通用安装方法
            if command -v cargo >/dev/null 2>&1; then
                cargo install ripgrep
            else
                echo -e "${YELLOW}请先安装 Rust/Cargo${NC}"
            fi
            ;;
    esac
}

# 安装 ugrep
install_ugrep() {
    echo -e "${BLUE}安装 ugrep...${NC}"

    if command -v ugrep >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ugrep 已安装${NC}"
        return
    fi

    case "$OS_TYPE" in
        macos)
            brew install ugrep
            ;;
        debian)
            # 添加 PPA
            sudo add-apt-repository ppa:genivia/ugrep -y
            sudo apt-get update
            sudo apt-get install -y ugrep
            ;;
        *)
            # 从源码编译
            echo -e "${YELLOW}需要从源码编译 ugrep${NC}"
            if [ ! -d /tmp/ugrep ]; then
                git clone https://github.com/Genivia/ugrep.git /tmp/ugrep
                cd /tmp/ugrep
                ./configure
                make -j$(nproc)
                sudo make install
            fi
            ;;
    esac
}

# 安装 ast-grep
install_ast_grep() {
    echo -e "${BLUE}安装 ast-grep...${NC}"

    if command -v ast-grep >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ast-grep 已安装${NC}"
        return
    fi

    # 优先使用 cargo
    if command -v cargo >/dev/null 2>&1; then
        cargo install ast-grep --locked
    # 其次使用 npm
    elif command -v npm >/dev/null 2>&1; then
        npm install -g @ast-grep/cli
    else
        echo -e "${YELLOW}需要 Rust/Cargo 或 Node.js/npm${NC}"
    fi
}

# 安装 Google codesearch
install_codesearch() {
    echo -e "${BLUE}安装 Google codesearch...${NC}"

    if command -v csearch >/dev/null 2>&1; then
        echo -e "${GREEN}✓ codesearch 已安装${NC}"
        return
    fi

    if command -v go >/dev/null 2>&1; then
        go install github.com/google/codesearch/cmd/...@latest
    else
        echo -e "${YELLOW}需要先安装 Go${NC}"
    fi
}

# 安装 hypergrep（如果可用）
install_hypergrep() {
    echo -e "${BLUE}检查 hypergrep...${NC}"

    if command -v hgrep >/dev/null 2>&1; then
        echo -e "${GREEN}✓ hypergrep 已安装${NC}"
        return
    fi

    # hypergrep 可能还不是公开项目
    echo -e "${YELLOW}hypergrep 暂时不可用${NC}"
}

# 配置搜索工具
configure_search_tools() {
    echo -e "${BLUE}配置搜索工具...${NC}"

    # 创建配置目录
    mkdir -p ~/.config/ripgrep

    # ripgrep 配置
    cat > ~/.config/ripgrep/config << 'EOF'
# 默认参数
--smart-case
--hidden
--glob=!.git/
--glob=!node_modules/
--glob=!*.pyc
--glob=!*.pyo
--glob=!*.swp
--glob=!.DS_Store
EOF

    # 设置 RIPGREP_CONFIG_PATH
    if ! grep -q "RIPGREP_CONFIG_PATH" ~/.bashrc 2>/dev/null; then
        echo 'export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"' >> ~/.bashrc
    fi

    if ! grep -q "RIPGREP_CONFIG_PATH" ~/.zshrc 2>/dev/null; then
        echo 'export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"' >> ~/.zshrc
    fi

    echo -e "${GREEN}✓ 配置完成${NC}"
}

# 性能测试
benchmark_search_tools() {
    echo -e "${BLUE}运行性能测试...${NC}"

    # 创建测试目录
    TEST_DIR="/tmp/search_benchmark"
    mkdir -p "$TEST_DIR"

    # 生成测试文件
    echo "生成测试数据..."
    for i in {1..1000}; do
        cat > "$TEST_DIR/file_$i.txt" << EOF
This is a test file number $i
TODO: implement feature
FIXME: bug in function
Lorem ipsum dolor sit amet
Pattern matching test
EOF
    done

    cd "$TEST_DIR"

    # 测试各工具
    echo -e "\n${YELLOW}搜索 'TODO' 性能对比：${NC}"

    if command -v rg >/dev/null 2>&1; then
        echo -n "ripgrep: "
        time -p rg -c "TODO" . 2>&1 | grep real
    fi

    if command -v ugrep >/dev/null 2>&1; then
        echo -n "ugrep:   "
        time -p ugrep -c "TODO" . 2>&1 | grep real
    fi

    if command -v ag >/dev/null 2>&1; then
        echo -n "ag:      "
        time -p ag -c "TODO" . 2>&1 | grep real
    fi

    echo -n "grep:    "
    time -p grep -r "TODO" . 2>&1 | grep real

    # 清理
    rm -rf "$TEST_DIR"
}

# 主函数
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      高性能搜索工具安装器             ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"

    # 安装工具
    install_ripgrep
    install_ugrep
    install_ast_grep
    install_codesearch
    install_hypergrep

    # 配置
    configure_search_tools

    # 询问是否运行基准测试
    echo ""
    read -rp "是否运行性能基准测试? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        benchmark_search_tools
    fi

    echo -e "\n${GREEN}安装完成！${NC}"
    echo -e "${YELLOW}提示：${NC}"
    echo "- 使用 'rg pattern' 进行快速搜索"
    echo "- 使用 'ugrep -z pattern' 搜索压缩文件"
    echo "- 使用 'ast-grep --pattern' 进行语法感知搜索"
    echo "- 使用 'cindex .' 建立索引，'csearch pattern' 搜索"
}

# 运行主函数
main "$@"
