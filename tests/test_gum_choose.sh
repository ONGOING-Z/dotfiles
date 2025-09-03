#!/usr/bin/env bash
# 测试 gum choose 的行为

echo "=== Testing gum choose behavior ==="

# 检查 gum 是否安装
if ! command -v gum >/dev/null 2>&1; then
    echo "gum is not installed"
    exit 1
fi

echo "Testing gum choose with test options..."

# 测试选项
options=(
    "Option 1"
    "Option 2"
    "Option 3"
)

# 运行 gum choose
echo "Please select one or more options:"
if choices=$(gum choose --no-limit "${options[@]}"); then
    echo "Raw output from gum choose:"
    echo "---"
    echo "$choices"
    echo "---"
    echo "Length of choices: ${#choices}"
    echo ""

    # 解析成数组
    selected=()
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            selected+=("$line")
            echo "Added to array: '$line'"
        fi
    done <<< "$choices"

    echo ""
    echo "Total items in array: ${#selected[@]}"
    echo "Array contents:"
    for i in "${!selected[@]}"; do
        echo "  [$i]: '${selected[$i]}'"
    done
else
    echo "User cancelled selection"
fi
