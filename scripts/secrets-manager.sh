#!/usr/bin/env bash
# 敏感信息管理工具

set -euo pipefail

# 配置
SECRETS_DIR="$HOME/.dotfiles/secrets"
ENCRYPTED_FILE="$SECRETS_DIR/secrets.enc"
SECRETS_FILE="$SECRETS_DIR/secrets.env"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 确保目录存在
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

# 检查加密工具
check_encryption_tool() {
    if command -v age >/dev/null 2>&1; then
        echo "age"
    elif command -v gpg >/dev/null 2>&1; then
        echo "gpg"
    else
        echo "none"
    fi
}

# Age 加密/解密
age_encrypt() {
    local input_file="$1"
    local output_file="$2"
    
    # 生成密钥（如果不存在）
    if [ ! -f "$SECRETS_DIR/age-key.txt" ]; then
        echo -e "${BLUE}生成 age 密钥...${NC}"
        age-keygen > "$SECRETS_DIR/age-key.txt"
        chmod 600 "$SECRETS_DIR/age-key.txt"
    fi
    
    # 加密
    age -e -i "$SECRETS_DIR/age-key.txt" -o "$output_file" "$input_file"
}

age_decrypt() {
    local input_file="$1"
    local output_file="$2"
    
    if [ ! -f "$SECRETS_DIR/age-key.txt" ]; then
        error "age 密钥不存在"
        return 1
    fi
    
    age -d -i "$SECRETS_DIR/age-key.txt" -o "$output_file" "$input_file"
}

# GPG 加密/解密
gpg_encrypt() {
    local input_file="$1"
    local output_file="$2"
    
    gpg --yes --armor --symmetric --cipher-algo AES256 --output "$output_file" "$input_file"
}

gpg_decrypt() {
    local input_file="$1"
    local output_file="$2"
    
    gpg --yes --decrypt --output "$output_file" "$input_file"
}

# 通用加密函数
encrypt_file() {
    local tool=$(check_encryption_tool)
    
    case "$tool" in
        age)
            age_encrypt "$1" "$2"
            ;;
        gpg)
            gpg_encrypt "$1" "$2"
            ;;
        *)
            error "没有可用的加密工具"
            echo "请安装 age 或 gpg:"
            echo "  macOS: brew install age"
            echo "  Linux: sudo apt-get install age"
            return 1
            ;;
    esac
}

# 通用解密函数
decrypt_file() {
    local tool=$(check_encryption_tool)
    
    case "$tool" in
        age)
            age_decrypt "$1" "$2"
            ;;
        gpg)
            gpg_decrypt "$1" "$2"
            ;;
        *)
            error "没有可用的加密工具"
            return 1
            ;;
    esac
}

# 错误处理
error() {
    echo -e "${RED}错误: $*${NC}" >&2
}

# 成功信息
success() {
    echo -e "${GREEN}成功: $*${NC}"
}

# 添加密钥
add_secret() {
    local key="$1"
    local value="$2"
    
    # 解密现有文件（如果存在）
    if [ -f "$ENCRYPTED_FILE" ]; then
        decrypt_file "$ENCRYPTED_FILE" "$SECRETS_FILE" || return 1
    fi
    
    # 添加或更新密钥
    if [ -f "$SECRETS_FILE" ]; then
        # 移除旧值
        grep -v "^${key}=" "$SECRETS_FILE" > "$SECRETS_FILE.tmp" || true
        mv "$SECRETS_FILE.tmp" "$SECRETS_FILE"
    fi
    
    # 添加新值
    echo "${key}=${value}" >> "$SECRETS_FILE"
    
    # 重新加密
    encrypt_file "$SECRETS_FILE" "$ENCRYPTED_FILE"
    
    # 删除明文文件
    rm -f "$SECRETS_FILE"
    
    success "密钥 '$key' 已添加"
}

