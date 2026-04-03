#!/usr/bin/env bash
# Docker 别名和辅助函数插件

# 插件元数据
PLUGIN_NAME="docker-aliases"
PLUGIN_VERSION="1.0.0"
PLUGIN_DESCRIPTION="Docker 和 Docker Compose 快捷命令"

# 插件初始化
plugin_init() {
    # Docker 别名
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dim='docker images'
    alias dex='docker exec -it'
    alias dlog='docker logs -f'
    alias dstop='docker stop'
    alias drm='docker rm'
    alias drmi='docker rmi'
    alias dprune='docker system prune -af'

    # Docker Compose 别名
    alias dcup='docker-compose up -d'
    alias dcdown='docker-compose down'
    alias dcrestart='docker-compose restart'
    alias dclogs='docker-compose logs -f'
    alias dcexec='docker-compose exec'
    alias dcbuild='docker-compose build'

    # Docker 函数

    # 进入容器 bash
    dbash() {
        local container="${1:-}"
        if [ -z "$container" ]; then
            echo "用法: dbash <container>"
            echo "可用容器:"
            docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
            return 1
        fi
        docker exec -it "$container" bash || docker exec -it "$container" sh
    }

    # 快速运行容器
    drun() {
        local image="${1:-ubuntu}"
        shift || true
        docker run -it --rm "$image" "$@"
    }

    # 清理所有停止的容器
    dclean() {
        echo "清理停止的容器..."
        docker container prune -f

        echo "清理未使用的镜像..."
        docker image prune -f

        echo "清理未使用的卷..."
        docker volume prune -f

        echo "清理未使用的网络..."
        docker network prune -f
    }

    # 停止所有容器
    dstopall() {
        local containers=$(docker ps -q)
        if [ -n "$containers" ]; then
            echo "停止所有容器..."
            docker stop $containers
        else
            echo "没有运行中的容器"
        fi
    }

    # 删除所有容器
    drmall() {
        local containers=$(docker ps -aq)
        if [ -n "$containers" ]; then
            echo "删除所有容器..."
            docker rm -f $containers
        else
            echo "没有容器"
        fi
    }

    # 查看容器统计信息
    dstats() {
        docker stats --no-stream
    }

    # 查看容器 IP
    dip() {
        local container="${1:-}"
        if [ -z "$container" ]; then
            echo "用法: dip <container>"
            return 1
        fi
        docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container"
    }

    # 导出容器文件
    dexport() {
        local container="${1:-}"
        local path="${2:-/}"
        local dest="${3:-.}"

        if [ -z "$container" ]; then
            echo "用法: dexport <container> [path] [destination]"
            return 1
        fi

        docker cp "$container:$path" "$dest"
    }

    # 导入文件到容器
    dimport() {
        local source="${1:-}"
        local container="${2:-}"
        local dest="${3:-/tmp}"

        if [ -z "$source" ] || [ -z "$container" ]; then
            echo "用法: dimport <source> <container> [destination]"
            return 1
        fi

        docker cp "$source" "$container:$dest"
    }

    # Docker Compose 环境切换
    dcenv() {
        local env="${1:-dev}"
        if [ -f "docker-compose.$env.yml" ]; then
            export COMPOSE_FILE="docker-compose.yml:docker-compose.$env.yml"
            echo "Docker Compose 环境: $env"
        else
            echo "环境文件不存在: docker-compose.$env.yml"
            return 1
        fi
    }

    # 查看 Docker 磁盘使用
    ddisk() {
        docker system df
    }

    # 构建并推送镜像
    dbuildpush() {
        local tag="${1:-latest}"
        local image_name=$(basename $(pwd))

        echo "构建镜像: $image_name:$tag"
        docker build -t "$image_name:$tag" .

        if [ -n "${DOCKER_REGISTRY:-}" ]; then
            local full_tag="$DOCKER_REGISTRY/$image_name:$tag"
            docker tag "$image_name:$tag" "$full_tag"
            echo "推送到: $full_tag"
            docker push "$full_tag"
        else
            echo "未设置 DOCKER_REGISTRY，跳过推送"
        fi
    }
}

# 插件卸载
plugin_unload() {
    # 移除别名
    unalias d dc dps dpsa dim dex dlog dstop drm drmi dprune 2>/dev/null || true
    unalias dcup dcdown dcrestart dclogs dcexec dcbuild 2>/dev/null || true

    # 移除函数
    unset -f dbash drun dclean dstopall drmall dstats dip dexport dimport dcenv ddisk dbuildpush 2>/dev/null || true
}

# 执行初始化
plugin_init
