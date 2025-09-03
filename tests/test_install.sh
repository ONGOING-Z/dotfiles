#!/usr/bin/env bash
# 简单的安装测试脚本

set -euo pipefail

echo "=== Running installation tests ==="

# 测试帮助命令
echo "Testing help command..."
./install --help || exit 1

# 测试健康检查
echo "Testing health check..."
./install --health-check || true

# 测试最小安装（dry-run）
echo "Testing minimal install (dry-run)..."
echo "n" | ./install --minimal || true

echo "=== All tests completed ==="