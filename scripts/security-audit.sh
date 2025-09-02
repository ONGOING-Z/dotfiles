#!/usr/bin/env bash
# 安全审计脚本

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# 审计结果
ISSUES_FOUND=0
WARNINGS=0
REPORT_FILE="security-audit-$(date +%Y%m%d-%H%M%S).txt"

# 日志函数
log_error() {
    echo -e "${RED}[错误]${NC} $*" | tee -a "$REPORT_FILE"
    ((ISSUES_FOUND++))
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $*" | tee -a "$REPORT_FILE"
    ((WARNINGS++))
}

log_success() {
    echo -e "${GREEN}[通过]${NC} $*" | tee -a "$REPORT_FILE"
}

log_info() {
    echo -e "${BLUE}[信息]${NC} $*" | tee -a "$REPORT_FILE"
}

# 检查文件权限
check_file_permissions() {
    echo -e "\n${BLUE}=== 检查文件权限 ===${NC}" | tee -a "$REPORT_FILE"
    
    # SSH 相关文件
    if [ -d "$HOME/.ssh" ]; then
        log_info "检查 SSH 目录权限..."
        
        # SSH 目录应该是 700
        if [ "$(stat -c %a "$HOME/.ssh" 2>/dev/null || stat -f %p "$HOME/.ssh" | cut -c 4-6)" != "700" ]; then
            log_error "SSH 目录权限不正确 (应为 700)"
        else
            log_success "SSH 目录权限正确"
        fi
        
        # SSH 私钥应该是 600
        for key in "$HOME/.ssh/"*; do
            if [ -f "$key" ] && [[ "$key" != *.pub ]] && [[ "$key" != *config ]] && [[ "$key" != *known_hosts* ]]; then
                perms=$(stat -c %a "$key" 2>/dev/null || stat -f %p "$key" | cut -c 4-6)
                if [ "$perms" != "600" ]; then
                    log_error "SSH 私钥权限不正确: $key (应为 600，当前为 $perms)"
                fi
            fi
        done
    fi
    
    # Git 配置
    if [ -f "$HOME/.gitconfig" ]; then
        perms=$(stat -c %a "$HOME/.gitconfig" 2>/dev/null || stat -f %p "$HOME/.gitconfig" | cut -c 4-6)
        if [ "$perms" = "777" ] || [ "$perms" = "666" ]; then
            log_warning "Git 配置文件权限过于宽松: $perms"
        else
            log_success "Git 配置文件权限正常"
        fi
    fi
}

# 检查敏感信息
check_sensitive_data() {
    echo -e "\n${BLUE}=== 检查敏感信息 ===${NC}" | tee -a "$REPORT_FILE"
    
    # 检查常见的敏感信息模式
    local patterns=(
        "password[[:space:]]*="
        "api[_-]?key[[:space:]]*="
        "secret[[:space:]]*="
        "token[[:space:]]*="
        "private[_-]?key"
        "BEGIN.*PRIVATE KEY"
    )
    
    # 排除的文件
    local exclude_patterns=(
        "*.git/*"
        "*.pyc"
        "__pycache__"
        "node_modules"
        ".venv"
    )
    
    log_info "扫描配置文件中的敏感信息..."
    
    local found_sensitive=false
    for pattern in "${patterns[@]}"; do
        while IFS= read -r file; do
            if grep -qi "$pattern" "$file" 2>/dev/null; then
                log_warning "可能包含敏感信息: $file (匹配: $pattern)"
                found_sensitive=true
            fi
        done < <(find . -type f \( -name "*.conf" -o -name "*.config" -o -name "*.ini" -o -name "*.env" \) 2>/dev/null | grep -vE "$(IFS='|'; echo "${exclude_patterns[*]}")")
    done
    
    if [ "$found_sensitive" = false ]; then
        log_success "未发现明文敏感信息"
    fi
}

# 检查环境变量
check_environment_vars() {
    echo -e "\n${BLUE}=== 检查环境变量 ===${NC}" | tee -a "$REPORT_FILE"
    
    # 检查可能包含敏感信息的环境变量
    local sensitive_vars=(
        "PASSWORD"
        "API_KEY"
        "SECRET"
        "TOKEN"
        "PRIVATE_KEY"
        "AWS_SECRET"
        "DATABASE_URL"
    )
    
    log_info "检查环境变量..."
    local found_env=false
    
    for var_pattern in "${sensitive_vars[@]}"; do
        while IFS='=' read -r var value; do
            if [[ "$var" == *"$var_pattern"* ]]; then
                # 脱敏显示
                masked_value="${value:0:3}***${value: -3}"
                log_warning "发现敏感环境变量: $var=$masked_value"
                found_env=true
            fi
        done < <(env | grep -i "$var_pattern" || true)
    done
    
    if [ "$found_env" = false ]; then
        log_success "环境变量检查通过"
    fi
}

