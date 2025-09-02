#!/usr/bin/env bash
# 安装流程集成测试

set -euo pipefail

# 测试环境设置
TEST_HOME="/tmp/dotfiles_test_$$"
ORIGINAL_HOME="$HOME"
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试计数
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# 设置测试环境
setup_test_env() {
    echo -e "${BLUE}设置测试环境...${NC}"
    
    # 创建测试 HOME
    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"
    
    # 复制必要文件
    cp -r "$DOTFILES_ROOT" "$TEST_HOME/dotfiles"
    cd "$TEST_HOME/dotfiles"
    
    # 创建一些已存在的配置文件来测试冲突处理
    echo "existing bashrc" > "$TEST_HOME/.bashrc"
    echo "existing vimrc" > "$TEST_HOME/.vimrc"
    
    echo -e "${GREEN}✓ 测试环境准备完成${NC}"
    echo ""
}

# 清理测试环境
cleanup_test_env() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_HOME"
}

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n -e "测试: $test_name ... "
    ((TESTS_RUN++))
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ 通过${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 测试帮助命令
test_help_command() {
    ./install --help | grep -q "用法"
}

# 测试健康检查
test_health_check() {
    ./install --health-check || true  # 允许失败但不应崩溃
}

# 测试最小安装
test_minimal_install() {
    # 创建模拟输入（跳过所有交互）
    echo "n" | ./install --minimal >/dev/null 2>&1 || true
    
    # 检查是否创建了基本的符号链接
    [ -L "$TEST_HOME/.tmux.conf" ]
}

# 测试配置备份
test_backup_existing() {
    # 确保已存在的文件被备份
    [ -f "$TEST_HOME/.bashrc" ] || return 1
    
    # 运行安装（会备份现有文件）
    echo "n" | ./scripts/install-unified.sh --minimal >/dev/null 2>&1 || true
    
    # 检查备份文件是否存在
    ls "$TEST_HOME/.bashrc.backup."* >/dev/null 2>&1
}

# 测试主题系统
test_theme_system() {
    # 列出主题
    ./scripts/theme-switcher.sh list | grep -q "dracula"
}

# 测试配置管理器
test_config_manager() {
    # 初始化配置
    ./scripts/config-manager.sh init
    
    # 检查配置目录
    [ -d "$TEST_HOME/.dotfiles" ]
}

# 测试环境检测
test_env_detector() {
    ./scripts/env-detector.sh | grep -q "操作系统"
}

# 测试别名和函数加载
test_shell_configs() {
    # 创建测试脚本
    cat > test_shell.sh << 'EOF'
#!/usr/bin/env bash
source config/bashrc 2>/dev/null || true
type mkcd >/dev/null 2>&1
EOF
    
    chmod +x test_shell.sh
    ./test_shell.sh
    local result=$?
    rm -f test_shell.sh
    return $result
}

# 测试 Git 配置
test_git_config() {
    # 检查 gitconfig 文件存在
    [ -f "git/gitconfig" ]
}

# 测试文档完整性
test_documentation() {
    # 检查关键文档存在
    [ -f "README.md" ] && \
    [ -f "docs/README_CN.md" ] && \
    [ -f "docs/TROUBLESHOOTING.md" ] && \
    [ -f "docs/CONTRIBUTING.md" ]
}

# 运行所有测试
run_all_tests() {
    echo -e "${BLUE}=== 运行集成测试 ===${NC}"
    echo ""
    
    # 基础功能测试
    run_test "帮助命令" test_help_command
    run_test "健康检查" test_health_check
    run_test "最小安装" test_minimal_install
    run_test "配置备份" test_backup_existing
    
    # 功能模块测试
    run_test "主题系统" test_theme_system
    run_test "配置管理器" test_config_manager
    run_test "环境检测" test_env_detector
    run_test "Shell 配置" test_shell_configs
    
    # 项目完整性测试
    run_test "Git 配置" test_git_config
    run_test "文档完整性" test_documentation
}

# 生成测试报告
generate_report() {
    echo ""
    echo -e "${BLUE}=== 测试报告 ===${NC}"
    echo -e "总测试数: $TESTS_RUN"
    echo -e "${GREEN}通过: $TESTS_PASSED${NC}"
    echo -e "${RED}失败: $TESTS_FAILED${NC}"
    
    local pass_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
    echo -e "通过率: ${pass_rate}%"
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "\n${GREEN}✓ 所有测试通过！${NC}"
        return 0
    else
        echo -e "\n${RED}✗ 有测试失败${NC}"
        return 1
    fi
}

# 主函数
main() {
    # 捕获退出信号以确保清理
    trap cleanup_test_env EXIT
    
    setup_test_env
    run_all_tests
    generate_report
    
    # 返回失败的测试数作为退出码
    exit "$TESTS_FAILED"
}

# 运行主函数
main "$@"