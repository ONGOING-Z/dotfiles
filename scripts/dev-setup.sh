#!/usr/bin/env bash
# 开发环境配置工具

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}[信息]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $*"
}

log_error() {
    echo -e "${RED}[错误]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $*"
}

# 显示菜单
show_menu() {
    echo -e "${MAGENTA}╔═══════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║         开发环境配置工具              ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo "请选择要配置的开发环境:"
    echo ""
    echo "  1) Python 开发环境"
    echo "  2) Node.js 开发环境"
    echo "  3) Go 开发环境"
    echo "  4) Rust 开发环境"
    echo "  5) Ruby 开发环境"
    echo "  6) Java 开发环境"
    echo "  7) PHP 开发环境"
    echo "  8) 数据库工具"
    echo "  9) 容器化工具"
    echo "  10) 全部安装"
    echo "  0) 退出"
    echo ""
}

# Python 开发环境
setup_python() {
    log_info "配置 Python 开发环境..."
    
    # 安装 pyenv
    if ! command -v pyenv >/dev/null 2>&1; then
        log_info "安装 pyenv..."
        curl https://pyenv.run | bash
        
        # 添加到 shell 配置
        cat >> ~/.bashrc.local << 'EOF'
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF
    fi
    
    # 安装 Python 版本
    log_info "安装 Python 3.11..."
    pyenv install 3.11.0 || true
    pyenv global 3.11.0
    
    # 安装常用包
    pip install --upgrade pip
    pip install virtualenv pipenv poetry black flake8 mypy pytest ipython notebook
    
    log_success "Python 开发环境配置完成"
}

# Node.js 开发环境
setup_nodejs() {
    log_info "配置 Node.js 开发环境..."
    
    # 安装 nvm
    if ! command -v nvm >/dev/null 2>&1; then
        log_info "安装 nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    fi
    
    # 加载 nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # 安装 Node.js
    log_info "安装 Node.js LTS..."
    nvm install --lts
    nvm use --lts
    
    # 安装全局包
    npm install -g yarn pnpm typescript ts-node nodemon pm2 eslint prettier
    
    log_success "Node.js 开发环境配置完成"
}

# Go 开发环境
setup_go() {
    log_info "配置 Go 开发环境..."
    
    local go_version="1.21.5"
    local go_os="linux"
    local go_arch="amd64"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        go_os="darwin"
    fi
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        go_arch="arm64"
    fi
    
    # 下载安装 Go
    if ! command -v go >/dev/null 2>&1; then
        log_info "下载 Go $go_version..."
        wget "https://go.dev/dl/go${go_version}.${go_os}-${go_arch}.tar.gz"
        sudo tar -C /usr/local -xzf "go${go_version}.${go_os}-${go_arch}.tar.gz"
        rm "go${go_version}.${go_os}-${go_arch}.tar.gz"
        
        # 添加到 PATH
        cat >> ~/.bashrc.local << 'EOF'
# Go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
    fi
    
    # 安装常用工具
    go install golang.org/x/tools/gopls@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    
    log_success "Go 开发环境配置完成"
}

# Rust 开发环境
setup_rust() {
    log_info "配置 Rust 开发环境..."
    
    # 安装 rustup
    if ! command -v rustup >/dev/null 2>&1; then
        log_info "安装 rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # 更新工具链
    rustup update
    
    # 安装常用组件
    rustup component add rustfmt clippy rust-src
    
    # 安装常用工具
    cargo install cargo-watch cargo-edit cargo-audit sccache
    
    log_success "Rust 开发环境配置完成"
}

# Ruby 开发环境
setup_ruby() {
    log_info "配置 Ruby 开发环境..."
    
    # 安装 rbenv
    if ! command -v rbenv >/dev/null 2>&1; then
        log_info "安装 rbenv..."
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
        
        cat >> ~/.bashrc.local << 'EOF'
# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
EOF
    fi
    
    # 安装 Ruby
    log_info "安装 Ruby 3.2.0..."
    rbenv install 3.2.0 || true
    rbenv global 3.2.0
    
    # 安装常用 gem
    gem install bundler rails pry rubocop
    
    log_success "Ruby 开发环境配置完成"
}

# 数据库工具
setup_database() {
    log_info "配置数据库工具..."
    
    # PostgreSQL 客户端
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y postgresql-client
    elif command -v brew >/dev/null 2>&1; then
        brew install postgresql
    fi
    
    # MySQL 客户端
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y mysql-client
    elif command -v brew >/dev/null 2>&1; then
        brew install mysql-client
    fi
    
    # Redis 客户端
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y redis-tools
    elif command -v brew >/dev/null 2>&1; then
        brew install redis
    fi
    
    # 数据库管理工具
    pip install pgcli mycli litecli || true
    
    log_success "数据库工具配置完成"
}

# 容器化工具
setup_container() {
    log_info "配置容器化工具..."
    
    # Docker
    if ! command -v docker >/dev/null 2>&1; then
        log_warning "请手动安装 Docker Desktop 或 Docker Engine"
        echo "访问: https://docs.docker.com/get-docker/"
    fi
    
    # Docker Compose
    if ! command -v docker-compose >/dev/null 2>&1; then
        log_info "安装 Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    # kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        log_info "安装 kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi
    
    # Helm
    if ! command -v helm >/dev/null 2>&1; then
        log_info "安装 Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    log_success "容器化工具配置完成"
}

# 主函数
main() {
    while true; do
        show_menu
        read -rp "请选择 [0-10]: " choice
        
        case $choice in
            1) setup_python ;;
            2) setup_nodejs ;;
            3) setup_go ;;
            4) setup_rust ;;
            5) setup_ruby ;;
            6) log_info "Java 环境请使用 SDKMAN 管理" ;;
            7) log_info "PHP 环境请使用系统包管理器" ;;
            8) setup_database ;;
            9) setup_container ;;
            10)
                setup_python
                setup_nodejs
                setup_go
                setup_rust
                setup_ruby
                setup_database
                setup_container
                ;;
            0)
                echo "退出"
                break
                ;;
            *)
                log_error "无效选择"
                ;;
        esac
        
        echo ""
        read -rp "按回车继续..."
    done
}

# 运行主函数
main "$@"