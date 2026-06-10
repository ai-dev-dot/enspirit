#!/usr/bin/env bash
#
# Enspirit 一键安装脚本
# 用法: curl -sSL https://raw.githubusercontent.com/ai-dev-dot/enspirit/main/install.sh | bash
#
# 支持: macOS (Intel/Apple Silicon) / Linux (x64/arm64)
# 依赖: PostgreSQL（自动检测，已有则跳过安装）
#

set -euo pipefail

# ============================================================================
# 配置
# ============================================================================

REPO="ai-dev-dot/enspirit"
INSTALL_DIR="$HOME/.enspirit"
DB_NAME="enspirit"
DB_USER="enspirit"
DB_PASSWORD="enspirit123"
DEFAULT_PORT=8080

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# 工具函数
# ============================================================================

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

# ============================================================================
# 检测系统
# ============================================================================

detect_os() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Darwin)  PLATFORM="darwin" ;;
        Linux)   PLATFORM="linux" ;;
        *)       error "不支持的操作系统: $os（仅支持 macOS / Linux）" ;;
    esac

    case "$arch" in
        x86_64|amd64)  ARCH="x64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *)             error "不支持的架构: $arch（仅支持 x64 / arm64）" ;;
    esac

    info "检测到系统: ${PLATFORM}-${ARCH}"
}

# ============================================================================
# 检测/安装 Node.js
# ============================================================================

check_node() {
    if command_exists node; then
        local version
        version="$(node -v | sed 's/v//' | cut -d. -f1)"
        if [[ "$version" -ge 22 ]]; then
            success "Node.js $(node -v) 已安装"
            return 0
        else
            warn "Node.js 版本过低（$(node -v)），需要 22+"
        fi
    fi

    info "正在安装 Node.js 22..."

    if [[ "$PLATFORM" == "darwin" ]]; then
        if command_exists brew; then
            brew install node@22
            brew link node@22 --force
        else
            error "请先安装 Homebrew: https://brew.sh"
        fi
    elif [[ "$PLATFORM" == "linux" ]]; then
        # 使用 NodeSource 仓库
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    if ! command_exists node; then
        error "Node.js 安装失败，请手动安装: https://nodejs.org"
    fi

    success "Node.js $(node -v) 安装完成"
}

# ============================================================================
# 检测/安装 PostgreSQL
# ============================================================================

check_postgres() {
    # 检测 pg_isready
    if command_exists pg_isready && pg_isready -q 2>/dev/null; then
        success "检测到 PostgreSQL 已运行"

        read -rp "使用现有 PostgreSQL？(Y/n): " choice
        if [[ "${choice:-Y}" =~ ^[Nn]$ ]]; then
            install_postgres
        fi
        return 0
    fi

    # 检测 psql 但服务未运行
    if command_exists psql; then
        warn "检测到 PostgreSQL 已安装但未运行"
        info "尝试启动 PostgreSQL..."

        if [[ "$PLATFORM" == "darwin" ]]; then
            brew services start postgresql@18 2>/dev/null || brew services start postgresql 2>/dev/null || true
        elif [[ "$PLATFORM" == "linux" ]]; then
            sudo systemctl start postgresql 2>/dev/null || true
        fi

        sleep 2
        if pg_isready -q 2>/dev/null; then
            success "PostgreSQL 已启动"
            return 0
        fi
    fi

    install_postgres
}

install_postgres() {
    info "正在安装 PostgreSQL..."

    if [[ "$PLATFORM" == "darwin" ]]; then
        if command_exists brew; then
            brew install postgresql@18
            brew services start postgresql@18
        else
            error "请先安装 Homebrew: https://brew.sh"
        fi
    elif [[ "$PLATFORM" == "linux" ]]; then
        # 使用 PostgreSQL 官方仓库
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
        curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
        sudo apt-get update
        sudo apt-get install -y postgresql-18
        sudo systemctl start postgresql
    fi

    if ! pg_isready -q 2>/dev/null; then
        error "PostgreSQL 安装失败，请手动安装: https://www.postgresql.org/download/"
    fi

    success "PostgreSQL 安装完成"
}

# ============================================================================
# 配置数据库
# ============================================================================

setup_database() {
    info "配置数据库..."

    # 检测连接方式（本地 socket vs TCP）
    local pg_user
    if [[ "$PLATFORM" == "darwin" ]]; then
        # macOS brew 安装的 PG 使用当前系统用户
        pg_user="$(whoami)"
    else
        # Linux 使用 postgres 用户
        pg_user="postgres"
    fi

    # 创建用户和数据库
    if [[ "$pg_user" == "postgres" ]]; then
        sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1 || \
            sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
        sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1 || \
            sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
        sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    else
        psql -tc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1 || \
            psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
        psql -tc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1 || \
            psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
        psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    fi

    success "数据库配置完成"
}

# ============================================================================
# 下载预编译包
# ============================================================================

