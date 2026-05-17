# 赋灵 | Enspirit

> 一款基于角色独立人格、自主演化剧情的 AI 小说创作工具。

**你不再是操控木偶的作者，只是世界的构建者，故事的旁观者与记录者。**

---

## 灵感

源自《三体 2：黑暗森林》中罗辑与白蓉关于文学创作的经典对话：

> "她好像是一个提线木偶，每个动作和每一句话都来自于我的设想，缺少一种生命感。"
>
> "你的方法不对，你是在作文，不是在创造文学形象。要知道，一个文学人物十分钟的行为，可能是她十年的经历的反映。你不要局限于小说的情节，要去想象她的整个生命，而真正写成文字的，只是冰山的一角。"
>
> "文学形象的塑造过程有一个最高状态，在那种状态下，小说中的人物在文学家的思想中拥有了生命，文学家无法控制这些人物，甚至无法预测他们下一步的行为，只是好奇地跟着他们，像偷窥狂一般观察他们生活中最细微的部分，记录下来，就成为了经典。"

本项目将这段创作思想落地实现：无需手动编写剧情大纲，不用强行操控人物走向。只需完善角色性格、过往人生与底层三观，将人物放入自定义世界观中，角色便会自主思考、自主抉择、自行产生矛盾与羁绊，自然而然推动整个故事生长延续。

---

## 功能

- **世界构建向导** — AI 世界建筑师通过自然对话帮你构建世界观：时代背景、核心规则、初始事件、角色建议
- **角色灵魂铸造** — AI 灵魂铸造师深入挖掘角色的人格特质（OCEAN 五因素）、核心价值观、人生经历、潜意识
- **三层仿真引擎** — B 环行为校验 → A 环叙事精修 → C 环导演品控，角色自主决策、情节自然演化
- **角色记忆系统** — LLM 从第一人称视角生成经历记忆，recency × importance 粗筛 + LLM 相关性检索
- **观察剧场** — 双面板实时观测叙事流和世界状态，支持事件注入、回合回溯、世界分支
- **世界备份与分支** — 自动 checkpoint + 一键重置世界 + 从当前状态或任意回合复制出平行世界
- **LLM 场景管理** — 12 个场景统一解析，支持多模型灵活分配
- **Prompt 工程系统** — 19 个模板存 DB，可在后台编辑优化

---

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Next.js 16 (App Router) |
| 语言 | TypeScript |
| 数据库 | PostgreSQL + Prisma 7 |
| 认证 | NextAuth v5 (Credentials + JWT) |
| AI | Vercel AI SDK (`generateText` + `generateObject`) |

---

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
