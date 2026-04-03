#!/usr/bin/env bash
# Dotfiles 健康检查脚本

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 图标
CHECK="✓"
CROSS="✗"
WARN="⚠"
INFO="ℹ"

# 计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNINGS=0
ERRORS=0

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 打印标题
print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${GREEN}          Dotfiles 健康检查报告                      ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${INFO} 检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${INFO} 系统信息: $(uname -s) $(uname -r)"
    echo ""
}

# 检查函数
check() {
    local description="$1"
    local check_command="$2"
    local severity="${3:-error}" # error, warning, info

    ((TOTAL_CHECKS++))

    echo -n -e "检查: $description ... "

    if eval "$check_command" >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} 通过${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        case "$severity" in
            warning)
                echo -e "${YELLOW}${WARN} 警告${NC}"
                ((WARNINGS++))
                ;;
            info)
                echo -e "${BLUE}${INFO} 信息${NC}"
                ;;
            *)
                echo -e "${RED}${CROSS} 失败${NC}"
                ((ERRORS++))
                ;;
        esac
        return 1
    fi
}

# 详细检查函数
check_with_details() {
    local description="$1"
    local check_command="$2"
    local details_command="$3"
    local severity="${4:-error}"

    if ! check "$description" "$check_command" "$severity"; then
        if [ -n "$details_command" ]; then
            echo -e "  ${YELLOW}└─ 详情:${NC}"
            eval "$details_command" 2>&1 | sed 's/^/     /'
        fi
    fi
}

# 开始检查
print_header

echo -e "${BLUE}=== 基础检查 ===${NC}"
check "Dotfiles 根目录存在" "[ -d '$DOTFILES_ROOT' ]"
check "install 脚本存在" "[ -f '$DOTFILES_ROOT/install' ]"
check "install 脚本可执行" "[ -x '$DOTFILES_ROOT/install' ]"
check "install.conf.yaml 存在" "[ -f '$DOTFILES_ROOT/install.conf.yaml' ]"

echo ""
echo -e "${BLUE}=== 目录结构检查 ===${NC}"
check "config 目录存在" "[ -d '$DOTFILES_ROOT/config' ]"
check "scripts 目录存在" "[ -d '$DOTFILES_ROOT/scripts' ]"
check "docs 目录存在" "[ -d '$DOTFILES_ROOT/docs' ]"
check "dotbot 子模块存在" "[ -d '$DOTFILES_ROOT/dotbot' ]"

echo ""
echo -e "${BLUE}=== 符号链接检查 ===${NC}"
# 检查主要配置文件的符号链接
for config in zshrc bashrc vimrc tmux.conf gitconfig; do
    link_target=""
    case "$config" in
        zshrc|bashrc) link_target="$HOME/.$config" ;;
        vimrc) link_target="$HOME/.vimrc" ;;
        tmux.conf) link_target="$HOME/.tmux.conf" ;;
        gitconfig) link_target="$HOME/.gitconfig" ;;
    esac

    if [ -L "$link_target" ]; then
        check "符号链接 $link_target" "[ -L '$link_target' ]"
        # 检查链接是否指向正确位置
        actual_target="$(readlink "$link_target" 2>/dev/null || true)"
        if [[ "$actual_target" == *"dotfiles"* ]]; then
            echo -e "  ${GREEN}└─ 链接到: $actual_target${NC}"
        else
            echo -e "  ${YELLOW}└─ 警告: 链接目标可能不正确: $actual_target${NC}"
        fi
    else
        check "符号链接 $link_target" "[ -L '$link_target' ]" "warning"
    fi
done

echo ""
echo -e "${BLUE}=== 依赖工具检查 ===${NC}"
# 检查常用工具
tools=(git zsh bash vim nvim tmux)
for tool in "${tools[@]}"; do
    check_with_details "$tool 已安装" "command -v $tool" "command -v $tool && $tool --version 2>&1 | head -1" "warning"
done

echo ""
echo -e "${BLUE}=== Git 子模块检查 ===${NC}"
check_with_details "Git 子模块已初始化" "cd '$DOTFILES_ROOT' && git submodule status | grep -v '^-'" \
    "cd '$DOTFILES_ROOT' && git submodule status" "warning"

echo ""
echo -e "${BLUE}=== 权限检查 ===${NC}"
# 检查敏感文件权限
if [ -f "$HOME/.ssh/config" ]; then
    check_with_details "SSH config 权限正确 (600)" "[ '$(stat -c %a $HOME/.ssh/config 2>/dev/null || stat -f %p $HOME/.ssh/config | cut -c4-6)' = '600' ]" \
        "ls -la $HOME/.ssh/config" "warning"
fi

if [ -d "$HOME/.ssh" ]; then
    check_with_details "SSH 目录权限正确 (700)" "[ '$(stat -c %a $HOME/.ssh 2>/dev/null || stat -f %p $HOME/.ssh | cut -c4-6)' = '700' ]" \
        "ls -lad $HOME/.ssh" "warning"
fi

echo ""
echo -e "${BLUE}=== Shell 配置检查 ===${NC}"
# 检查当前 shell
current_shell="$(basename "$SHELL")"
echo -e "${INFO} 当前 Shell: $current_shell"

# 检查默认 shell
if [ "$current_shell" = "zsh" ]; then
    check "Zsh 是默认 Shell" "[ '$SHELL' = '/bin/zsh' -o '$SHELL' = '/usr/bin/zsh' ]" "info"
    check "Oh My Zsh 已安装" "[ -d '$HOME/.oh-my-zsh' ]" "warning"
fi

echo ""
echo -e "${BLUE}=== 性能检查 ===${NC}"
# 检查 shell 启动时间（简单测试）
if command -v zsh >/dev/null 2>&1; then
    echo -n "测试 Zsh 启动时间... "
    start_time=$(date +%s%N)
    zsh -i -c exit 2>/dev/null
    end_time=$(date +%s%N)
    startup_time=$(( (end_time - start_time) / 1000000 ))

    if [ "$startup_time" -lt 500 ]; then
        echo -e "${GREEN}${CHECK} 快速 (${startup_time}ms)${NC}"
    elif [ "$startup_time" -lt 1000 ]; then
        echo -e "${YELLOW}${WARN} 一般 (${startup_time}ms)${NC}"
    else
        echo -e "${RED}${CROSS} 较慢 (${startup_time}ms)${NC}"
    fi
fi

echo ""
echo -e "${BLUE}=== 总结 ===${NC}"
echo -e "总检查项: $TOTAL_CHECKS"
echo -e "${GREEN}通过: $PASSED_CHECKS${NC}"
echo -e "${YELLOW}警告: $WARNINGS${NC}"
echo -e "${RED}错误: $ERRORS${NC}"

# 计算健康分数
HEALTH_SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
echo ""
echo -n "健康评分: "
if [ "$HEALTH_SCORE" -ge 90 ]; then
    echo -e "${GREEN}${HEALTH_SCORE}% - 优秀${NC}"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
    echo -e "${YELLOW}${HEALTH_SCORE}% - 良好${NC}"
else
    echo -e "${RED}${HEALTH_SCORE}% - 需要改进${NC}"
fi

echo ""

# 根据结果退出
if [ "$ERRORS" -gt 0 ]; then
    exit 1
else
    exit 0
fi
