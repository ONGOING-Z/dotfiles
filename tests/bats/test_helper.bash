#!/usr/bin/env bash
# 测试辅助函数和通用设置

# 设置测试环境
export TEST_TEMP_DIR=""
export DOTFILES_ROOT=""
export ORIGINAL_HOME=""

# 初始化测试环境
setup_test_env() {
    # 保存原始 HOME
    ORIGINAL_HOME="$HOME"

    # 创建临时测试目录
    TEST_TEMP_DIR="$(mktemp -d)"
    export HOME="$TEST_TEMP_DIR/home"
    mkdir -p "$HOME"

    # 设置 dotfiles 根目录
    DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    # 复制必要的文件到测试环境
    cp -r "$DOTFILES_ROOT/config" "$TEST_TEMP_DIR/config" 2>/dev/null || true
    cp -r "$DOTFILES_ROOT/scripts" "$TEST_TEMP_DIR/scripts" 2>/dev/null || true

    # 导出路径
    export PATH="$DOTFILES_ROOT:$PATH"
}

# 清理测试环境
teardown_test_env() {
    # 恢复原始 HOME
    export HOME="$ORIGINAL_HOME"

    # 清理临时目录
    if [ -n "$TEST_TEMP_DIR" ] && [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# 检查文件是否存在
assert_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "文件不存在: $file"
        return 1
    fi
}

# 检查目录是否存在
assert_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "目录不存在: $dir"
        return 1
    fi
}

# 检查符号链接
assert_link_exists() {
    local link="$1"
    local target="$2"

    if [ ! -L "$link" ]; then
        echo "符号链接不存在: $link"
        return 1
    fi

    if [ -n "$target" ]; then
        local actual_target="$(readlink "$link")"
        if [ "$actual_target" != "$target" ]; then
            echo "符号链接目标不匹配: 期望 $target, 实际 $actual_target"
            return 1
        fi
    fi
}

# 检查命令是否成功
assert_success() {
    local exit_code="$1"
    if [ "$exit_code" -ne 0 ]; then
        echo "命令失败，退出码: $exit_code"
        return 1
    fi
}

# 检查命令是否失败
assert_failure() {
    local exit_code="$1"
    if [ "$exit_code" -eq 0 ]; then
        echo "命令应该失败但成功了"
        return 1
    fi
}

# 模拟用户输入
mock_user_input() {
    echo "$1"
}

# 创建测试配置文件
create_test_config() {
    local config_file="$1"
    cat > "$config_file" << 'EOF'
- defaults:
    link:
      create: true
      relink: true

- clean: ['~']

- link:
    ~/.test_config: config/test_config

- create:
    - ~/test_dir
EOF
}
