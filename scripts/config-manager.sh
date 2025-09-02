#!/usr/bin/env bash
# 配置管理器 - 保存和恢复安装配置

set -euo pipefail

# 配置目录
CONFIG_DIR="$HOME/.dotfiles"
CONFIG_FILE="$CONFIG_DIR/install-config.json"
HISTORY_FILE="$CONFIG_DIR/install-history.log"
BACKUP_DIR="$CONFIG_DIR/backups"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 初始化配置目录
init_config_dir() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # 创建默认配置文件
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "1.0",
  "last_install": null,
  "preferences": {
    "shell": "zsh",
    "theme": "dracula",
    "plugins": []
  },
  "components": {
    "dotfiles": true,
    "homebrew": false,
    "zsh": false,
    "tmux": false,
    "vim": false,
    "git": false
  }
}
EOF
    fi
    
    # 创建历史文件
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "# Dotfiles 安装历史" > "$HISTORY_FILE"
        echo "# 格式: [时间] 操作 详情" >> "$HISTORY_FILE"
    fi
}

# 保存配置
save_config() {
    local config_type="$1"
    local config_data="$2"
    
    init_config_dir
    
    case "$config_type" in
        "preferences")
            # 使用 Python 更新 JSON
            python3 -c "
import json
data = json.load(open('$CONFIG_FILE'))
data['preferences'].update($config_data)
data['last_install'] = '$(date -Iseconds)'
json.dump(data, open('$CONFIG_FILE', 'w'), indent=2)
"
            ;;
        "components")
            python3 -c "
import json
data = json.load(open('$CONFIG_FILE'))
data['components'].update($config_data)
data['last_install'] = '$(date -Iseconds)'
json.dump(data, open('$CONFIG_FILE', 'w'), indent=2)
"
            ;;
        "full")
            echo "$config_data" > "$CONFIG_FILE"
            ;;
    esac
    
    # 记录到历史
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 保存配置 - $config_type" >> "$HISTORY_FILE"
}

# 加载配置
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "{}"
        return
    fi
    
    cat "$CONFIG_FILE"
}

# 获取配置值
get_config_value() {
    local key="$1"
    local default="${2:-}"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "$default"
        return
    fi
    
    local value=$(python3 -c "
import json
try:
    data = json.load(open('$CONFIG_FILE'))
    keys = '$key'.split('.')
    value = data
    for k in keys:
        value = value.get(k, None)
        if value is None:
            break
    print(value if value is not None else '$default')
except:
    print('$default')
")
    
    echo "$value"
}

# 创建配置快照
create_snapshot() {
    local snapshot_name="${1:-snapshot}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snapshot_file="$BACKUP_DIR/${snapshot_name}_${timestamp}.tar.gz"
    
    init_config_dir
    
    echo -e "${BLUE}创建配置快照...${NC}"
    
    # 收集需要备份的文件
    local files_to_backup=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.vimrc"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$CONFIG_FILE"
    )
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    
    # 复制文件到临时目录
    for file in "${files_to_backup[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "$temp_dir/$(basename "$file")"
        fi
    done
    
    # 创建压缩包
    tar -czf "$snapshot_file" -C "$temp_dir" .
    
    # 清理临时目录
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}✓ 快照已创建: $snapshot_file${NC}"
    
    # 记录到历史
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 创建快照 - $snapshot_file" >> "$HISTORY_FILE"
    
    # 清理旧快照（保留最近5个）
    cleanup_old_snapshots
}

