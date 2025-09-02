#!/usr/bin/env bash
# Nord 主题颜色定义

# Polar Night (极夜)
export NORD0="#2e3440"   # 最深背景
export NORD1="#3b4252"   # 深背景
export NORD2="#434c5e"   # 背景高亮
export NORD3="#4c566a"   # 注释，不可见字符

# Snow Storm (雪暴)
export NORD4="#d8dee9"   # 主要内容
export NORD5="#e5e9f0"   # 次要内容
export NORD6="#eceff4"   # 高亮内容

# Frost (霜)
export NORD7="#8fbcbb"   # 独特元素
export NORD8="#88c0d0"   # 信息，提示
export NORD9="#81a1c1"   # 主要品牌色
export NORD10="#5e81ac"  # 次要品牌色

# Aurora (极光)
export NORD11="#bf616a"  # 错误，危险
export NORD12="#d08770"  # 警告
export NORD13="#ebcb8b"  # 成功
export NORD14="#a3be8c"  # 字符串
export NORD15="#b48ead"  # 特殊

# ANSI 颜色映射
export COLOR_BLACK="$NORD1"
export COLOR_RED="$NORD11"
export COLOR_GREEN="$NORD14"
export COLOR_YELLOW="$NORD13"
export COLOR_BLUE="$NORD9"
export COLOR_MAGENTA="$NORD15"
export COLOR_CYAN="$NORD8"
export COLOR_WHITE="$NORD5"

# 亮色版本
export COLOR_BRIGHT_BLACK="$NORD3"
export COLOR_BRIGHT_RED="$NORD11"
export COLOR_BRIGHT_GREEN="$NORD14"
export COLOR_BRIGHT_YELLOW="$NORD13"
export COLOR_BRIGHT_BLUE="$NORD9"
export COLOR_BRIGHT_MAGENTA="$NORD15"
export COLOR_BRIGHT_CYAN="$NORD7"
export COLOR_BRIGHT_WHITE="$NORD6"

# 特殊用途
export COLOR_BACKGROUND="$NORD0"
export COLOR_FOREGROUND="$NORD4"
export COLOR_SELECTION="$NORD2"
export COLOR_CURSOR="$NORD4"