#!/usr/bin/env bash
# 端到端测试 - 完整安装流程

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试环境
TEST_HOME="/tmp/dotfiles_e2e_test_$$"
ORIGINAL_HOME="$HOME"
TEST_LOG="$TEST_HOME/test.log"

# 清理函数
cleanup() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_HOME"
}

# 错误处理
trap cleanup EXIT

# 创建测试环境
setup_test_env() {
    echo -e "${BLUE}=== 设置 E2E 测试环境 ===${NC}"
    
    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"
    
    # 复制 dotfiles 到测试环境
    cp -r "$(pwd)" "$TEST_HOME/dotfiles"
    cd "$TEST_HOME/dotfiles"
    
    echo -e "${GREEN}✓ 测试环境准备完成${NC}"
}

# 测试最小安装
test_minimal_install() {
    echo -e "\n${BLUE}测试: 最小安装模式${NC}"
    
    echo "n" | ./install --minimal > "$TEST_LOG" 2>&1 || {
        echo -e "${RED}✗ 最小安装失败${NC}"
        cat "$TEST_LOG"
        return 1
    }
    
    # 验证符号链接
    if [ -L "$HOME/.tmux.conf" ]; then
        echo -e "${GREEN}✓ tmux 配置链接创建成功${NC}"
    else
        echo -e "${RED}✗ tmux 配置链接未创建${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ 最小安装测试通过${NC}"
}

# 测试快速安装
test_quick_install() {
    echo -e "\n${BLUE}测试: 快速安装模式${NC}"
    
    # 先清理
    rm -rf "$HOME"/.* 2>/dev/null || true
    mkdir -p "$HOME"
    
    echo "n" | ./install --quick > "$TEST_LOG" 2>&1 || {
        echo -e "${RED}✗ 快速安装失败${NC}"
        cat "$TEST_LOG"
        return 1
    }
    
    echo -e "${GREEN}✓ 快速安装测试通过${NC}"
}

# 测试健康检查
test_health_check() {
    echo -e "\n${BLUE}测试: 健康检查${NC}"
    
    ./install --health-check > "$TEST_LOG" 2>&1 || {
        echo -e "${YELLOW}⚠ 健康检查报告了一些问题（这是预期的）${NC}"
    }
    
    if grep -q "健康检查报告" "$TEST_LOG"; then
        echo -e "${GREEN}✓ 健康检查运行成功${NC}"
    else
        echo -e "${RED}✗ 健康检查未能运行${NC}"
        return 1
    fi
}

# 测试主题切换
test_theme_switcher() {
    echo -e "\n${BLUE}测试: 主题切换器${NC}"
    
    if ./scripts/theme-switcher.sh list > "$TEST_LOG" 2>&1; then
        if grep -q "dracula" "$TEST_LOG"; then
            echo -e "${GREEN}✓ 主题列表功能正常${NC}"
        else
            echo -e "${RED}✗ 主题列表不包含预期主题${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ 主题切换器运行失败${NC}"
        return 1
    fi
}

# 测试配置管理器
test_config_manager() {
    echo -e "\n${BLUE}测试: 配置管理器${NC}"
    
    # 初始化配置
    if ./scripts/config-manager.sh init > "$TEST_LOG" 2>&1; then
        echo -e "${GREEN}✓ 配置管理器初始化成功${NC}"
    else
        echo -e "${RED}✗ 配置管理器初始化失败${NC}"
        cat "$TEST_LOG"
        return 1
    fi
    
    # 创建快照
    if ./scripts/config-manager.sh snapshot test-snapshot > "$TEST_LOG" 2>&1; then
        echo -e "${GREEN}✓ 配置快照创建成功${NC}"
    else
        echo -e "${RED}✗ 配置快照创建失败${NC}"
        return 1
    fi
}

# 测试卸载
test_uninstall() {
    echo -e "\n${BLUE}测试: 卸载功能${NC}"
    
    echo "y" | ./scripts/uninstall.sh > "$TEST_LOG" 2>&1 || {
        echo -e "${YELLOW}⚠ 卸载过程有警告（可能是正常的）${NC}"
    }
    
    # 验证链接已移除
    if [ ! -L "$HOME/.tmux.conf" ]; then
        echo -e "${GREEN}✓ 配置链接已成功移除${NC}"
    else
        echo -e "${RED}✗ 配置链接未能移除${NC}"
        return 1
    fi
}

# 主函数
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        端到端测试套件                 ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    
    setup_test_env
    
    local tests_passed=0
    local tests_failed=0
    
    # 运行测试
    for test in test_minimal_install test_quick_install test_health_check \
                test_theme_switcher test_config_manager test_uninstall; do
        if $test; then
            ((tests_passed++))
        else
            ((tests_failed++))
        fi
    done
    
    # 结果汇总
    echo -e "\n${BLUE}=== 测试结果 ===${NC}"
    echo -e "通过: ${GREEN}$tests_passed${NC}"
    echo -e "失败: ${RED}$tests_failed${NC}"
    
    if [ $tests_failed -eq 0 ]; then
        echo -e "\n${GREEN}所有 E2E 测试通过！ 🎉${NC}"
        exit 0
    else
        echo -e "\n${RED}有测试失败${NC}"
        exit 1
    fi
}

# 运行测试
main "$@"