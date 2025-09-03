#!/usr/bin/env bash
# 安全的 checkout 脚本，处理私有子模块

set -euo pipefail

echo "Attempting to checkout with submodules..."

# 尝试初始化子模块
if git submodule update --init --recursive; then
    echo "✅ All submodules checked out successfully"
else
    echo "⚠️  Some submodules failed to checkout (may be private)"
    echo "Continuing without private submodules..."
    
    # 列出所有子模块
    git config --file .gitmodules --get-regexp path | while read -r key path; do
        submodule_name=$(echo "$key" | sed 's/^submodule\.\(.*\)\.path$/\1/')
        
        # 检查子模块是否已经初始化
        if [ ! -d "$path/.git" ]; then
            echo "  - Skipping private/unavailable submodule: $submodule_name"
            # 创建空目录以避免路径问题
            mkdir -p "$path"
            touch "$path/.gitkeep"
        fi
    done
fi

echo "Checkout process completed"