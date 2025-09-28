#!/bin/bash

# Navi 交互式命令行备忘单配置
# 提供快速访问命令备忘单的功能

# Navi 环境变量配置
export NAVI_PATH="$HOME/.local/share/navi/cheats:$(dirname "$0")/navi-cheats"
export NAVI_CONFIG="$HOME/.config/navi/config.yaml"
export NAVI_FZF_OVERRIDES="--height=50% --layout=reverse --border"

# 创建必要的目录
mkdir -p "$HOME/.local/share/navi/cheats"
mkdir -p "$HOME/.config/navi"

# 复制配置文件（如果不存在）
if [[ ! -f "$NAVI_CONFIG" && -f "$(dirname "$0")/navi-config.yaml" ]]; then
    cp "$(dirname "$0")/navi-config.yaml" "$NAVI_CONFIG"
fi

# 自定义 Navi 函数
navi_search() {
    local query="$1"
    if [[ -n "$query" ]]; then
        navi --query "$query"
    else
        navi
    fi
}

# 按标签搜索备忘单
navi_tag() {
    local tag="$1"
    if [[ -z "$tag" ]]; then
        echo "用法: navi_tag <标签名>"
        echo "可用标签:"
        navi --tag-rules | grep -o '%[^,]*' | sort | uniq | sed 's/%/  /'
        return 1
    fi
    navi --tag-rules --query "$tag"
}

# 搜索特定备忘单文件
navi_cheat() {
    local cheat_file="$1"
    if [[ -z "$cheat_file" ]]; then
        echo "用法: navi_cheat <备忘单文件名>"
        echo "可用备忘单:"
        find "$HOME/.local/share/navi/cheats" "$(dirname "$0")/navi-cheats" -name "*.cheat" -exec basename {} .cheat \; 2>/dev/null | sort | uniq | sed 's/^/  /'
        return 1
    fi
    
    # 查找备忘单文件
    local cheat_path=""
    for dir in "$HOME/.local/share/navi/cheats" "$(dirname "$0")/navi-cheats"; do
        if [[ -f "$dir/${cheat_file}.cheat" ]]; then
            cheat_path="$dir/${cheat_file}.cheat"
            break
        fi
    done
    
    if [[ -z "$cheat_path" ]]; then
        echo "❌ 找不到备忘单: $cheat_file"
        return 1
    fi
    
    navi --path "$cheat_path"
}

# 添加新的备忘单
navi_add() {
    local cheat_name="$1"
    if [[ -z "$cheat_name" ]]; then
        echo "用法: navi_add <备忘单名称>"
        return 1
    fi
    
    local cheat_file="$HOME/.local/share/navi/cheats/${cheat_name}.cheat"
    
    if [[ -f "$cheat_file" ]]; then
        echo "📝 编辑现有备忘单: $cheat_file"
    else
        echo "📝 创建新备忘单: $cheat_file"
        cat > "$cheat_file" << EOF
# $cheat_name 备忘单

% $cheat_name

# 示例命令描述
echo "Hello, World!"

# 带参数的命令
echo "<message>"

\$ message: echo -e "Hello\nWorld\nNavi"
EOF
    fi
    
    ${EDITOR:-nano} "$cheat_file"
}