# 恢复快照
restore_snapshot() {
    local snapshot_file="$1"
    
    if [ ! -f "$snapshot_file" ]; then
        echo -e "${RED}错误: 快照文件不存在: $snapshot_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}恢复配置快照...${NC}"
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    
    # 解压快照
    tar -xzf "$snapshot_file" -C "$temp_dir"
    
    # 恢复文件
    for file in "$temp_dir"/*; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local target="$HOME/.$filename"
            
            # 特殊处理配置文件
            if [ "$filename" = "install-config.json" ]; then
                target="$CONFIG_FILE"
            fi
            
            # 备份现有文件
            if [ -f "$target" ]; then
                cp "$target" "${target}.before-restore"
            fi
            
            # 恢复文件
            cp "$file" "$target"
            echo -e "  ${GREEN}✓${NC} 恢复: $target"
        fi
    done
    
    # 清理临时目录
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}✓ 快照恢复完成${NC}"
    
    # 记录到历史
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 恢复快照 - $snapshot_file" >> "$HISTORY_FILE"
}

# 列出快照
list_snapshots() {
    echo -e "${BLUE}可用快照:${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo "  没有可用的快照"
        return
    fi
    
    ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null | while read -r line; do
        local file=$(echo "$line" | awk '{print $NF}')
        local size=$(echo "$line" | awk '{print $5}')
        local date=$(echo "$line" | awk '{print $6, $7, $8}')
        local name=$(basename "$file" .tar.gz)
        
        echo -e "  ${GREEN}•${NC} $name"
        echo "    大小: $size bytes, 日期: $date"
    done
}

# 清理旧快照
cleanup_old_snapshots() {
    local max_snapshots=5
    
    if [ ! -d "$BACKUP_DIR" ]; then
        return
    fi
    
    # 获取快照数量
    local snapshot_count=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
    
    if [ "$snapshot_count" -gt "$max_snapshots" ]; then
        # 删除最旧的快照
        local files_to_delete=$((snapshot_count - max_snapshots))
        ls -t "$BACKUP_DIR"/*.tar.gz | tail -n "$files_to_delete" | xargs rm -f
        echo -e "${YELLOW}清理了 $files_to_delete 个旧快照${NC}"
    fi
}

# 显示安装历史
show_history() {
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "没有安装历史"
        return
    fi
    
    echo -e "${BLUE}安装历史:${NC}"
    echo ""
    tail -n 20 "$HISTORY_FILE" | while read -r line; do
        if [[ "$line" =~ ^\[.*\] ]]; then
            echo "  $line"
        fi
    done
}

# 导出配置
export_config() {
    local export_file="${1:-dotfiles-config-export.json}"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}错误: 没有配置可导出${NC}"
        return 1
    fi
    
    cp "$CONFIG_FILE" "$export_file"
    echo -e "${GREEN}✓ 配置已导出到: $export_file${NC}"
}

# 导入配置
import_config() {
    local import_file="$1"
    
    if [ ! -f "$import_file" ]; then
        echo -e "${RED}错误: 导入文件不存在: $import_file${NC}"
        return 1
    fi
    
    # 验证 JSON 格式
    if ! python3 -m json.tool "$import_file" >/dev/null 2>&1; then
        echo -e "${RED}错误: 无效的配置文件格式${NC}"
        return 1
    fi
    
    # 备份当前配置
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    fi
    
    # 导入配置
    cp "$import_file" "$CONFIG_FILE"
    echo -e "${GREEN}✓ 配置已导入${NC}"
    
    # 记录到历史
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 导入配置 - $import_file" >> "$HISTORY_FILE"
}

# 主函数
main() {
    case "${1:-help}" in
        save)
            shift
            save_config "$@"
            ;;
        load)
            load_config
            ;;
        get)
            shift
            get_config_value "$@"
            ;;
        snapshot)
            shift
            create_snapshot "$@"
            ;;
        restore)
            shift
            restore_snapshot "$@"
            ;;
        list-snapshots)
            list_snapshots
            ;;
        history)
            show_history
            ;;
        export)
            shift
            export_config "$@"
            ;;
        import)
            shift
            import_config "$@"
            ;;
        init)
            init_config_dir
            echo -e "${GREEN}✓ 配置目录已初始化${NC}"
            ;;
        help|--help|-h)
            cat << EOF
配置管理器

用法: config-manager.sh [命令] [参数]

命令:
    save <类型> <数据>    保存配置
    load                 加载配置
    get <键> [默认值]     获取配置值
    snapshot [名称]      创建配置快照
    restore <文件>       恢复快照
    list-snapshots       列出所有快照
    history             显示操作历史
    export [文件]        导出配置
    import <文件>        导入配置
    init                初始化配置目录
    help                显示帮助

示例:
    config-manager.sh save preferences '{"theme": "nord"}'
    config-manager.sh get preferences.theme
    config-manager.sh snapshot before-update
    config-manager.sh restore ~/.dotfiles/backups/snapshot_20240101_120000.tar.gz
EOF
            ;;
        *)
            echo -e "${RED}错误: 未知命令 '$1'${NC}"
            echo "使用 'config-manager.sh help' 查看帮助"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"