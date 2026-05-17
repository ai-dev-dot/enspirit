# 赋灵 | Enspirit

角色独立人格 · 自主演化剧情 —— 一款 AI 小说创作工具。

## 灵感来源

源自《三体 2：黑暗森林》中的经典文学创作理念。罗辑向白蓉诉说自己创作时遇到的困境：

> "她好像是一个提线木偶，每个动作和每一句话都来自于我的设想，缺少一种生命感。"

白蓉回答：

> "你的方法不对，你是在作文，不是在创造文学形象。要知道，一个文学人物十分钟的行为，可能是她十年的经历的反映。你不要局限于小说的情节，要去想象她的整个生命，而真正写成文字的，只是冰山的一角。"

后来罗辑按照白蓉说的方法去做，真的让想象中的人物拥有了生命。白蓉接着说：

> "现在你知道错了，这就是一个普通写手和一个文学家的区别。文学形象的塑造过程有一个最高状态，在那种状态下，小说中的人物在文学家的思想中拥有了生命，文学家无法控制这些人物，甚至无法预测他们下一步的行为，只是好奇地跟着他们，像偷窥狂一般观察他们生活中最细微的部分，记录下来，就成为了经典。"

本项目将这段创作思想落地实现：

无需手动编写剧情大纲，不用强行操控人物走向，只需完善角色性格、过往人生与底层三观，将人物放入自定义世界观中。角色便会自主思考、自主抉择、自行产生矛盾与羁绊，自然而然推动整个故事生长延续。

你不再是操控木偶的作者，只是世界构建者，故事的旁观者与记录者。

## 核心特性

- **深度人格构建**：完整人生履历、性格逻辑、内心执念，而非简单标签
- **角色自主决策**：严格贴合人设行动，不 OOC，剧情不受人工强制干预
- **自由世界设定**：自定义时代、社会规则、世界观背景与初始事件
- **连贯小说生成**：角色自然互动演化剧情，自动整理成文，支持导出保存

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
