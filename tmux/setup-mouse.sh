#!/usr/bin/env bash
# tmux 鼠标支持快速设置脚本

set -e

echo "🖱️  tmux 鼠标支持设置"
echo "====================="
echo ""

# 检测操作系统
OS="$(uname -s)"

# 检查并安装剪贴板工具
install_clipboard_tools() {
    echo "📋 检查剪贴板工具..."
    
    if [ "$OS" = "Darwin" ]; then
        # macOS
        if ! command -v pbcopy >/dev/null 2>&1; then
            echo "pbcopy 已内置于 macOS"
        else
            echo "✓ pbcopy 已就绪"
        fi
        
        # 检查 reattach-to-user-namespace（某些旧版本 macOS 需要）
        if ! command -v reattach-to-user-namespace >/dev/null 2>&1; then
            echo "安装 reattach-to-user-namespace..."
            if command -v brew >/dev/null 2>&1; then
                brew install reattach-to-user-namespace
            else
                echo "⚠️  请手动安装: brew install reattach-to-user-namespace"
            fi
        fi
    elif [ "$OS" = "Linux" ]; then
        # Linux
        if ! command -v xclip >/dev/null 2>&1 && ! command -v xsel >/dev/null 2>&1; then
            echo "安装剪贴板工具..."
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y xclip
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y xclip
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S xclip
            else
                echo "⚠️  请手动安装 xclip 或 xsel"
            fi
        else
            echo "✓ 剪贴板工具已就绪"
        fi
    fi
}

# 安装 tmux 插件管理器
install_tpm() {
    echo ""
    echo "🔌 检查 tmux 插件管理器..."
    
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        echo "安装 TPM..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    else
        echo "✓ TPM 已安装"
    fi
}

# 重新加载 tmux 配置
reload_tmux() {
    echo ""
    echo "🔄 重新加载 tmux 配置..."
    
    if tmux info &> /dev/null; then
        tmux source-file ~/.tmux.conf
        echo "✓ 配置已重新加载"
        
        # 安装插件
        echo "📦 安装 tmux 插件..."
        ~/.tmux/plugins/tpm/bin/install_plugins
    else
        echo "ℹ️  tmux 未运行，配置将在下次启动时生效"
    fi
}

# 显示使用说明
show_usage() {
    echo ""
    echo "✨ 设置完成！"
    echo ""
    echo "🖱️  鼠标操作快速参考："
    echo "├─ 拖动选择：选择并复制文本"
    echo "├─ 双击：选择单词"
    echo "├─ 三击：选择整行"
    echo "├─ 右键：粘贴"
    echo "├─ 滚轮：滚动内容"
    echo "└─ Shift+拖动：使用终端原生选择"
    echo ""
    echo "⌨️  快捷键："
    echo "├─ Ctrl-a + m：启用鼠标"
    echo "├─ Ctrl-a + M：禁用鼠标"
    echo "└─ Ctrl-a + Ctrl-m：切换鼠标模式"
    echo ""
    echo "📚 详细文档：tmux/MOUSE_GUIDE.md"
}

# 主流程
main() {
    install_clipboard_tools
    install_tpm
    reload_tmux
    show_usage
}

main "$@"