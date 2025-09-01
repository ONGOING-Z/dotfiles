#!/usr/bin/env bash
# Dotfiles 卸载脚本
# 安全移除 dotfiles 符号链接并可选恢复备份

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_SUFFIX=".dotfiles-backup"

# 要卸载的文件列表
DOTFILES=(
    ".zshrc"
    ".bashrc"
    ".bash_aliases"
    ".tmux.conf"
    ".vimrc"
    ".gitconfig"
    ".gdbinit"
    ".ripgreprc"
    ".config/nvim/init.vim"
    ".pip/pip.conf"
)

# ============================================================================
# 辅助函数
# ============================================================================

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

confirm() {
    local prompt="${1:-确认操作?}"
    local default="${2:-n}"
    local response

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -rp "$prompt" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================================================
# 卸载函数
# ============================================================================

check_dotfiles() {
    print_info "检查 dotfiles 链接..."

    local found_links=0
    for file in "${DOTFILES[@]}"; do
        local target="$HOME/$file"
        if [ -L "$target" ]; then
            local link_target=$(readlink "$target")
            if [[ "$link_target" == *"$DOTFILES_DIR"* ]] || [[ "$link_target" == *"dotfiles"* ]]; then
                echo "  - $file -> $link_target"
                ((found_links++))
            fi
        fi
    done

    if [ $found_links -eq 0 ]; then
        print_warning "未找到 dotfiles 符号链接"
        return 1
    else
        print_info "找到 $found_links 个 dotfiles 链接"
        return 0
    fi
}

remove_links() {
    print_info "移除符号链接..."

    for file in "${DOTFILES[@]}"; do
        local target="$HOME/$file"

        if [ -L "$target" ]; then
            local link_target=$(readlink "$target")
            if [[ "$link_target" == *"$DOTFILES_DIR"* ]] || [[ "$link_target" == *"dotfiles"* ]]; then
                rm "$target"
                print_success "已移除: $file"

                # 检查备份
                if [ -f "${target}${BACKUP_SUFFIX}" ]; then
                    if confirm "  发现备份文件 ${file}${BACKUP_SUFFIX}，是否恢复？" "y"; then
                        mv "${target}${BACKUP_SUFFIX}" "$target"
                        print_success "  已恢复: $file"
                    fi
                fi
            fi
        fi
    done
}

remove_generated_files() {
    print_info "清理生成的文件..."

    # 清理可能生成的文件
    local generated_files=(
        "$HOME/.zcompdump*"
        "$HOME/.zsh_history"
        "$HOME/.vim/undo-history"
    )

    for pattern in "${generated_files[@]}"; do
        for file in $pattern; do
            if [ -f "$file" ]; then
                if confirm "删除 $file？" "n"; then
                    rm "$file"
                    print_success "已删除: $file"
                fi
            fi
        done
    done
}

restore_from_backup() {
    print_info "查找备份目录..."

    # 查找备份目录
    local backup_dirs=()
    for dir in "$HOME"/.dotfiles-backup-*; do
        if [ -d "$dir" ]; then
            backup_dirs+=("$dir")
        fi
    done

    if [ ${#backup_dirs[@]} -eq 0 ]; then
        print_warning "未找到备份目录"
        return
    fi

    echo "找到以下备份目录:"
    for i in "${!backup_dirs[@]}"; do
        echo "  $((i+1)). ${backup_dirs[$i]}"
    done

    local choice
    read -rp "选择要恢复的备份 (输入编号，或按 Enter 跳过): " choice

    if [ -n "$choice" ] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#backup_dirs[@]}" ]; then
        local backup_dir="${backup_dirs[$((choice-1))]}"

        print_info "从 $backup_dir 恢复文件..."

        for file in "$backup_dir"/*; do
            if [ -f "$file" ]; then
                local basename=$(basename "$file")
                local target="$HOME/.$basename"

                # 移除前缀点（备份时可能没有）
                if [[ "$basename" != .* ]]; then
                    target="$HOME/.$basename"
                else
                    target="$HOME/$basename"
                fi

                if [ ! -e "$target" ]; then
                    cp "$file" "$target"
                    print_success "已恢复: $basename"
                else
                    print_warning "跳过 $basename (文件已存在)"
                fi
            fi
        done
    fi
}

uninstall_packages() {
    print_info "检查已安装的包..."

    # Oh-My-Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        if confirm "卸载 Oh-My-Zsh？" "n"; then
            if [ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]; then
                sh "$HOME/.oh-my-zsh/tools/uninstall.sh"
                print_success "Oh-My-Zsh 已卸载"
            else
                rm -rf "$HOME/.oh-my-zsh"
                print_success "Oh-My-Zsh 目录已删除"
            fi
        fi
    fi

    # Zplug
    if [ -d "$HOME/.zplug" ]; then
        if confirm "卸载 Zplug？" "n"; then
            rm -rf "$HOME/.zplug"
            print_success "Zplug 已卸载"
        fi
    fi

    # TPM (Tmux Plugin Manager)
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        if confirm "卸载 Tmux 插件管理器？" "n"; then
            rm -rf "$HOME/.tmux/plugins"
            print_success "TPM 已卸载"
        fi
    fi
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              Dotfiles 卸载工具                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo

    # 检查 dotfiles
    if ! check_dotfiles; then
        if ! confirm "继续卸载？" "n"; then
            print_info "卸载已取消"
            exit 0
        fi
    fi

    echo
    print_warning "此操作将移除所有 dotfiles 符号链接"

    if ! confirm "确认卸载 dotfiles？" "n"; then
        print_info "卸载已取消"
        exit 0
    fi

    # 执行卸载
    remove_links

    # 可选操作
    echo
    if confirm "是否从备份恢复原配置？" "n"; then
        restore_from_backup
    fi

    if confirm "是否清理生成的文件？" "n"; then
        remove_generated_files
    fi

    if confirm "是否卸载相关包管理器（Oh-My-Zsh、Zplug 等）？" "n"; then
        uninstall_packages
    fi

    echo
    print_success "卸载完成！"

    # 提示
    echo
    print_info "提示:"
    echo "  - dotfiles 仓库仍保留在: $DOTFILES_DIR"
    echo "  - 可以安全删除: rm -rf $DOTFILES_DIR"
    echo "  - 如需重新安装: cd $DOTFILES_DIR && ./install"
}

# 显示帮助
show_help() {
    cat << EOF
用法: $0 [选项]

Dotfiles 卸载工具 - 安全移除 dotfiles 配置

选项:
    -h, --help      显示此帮助信息
    -f, --force     强制卸载（跳过确认）
    -k, --keep      保留备份文件
    -r, --restore   仅恢复备份

示例:
    $0              # 交互式卸载
    $0 --force      # 强制卸载
    $0 --restore    # 仅恢复备份

EOF
}

# 参数处理
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -r|--restore)
        restore_from_backup
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
