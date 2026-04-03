#!/usr/bin/env bash
# 运行所有测试

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Dotfiles 测试套件 ===${NC}"
echo ""

# 检查 bats 是否安装
if ! command -v bats >/dev/null 2>&1; then
    echo -e "${YELLOW}警告: BATS 未安装${NC}"
    echo "请安装 BATS: https://github.com/bats-core/bats-core"
    echo ""
    echo "Ubuntu/Debian: sudo apt-get install bats"
    echo "macOS: brew install bats-core"
    echo ""
    exit 1
fi

# 运行 shellcheck
echo -e "${GREEN}运行 ShellCheck...${NC}"
if command -v shellcheck >/dev/null 2>&1; then
    find .. -name "*.sh" -type f -not -path "../.git/*" -not -path "../.venv/*" | while read -r script; do
        echo "检查: $script"
        shellcheck "$script" || true
    done
    echo ""
else
    echo -e "${YELLOW}ShellCheck 未安装，跳过${NC}"
    echo ""
fi

# 运行 BATS 测试
echo -e "${GREEN}运行 BATS 测试...${NC}"
if [ -d "bats" ]; then
    bats bats/*.bats
else
    echo -e "${RED}错误: 未找到 bats 测试目录${NC}"
    exit 1
fi

# 运行 Python 测试
echo ""
echo -e "${GREEN}运行 Python 测试...${NC}"
if command -v python3 >/dev/null 2>&1; then
    cd ..
    python3 -m pytest -v
else
    echo -e "${YELLOW}Python3 未安装，跳过 Python 测试${NC}"
fi

echo ""
echo -e "${GREEN}✓ 所有测试完成！${NC}"
