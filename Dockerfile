# Dotfiles 测试容器
FROM ubuntu:22.04

# 设置非交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 安装基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    sudo \
    zsh \
    bash \
    make \
    python3 \
    python3-pip \
    python3-venv \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 设置语言环境
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 创建测试用户
RUN useradd -m -s /bin/bash testuser && \
    echo 'testuser:password' | chpasswd && \
    usermod -aG sudo testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 切换到测试用户
USER testuser
WORKDIR /home/testuser

# 复制 dotfiles
COPY --chown=testuser:testuser . /home/testuser/dotfiles/

# 设置权限
RUN find /home/testuser/dotfiles -name "*.sh" -type f -exec chmod +x {} \; && \
    chmod +x /home/testuser/dotfiles/install

# 默认命令
CMD ["/bin/bash"]