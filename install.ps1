#
# Enspirit 一键安装脚本 (Windows PowerShell)
# 用法: irm https://raw.githubusercontent.com/ai-dev-dot/enspirit/main/install.ps1 | iex
#
# 依赖: PostgreSQL（自动检测，已有则跳过安装）
#

$ErrorActionPreference = "Stop"

# ============================================================================
# 配置
# ============================================================================

$REPO = "ai-dev-dot/enspirit"
$INSTALL_DIR = "$env:USERPROFILE\.enspirit"
$DB_NAME = "enspirit"
$DB_USER = "enspirit"
$DB_PASSWORD = "enspirit123"
$DEFAULT_PORT = 3000

# ============================================================================
# 工具函数
# ============================================================================

function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Ok { Write-Host "[✓] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[!] $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "[✗] $args" -ForegroundColor Red; exit 1 }

function Test-Command { Get-Command $args[0] -ErrorAction SilentlyContinue }

# ============================================================================
# 检测系统
# ============================================================================

function Get-SystemInfo {
    $arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
    $script:PLATFORM = "win"
    $script:ARCH = $arch
    Write-Info "检测到系统: Windows-$arch"
}

# ============================================================================
# 检测/安装 Node.js
# ============================================================================

function Test-Node {
    $node = Test-Command node
    if ($node) {
        $version = (node -v) -replace 'v', '' -replace '\..*', ''
        if ([int]$version -ge 22) {
            Write-Ok "Node.js $(node -v) 已安装"
            return
        } else {
            Write-Warn "Node.js 版本过低（$(node -v)），需要 22+"
        }
    }

    Write-Info "正在安装 Node.js 22..."

    if (Test-Command winget) {
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    } elseif (Test-Command choco) {
        choco install nodejs-lts -y
    } elseif (Test-Command scoop) {
        scoop install nodejs22
    } else {
        Write-Err "请手动安装 Node.js 22+: https://nodejs.org"
    }

    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (!(Test-Command node)) {
        Write-Err "Node.js 安装失败，请手动安装: https://nodejs.org"
    }

    Write-Ok "Node.js $(node -v) 安装完成"
}

# ============================================================================
# 检测/安装 PostgreSQL
# ============================================================================

function Test-Postgres {
    # 检测 pg_isready
    if (Test-Command pg_isready) {
        $result = & pg_isready -q 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "检测到 PostgreSQL 已运行"
            $choice = Read-Host "使用现有 PostgreSQL？(Y/n)"
            if ($choice -match '^[Nn]') {
                Install-Postgres
            }
            return
        }
    }

    # 检测 psql 但服务未运行
    if (Test-Command psql) {
        Write-Warn "检测到 PostgreSQL 已安装但未运行"
        Write-Info "尝试启动 PostgreSQL..."

        # 尝试启动服务
        Start-Service -Name "postgresql*" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3

        if ((Test-Command pg_isready) -and (& pg_isready -q 2>&1; $LASTEXITCODE -eq 0)) {
            Write-Ok "PostgreSQL 已启动"
            return
        }
    }

    Install-Postgres
}

function Install-Postgres {
    Write-Info "正在安装 PostgreSQL..."

    if (Test-Command winget) {
        winget install PostgreSQL.PostgreSQL.18 --accept-package-agreements --accept-source-agreements
    } elseif (Test-Command choco) {
        choco install postgresql18 -y --params '/Password:postgres'
    } else {
        Write-Err "请手动安装 PostgreSQL: https://www.postgresql.org/download/windows/"
    }

    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (!(Test-Command pg_isready)) {
        Write-Err "PostgreSQL 安装失败，请手动安装: https://www.postgresql.org/download/windows/"
    }

    Write-Ok "PostgreSQL 安装完成"
}

# ============================================================================
# 配置数据库
# ============================================================================

function Set-Database {
    Write-Info "配置数据库..."

    # 检测连接方式
    $pgUser = "postgres"
    $pgPass = Read-Host "请输入 PostgreSQL postgres 用户密码（默认: postgres）"
    if (!$pgPass) { $pgPass = "postgres" }

    # 创建用户和数据库
    $env:PGPASSWORD = $pgPass

    # 检查用户是否存在
    $userExists = & psql -U $pgUser -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" 2>&1
    if ($userExists -ne "1") {
        & psql -U $pgUser -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
    }

    # 检查数据库是否存在
    $dbExists = & psql -U $pgUser -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>&1
    if ($dbExists -ne "1") {
        & psql -U $pgUser -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
    }

    & psql -U $pgUser -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

    $env:PGPASSWORD = $null

    Write-Ok "数据库配置完成"
}

