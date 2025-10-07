#!/usr/bin/env bash
# Dotfiles Web UI 启动脚本

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}🚀 Dotfiles Web UI 启动脚本${NC}"
echo ""

# 检查 Python 版本
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误: 未找到 python3${NC}"
    echo "请先安装 Python 3.8 或更高版本"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓${NC} Python 版本: $PYTHON_VERSION"

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}创建虚拟环境...${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✓${NC} 虚拟环境创建完成"
fi

# 激活虚拟环境
echo -e "${BLUE}激活虚拟环境...${NC}"
source venv/bin/activate

# 安装依赖
if [ ! -f "venv/.installed" ]; then
    echo -e "${YELLOW}安装依赖包...${NC}"
    pip install --upgrade pip > /dev/null
    pip install -r requirements.txt
    touch venv/.installed
    echo -e "${GREEN}✓${NC} 依赖安装完成"
else
    echo -e "${GREEN}✓${NC} 依赖已安装"
fi

# 检查配置目录
CONFIG_DIR="$HOME/.dotfiles"
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}初始化配置目录...${NC}"
    mkdir -p "$CONFIG_DIR"
    echo -e "${GREEN}✓${NC} 配置目录已创建: $CONFIG_DIR"
fi

# 启动应用
echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Dotfiles Web UI 正在启动...${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "  访问地址: ${BLUE}http://localhost:5000${NC}"
echo ""
echo -e "  按 ${YELLOW}Ctrl+C${NC} 停止服务器"
echo ""

# 启动 Flask 应用
python3 app.py
