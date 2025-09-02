#!/usr/bin/env bash
# 主题切换脚本

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(cd "$SCRIPT_DIR/../themes" && pwd)"
CONFIG_DIR="$HOME/.config/dotfiles"

# 当前主题文件
CURRENT_THEME_FILE="$CONFIG_DIR/current-theme"

# 显示帮助
show_help() {
    cat << EOF
主题切换工具

用法: theme-switcher.sh [命令] [主题名]

命令:
    list              列出所有可用主题
    set <主题名>      切换到指定主题
    current          显示当前主题
    preview <主题名>  预览主题（不应用）
    help             显示此帮助信息

示例:
    theme-switcher.sh list
    theme-switcher.sh set dracula
    theme-switcher.sh current
EOF
}

# 列出可用主题
list_themes() {
    echo -e "${BLUE}可用主题：${NC}"
    echo ""
    
    for theme_dir in "$THEMES_DIR"/*; do
        if [ -d "$theme_dir" ]; then
            theme_name=$(basename "$theme_dir")
            
            # 检查主题完整性
            if [ -f "$theme_dir/colors.sh" ]; then
                echo -e "  ${GREEN}✓${NC} $theme_name"
                
                # 显示主题描述（如果有）
                if [ -f "$theme_dir/README.md" ]; then
                    description=$(head -n 3 "$theme_dir/README.md" | tail -n 1 2>/dev/null || echo "")
                    if [ -n "$description" ]; then
                        echo "    $description"
                    fi
                fi
            else
                echo -e "  ${YELLOW}⚠${NC} $theme_name (不完整)"
            fi
        fi
    done
}

# 获取当前主题
get_current_theme() {
    if [ -f "$CURRENT_THEME_FILE" ]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "default"
    fi
}

# 显示当前主题
show_current_theme() {
    local current=$(get_current_theme)
    echo -e "${BLUE}当前主题：${NC}$current"
}

# 应用主题
apply_theme() {
    local theme_name="$1"
    local theme_dir="$THEMES_DIR/$theme_name"
    
    if [ ! -d "$theme_dir" ]; then
        echo -e "${RED}错误：主题 '$theme_name' 不存在${NC}"
        return 1
    fi
    
    echo -e "${BLUE}应用主题：$theme_name${NC}"
    
    # 创建配置目录
    mkdir -p "$CONFIG_DIR"
    
    # 应用终端颜色
    if [ -f "$theme_dir/colors.sh" ]; then
        echo -e "  ${GREEN}✓${NC} 加载颜色定义"
        # 创建符号链接
        ln -sf "$theme_dir/colors.sh" "$CONFIG_DIR/theme-colors.sh"
    fi
    
    # 应用 Vim 主题
    if [ -f "$theme_dir/vim.vim" ]; then
        echo -e "  ${GREEN}✓${NC} 配置 Vim 主题"
        mkdir -p "$HOME/.vim/colors"
        cp "$theme_dir/vim.vim" "$HOME/.vim/colors/${theme_name}.vim"
        
        # 更新 vimrc
        if [ -f "$HOME/.vimrc" ]; then
            # 备份原文件
            cp "$HOME/.vimrc" "$HOME/.vimrc.backup"
            
            # 更新 colorscheme
            if grep -q "^colorscheme" "$HOME/.vimrc"; then
                sed -i.tmp "s/^colorscheme .*/colorscheme $theme_name/" "$HOME/.vimrc"
            else
                echo "colorscheme $theme_name" >> "$HOME/.vimrc"
            fi
            rm -f "$HOME/.vimrc.tmp"
        fi
    fi
    
    # 应用 Tmux 主题
    if [ -f "$theme_dir/tmux.conf" ]; then
        echo -e "  ${GREEN}✓${NC} 配置 Tmux 主题"
        ln -sf "$theme_dir/tmux.conf" "$CONFIG_DIR/tmux-theme.conf"
        
        # 在 tmux.conf 中引入主题
        if [ -f "$HOME/.tmux.conf" ]; then
            if ! grep -q "source.*tmux-theme.conf" "$HOME/.tmux.conf"; then
                echo "" >> "$HOME/.tmux.conf"
                echo "# 主题配置" >> "$HOME/.tmux.conf"
                echo "source-file $CONFIG_DIR/tmux-theme.conf" >> "$HOME/.tmux.conf"
            fi
        fi
    fi
    
    # 保存当前主题
    echo "$theme_name" > "$CURRENT_THEME_FILE"
    
    echo ""
    echo -e "${GREEN}主题应用成功！${NC}"
    echo ""
    echo "提示："
    echo "  - 重新打开终端以查看终端颜色变化"
    echo "  - 在 Vim 中运行 :source ~/.vimrc 以应用 Vim 主题"
    echo "  - 在 Tmux 中运行 tmux source ~/.tmux.conf 以应用 Tmux 主题"
}

# 预览主题
preview_theme() {
    local theme_name="$1"
    local theme_dir="$THEMES_DIR/$theme_name"
    
    if [ ! -d "$theme_dir" ]; then
        echo -e "${RED}错误：主题 '$theme_name' 不存在${NC}"
        return 1
    fi
    
    echo -e "${BLUE}预览主题：$theme_name${NC}"
    echo ""
    
    # 加载颜色
    if [ -f "$theme_dir/colors.sh" ]; then
        source "$theme_dir/colors.sh"
        
        # 显示颜色示例
        echo "基础颜色："
        echo -e "  ${COLOR_BLACK}■■■${NC} BLACK"
        echo -e "  ${COLOR_RED}■■■${NC} RED"
        echo -e "  ${COLOR_GREEN}■■■${NC} GREEN"
        echo -e "  ${COLOR_YELLOW}■■■${NC} YELLOW"
        echo -e "  ${COLOR_BLUE}■■■${NC} BLUE"
        echo -e "  ${COLOR_MAGENTA}■■■${NC} MAGENTA"
        echo -e "  ${COLOR_CYAN}■■■${NC} CYAN"
        echo -e "  ${COLOR_WHITE}■■■${NC} WHITE"
    fi
}

# 主函数
main() {
    case "${1:-help}" in
        list)
            list_themes
            ;;
        set)
            if [ -z "${2:-}" ]; then
                echo -e "${RED}错误：请指定主题名${NC}"
                echo "使用 'theme-switcher.sh list' 查看可用主题"
                exit 1
            fi
            apply_theme "$2"
            ;;
        current)
            show_current_theme
            ;;
        preview)
            if [ -z "${2:-}" ]; then
                echo -e "${RED}错误：请指定主题名${NC}"
                exit 1
            fi
            preview_theme "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}错误：未知命令 '$1'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"