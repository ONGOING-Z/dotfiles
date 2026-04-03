#!/usr/bin/env bash
# Shell 脚本格式化工具

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查 shfmt 是否安装
check_shfmt() {
    if ! command -v shfmt >/dev/null 2>&1; then
        echo -e "${RED}错误: shfmt 未安装${NC}"
        echo ""
        echo "安装方法:"
        echo "  macOS:  brew install shfmt"
        echo "  Linux:  GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt"
        echo "  或访问: https://github.com/mvdan/sh"
        exit 1
    fi
}

# 格式化单个文件
format_file() {
    local file="$1"
    echo -e "${BLUE}格式化: $file${NC}"

    # 备份原文件
    cp "$file" "${file}.backup"

    # 格式化
    if shfmt -i 4 -bn -ci -w "$file"; then
        echo -e "${GREEN}  ✓ 成功${NC}"
        rm "${file}.backup"
        return 0
    else
        echo -e "${RED}  ✗ 失败${NC}"
        mv "${file}.backup" "$file"
        return 1
    fi
}

# 检查单个文件
check_file() {
    local file="$1"
    echo -n "检查: $file ... "

    if shfmt -i 4 -bn -ci -d "$file" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${YELLOW}需要格式化${NC}"
        return 1
    fi
}

# 主函数
main() {
    local mode="${1:-check}"
    local target="${2:-.}"

    check_shfmt

    echo -e "${BLUE}=== Shell 脚本格式化工具 ===${NC}"
    echo ""

    local files=()

    # 收集需要处理的文件
    if [ -f "$target" ]; then
        files=("$target")
    else
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$target" -type f \( -name "*.sh" -o -name "*.bash" \) -not -path "*/.git/*" -not -path "*/.venv/*" -print0)

        # 添加特殊的可执行脚本
        for special in install; do
            if [ -f "$special" ] && [ -x "$special" ]; then
                if head -n 1 "$special" | grep -q '^#!/.*sh'; then
                    files+=("$special")
                fi
            fi
        done
    fi

    if [ ${#files[@]} -eq 0 ]; then
        echo "没有找到 Shell 脚本"
        exit 0
    fi

    case "$mode" in
        check)
            echo "检查模式 - 检查格式问题"
            echo ""
            local need_format=0
            for file in "${files[@]}"; do
                if ! check_file "$file"; then
                    need_format=1
                fi
            done

            echo ""
            if [ $need_format -eq 1 ]; then
                echo -e "${YELLOW}一些文件需要格式化${NC}"
                echo "运行 '$0 format' 来格式化所有文件"
                exit 1
            else
                echo -e "${GREEN}所有文件格式正确！${NC}"
            fi
            ;;

        format)
            echo "格式化模式 - 自动修复格式"
            echo ""
            local failed=0
            for file in "${files[@]}"; do
                if ! format_file "$file"; then
                    failed=$((failed + 1))
                fi
            done

            echo ""
            if [ $failed -eq 0 ]; then
                echo -e "${GREEN}格式化完成！${NC}"
            else
                echo -e "${RED}$failed 个文件格式化失败${NC}"
                exit 1
            fi
            ;;

        *)
            echo "用法: $0 [check|format] [文件或目录]"
            echo ""
            echo "模式:"
            echo "  check  - 检查格式问题（默认）"
            echo "  format - 自动格式化文件"
            echo ""
            echo "示例:"
            echo "  $0                    # 检查当前目录"
            echo "  $0 format             # 格式化当前目录"
            echo "  $0 check script.sh    # 检查特定文件"
            echo "  $0 format scripts/    # 格式化特定目录"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
