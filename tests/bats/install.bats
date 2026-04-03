#!/usr/bin/env bats
# 安装脚本测试

load test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "install 脚本存在且可执行" {
    assert_file_exists "$DOTFILES_ROOT/install"
    [ -x "$DOTFILES_ROOT/install" ]
}

@test "install --help 显示帮助信息" {
    run "$DOTFILES_ROOT/install" --help
    assert_success "$status"
    [[ "$output" =~ "用法" ]]
    [[ "$output" =~ "无参数运行" ]]
    [[ "$output" =~ "带参数运行" ]]
}

@test "install-new.sh 脚本存在" {
    assert_file_exists "$DOTFILES_ROOT/scripts/install-new.sh"
}

@test "install-unified.sh 脚本存在" {
    assert_file_exists "$DOTFILES_ROOT/scripts/install-unified.sh"
}

@test "无参数运行时调用 install-new.sh" {
    # 创建一个模拟的 install-new.sh
    mkdir -p "$TEST_TEMP_DIR/scripts"
    cat > "$TEST_TEMP_DIR/scripts/install-new.sh" << 'EOF'
#!/usr/bin/env bash
echo "MOCK: install-new.sh called"
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/scripts/install-new.sh"

    # 修改 install 脚本使用测试目录
    sed "s|SCRIPT_DIR/scripts|TEST_TEMP_DIR/scripts|g" "$DOTFILES_ROOT/install" > "$TEST_TEMP_DIR/install"
    chmod +x "$TEST_TEMP_DIR/install"

    run "$TEST_TEMP_DIR/install"
    assert_success "$status"
    [[ "$output" =~ "MOCK: install-new.sh called" ]]
}

@test "带参数运行时调用 install-unified.sh" {
    # 创建模拟脚本
    mkdir -p "$TEST_TEMP_DIR/scripts"
    cat > "$TEST_TEMP_DIR/scripts/install-unified.sh" << 'EOF'
#!/usr/bin/env bash
echo "MOCK: install-unified.sh called with args: $@"
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/scripts/install-unified.sh"

    # 修改 install 脚本
    sed "s|SCRIPT_DIR/scripts|TEST_TEMP_DIR/scripts|g" "$DOTFILES_ROOT/install" > "$TEST_TEMP_DIR/install"
    chmod +x "$TEST_TEMP_DIR/install"

    run "$TEST_TEMP_DIR/install" --quick
    assert_success "$status"
    [[ "$output" =~ "MOCK: install-unified.sh called with args: --quick" ]]
}

@test "dotbot 配置文件存在" {
    assert_file_exists "$DOTFILES_ROOT/install.conf.yaml"
}

@test "所有必要的目录存在" {
    assert_dir_exists "$DOTFILES_ROOT/config"
    assert_dir_exists "$DOTFILES_ROOT/scripts"
    assert_dir_exists "$DOTFILES_ROOT/docs"
    assert_dir_exists "$DOTFILES_ROOT/dotbot"
}

@test "配置文件语法正确" {
    # 使用 Python 检查 YAML 语法
    if command -v python3 >/dev/null 2>&1; then
        run python3 -c "import yaml; yaml.safe_load(open('$DOTFILES_ROOT/install.conf.yaml'))"
        assert_success "$status"
    else
        skip "Python3 not available"
    fi
}
