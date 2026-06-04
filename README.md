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
- **事件驱动因果链引擎** — Director LLM 调度 + 因果链循环，角色自主行动、情节自然演化
- **角色记忆系统** — LLM 从第一人称视角生成经历记忆，recency × importance 粗筛 + LLM 相关性检索
- **观察剧场** — 双面板实时观测叙事流和世界状态，支持事件注入、回合回溯、世界分支
- **世界备份与分支** — 自动 checkpoint + 一键重置世界 + 从当前状态或任意回合复制出平行世界
- **NPC 激活系统** — 自动从叙事中识别 NPC，LLM 多步提取经历/心理/记忆，一键激活为正式角色
- **LLM 场景管理** — 20 个场景统一解析，支持多模型灵活分配
- **Prompt 工程系统** — 27 个模板存文件系统（prompts/），可在后台编辑，版本管理由 Git 负责
- **QA 质量分析** — 基于真实世界的四角色 LLM 评审团（叙事评论家、Agent 架构师、Prompt 工程师、一致性审计）

---

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Next.js 16 (App Router) |
| 语言 | TypeScript |
| 数据库 | PostgreSQL + Prisma 7 |
| 认证 | NextAuth v5 (Credentials + JWT) |
| AI | Vercel AI SDK (`generateText` + `generateObject`) |
| 样式 | Tailwind CSS + 墨韵 (Ink Rhythm) 设计系统 |
| 字体 | Noto Serif SC / LXGW WenKai TC |

---

## 快速开始

### 环境要求

- Node.js 20+
- PostgreSQL 16+
- Git

### 安装

```bash
git clone https://github.com/ai-dev-dot/enspirit.git
cd enspirit
npm install
```

### 配置

创建 `.env` 文件：

```env
DATABASE_URL="postgresql://<user>:<password>@localhost:5432/enspirit"
AUTH_SECRET="your-auth-secret"
```

### 数据库

```bash
npx prisma db push      # 同步 schema 到数据库
npx prisma generate      # 生成 Prisma client
npx tsx scripts/seed-config.ts    # 写入系统参数
npx tsx scripts/seed-test-users.ts # 创建测试账户
# Prompt 模板存储在 prompts/ 目录，无需 seed 脚本
```

### 启动

```bash
npm run dev
```

打开 [http://localhost:3000](http://localhost:3000)，使用 `testadmin` / `testadmin` 登录。

---

## 项目结构

```
app/
├── create-world/        # 世界构建（AI 向导 + 表单）
├── create-character/    # 角色创建（AI 向导 + 表单）
├── world/[worldId]/     # 世界详情 + LLM 配置
├── theater/[worldId]/   # 观察剧场
├── character/[id]/      # 角色档案 + 编辑
├── library/             # 用户世界列表
├── login/ register/     # 认证
├── admin/               # 管理后台
├── lib/simulation/      # 仿真引擎（Director + 因果链）
├── lib/llm/             # LLM 解析、场景管理
└── ui/                  # 共享 UI 样式
prisma/
└── schema.prisma        # 数据模型
docs/
├── data-dictionary.md   # 数据字典
└── superpowers/         # 设计文档与计划
scripts/                 # 数据库种子脚本
```

---

## 文档

- [CLAUDE.md](./CLAUDE.md) — AI 编码助手上下文
- [数据字典](./docs/data-dictionary.md) — 业务语义说明
- [设计文档](./docs/superpowers/specs/) — 产品规格说明
- [实现计划](./docs/superpowers/plans/) — 开发计划

---

## 许可证

MIT