download_release() {
    info "获取最新版本..."

    local tag
    tag="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')"

    if [[ -z "$tag" ]]; then
        error "无法获取最新版本，请检查网络连接"
    fi

    info "最新版本: $tag"

    # 尝试两种文件名格式（带/不带 v 前缀）
    local filename="enspirit-${tag}-${PLATFORM}-${ARCH}.tar.gz"
    local url="https://github.com/$REPO/releases/download/${tag}/${filename}"

    # 如果带 v 前缀的文件不存在，尝试不带 v 的版本
    local version="${tag#v}"
    local alt_filename="enspirit-${version}-${PLATFORM}-${ARCH}.tar.gz"
    local alt_url="https://github.com/$REPO/releases/download/${tag}/${alt_filename}"

    info "下载预编译包..."
    mkdir -p "$INSTALL_DIR"

    if command_exists curl; then
        # 先尝试带 v 的文件名
        if ! curl -fSL "$url" -o "$INSTALL_DIR/$filename" 2>/dev/null; then
            # 如果失败，尝试不带 v 的文件名
            filename="$alt_filename"
            url="$alt_url"
            curl -fSL "$url" -o "$INSTALL_DIR/$filename"
        fi
    elif command_exists wget; then
        # 先尝试带 v 的文件名
        if ! wget "$url" -O "$INSTALL_DIR/$filename" 2>/dev/null; then
            # 如果失败，尝试不带 v 的文件名
            filename="$alt_filename"
            url="$alt_url"
            wget "$url" -O "$INSTALL_DIR/$filename"
        fi
    else
        error "需要 curl 或 wget，请安装后重试"
    fi

    info "解压中..."
    tar xzf "$INSTALL_DIR/$filename" -C "$INSTALL_DIR"
    rm -f "$INSTALL_DIR/$filename"

    success "下载完成"
}

# ============================================================================
# 初始化应用
# ============================================================================

init_app() {
    info "初始化应用..."

    cd "$INSTALL_DIR"

    # 写入配置
    cat > .env << EOF
DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}"
AUTH_SECRET="$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)"
PORT=${DEFAULT_PORT}
EOF

    # 安装依赖
    if [[ -f "package.json" ]]; then
        npm install --production --no-audit --no-fund 2>/dev/null || true
    fi

    # 同步数据库 schema
    if [[ -f "node_modules/.bin/prisma" ]]; then
        npx prisma db push --skip-generate
    fi

    # 运行 seed 脚本
    for seed in scripts/seed-*.js; do
        [[ -f "$seed" ]] && node "$seed" 2>/dev/null || true
    done

    success "初始化完成"
}

# ============================================================================
# 启动服务
# ============================================================================

create_service() {
    info "创建启动脚本..."

    cat > "$INSTALL_DIR/start.sh" << 'STARTEOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
export $(grep -v '^#' .env | xargs)
exec node .next/standalone/server.js
STARTEOF
    chmod +x "$INSTALL_DIR/start.sh"

    # 创建 systemd service（Linux）
    if [[ "$PLATFORM" == "linux" ]] && command_exists systemctl; then
        cat > /tmp/enspirit.service << SVCEOF
[Unit]
Description=Enspirit Server
After=network.target postgresql.service

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/start.sh
Restart=on-failure
RestartSec=5
EnvironmentFile=$INSTALL_DIR/.env

[Install]
WantedBy=multi-user.target
SVCEOF
        sudo mv /tmp/enspirit.service /etc/systemd/system/enspirit.service
        sudo systemctl daemon-reload
        info "已创建 systemd 服务，可用以下命令管理:"
        info "  sudo systemctl start enspirit"
        info "  sudo systemctl enable enspirit  # 开机自启"
    fi
}

start_app() {
    info "启动 Enspirit..."

    cd "$INSTALL_DIR"
    export $(grep -v '^#' .env | xargs)

    # 后台启动
    nohup node .next/standalone/server.js > "$INSTALL_DIR/enspirit.log" 2>&1 &
    local pid=$!
    echo "$pid" > "$INSTALL_DIR/enspirit.pid"

    # 等待启动
    sleep 3
    if kill -0 "$pid" 2>/dev/null; then
        success "Enspirit 已启动"
    else
        error "启动失败，请查看日志: $INSTALL_DIR/enspirit.log"
    fi
}

# ============================================================================
# 主流程
# ============================================================================

main() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║     赋灵 | Enspirit 安装程序             ║"
    echo "║     角色独立人格 · 自主演化剧情           ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    detect_os
    check_node
    check_postgres
    setup_database
    download_release
    init_app
    create_service
    start_app

    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║           安装完成！                      ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
    echo "  访问地址: http://localhost:${DEFAULT_PORT}"
    echo "  安装目录: ${INSTALL_DIR}"
    echo "  日志文件: ${INSTALL_DIR}/enspirit.log"
    echo ""
    echo "  管理命令:"
    echo "    启动: ${INSTALL_DIR}/start.sh"
    echo "    停止: kill \$(cat ${INSTALL_DIR}/enspirit.pid)"
    echo "    日志: tail -f ${INSTALL_DIR}/enspirit.log"
    echo ""
    if [[ "$PLATFORM" == "linux" ]] && command_exists systemctl; then
        echo "  systemd 服务:"
        echo "    启动: sudo systemctl start enspirit"
        echo "    停止: sudo systemctl stop enspirit"
        echo "    状态: sudo systemctl status enspirit"
        echo "    自启: sudo systemctl enable enspirit"
        echo ""
    fi
}

main "$@"
