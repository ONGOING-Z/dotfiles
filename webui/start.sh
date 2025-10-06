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
    if ! pip install -r requirements.txt; then
        echo -e "${YELLOW}首次安装失败，尝试使用 PyPI 官方源重试...${NC}"
        if ! pip install -r requirements.txt -i https://pypi.org/simple --proxy http://127.0.0.1:7897; then
            echo -e "${RED}依赖安装失败，请检查网络或 pip 源配置${NC}"
            exit 1
        fi
    fi
    touch venv/.installed
    echo -e "${GREEN}✓${NC} 依赖安装完成"
else
    echo -e "${GREEN}✓${NC} 依赖已安装"
fi

# 准备前端本地依赖（一次性缓存到 static/vendor 与 static/css）
echo -e "${BLUE}检查前端本地依赖...${NC}"
mkdir -p static/vendor static/css static/webfonts

download() {
    local url="$1"
    local out="$2"
    if [ -f "$out" ]; then
        return
    fi
    echo -e "${YELLOW}下载 ${url} -> ${out}${NC}"
    # 如需代理，可通过环境变量 HTTP_PROXY/HTTPS_PROXY 或默认 127.0.0.1:7897
    local proxy_arg=""
    if [ -n "${HTTPS_PROXY:-}" ]; then
        proxy_arg="--proxy ${HTTPS_PROXY}"
    elif [ -n "${HTTP_PROXY:-}" ]; then
        proxy_arg="--proxy ${HTTP_PROXY}"
    else
        proxy_arg="--proxy http://127.0.0.1:7897"
    fi
    curl -fsSL ${proxy_arg} -o "$out" "$url" || {
        echo -e "${RED}下载失败: ${url}${NC}"
        exit 1
    }
}

# 版本可按需调整
download "https://cdn.jsdelivr.net/npm/vue@3/dist/vue.global.prod.js" "static/vendor/vue.global.prod.js"
download "https://cdn.jsdelivr.net/npm/axios@1/dist/axios.min.js" "static/vendor/axios.min.js"
download "https://cdn.jsdelivr.net/npm/vis-network@9.1.2/dist/vis-network.min.js" "static/vendor/vis-network.min.js"

# Font Awesome 样式与字体
download "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" "static/css/all.min.css"
download "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/fa-solid-900.woff2" "static/webfonts/fa-solid-900.woff2"
download "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/fa-regular-400.woff2" "static/webfonts/fa-regular-400.woff2"
download "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/fa-brands-400.woff2" "static/webfonts/fa-brands-400.woff2"

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
PORT=${FLASK_PORT:-5000}
echo -e "  访问地址: ${BLUE}http://localhost:${PORT}${NC}"
echo ""
echo -e "  按 ${YELLOW}Ctrl+C${NC} 停止服务器"
echo ""

# 启动 Flask 应用（支持自定义端口）
python3 app.py --port "${PORT}"
