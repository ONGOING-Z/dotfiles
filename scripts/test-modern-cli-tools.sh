#!/bin/bash

# 现代 CLI 工具测试脚本
# 验证 Starship、McFly 和 Navi 是否正确安装和配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果统计
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

# 测试函数
test_command() {
    local cmd="$1"
    local description="$2"
    ((TESTS_TOTAL++))
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$description: $cmd 已安装"
        return 0
    else
        log_error "$description: $cmd 未找到"
        return 1
    fi
}

test_file() {
    local file="$1"
    local description="$2"
    ((TESTS_TOTAL++))
    
    if [[ -f "$file" ]]; then
        log_success "$description: $file 存在"
        return 0
    else
        log_error "$description: $file 不存在"
        return 1
    fi
}

test_directory() {
    local dir="$1"
    local description="$2"
    ((TESTS_TOTAL++))
    
    if [[ -d "$dir" ]]; then
        log_success "$description: $dir 存在"
        return 0
    else
        log_error "$description: $dir 不存在"
        return 1
    fi
}

test_shell_config() {
    local shell_file="$1"
    local search_pattern="$2"
    local description="$3"
    ((TESTS_TOTAL++))
    
    if [[ -f "$shell_file" ]] && grep -q "$search_pattern" "$shell_file"; then
        log_success "$description: 配置已添加到 $shell_file"
        return 0
    else
        log_error "$description: 配置未找到在 $shell_file"
        return 1
    fi
}

# 主测试函数
main() {
    echo "🧪 现代 CLI 工具测试"
    echo "==================="
    echo
    
    # 测试工具安装
    log_info "1. 测试工具安装..."
    test_command "starship" "Starship 提示符"
    test_command "mcfly" "McFly 智能历史"
    test_command "navi" "Navi 备忘单"
    echo
    
    # 测试配置文件
    log_info "2. 测试配置文件..."
    test_file "$HOME/.config/starship.toml" "Starship 配置文件"
    test_file "$HOME/.mcfly.sh" "McFly 配置文件"
    test_file "$HOME/.navi.sh" "Navi 配置文件"
    test_file "$HOME/.config/navi/config.yaml" "Navi YAML 配置"
    echo
    
    # 测试目录结构
    log_info "3. 测试目录结构..."
    test_directory "$HOME/.local/share/navi/cheats" "Navi 备忘单目录"
    test_directory "$HOME/.config/navi" "Navi 配置目录"
    echo
    
    # 测试备忘单文件
    log_info "4. 测试备忘单文件..."
    test_file "$HOME/.local/share/navi/cheats/git.cheat" "Git 备忘单"
    test_file "$HOME/.local/share/navi/cheats/docker.cheat" "Docker 备忘单"
    test_file "$HOME/.local/share/navi/cheats/linux.cheat" "Linux 备忘单"
    test_file "$HOME/.local/share/navi/cheats/network.cheat" "网络备忘单"
    echo
    
    # 测试 shell 配置
    log_info "5. 测试 shell 配置..."
    if [[ -f "$HOME/.bashrc" ]]; then
        test_shell_config "$HOME/.bashrc" "starship init" "Starship Bash 集成"
        test_shell_config "$HOME/.bashrc" "source.*\.mcfly\.sh" "McFly Bash 集成"
        test_shell_config "$HOME/.bashrc" "source.*\.navi\.sh" "Navi Bash 集成"
    fi
    
    if [[ -f "$HOME/.zshrc" ]]; then
        test_shell_config "$HOME/.zshrc" "starship init" "Starship Zsh 集成"
        test_shell_config "$HOME/.zshrc" "source.*\.mcfly\.sh" "McFly Zsh 集成"
        test_shell_config "$HOME/.zshrc" "source.*\.navi\.sh" "Navi Zsh 集成"
    fi
    echo
    
    # 功能测试
    log_info "6. 功能测试..."
    
    # 测试 Starship
    if command -v starship &> /dev/null; then
        ((TESTS_TOTAL++))
        if starship --version &> /dev/null; then
            log_success "Starship 版本检查: $(starship --version)"
        else
            log_error "Starship 版本检查失败"
        fi
    fi
    
    # 测试 McFly
    if command -v mcfly &> /dev/null; then
        ((TESTS_TOTAL++))
        if mcfly --version &> /dev/null; then
            log_success "McFly 版本检查: $(mcfly --version)"
        else
            log_error "McFly 版本检查失败"
        fi
    fi
    
    # 测试 Navi
    if command -v navi &> /dev/null; then
        ((TESTS_TOTAL++))
        if navi --version &> /dev/null; then
            log_success "Navi 版本检查: $(navi --version)"
        else
            log_error "Navi 版本检查失败"
        fi
    fi
    echo
    
    # 高级测试
    log_info "7. 高级功能测试..."
    
    # 测试 Starship 配置语法
    if command -v starship &> /dev/null && [[ -f "$HOME/.config/starship.toml" ]]; then
        ((TESTS_TOTAL++))
        if starship config 2>/dev/null | head -1 | grep -q "starship"; then
            log_success "Starship 配置语法正确"
        else
            log_error "Starship 配置语法错误"
        fi
    fi
    
    # 测试 Navi 备忘单加载
    if command -v navi &> /dev/null; then
        ((TESTS_TOTAL++))
        local cheat_count=$(find "$HOME/.local/share/navi/cheats" -name "*.cheat" 2>/dev/null | wc -l)
        if [[ $cheat_count -gt 0 ]]; then
            log_success "Navi 备忘单加载: 找到 $cheat_count 个备忘单"
        else
            log_error "Navi 备忘单加载: 未找到备忘单"
        fi
    fi
    echo
    
    # 显示测试结果
    echo "📊 测试结果汇总"
    echo "==============="
    echo "总测试数: $TESTS_TOTAL"
    echo -e "通过: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "失败: ${RED}$TESTS_FAILED${NC}"
    
    local success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    echo "成功率: $success_rate%"
    echo
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 所有测试通过！现代 CLI 工具已正确安装和配置。${NC}"
        echo
        echo "💡 接下来的步骤："
        echo "  1. 重启 shell 或运行 'source ~/.bashrc' (或 ~/.zshrc)"
        echo "  2. 尝试使用 Ctrl+R 进行智能历史搜索 (McFly)"
        echo "  3. 尝试使用 Ctrl+G 打开备忘单 (Navi)"
        echo "  4. 观察新的提示符样式 (Starship)"
        return 0
    else
        echo -e "${RED}❌ 有 $TESTS_FAILED 个测试失败。请检查安装和配置。${NC}"
        echo
        echo "🔧 故障排除建议："
        echo "  1. 重新运行安装脚本: ./scripts/install-modern-cli-tools.sh"
        echo "  2. 检查系统依赖是否满足"
        echo "  3. 查看安装日志中的错误信息"
        echo "  4. 参考文档: docs/MODERN_CLI_TOOLS.md"
        return 1
    fi
}

# 运行测试
main "$@"