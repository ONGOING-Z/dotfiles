#!/usr/bin/env bash
# 插件管理器

set -euo pipefail

# 配置
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGINS_DIR="$DOTFILES_ROOT/plugins"
PLUGIN_CONFIG="$HOME/.dotfiles/plugins.conf"
ENABLED_PLUGINS="$HOME/.dotfiles/enabled-plugins"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 确保目录存在
mkdir -p "$(dirname "$PLUGIN_CONFIG")"
mkdir -p "$ENABLED_PLUGINS"

# 日志函数
log_info() {
    echo -e "${BLUE}[信息]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $*"
}

log_error() {
    echo -e "${RED}[错误]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $*"
}

# 获取所有插件
get_all_plugins() {
    local plugins=()

    # 扫描插件目录
    for category in core community personal; do
        if [ -d "$PLUGINS_DIR/$category" ]; then
            for plugin_dir in "$PLUGINS_DIR/$category"/*; do
                if [ -d "$plugin_dir" ] && [ -f "$plugin_dir/init.sh" ]; then
                    plugins+=("$category/$(basename "$plugin_dir")")
                fi
            done
        fi
    done

    printf '%s\n' "${plugins[@]}"
}

# 检查插件是否已启用
is_plugin_enabled() {
    local plugin="$1"
    [ -L "$ENABLED_PLUGINS/$(basename "$plugin")" ]
}

# 获取插件信息
get_plugin_info() {
    local plugin_path="$1"
    local init_file="$plugin_path/init.sh"

    if [ ! -f "$init_file" ]; then
        return 1
    fi

    # 提取元数据
    local name=$(grep "^PLUGIN_NAME=" "$init_file" 2>/dev/null | cut -d'"' -f2 || echo "$(basename "$plugin_path")")
    local version=$(grep "^PLUGIN_VERSION=" "$init_file" 2>/dev/null | cut -d'"' -f2 || echo "unknown")
    local description=$(grep "^PLUGIN_DESCRIPTION=" "$init_file" 2>/dev/null | cut -d'"' -f2 || echo "No description")

    echo "名称: $name"
    echo "版本: $version"
    echo "描述: $description"
}

# 列出插件
list_plugins() {
    echo -e "${MAGENTA}=== 可用插件 ===${NC}\n"

    local plugins=($(get_all_plugins))

    if [ ${#plugins[@]} -eq 0 ]; then
        log_info "没有找到插件"
        return
    fi

    for plugin in "${plugins[@]}"; do
        local plugin_path="$PLUGINS_DIR/$plugin"
        local status=""

        if is_plugin_enabled "$plugin"; then
            status="${GREEN}[已启用]${NC}"
        else
            status="${YELLOW}[未启用]${NC}"
        fi

        echo -e "$status ${CYAN}$plugin${NC}"

        if [ -f "$plugin_path/init.sh" ]; then
            local info=$(get_plugin_info "$plugin_path" | sed 's/^/    /')
            echo "$info"
        fi

        echo ""
    done
}

# 安装插件
install_plugin() {
    local plugin="$1"
    local plugin_path="$PLUGINS_DIR/$plugin"

    if [ ! -d "$plugin_path" ]; then
        log_error "插件不存在: $plugin"
        return 1
    fi

    if [ ! -f "$plugin_path/init.sh" ]; then
        log_error "插件无效（缺少 init.sh）: $plugin"
        return 1
    fi

    # 运行安装脚本（如果存在）
    if [ -f "$plugin_path/install.sh" ]; then
        log_info "运行安装脚本..."
        bash "$plugin_path/install.sh" || {
            log_error "安装脚本执行失败"
            return 1
        }
    fi

    log_success "插件安装成功: $plugin"
}

# 启用插件
enable_plugin() {
    local plugin="$1"
    local plugin_path="$PLUGINS_DIR/$plugin"
    local plugin_name=$(basename "$plugin")

    if [ ! -d "$plugin_path" ]; then
        log_error "插件不存在: $plugin"
        return 1
    fi

    if is_plugin_enabled "$plugin"; then
        log_warning "插件已启用: $plugin"
        return 0
    fi

    # 创建符号链接
    ln -sf "$plugin_path" "$ENABLED_PLUGINS/$plugin_name"

    # 记录到配置
    echo "$plugin" >> "$PLUGIN_CONFIG"

    log_success "插件已启用: $plugin"
    log_info "请重新加载 Shell 以生效"
}

# 禁用插件
disable_plugin() {
    local plugin="$1"
    local plugin_name=$(basename "$plugin")

    if ! is_plugin_enabled "$plugin"; then
        log_warning "插件未启用: $plugin"
        return 0
    fi

    # 删除符号链接
    rm -f "$ENABLED_PLUGINS/$plugin_name"

    # 从配置中移除
    if [ -f "$PLUGIN_CONFIG" ]; then
        grep -v "^$plugin$" "$PLUGIN_CONFIG" > "$PLUGIN_CONFIG.tmp" || true
        mv "$PLUGIN_CONFIG.tmp" "$PLUGIN_CONFIG"
    fi

    log_success "插件已禁用: $plugin"
    log_info "请重新加载 Shell 以生效"
}

# 创建新插件
create_plugin() {
    local plugin_name="$1"
    local category="${2:-personal}"
    local plugin_dir="$PLUGINS_DIR/$category/$plugin_name"

    if [ -d "$plugin_dir" ]; then
        log_error "插件已存在: $plugin_name"
        return 1
    fi

    log_info "创建新插件: $plugin_name"

    # 创建插件目录
    mkdir -p "$plugin_dir"

    # 创建 init.sh
    cat > "$plugin_dir/init.sh" << EOF
#!/usr/bin/env bash
# $plugin_name 插件

# 插件元数据
PLUGIN_NAME="$plugin_name"
PLUGIN_VERSION="1.0.0"
PLUGIN_DESCRIPTION="描述您的插件功能"

# 插件初始化
plugin_init() {
    # 在这里添加您的插件代码
    # 例如：定义别名、函数、环境变量等

    # 示例别名
    alias ${plugin_name}_hello='echo "Hello from $plugin_name plugin!"'

    # 示例函数
    ${plugin_name}_info() {
        echo "Plugin: \$PLUGIN_NAME v\$PLUGIN_VERSION"
        echo "Description: \$PLUGIN_DESCRIPTION"
    }
}

# 插件卸载
plugin_unload() {
    # 清理插件创建的内容
    unalias ${plugin_name}_hello 2>/dev/null || true
    unset -f ${plugin_name}_info 2>/dev/null || true
}

# 执行初始化
plugin_init
EOF

    chmod +x "$plugin_dir/init.sh"

    # 创建 README.md
    cat > "$plugin_dir/README.md" << EOF
# $plugin_name

## 描述

描述您的插件功能和用途。

## 安装

\`\`\`bash
./scripts/plugin-manager.sh install $category/$plugin_name
./scripts/plugin-manager.sh enable $category/$plugin_name
\`\`\`

## 使用

说明如何使用您的插件。

## 配置

如果插件有配置选项，在这里说明。

## 依赖

列出插件的依赖项。
EOF

    log_success "插件创建成功: $plugin_dir"
    log_info "编辑 $plugin_dir/init.sh 来实现您的插件"
}

# 加载所有启用的插件
load_plugins() {
    if [ ! -d "$ENABLED_PLUGINS" ]; then
        return
    fi

    for plugin_link in "$ENABLED_PLUGINS"/*; do
        if [ -L "$plugin_link" ] && [ -f "$plugin_link/init.sh" ]; then
            source "$plugin_link/init.sh"
        fi
    done
}

# 显示帮助
show_help() {
    echo "用法: $0 <command> [args]"
    echo ""
    echo "命令:"
    echo "  list                    - 列出所有插件"
    echo "  install <plugin>        - 安装插件"
    echo "  enable <plugin>         - 启用插件"
    echo "  disable <plugin>        - 禁用插件"
    echo "  create <name> [category] - 创建新插件"
    echo "  info <plugin>           - 显示插件信息"
    echo "  load                    - 加载所有启用的插件"
    echo "  help                    - 显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 list"
    echo "  $0 enable core/git-extras"
    echo "  $0 create my-plugin personal"
    echo ""
    echo "插件位置: $PLUGINS_DIR"
    echo "配置文件: $PLUGIN_CONFIG"
}

# 主函数
main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        list|ls)
            list_plugins
            ;;
        install)
            if [ $# -eq 0 ]; then
                log_error "请指定插件名称"
                exit 1
            fi
            install_plugin "$1"
            ;;
        enable)
            if [ $# -eq 0 ]; then
                log_error "请指定插件名称"
                exit 1
            fi
            enable_plugin "$1"
            ;;
        disable)
            if [ $# -eq 0 ]; then
                log_error "请指定插件名称"
                exit 1
            fi
            disable_plugin "$1"
            ;;
        create|new)
            if [ $# -eq 0 ]; then
                log_error "请指定插件名称"
                exit 1
            fi
            create_plugin "$@"
            ;;
        info)
            if [ $# -eq 0 ]; then
                log_error "请指定插件名称"
                exit 1
            fi
            local plugin_path="$PLUGINS_DIR/$1"
            if [ -d "$plugin_path" ]; then
                get_plugin_info "$plugin_path"
            else
                log_error "插件不存在: $1"
                exit 1
            fi
            ;;
        load)
            load_plugins
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
