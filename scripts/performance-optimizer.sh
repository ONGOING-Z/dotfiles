#!/usr/bin/env bash
# 性能优化器 - 自动优化 Shell 配置

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 性能基准测试
benchmark_shell_startup() {
    local shell_path="${1:-$SHELL}"
    local iterations="${2:-10}"
    local times=()

    echo -e "${BLUE}测试 $(basename "$shell_path") 启动性能 ($iterations 次迭代)...${NC}"

    for i in $(seq 1 "$iterations"); do
        local start_time
        start_time=$(date +%s%N)

        # 使用超时防止卡死
        if timeout 10s "$shell_path" -i -c exit >/dev/null 2>&1; then
            local end_time
            end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            times+=("$duration")
            echo -e "  迭代 $i: ${duration}ms"
        else
            echo -e "  迭代 $i: ${RED}超时${NC}"
            times+=("10000")  # 10秒超时作为惩罚值
        fi
    done

    # 计算统计信息
    local sum=0
    local min=999999
    local max=0

    for time in "${times[@]}"; do
        sum=$((sum + time))
        (( time < min )) && min=$time
        (( time > max )) && max=$time
    done

    local avg=$((sum / ${#times[@]}))

    echo ""
    echo -e "${BLUE}=== 性能统计 ===${NC}"
    echo -e "平均启动时间: ${avg}ms"
    echo -e "最快启动时间: ${min}ms"
    echo -e "最慢启动时间: ${max}ms"

    # 性能评级
    if (( avg < 100 )); then
        echo -e "性能评级: ${GREEN}优秀 ⚡${NC}"
    elif (( avg < 300 )); then
        echo -e "性能评级: ${GREEN}良好 ✓${NC}"
    elif (( avg < 500 )); then
        echo -e "性能评级: ${YELLOW}一般 ⚠${NC}"
    else
        echo -e "性能评级: ${RED}需要优化 ✗${NC}"
    fi

    return $avg
}

# 分析配置文件性能瓶颈
analyze_config_bottlenecks() {
    local config_file="$1"

    echo -e "${BLUE}分析配置文件: $config_file${NC}"

    if [[ ! -f "$config_file" ]]; then
        echo -e "${RED}配置文件不存在${NC}"
        return 1
    fi

    echo -e "${YELLOW}潜在性能问题:${NC}"

    # 检查同步的 eval 调用
    local eval_count
    eval_count=$(grep -c "eval.*\$(" "$config_file" 2>/dev/null || echo "0")
    if (( eval_count > 3 )); then
        echo -e "  ${RED}✗${NC} 过多的 eval 调用 ($eval_count 个) - 建议使用延迟加载"
    fi

    # 检查 source 调用
    local source_count
    source_count=$(grep -c "source\|^\." "$config_file" 2>/dev/null || echo "0")
    if (( source_count > 10 )); then
        echo -e "  ${RED}✗${NC} 过多的 source 调用 ($source_count 个) - 建议合并或缓存"
    fi

    # 检查命令存在性检查
    local command_check_count
    command_check_count=$(grep -c "command -v\|which\|type" "$config_file" 2>/dev/null || echo "0")
    if (( command_check_count > 5 )); then
        echo -e "  ${YELLOW}⚠${NC} 多个命令检查 ($command_check_count 个) - 建议批量检查和缓存"
    fi

    # 检查可能的阻塞操作
    if grep -q "curl\|wget\|git.*remote" "$config_file" 2>/dev/null; then
        echo -e "  ${RED}✗${NC} 包含网络调用 - 建议移到后台或延迟执行"
    fi

    # 检查大循环
    if grep -q "for.*in.*{[0-9]*\.\.[0-9]*}" "$config_file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC} 包含大循环 - 检查是否必要"
    fi

    echo ""
}

# 生成优化的配置
generate_optimized_config() {
    local original_config="$1"
    local optimized_config="${original_config}.optimized"
    local backup_config="${original_config}.backup.$(date +%Y%m%d_%H%M%S)"

    echo -e "${BLUE}生成优化配置...${NC}"

    # 备份原配置
    cp "$original_config" "$backup_config"
    echo -e "原配置备份到: $backup_config"

    # 开始生成优化配置
    cat > "$optimized_config" << 'EOF'
#!/usr/bin/env zsh
# 优化的 zsh 配置 - 自动生成
# 原配置备份位置见注释

# 性能优化设置
setopt NO_BEEP
setopt NO_NOMATCH
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# 跳过非交互式 shell 的重型初始化
[[ $- != *i* ]] && return

# 加载智能缓存系统
if [[ -f "$HOME/dotfiles/shell/intelligent-cache.sh" ]]; then
    source "$HOME/dotfiles/shell/intelligent-cache.sh"
fi

# 使用缓存的初始化
if command -v cache_command >/dev/null 2>&1; then
    # 缓存常用的初始化命令
    eval "$(cache_command "zoxide_init" "command -v zoxide >/dev/null && zoxide init zsh" 86400)"
    eval "$(cache_command "fzf_init" "command -v fzf >/dev/null && fzf --zsh" 86400)"
else
    # 回退到传统方式
    command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
    command -v fzf >/dev/null && eval "$(fzf --zsh)"
fi

EOF

    # 从原配置提取基本设置，跳过性能瓶颈
    echo "# 从原配置提取的设置" >> "$optimized_config"

    # 提取基本的 export 和 alias
    grep -E "^export |^alias " "$original_config" | head -20 >> "$optimized_config" || true

    # 添加延迟加载的插件
    cat >> "$optimized_config" << 'EOF'

# 延迟加载重型插件
if [[ -f "$HOME/dotfiles/shell/lazy-load.sh" ]]; then
    source "$HOME/dotfiles/shell/lazy-load.sh"
fi

# 加载别名和函数
[[ -f "$HOME/dotfiles/shell/aliases.sh" ]] && source "$HOME/dotfiles/shell/aliases.sh"
[[ -f "$HOME/dotfiles/shell/functions.sh" ]] && source "$HOME/dotfiles/shell/functions.sh"

# 性能监控（可选）
if [[ "${ZSH_PROFILE:-0}" == "1" ]]; then
    zmodload zsh/zprof
fi
EOF

    echo -e "${GREEN}优化配置已生成: $optimized_config${NC}"
    echo -e "${YELLOW}使用方法:${NC}"
    echo -e "  1. 测试: mv ~/.zshrc ~/.zshrc.old && ln -s $optimized_config ~/.zshrc"
    echo -e "  2. 重启 shell 并测试性能"
    echo -e "  3. 如果满意: mv $optimized_config $original_config"
}

# 系统性能优化建议
system_optimization_tips() {
    echo -e "${BLUE}=== 系统性能优化建议 ===${NC}"

    # 检查系统负载
    if command -v uptime >/dev/null 2>&1; then
        local load
        load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
        if (( $(echo "$load > 2.0" | bc -l 2>/dev/null || echo "0") )); then
            echo -e "  ${YELLOW}⚠${NC} 系统负载较高 ($load) - 可能影响 shell 性能"
        fi
    fi

    # 检查内存使用
    if command -v free >/dev/null 2>&1; then
        local mem_usage
        mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        if (( $(echo "$mem_usage > 90.0" | bc -l 2>/dev/null || echo "0") )); then
            echo -e "  ${YELLOW}⚠${NC} 内存使用率较高 (${mem_usage}%) - 建议关闭不必要的程序"
        fi
    fi

    # 检查磁盘 I/O
    if command -v df >/dev/null 2>&1; then
        local disk_usage
        disk_usage=$(df -h "$HOME" | tail -1 | awk '{print $5}' | tr -d '%')
        if (( disk_usage > 90 )); then
            echo -e "  ${YELLOW}⚠${NC} 磁盘使用率较高 (${disk_usage}%) - 可能影响文件访问速度"
        fi
    fi

    echo -e "${GREEN}优化建议:${NC}"
    echo -e "  • 使用 SSD 存储配置文件"
    echo -e "  • 定期清理缓存目录"
    echo -e "  • 避免在网络存储上放置配置文件"
    echo -e "  • 使用本地 DNS 缓存"
}

# 主函数
main() {
    local action="${1:-benchmark}"

    case "$action" in
        "benchmark"|"bench")
            benchmark_shell_startup "${2:-$SHELL}"
            ;;
        "analyze")
            local config_file="${2:-$HOME/.zshrc}"
            analyze_config_bottlenecks "$config_file"
            ;;
        "optimize")
            local config_file="${2:-$HOME/.zshrc}"
            generate_optimized_config "$config_file"
            ;;
        "system")
            system_optimization_tips
            ;;
        "full")
            echo -e "${GREEN}=== 完整性能分析 ===${NC}"
            benchmark_shell_startup
            echo ""
            analyze_config_bottlenecks "${2:-$HOME/.zshrc}"
            echo ""
            system_optimization_tips
            ;;
        "help"|*)
            echo "性能优化器 - Dotfiles Shell 性能分析和优化工具"
            echo ""
            echo "用法: $0 <命令> [参数]"
            echo ""
            echo "命令:"
            echo "  benchmark [shell]  - 基准测试 shell 启动时间"
            echo "  analyze [config]   - 分析配置文件性能瓶颈"
            echo "  optimize [config]  - 生成优化的配置文件"
            echo "  system            - 系统性能优化建议"
            echo "  full [config]     - 完整的性能分析"
            echo "  help              - 显示此帮助"
            echo ""
            echo "示例:"
            echo "  $0 benchmark                    # 测试当前 shell"
            echo "  $0 analyze ~/.zshrc            # 分析 zsh 配置"
            echo "  $0 optimize ~/.zshrc           # 优化 zsh 配置"
            echo "  $0 full                        # 完整分析"
            ;;
    esac
}

# 如果直接执行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