# ============================================================================
# 下载预编译包
# ============================================================================

function Get-Release {
    Write-Info "获取最新版本..."

    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$REPO/releases/latest"
    $tag = $release.tag_name

    if (!$tag) {
        Write-Err "无法获取最新版本，请检查网络连接"
    }

    Write-Info "最新版本: $tag"

    $filename = "enspirit-${tag}-${PLATFORM}-${ARCH}.zip"
    $url = "https://github.com/$REPO/releases/download/${tag}/${filename}"

    Write-Info "下载预编译包..."
    New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null

    $downloadPath = "$INSTALL_DIR\$filename"
    Invoke-WebRequest -Uri $url -OutFile $downloadPath

    Write-Info "解压中..."
    Expand-Archive -Path $downloadPath -DestinationPath $INSTALL_DIR -Force
    Remove-Item -Path $downloadPath

    Write-Ok "下载完成"
}

# ============================================================================
# 初始化应用
# ============================================================================

function Initialize-App {
    Write-Info "初始化应用..."

    Set-Location $INSTALL_DIR

    # 写入配置
    $authSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    @"
DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}"
AUTH_SECRET="$authSecret"
PORT=${DEFAULT_PORT}
"@ | Out-File -FilePath ".env" -Encoding utf8

    # 安装依赖
    if (Test-Path "package.json") {
        npm install --production --no-audit --no-fund 2>$null
    }

    # 同步数据库 schema
    if (Test-Path "node_modules\.bin\prisma.cmd") {
        & npx prisma db push --skip-generate
    }

    # 运行 seed 脚本
    Get-ChildItem -Path "scripts" -Filter "seed-*.js" -ErrorAction SilentlyContinue | ForEach-Object {
        & node $_.FullName 2>$null
    }

    Write-Ok "初始化完成"
}

# ============================================================================
# 创建启动脚本
# ============================================================================

function New-StartScript {
    Write-Info "创建启动脚本..."

    @"
cd "$INSTALL_DIR"
`$env:DATABASE_URL = "postgresql://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}"
`$env:AUTH_SECRET = (Get-Content .env | Where-Object { `$_ -match 'AUTH_SECRET=' } | ForEach-Object { `$_ -replace 'AUTH_SECRET=', '' -replace '"', '' })
`$env:PORT = ${DEFAULT_PORT}
node .next/standalone/server.js
"@ | Out-File -FilePath "$INSTALL_DIR\start.ps1" -Encoding utf8

    # 创建批处理启动脚本
    @"
@echo off
cd /d "$INSTALL_DIR"
for /f "tokens=1,* delims==" %%a in (.env) do set "%%a=%%b"
node .next\standalone\server.js
"@ | Out-File -FilePath "$INSTALL_DIR\start.bat" -Encoding ascii

    Write-Ok "启动脚本创建完成"
}

# ============================================================================
# 启动应用
# ============================================================================

function Start-App {
    Write-Info "启动 Enspirit..."

    Set-Location $INSTALL_DIR

    # 读取环境变量
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.+)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim().Trim('"'), "Process")
        }
    }

    # 后台启动
    $process = Start-Process -FilePath "node" -ArgumentList ".next/standalone/server.js" -WorkingDirectory $INSTALL_DIR -PassThru -WindowStyle Hidden
    $process.Id | Out-File -FilePath "$INSTALL_DIR\enspirit.pid"

    Start-Sleep -Seconds 3

    if (!$process.HasExited) {
        Write-Ok "Enspirit 已启动"
    } else {
        Write-Err "启动失败，请查看日志: $INSTALL_DIR\enspirit.log"
    }
}

# ============================================================================
# 主流程
# ============================================================================

function Main {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗"
    Write-Host "║     赋灵 | Enspirit 安装程序             ║"
    Write-Host "║     角色独立人格 · 自主演化剧情           ║"
    Write-Host "╚══════════════════════════════════════════╝"
    Write-Host ""

    Get-SystemInfo
    Test-Node
    Test-Postgres
    Set-Database
    Get-Release
    Initialize-App
    New-StartScript
    Start-App

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗"
    Write-Host "║           安装完成！                      ║"
    Write-Host "╚══════════════════════════════════════════╝"
    Write-Host ""
    Write-Host "  访问地址: http://localhost:${DEFAULT_PORT}"
    Write-Host "  安装目录: ${INSTALL_DIR}"
    Write-Host ""
    Write-Host "  启动方式:"
    Write-Host "    双击: ${INSTALL_DIR}\start.bat"
    Write-Host "    或运行: powershell ${INSTALL_DIR}\start.ps1"
    Write-Host ""
}

Main