# 检查 Git 历史
check_git_history() {
    echo -e "\n${BLUE}=== 检查 Git 历史 ===${NC}" | tee -a "$REPORT_FILE"
    
    if [ -d .git ]; then
        log_info "扫描 Git 历史中的敏感信息..."
        
        # 检查是否有大文件
        large_files=$(git rev-list --objects --all | 
            git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
            awk '$1=="blob" && $3>1048576 {print $4, $3/1048576 "MB"}' |
            head -10)
        
        if [ -n "$large_files" ]; then
            log_warning "Git 历史中发现大文件:"
            echo "$large_files" | while read -r line; do
                echo "  - $line" | tee -a "$REPORT_FILE"
            done
        fi
        
        # 检查已删除但仍在历史中的敏感文件
        sensitive_files=(".env" ".secrets" "credentials" "private_key" "id_rsa")
        for file in "${sensitive_files[@]}"; do
            if git log --all --full-history -- "*$file*" | grep -q .; then
                log_warning "Git 历史中可能包含敏感文件: *$file*"
            fi
        done
    else
        log_info "不是 Git 仓库，跳过历史检查"
    fi
}

# 检查网络配置
check_network_security() {
    echo -e "\n${BLUE}=== 检查网络安全配置 ===${NC}" | tee -a "$REPORT_FILE"
    
    # 检查 Git URLs
    if [ -f .git/config ]; then
        log_info "检查 Git 远程仓库配置..."
        
        if grep -q "url.*http://" .git/config; then
            log_warning "Git 远程仓库使用 HTTP (建议使用 HTTPS 或 SSH)"
        else
            log_success "Git 远程仓库使用安全协议"
        fi
    fi
    
    # 检查 npm/pip 配置
    if [ -f "$HOME/.npmrc" ]; then
        if grep -q "registry.*http://" "$HOME/.npmrc"; then
            log_warning "NPM 注册表使用 HTTP"
        fi
    fi
    
    if [ -f "$HOME/.pip/pip.conf" ] || [ -f "$HOME/.config/pip/pip.conf" ]; then
        pip_conf="$HOME/.pip/pip.conf"
        [ -f "$HOME/.config/pip/pip.conf" ] && pip_conf="$HOME/.config/pip/pip.conf"
        
        if grep -q "index-url.*http://" "$pip_conf"; then
            log_warning "PyPI 索引使用 HTTP"
        fi
    fi
}

# 生成修复建议
generate_recommendations() {
    echo -e "\n${BLUE}=== 安全建议 ===${NC}" | tee -a "$REPORT_FILE"
    
    if [ $ISSUES_FOUND -gt 0 ] || [ $WARNINGS -gt 0 ]; then
        echo -e "\n${YELLOW}发现的问题:${NC}" | tee -a "$REPORT_FILE"
        echo "- 严重问题: $ISSUES_FOUND" | tee -a "$REPORT_FILE"
        echo "- 警告: $WARNINGS" | tee -a "$REPORT_FILE"
        
        echo -e "\n${MAGENTA}修复建议:${NC}" | tee -a "$REPORT_FILE"
        echo "1. 修复 SSH 密钥权限: chmod 700 ~/.ssh && chmod 600 ~/.ssh/*" | tee -a "$REPORT_FILE"
        echo "2. 使用密码管理器存储敏感信息" | tee -a "$REPORT_FILE"
        echo "3. 考虑使用 git-crypt 或 age 加密敏感文件" | tee -a "$REPORT_FILE"
        echo "4. 定期审查和轮换凭据" | tee -a "$REPORT_FILE"
        echo "5. 使用 .gitignore 排除敏感文件" | tee -a "$REPORT_FILE"
    else
        echo -e "${GREEN}未发现安全问题！${NC}" | tee -a "$REPORT_FILE"
    fi
}

# 主函数
main() {
    echo -e "${MAGENTA}╔═══════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║         安全审计工具 v1.0             ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════╝${NC}"
    echo ""
    
    echo "开始安全审计..." | tee "$REPORT_FILE"
    echo "时间: $(date)" | tee -a "$REPORT_FILE"
    echo "用户: $(whoami)" | tee -a "$REPORT_FILE"
    echo "目录: $(pwd)" | tee -a "$REPORT_FILE"
    
    # 运行检查
    check_file_permissions
    check_sensitive_data
    check_environment_vars
    check_git_history
    check_network_security
    
    # 生成建议
    generate_recommendations
    
    echo -e "\n${GREEN}审计完成！${NC}"
    echo "详细报告已保存到: $REPORT_FILE"
    
    # 返回状态码
    [ $ISSUES_FOUND -eq 0 ] && exit 0 || exit 1
}

# 运行主函数
main "$@"