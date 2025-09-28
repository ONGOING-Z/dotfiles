#!/bin/bash

# 现代 CLI 工具演示脚本
# 展示 Starship、McFly 和 Navi 的主要功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 打字效果函数
typewriter() {
    local text="$1"
    local delay="${2:-0.05}"
    
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# 等待用户输入
wait_for_user() {
    echo -e "\n${CYAN}按 Enter 继续...${NC}"
    read -r
}

# 显示标题
show_title() {
    clear
    echo -e "${MAGENTA}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                        现代 CLI 工具演示                            ║"
    echo "║                                                                      ║"
    echo "║  🚀 Starship  - 跨 shell 提示符                                     ║"
    echo "║  🧠 McFly     - 智能 shell 历史                                     ║"
    echo "║  📚 Navi      - 交互式命令行备忘单                                   ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    wait_for_user
}

# 演示 Starship
demo_starship() {
    clear
    echo -e "${BLUE}🚀 Starship 演示${NC}"
    echo "=================="
    echo
    
    if command -v starship &> /dev/null; then
        echo -e "${GREEN}✅ Starship 已安装${NC}"
        echo "版本: $(starship --version)"
        echo
        
        echo -e "${YELLOW}📋 主要特性:${NC}"
        echo "  • 快速响应的跨 shell 提示符"
        echo "  • 自动检测项目类型和状态"
        echo "  • 美观的 Git 状态显示"
        echo "  • 编程语言版本显示"
        echo "  • 系统状态监控"
        echo
        
        echo -e "${CYAN}🎨 配置文件位置:${NC}"
        echo "  ~/.config/starship.toml"
        echo
        
        if [[ -f "$HOME/.config/starship.toml" ]]; then
            echo -e "${GREEN}✅ 配置文件已存在${NC}"
        else
            echo -e "${RED}❌ 配置文件未找到${NC}"
        fi
        
        echo
        echo -e "${YELLOW}💡 使用提示:${NC}"
        echo "  重启 shell 后，您将看到新的提示符样式"
        echo "  提示符会根据当前目录和 Git 状态自动调整"
        
    else
        echo -e "${RED}❌ Starship 未安装${NC}"
        echo "请运行安装脚本: ./scripts/install-modern-cli-tools.sh"
    fi
    
    wait_for_user
}

# 演示 McFly
demo_mcfly() {
    clear
    echo -e "${BLUE}🧠 McFly 演示${NC}"
    echo "==============="
    echo
    
    if command -v mcfly &> /dev/null; then
        echo -e "${GREEN}✅ McFly 已安装${NC}"
        echo "版本: $(mcfly --version)"
        echo
        
        echo -e "${YELLOW}📋 主要特性:${NC}"
        echo "  • 智能历史搜索算法"
        echo "  • 学习您的使用模式"
        echo "  • 模糊匹配支持"
        echo "  • 快速响应"
        echo
        
        echo -e "${CYAN}⌨️  快捷键:${NC}"
        echo "  Ctrl+R  - 智能历史搜索"
        echo "  Ctrl+N  - 下一个建议"
        echo "  Ctrl+P  - 上一个建议"
        echo
        
        echo -e "${CYAN}🔧 常用命令:${NC}"
        echo "  mf <搜索词>  - 搜索历史"
        echo "  mfa          - 历史分析"
        echo "  mfc          - 清理重复"
        echo "  mfcfg        - 查看配置"
        echo
        
        if [[ -f "$HOME/.mcfly.sh" ]]; then
            echo -e "${GREEN}✅ 配置文件已存在: ~/.mcfly.sh${NC}"
        else
            echo -e "${RED}❌ 配置文件未找到${NC}"
        fi
        
        echo
        echo -e "${YELLOW}💡 使用提示:${NC}"
        echo "  使用 Ctrl+R 开始智能搜索"
        echo "  McFly 会学习您的命令使用模式"
        echo "  支持模糊匹配，输入部分关键词即可"
        
    else
        echo -e "${RED}❌ McFly 未安装${NC}"
        echo "请运行安装脚本: ./scripts/install-modern-cli-tools.sh"
    fi
    
    wait_for_user
}

# 演示 Navi
demo_navi() {
    clear
    echo -e "${BLUE}📚 Navi 演示${NC}"
    echo "=============="
    echo
    
    if command -v navi &> /dev/null; then
        echo -e "${GREEN}✅ Navi 已安装${NC}"
        echo "版本: $(navi --version)"
        echo
        
        echo -e "${YELLOW}📋 主要特性:${NC}"
        echo "  • 交互式命令备忘单"
        echo "  • 标签分类系统"
        echo "  • 参数自动补全"
        echo "  • 自定义备忘单支持"
        echo
        
        echo -e "${CYAN}⌨️  快捷键:${NC}"
        echo "  Ctrl+G    - 打开 Navi"
        echo "  Enter     - 执行命令"
        echo "  Ctrl+Y    - 复制命令"
        echo "  Esc       - 退出"
        echo
        
        echo -e "${CYAN}🔧 常用命令:${NC}"
        echo "  n / navi         - 打开交互搜索"
        echo "  ns <关键词>      - 搜索特定内容"
        echo "  nt <标签>        - 按标签搜索"
        echo "  nc <备忘单>      - 打开特定备忘单"
        echo "  na <名称>        - 添加新备忘单"
        echo "  nl               - 列出所有备忘单"
        echo
        
        echo -e "${CYAN}📚 内置备忘单:${NC}"
        local cheat_count=0
        if [[ -d "$HOME/.local/share/navi/cheats" ]]; then
            while IFS= read -r -d '' cheat_file; do
                local cheat_name=$(basename "$cheat_file" .cheat)
                echo "  • $cheat_name"
                ((cheat_count++))
            done < <(find "$HOME/.local/share/navi/cheats" -name "*.cheat" -print0 2>/dev/null | head -z -8)
            
            if [[ $cheat_count -gt 0 ]]; then
                echo -e "${GREEN}  总计: $cheat_count 个备忘单${NC}"
            fi
        fi
        
        if [[ $cheat_count -eq 0 ]]; then
            echo -e "${RED}  ❌ 未找到备忘单${NC}"
        fi
        
        echo
        echo -e "${YELLOW}💡 使用提示:${NC}"
        echo "  使用 Ctrl+G 快速打开备忘单搜索"
        echo "  可以创建自定义备忘单存储常用命令"
        echo "  支持参数化命令，提供选择菜单"
        
    else
        echo -e "${RED}❌ Navi 未安装${NC}"
        echo "请运行安装脚本: ./scripts/install-modern-cli-tools.sh"
    fi
    
    wait_for_user
}

# 演示集成使用
demo_integration() {
    clear
    echo -e "${BLUE}🔗 集成使用演示${NC}"
    echo "=================="
    echo
    
    echo -e "${YELLOW}🚀 完整工作流程:${NC}"
    echo
    
    echo -e "${CYAN}1. 美化的提示符 (Starship)${NC}"
    echo "   • 显示当前目录、Git 状态、语言版本等"
    echo "   • 根据项目类型自动调整显示内容"
    echo
    
    echo -e "${CYAN}2. 智能历史搜索 (McFly)${NC}"
    echo "   • 按 Ctrl+R 搜索历史命令"
    echo "   • 智能排序，常用命令优先显示"
    echo "   • 支持模糊匹配和上下文感知"
    echo
    
    echo -e "${CYAN}3. 命令备忘单 (Navi)${NC}"
    echo "   • 按 Ctrl+G 打开备忘单搜索"
    echo "   • 查找复杂命令和参数组合"
    echo "   • 支持参数化和自动补全"
    echo
    
    echo -e "${YELLOW}💡 推荐使用场景:${NC}"
    echo
    echo "• 日常开发: Starship 显示项目状态，McFly 快速找到历史命令"
    echo "• 系统管理: Navi 查找系统管理命令，McFly 记住复杂操作"
    echo "• 学习新工具: Navi 备忘单学习语法，McFly 记录练习命令"
    echo "• 团队协作: 共享 Navi 备忘单，统一命令规范"
    echo
    
    echo -e "${GREEN}🎯 最佳实践:${NC}"
    echo "• 定期更新备忘单，添加新学到的命令"
    echo "• 使用标签系统组织备忘单"
    echo "• 自定义 Starship 配置适应个人需求"
    echo "• 利用 McFly 的学习能力，让搜索越来越精准"
    
    wait_for_user
}

# 显示安装状态
show_installation_status() {
    clear
    echo -e "${BLUE}📊 安装状态检查${NC}"
    echo "=================="
    echo
    
    local all_installed=true
    
    # 检查工具安装
    echo -e "${YELLOW}工具安装状态:${NC}"
    if command -v starship &> /dev/null; then
        echo -e "  ${GREEN}✅ Starship${NC} - $(starship --version)"
    else
        echo -e "  ${RED}❌ Starship 未安装${NC}"
        all_installed=false
    fi
    
    if command -v mcfly &> /dev/null; then
        echo -e "  ${GREEN}✅ McFly${NC} - $(mcfly --version)"
    else
        echo -e "  ${RED}❌ McFly 未安装${NC}"
        all_installed=false
    fi
    
    if command -v navi &> /dev/null; then
        echo -e "  ${GREEN}✅ Navi${NC} - $(navi --version)"
    else
        echo -e "  ${RED}❌ Navi 未安装${NC}"
        all_installed=false
    fi
    
    echo
    
    # 检查配置文件
    echo -e "${YELLOW}配置文件状态:${NC}"
    [[ -f "$HOME/.config/starship.toml" ]] && echo -e "  ${GREEN}✅ Starship 配置${NC}" || echo -e "  ${RED}❌ Starship 配置${NC}"
    [[ -f "$HOME/.mcfly.sh" ]] && echo -e "  ${GREEN}✅ McFly 配置${NC}" || echo -e "  ${RED}❌ McFly 配置${NC}"
    [[ -f "$HOME/.navi.sh" ]] && echo -e "  ${GREEN}✅ Navi 配置${NC}" || echo -e "  ${RED}❌ Navi 配置${NC}"
    
    echo
    
    if $all_installed; then
        echo -e "${GREEN}🎉 所有工具已正确安装！${NC}"
        echo
        echo -e "${CYAN}下一步:${NC}"
        echo "1. 重启 shell: exec \$SHELL"
        echo "2. 或运行: source ~/.bashrc (或 ~/.zshrc)"
        echo "3. 开始享受现代化的命令行体验！"
    else
        echo -e "${RED}❌ 部分工具未安装${NC}"
        echo
        echo -e "${CYAN}解决方案:${NC}"
        echo "运行安装脚本: ./scripts/install-modern-cli-tools.sh"
    fi
    
    wait_for_user
}

# 主菜单
show_menu() {
    while true; do
        clear
        echo -e "${MAGENTA}"
        echo "╔══════════════════════════════════════════════════════════════════════╗"
        echo "║                        现代 CLI 工具演示                            ║"
        echo "╠══════════════════════════════════════════════════════════════════════╣"
        echo "║                                                                      ║"
        echo "║  1. 🚀 Starship 演示                                                ║"
        echo "║  2. 🧠 McFly 演示                                                   ║"
        echo "║  3. 📚 Navi 演示                                                    ║"
        echo "║  4. 🔗 集成使用演示                                                 ║"
        echo "║  5. 📊 安装状态检查                                                 ║"
        echo "║  6. 🚪 退出                                                         ║"
        echo "║                                                                      ║"
        echo "╚══════════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo -n "请选择选项 (1-6): "
        
        read -r choice
        
        case $choice in
            1) demo_starship ;;
            2) demo_mcfly ;;
            3) demo_navi ;;
            4) demo_integration ;;
            5) show_installation_status ;;
            6) 
                echo -e "\n${GREEN}感谢使用现代 CLI 工具演示！${NC}"
                echo -e "${CYAN}享受您的现代化命令行体验！ ✨${NC}\n"
                exit 0
                ;;
            *)
                echo -e "\n${RED}无效选项，请选择 1-6${NC}"
                sleep 2
                ;;
        esac
    done
}

# 主函数
main() {
    # 检查终端支持
    if [[ ! -t 1 ]]; then
        echo "此演示需要在交互式终端中运行"
        exit 1
    fi
    
    # 显示欢迎界面
    show_title
    
    # 显示主菜单
    show_menu
}

# 运行主函数
main "$@"