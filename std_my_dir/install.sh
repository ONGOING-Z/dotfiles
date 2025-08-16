#!/bin/bash

echo "🚀 安装 stddirs 全局命令..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STDDIRS_SCRIPT="$SCRIPT_DIR/stddirs"

if [ ! -f "$STDDIRS_SCRIPT" ]; then
    echo "❌ 错误: 找不到 stddirs 脚本"
    exit 1
fi

chmod +x "$STDDIRS_SCRIPT"

# 安装到用户本地bin目录
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
cp "$STDDIRS_SCRIPT" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/stddirs"

echo "✅ 安装完成到: $INSTALL_DIR"

# 检查PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "⚠️  请将以下行添加到 ~/.zshrc:"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "然后运行: source ~/.zshrc"
else
    echo "🎉 stddirs 命令已可用！"
    echo "测试: stddirs --help"
fi
