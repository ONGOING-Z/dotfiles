#!/usr/bin/env bash

# 演示 Gum vs Bash 界面对比

echo "==================================="
echo "    交互式界面对比演示"
echo "==================================="
echo ""
echo "1. 纯 Bash 版本（当前 install-interactive.sh）"
echo "   - 优点：零依赖，任何环境都能运行"
echo "   - 缺点：只能用数字选择，没有视觉反馈"
echo ""
echo "2. Gum 增强版（新的 install-interactive-enhanced.sh）"
echo "   - 优点：精美界面，键盘导航，实时反馈"
echo "   - 缺点：需要安装 gum（约 10MB）"
echo ""
echo "-----------------------------------"
echo ""

# 检查 gum 是否安装
if command -v gum >/dev/null 2>&1; then
    echo "✅ 检测到 Gum 已安装"
    echo ""
    echo "Gum 版本界面示例："
    echo ""
    
    # 演示单选
    echo "📌 单选示例："
    theme=$(echo -e "robbyrussell - 默认主题\nagnoster - Git 状态\npowerlevel10k - 高度定制" | \
            gum choose --header "选择 Zsh 主题（使用方向键）")
    echo "您选择了: $theme"
    echo ""
    
    # 演示多选
    echo "📌 多选示例："
    plugins=$(echo -e "zsh-autosuggestions\nzsh-syntax-highlighting\ngit\ndocker" | \
              gum choose --no-limit --header "选择插件（空格选择，回车确认）")
    echo "您选择了:"
    echo "$plugins"
    echo ""
    
    # 演示输入
    echo "📌 输入示例："
    name=$(gum input --placeholder "Your Name" --prompt "Git 用户名: ")
    echo "您输入了: $name"
    echo ""
    
    # 演示确认
    echo "📌 确认示例："
    if gum confirm "这样的界面是否更友好？"; then
        echo "太好了！"
    else
        echo "没关系，纯 Bash 版本也能用"
    fi
else
    echo "❌ Gum 未安装"
    echo ""
    echo "您可以通过以下方式安装 Gum："
    echo "  • macOS:  brew install gum"
    echo "  • Linux:  参考 https://github.com/charmbracelet/gum"
    echo ""
    echo "或者运行新的安装脚本，它会自动提示安装 Gum："
    echo "  ./install-interactive-enhanced.sh"
fi

echo ""
echo "-----------------------------------"
echo ""
echo "📊 对比总结："
echo ""
echo "纯 Bash 版本适合："
echo "  • CI/CD 环境"
echo "  • 服务器环境"
echo "  • 无法安装额外工具的场景"
echo ""
echo "Gum 增强版适合："
echo "  • 个人开发环境"
echo "  • 需要友好交互的场景"
echo "  • 追求最佳用户体验"
echo ""
echo "🎯 建议：使用增强版脚本（自动降级）"
echo "   ./install-interactive-enhanced.sh"
echo "   - 有 Gum：精美界面"
echo "   - 无 Gum：自动降级到 Bash 版本"