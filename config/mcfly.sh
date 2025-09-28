#!/bin/bash

# McFly 智能 shell 历史配置
# 提供智能的命令历史搜索和建议

# McFly 环境变量配置
export MCFLY_KEY_SCHEME=vim                    # 使用 vim 键绑定
export MCFLY_FUZZY=2                          # 启用模糊搜索（0=关闭，1=部分，2=完全）
export MCFLY_RESULTS=50                       # 搜索结果数量
export MCFLY_INTERFACE_VIEW=TOP               # 界面显示位置 (TOP/BOTTOM)
export MCFLY_RESULTS_SORT=LAST_RUN           # 结果排序方式 (RANK/LAST_RUN)
export MCFLY_PROMPT="❯"                      # 自定义提示符
export MCFLY_DISABLE_MENU=FALSE              # 是否禁用菜单
export MCFLY_LIGHT=FALSE                     # 使用浅色主题

# 高级配置
export MCFLY_HISTFILE="$HOME/.bash_history"  # 历史文件路径
export MCFLY_HISTORY_LIMIT=10000            # 历史记录限制

# 自定义快捷键函数
mcfly_search() {
    local selected
    selected=$(mcfly search --limit 20 "$@")
    if [[ -n "$selected" ]]; then
        # 将选中的命令添加到命令行
        READLINE_LINE="$selected"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

# 绑定快捷键 (Ctrl+R)
bind -x '"\C-r": mcfly_search'

# 智能历史分析函数
mcfly_analyze() {
    echo "📊 McFly 历史分析"
    echo "=================="

    if command -v mcfly &> /dev/null; then
        # 显示最常用的命令
        echo "🔝 最常用的命令："
        mcfly search --limit 10 | head -10

        echo
        echo "📈 历史统计："
        echo "总命令数: $(wc -l < "$MCFLY_HISTFILE")"
        echo "唯一命令数: $(sort "$MCFLY_HISTFILE" | uniq | wc -l)"

        # 显示最近使用的目录
        echo
        echo "📁 最近访问的目录："
        grep -o 'cd [^;]*' "$MCFLY_HISTFILE" | tail -10 | cut -d' ' -f2-
    else
        echo "❌ McFly 未安装或未正确配置"
    fi
}

# 清理重复历史记录
mcfly_clean_history() {
    echo "🧹 清理重复的历史记录..."

    # 备份当前历史
    cp "$MCFLY_HISTFILE" "${MCFLY_HISTFILE}.backup.$(date +%Y%m%d_%H%M%S)"

    # 去重并保持顺序
    awk '!seen[$0]++' "$MCFLY_HISTFILE" > "${MCFLY_HISTFILE}.tmp"
    mv "${MCFLY_HISTFILE}.tmp" "$MCFLY_HISTFILE"

    echo "✅ 历史记录清理完成"
}

# 导出 McFly 历史
mcfly_export() {
    local output_file="${1:-mcfly_history_export_$(date +%Y%m%d_%H%M%S).txt}"

    echo "📤 导出 McFly 历史到: $output_file"

    if command -v mcfly &> /dev/null; then
        mcfly search --limit 1000 > "$output_file"
        echo "✅ 导出完成: $output_file"
    else
        echo "❌ McFly 未安装"
    fi
}

# 导入外部历史文件到 McFly
mcfly_import() {
    local import_file="$1"

    if [[ -z "$import_file" ]]; then
        echo "❌ 请指定要导入的历史文件"
        echo "用法: mcfly_import <历史文件路径>"
        return 1
    fi

    if [[ ! -f "$import_file" ]]; then
        echo "❌ 文件不存在: $import_file"
        return 1
    fi

    echo "📥 导入历史文件: $import_file"

    # 备份当前历史
    cp "$MCFLY_HISTFILE" "${MCFLY_HISTFILE}.backup.$(date +%Y%m%d_%H%M%S)"

    # 合并历史文件
    cat "$import_file" >> "$MCFLY_HISTFILE"

    # 去重
    mcfly_clean_history

    echo "✅ 导入完成"
}

# 显示 McFly 配置
mcfly_config() {
    echo "⚙️  McFly 当前配置"
    echo "=================="
    echo "键绑定模式: $MCFLY_KEY_SCHEME"
    echo "模糊搜索: $MCFLY_FUZZY"
    echo "结果数量: $MCFLY_RESULTS"
    echo "界面位置: $MCFLY_INTERFACE_VIEW"
    echo "排序方式: $MCFLY_RESULTS_SORT"
    echo "历史文件: $MCFLY_HISTFILE"
    echo "历史限制: $MCFLY_HISTORY_LIMIT"
    echo "浅色主题: $MCFLY_LIGHT"
}

# 别名定义
alias mf='mcfly search'
alias mfa='mcfly_analyze'
alias mfc='mcfly_clean_history'
alias mfe='mcfly_export'
alias mfi='mcfly_import'
alias mfcfg='mcfly_config'

# 初始化 McFly (这应该在 shell 配置文件的最后调用)
if command -v mcfly &> /dev/null; then
    eval "$(mcfly init bash)"
fi
