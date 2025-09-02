#!/usr/bin/env bash
# 设置 Git hooks

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查 pre-commit 是否安装
check_pre_commit() {
    if ! command -v pre-commit >/dev/null 2>&1; then
        echo -e "${YELLOW}pre-commit 未安装${NC}"
        echo ""
        echo "安装方法:"
        echo "  pip install pre-commit"
        echo "  或"
        echo "  brew install pre-commit"
        echo ""
        read -rp "是否尝试自动安装? [y/N] " install_pc
        
        if [[ "$install_pc" =~ ^[Yy]$ ]]; then
            if command -v pip3 >/dev/null 2>&1; then
                pip3 install pre-commit
            elif command -v brew >/dev/null 2>&1; then
                brew install pre-commit
            else
                echo -e "${RED}无法自动安装，请手动安装 pre-commit${NC}"
                exit 1
            fi
        else
            exit 1
        fi
    fi
}

# 安装 hooks
install_hooks() {
    echo -e "${BLUE}安装 Git hooks...${NC}"
    
    # 安装 pre-commit hooks
    pre-commit install
    pre-commit install --hook-type commit-msg
    
    echo -e "${GREEN}✓ Pre-commit hooks 已安装${NC}"
    
    # 首次运行（可选）
    read -rp "是否立即运行所有 hooks 检查? [y/N] " run_now
    if [[ "$run_now" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}运行 pre-commit 检查...${NC}"
        pre-commit run --all-files || true
    fi
}

# 创建自定义 hooks
create_custom_hooks() {
    local hooks_dir=".git/hooks"
    
    # 确保 hooks 目录存在
    mkdir -p "$hooks_dir"
    
    # 创建 commit-msg hook（检查提交信息格式）
    cat > "$hooks_dir/commit-msg.custom" << 'EOF'
#!/usr/bin/env bash
# 自定义提交信息检查

# 读取提交信息
commit_msg=$(cat "$1")

# 检查是否符合约定式提交
if ! echo "$commit_msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|chore|build|ci)(\(.+\))?: .+'; then
    echo "错误: 提交信息不符合约定式提交规范"
    echo ""
    echo "格式: <type>(<scope>): <subject>"
    echo ""
    echo "示例:"
    echo "  feat: 添加用户登录功能"
    echo "  fix(auth): 修复登录验证错误"
    echo "  docs: 更新 README"
    echo ""
    echo "类型:"
    echo "  feat     - 新功能"
    echo "  fix      - 错误修复"
    echo "  docs     - 文档更新"
    echo "  style    - 代码格式（不影响代码运行的变动）"
    echo "  refactor - 重构（既不是新增功能，也不是修复bug）"
    echo "  perf     - 性能优化"
    echo "  test     - 增加测试"
    echo "  chore    - 构建过程或辅助工具的变动"
    exit 1
fi
EOF
    
    chmod +x "$hooks_dir/commit-msg.custom"
    
    # 创建 pre-push hook（运行测试）
    cat > "$hooks_dir/pre-push.custom" << 'EOF'
#!/usr/bin/env bash
# 推送前运行测试

echo "运行测试..."

# Shell 脚本测试
if [ -f tests/run_tests.sh ]; then
    ./tests/run_tests.sh || exit 1
fi

# Python 测试
if [ -f pytest.ini ]; then
    python -m pytest -q || exit 1
fi

echo "所有测试通过 ✓"
EOF
    
    chmod +x "$hooks_dir/pre-push.custom"
    
    echo -e "${GREEN}✓ 自定义 hooks 已创建${NC}"
}

# 显示 hooks 状态
show_hooks_status() {
    echo -e "\n${BLUE}=== Git Hooks 状态 ===${NC}"
    
    if [ -d .git/hooks ]; then
        echo -e "\n已安装的 hooks:"
        for hook in .git/hooks/*; do
            if [ -x "$hook" ] && [ ! -f "$hook.sample" ]; then
                echo "  • $(basename "$hook")"
            fi
        done
    fi
    
    if command -v pre-commit >/dev/null 2>&1; then
        echo -e "\nPre-commit 配置:"
        pre-commit --version
        echo "配置文件: .pre-commit-config.yaml"
    fi
}

# 主函数
main() {
    echo -e "${BLUE}=== Git Hooks 设置工具 ===${NC}\n"
    
    # 检查是否在 Git 仓库中
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo -e "${RED}错误: 不在 Git 仓库中${NC}"
        exit 1
    fi
    
    check_pre_commit
    install_hooks
    create_custom_hooks
    show_hooks_status
    
    echo -e "\n${GREEN}Git hooks 设置完成！${NC}"
    echo ""
    echo "提示:"
    echo "  • 提交代码时会自动运行检查"
    echo "  • 使用 'pre-commit run --all-files' 手动运行所有检查"
    echo "  • 使用 'git commit --no-verify' 跳过 hooks（不推荐）"
}

# 运行主函数
main "$@"