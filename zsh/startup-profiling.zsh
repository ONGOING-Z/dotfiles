#!/usr/bin/env zsh
# Zsh 启动性能分析工具

# 启用性能分析
# 使用方法: 在 .zshrc 开头 source 此文件，或设置 ZSH_PROFILE=1

if [[ "${ZSH_PROFILE:-0}" == "1" ]]; then
  zmodload zsh/zprof 2>/dev/null || true

  # 记录启动时间
  export ZSH_START_TIME=$(date +%s%N)

  # 在 shell 完全加载后显示启动时间
  _show_startup_time() {
    if [[ -n "$ZSH_START_TIME" ]]; then
      local end_time=$(date +%s%N)
      local elapsed=$(( ($end_time - $ZSH_START_TIME) / 1000000 ))
      echo "Zsh startup time: ${elapsed}ms"
      unset ZSH_START_TIME
    fi
  }

  # 添加到 precmd 钩子（只运行一次）
  _startup_time_hook() {
    _show_startup_time
    # 移除钩子，避免重复执行
    precmd_functions=(${precmd_functions[@]/_startup_time_hook})
  }
  precmd_functions+=(_startup_time_hook)
fi

# 延迟加载函数
lazy_load() {
  local plugin="$1"
  shift
  for cmd in "$@"; do
    eval "$cmd() {
      unfunction $cmd
      source $plugin
      $cmd \"\$@\"
    }"
  done
}

# 条件加载函数
conditional_source() {
  [[ -f "$1" ]] && source "$1"
}

# 异步加载函数（在后台加载，不阻塞启动）
async_source() {
  local file="$1"
  if [[ -f "$file" ]]; then
    {
      source "$file"
    } &!
  fi
}