# 获取密钥
get_secret() {
    local key="$1"
    
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        error "没有存储的密钥"
        return 1
    fi
    
    # 解密到临时文件
    local temp_file=$(mktemp)
    decrypt_file "$ENCRYPTED_FILE" "$temp_file" || return 1
    
    # 获取值
    local value=$(grep "^${key}=" "$temp_file" | cut -d'=' -f2-)
    
    # 清理
    rm -f "$temp_file"
    
    if [ -n "$value" ]; then
        echo "$value"
    else
        error "密钥 '$key' 不存在"
        return 1
    fi
}

# 列出所有密钥
list_secrets() {
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        echo "没有存储的密钥"
        return 0
    fi
    
    # 解密到临时文件
    local temp_file=$(mktemp)
    decrypt_file "$ENCRYPTED_FILE" "$temp_file" || return 1
    
    echo -e "${BLUE}存储的密钥:${NC}"
    while IFS='=' read -r key value; do
        # 脱敏显示
        masked_value="${value:0:3}***${value: -3}"
        echo "  • $key = $masked_value"
    done < "$temp_file"
    
    # 清理
    rm -f "$temp_file"
}

# 删除密钥
remove_secret() {
    local key="$1"
    
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        error "没有存储的密钥"
        return 1
    fi
    
    # 解密
    decrypt_file "$ENCRYPTED_FILE" "$SECRETS_FILE" || return 1
    
    # 删除密钥
    grep -v "^${key}=" "$SECRETS_FILE" > "$SECRETS_FILE.tmp" || true
    mv "$SECRETS_FILE.tmp" "$SECRETS_FILE"
    
    # 重新加密
    encrypt_file "$SECRETS_FILE" "$ENCRYPTED_FILE"
    
    # 清理
    rm -f "$SECRETS_FILE"
    
    success "密钥 '$key' 已删除"
}

# 导出到 shell
export_to_shell() {
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        error "没有存储的密钥"
        return 1
    fi
    
    # 解密到临时文件
    local temp_file=$(mktemp)
    decrypt_file "$ENCRYPTED_FILE" "$temp_file" || return 1
    
    # 导出
    while IFS='=' read -r key value; do
        export "$key=$value"
    done < "$temp_file"
    
    # 清理
    rm -f "$temp_file"
    
    success "密钥已导出到当前 shell"
}

# 交互式添加
interactive_add() {
    echo -e "${CYAN}添加新密钥${NC}"
    
    read -rp "密钥名称: " key
    read -rsp "密钥值: " value
    echo
    
    if [ -z "$key" ] || [ -z "$value" ]; then
        error "密钥名称和值不能为空"
        return 1
    fi
    
    add_secret "$key" "$value"
}

# 显示帮助
show_help() {
    echo "用法: $0 <command> [args]"
    echo ""
    echo "命令:"
    echo "  add <key> <value>  - 添加密钥"
    echo "  get <key>          - 获取密钥值"
    echo "  remove <key>       - 删除密钥"
    echo "  list               - 列出所有密钥"
    echo "  export             - 导出到当前 shell"
    echo "  interactive        - 交互式添加"
    echo "  help               - 显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 add API_KEY abc123"
    echo "  $0 get API_KEY"
    echo "  $0 list"
    echo ""
    echo "加密工具: $(check_encryption_tool)"
}

# 主函数
main() {
    local command="${1:-help}"
    
    case "$command" in
        add)
            if [ $# -lt 3 ]; then
                error "用法: $0 add <key> <value>"
                exit 1
            fi
            add_secret "$2" "$3"
            ;;
        get)
            if [ $# -lt 2 ]; then
                error "用法: $0 get <key>"
                exit 1
            fi
            get_secret "$2"
            ;;
        remove|rm)
            if [ $# -lt 2 ]; then
                error "用法: $0 remove <key>"
                exit 1
            fi
            remove_secret "$2"
            ;;
        list|ls)
            list_secrets
            ;;
        export)
            export_to_shell
            ;;
        interactive|i)
            interactive_add
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"