#!/usr/bin/env bash
# 烟雾测试 - 快速验证基本功能

set -euo pipefail

echo "=== Running smoke tests ==="

# 测试 1: 检查主要脚本是否存在
echo -n "Checking main scripts exist... "
for script in install scripts/install-new.sh scripts/health-check.sh; do
    if [ ! -f "$script" ]; then
        echo "FAIL: $script not found"
        exit 1
    fi
done
echo "PASS"

# 测试 2: 检查脚本是否有执行权限
echo -n "Checking script permissions... "
for script in install scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        echo "FAIL: $script is not executable"
        exit 1
    fi
done
echo "PASS"

# 测试 3: 检查基本语法
echo -n "Checking bash syntax... "
if bash -n install 2>/dev/null; then
    echo "PASS"
else
    echo "FAIL: install script has syntax errors"
    exit 1
fi

# 测试 4: 检查配置文件
echo -n "Checking config files... "
for config in install.conf.yaml .gitmodules; do
    if [ ! -f "$config" ]; then
        echo "FAIL: $config not found"
        exit 1
    fi
done
echo "PASS"

echo ""
echo "=== All smoke tests passed ✅ ==="