# 列出所有备忘单
navi_list() {
    echo "📚 可用的备忘单:"
    echo "================"
    
    local found_cheats=()
    
    # 搜索所有备忘单文件
    while IFS= read -r -d '' cheat_file; do
        local cheat_name=$(basename "$cheat_file" .cheat)
        local cheat_path=$(dirname "$cheat_file")
        
        # 获取备忘单的描述（第一行注释）
        local description=$(head -n 5 "$cheat_file" | grep "^#" | head -n 1 | sed 's/^# *//')
        
        echo "  📄 $cheat_name"
        [[ -n "$description" ]] && echo "     $description"
        echo "     路径: $cheat_path"
        echo
        
        found_cheats+=("$cheat_name")
    done < <(find "$HOME/.local/share/navi/cheats" "$(dirname "$0")/navi-cheats" -name "*.cheat" -print0 2>/dev/null | sort -z)
    
    if [[ ${#found_cheats[@]} -eq 0 ]]; then
        echo "❌ 没有找到备忘单文件"
        echo "💡 使用 'navi_add <名称>' 创建新的备忘单"
    else
        echo "总计: ${#found_cheats[@]} 个备忘单"
        echo
        echo "💡 使用方法:"
        echo "  navi              - 打开交互式搜索"
        echo "  navi_cheat <名称> - 打开特定备忘单"
        echo "  navi_tag <标签>   - 按标签搜索"
        echo "  navi_search <关键词> - 搜索命令"
    fi
}

# 备份备忘单
navi_backup() {
    local backup_dir="$HOME/.local/share/navi/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    echo "💾 备份备忘单到: $backup_dir"
    
    # 备份用户备忘单
    if [[ -d "$HOME/.local/share/navi/cheats" ]]; then
        cp -r "$HOME/.local/share/navi/cheats"/* "$backup_dir/" 2>/dev/null
    fi
    
    # 备份配置文件
    if [[ -f "$NAVI_CONFIG" ]]; then
        cp "$NAVI_CONFIG" "$backup_dir/config.yaml"
    fi
    
    echo "✅ 备份完成"
    echo "📁 备份位置: $backup_dir"
}

# 同步官方备忘单
navi_sync() {
    echo "🔄 同步官方备忘单..."
    
    # 下载官方备忘单仓库
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if git clone https://github.com/denisidoro/cheats.git; then
        # 复制到用户目录
        mkdir -p "$HOME/.local/share/navi/cheats/official"
        cp -r cheats/* "$HOME/.local/share/navi/cheats/official/"
        
        echo "✅ 官方备忘单同步完成"
        echo "📁 位置: $HOME/.local/share/navi/cheats/official"
    else
        echo "❌ 同步失败，请检查网络连接"
    fi
    
    # 清理临时目录
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# 搜索备忘单内容
navi_grep() {
    local search_term="$1"
    if [[ -z "$search_term" ]]; then
        echo "用法: navi_grep <搜索词>"
        return 1
    fi
    
    echo "🔍 搜索备忘单内容: $search_term"
    echo "================================"
    
    # 在所有备忘单中搜索
    find "$HOME/.local/share/navi/cheats" "$(dirname "$0")/navi-cheats" -name "*.cheat" -exec grep -l -i "$search_term" {} \; 2>/dev/null | while read -r cheat_file; do
        local cheat_name=$(basename "$cheat_file" .cheat)
        echo "📄 在 $cheat_name 中找到:"
        grep -n -i --color=always "$search_term" "$cheat_file" | head -5
        echo
    done
}

# 显示 Navi 统计信息
navi_stats() {
    echo "📊 Navi 统计信息"
    echo "================"
    
    local total_cheats=0
    local total_commands=0
    
    while IFS= read -r -d '' cheat_file; do
        ((total_cheats++))
        local commands=$(grep -c "^[^#%$].*" "$cheat_file" 2>/dev/null || echo 0)
        ((total_commands+=commands))
    done < <(find "$HOME/.local/share/navi/cheats" "$(dirname "$0")/navi-cheats" -name "*.cheat" -print0 2>/dev/null)
    
    echo "备忘单数量: $total_cheats"
    echo "命令总数: $total_commands"
    echo "配置文件: $NAVI_CONFIG"
    echo "备忘单路径: $NAVI_PATH"
    
    if command -v navi &> /dev/null; then
        echo "Navi 版本: $(navi --version)"
    fi
}

# 别名定义
alias n='navi'
alias ns='navi_search'
alias nt='navi_tag'
alias nc='navi_cheat'
alias na='navi_add'
alias nl='navi_list'
alias nb='navi_backup'
alias nsync='navi_sync'
alias ng='navi_grep'
alias nstats='navi_stats'

# 快捷键绑定
if [[ -n "$BASH_VERSION" ]]; then
    # Bash 快捷键绑定
    bind -x '"\C-g": navi_search'
    bind -x '"\C-n": navi'
elif [[ -n "$ZSH_VERSION" ]]; then
    # Zsh 快捷键绑定
    bindkey -s '^g' 'navi_search\n'
    bindkey -s '^n' 'navi\n'
fi

# 初始化 Navi
if command -v navi &> /dev/null; then
    # 设置 shell 集成
    eval "$(navi widget bash 2>/dev/null || navi widget zsh 2>/dev/null || echo '')"
    
    # 首次运行提示
    if [[ ! -f "$HOME/.local/share/navi/.initialized" ]]; then
        echo "🎉 Navi 首次运行!"
        echo "💡 使用 'navi_list' 查看可用的备忘单"
        echo "💡 使用 'Ctrl+G' 快速搜索命令"
        echo "💡 使用 'navi_add <名称>' 添加自定义备忘单"
        
        touch "$HOME/.local/share/navi/.initialized"
    fi
fi