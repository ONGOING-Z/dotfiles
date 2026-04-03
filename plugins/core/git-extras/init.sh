#!/usr/bin/env bash
# Git 增强插件

# 插件元数据
PLUGIN_NAME="git-extras"
PLUGIN_VERSION="1.0.0"
PLUGIN_DESCRIPTION="Git 命令增强和快捷操作"

# 插件初始化
plugin_init() {
    # Git 别名
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git pull'
    alias gd='git diff'
    alias gco='git checkout'
    alias gb='git branch'
    alias glog='git log --oneline --graph --decorate'
    alias gundo='git reset HEAD~1 --soft'

    # Git 函数

    # 快速提交
    gquick() {
        local message="${1:-Quick commit}"
        git add -A && git commit -m "$message"
    }

    # 创建并切换分支
    gnew() {
        local branch="$1"
        if [ -z "$branch" ]; then
            echo "用法: gnew <branch-name>"
            return 1
        fi
        git checkout -b "$branch"
    }

    # 删除本地和远程分支
    gdelete() {
        local branch="$1"
        if [ -z "$branch" ]; then
            echo "用法: gdelete <branch-name>"
            return 1
        fi

        echo "删除分支: $branch"
        git branch -d "$branch" 2>/dev/null || git branch -D "$branch"
        git push origin --delete "$branch" 2>/dev/null || true
    }

    # 交互式 rebase
    grebase() {
        local commits="${1:-10}"
        git rebase -i HEAD~"$commits"
    }

    # 查看贡献者统计
    gcontrib() {
        git shortlog -sn --all --no-merges
    }

    # 查找包含特定提交的分支
    gfind() {
        local commit="$1"
        if [ -z "$commit" ]; then
            echo "用法: gfind <commit-hash>"
            return 1
        fi
        git branch -a --contains "$commit"
    }

    # 清理已合并的分支
    gclean() {
        echo "清理已合并的本地分支..."
        git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d 2>/dev/null || true

        echo "清理远程跟踪分支..."
        git remote prune origin
    }

    # 显示文件历史
    ghistory() {
        local file="$1"
        if [ -z "$file" ]; then
            echo "用法: ghistory <file>"
            return 1
        fi
        git log --follow -p -- "$file"
    }

    # 暂存和恢复工作
    gstash() {
        if [ "$1" = "pop" ]; then
            git stash pop
        elif [ "$1" = "list" ]; then
            git stash list
        elif [ "$1" = "show" ]; then
            git stash show -p "${2:-0}"
        else
            git stash push -m "${1:-WIP}"
        fi
    }

    # Git 工作流助手
    gflow() {
        case "$1" in
            feature)
                gnew "feature/$2"
                ;;
            hotfix)
                git checkout main || git checkout master
                git pull origin main || git pull origin master
                gnew "hotfix/$2"
                ;;
            release)
                gnew "release/$2"
                ;;
            pr|pull-request)
                local branch=$(git branch --show-current)
                local remote=$(git remote | head -1)
                echo "创建 Pull Request:"
                echo "https://github.com/$(git remote get-url $remote | sed 's/.*://;s/\.git$//')/pull/new/$branch"
                ;;
            *)
                echo "用法: gflow <feature|hotfix|release|pr> [name]"
                ;;
        esac
    }
}

# 插件卸载
plugin_unload() {
    # 移除别名
    unalias gs ga gc gp gl gd gco gb glog gundo 2>/dev/null || true

    # 移除函数
    unset -f gquick gnew gdelete grebase gcontrib gfind gclean ghistory gstash gflow 2>/dev/null || true
}

# 执行初始化
plugin_init
