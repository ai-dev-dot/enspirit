# 赋灵 | Enspirit

角色独立人格 · 自主演化剧情 —— 一款 AI 小说创作工具。

## 快速部署

需要：Docker 和 Docker Compose（Windows 用户推荐 [Docker Desktop](https://www.docker.com/products/docker-desktop/)）。

```bash
# macOS / Linux
curl -O https://raw.githubusercontent.com/ai-dev-dot/enspirit/main/docker-compose.yml
curl -O https://raw.githubusercontent.com/ai-dev-dot/enspirit/main/.env.example
```

```powershell
# Windows (PowerShell)
Invoke-WebRequest -Uri https://raw.githubusercontent.com/ai-dev-dot/enspirit/main/docker-compose.yml -OutFile docker-compose.yml
Invoke-WebRequest -Uri https://raw.githubusercontent.com/ai-dev-dot/enspirit/main/.env.example -OutFile .env.example
```

```bash
# 配置环境变量
cp .env.example .env
# 编辑 .env，设置 DB_PASSWORD 为你的强密码

# 启动
docker compose up -d

# 访问 http://localhost:3000
# 第一个注册的用户自动成为管理员
```

## 升级

```bash
docker compose pull
docker compose up -d
```

## 配置 LLM

启动后，登录管理员账号，在管理后台 `/admin/models` 中配置 LLM Provider（API Key、模型等）。

支持的 LLM 协议：
- OpenAI 兼容（OpenAI、DeepSeek、通义千问、GLM 等）
- Anthropic 兼容（Claude 系列）

## 系统要求

- Docker 20.10+
- 至少 2GB 可用内存
