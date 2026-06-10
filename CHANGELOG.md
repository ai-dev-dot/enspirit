# Changelog

本项目的所有重要变更记录。格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]

## [v0.3.0] - 2026-06-10

### Added
- **世界事实库（WorldFacts）系统**：从叙事中自动抽取硬事实，跨回合检测事实矛盾并触发重写
- **世界事实查看页**：世界详情页新增「事实」标签页，展示当前回合所有硬事实
- **Event Planner（事件编排器）**：用户注入事件后，LLM 编排为结构化引导步骤（guidedSteps），供 Director 逐步执行
- **编排确认页**：推演前可预览并确认事件编排计划，再交由 Director 执行
- **无事件编排**：支持承上启下自动推演，无需注入事件也可推进剧情
- **Director 自由发挥提示**：角色可在无外部事件时自主行动
- 新增 LLM 场景：FACT_EXTRACTOR、FACT_CONFLICT_CHECK、EVENT_PLANNER
- 新增 prompt 模板：fact-extractor、fact-conflict-check、event-planner
- 新增数据库表：WorldFact、OrchestrationPlan
- QA 评审系统完善：新增 callType 支持、情绪雷达等功能

### Changed
- 推演流程重构：从多事件并行改为单事件注入 + 引导步骤执行
- Director Prompt 精简：移除已由 Event Planner 覆盖的编排内容
- LLM 场景总数从 20 个增至 22 个
- 动态步数上限公式调整

### Fixed
- 因果链位置漂移、收束逻辑缺陷修复
- 冲突检测漏判修复：抽取器保留变更前提 + 增加伪变更判定规则
- 删除回合/取消推演时补齐 WorldFact、WorldEvent 清理
- QA 解析失败修复
- closing-director maxOutputTokens 修复
- 角色位置持久化 bug 修复
- Event Planner 工具调用结果提取修复
- 情绪雷达 JSON 解析失败 bug 修复
- EntityManager 创建实体时 actorId 为 null 修复
- 无事件场景按钮禁用条件修复

## [v0.2.0] - 2026-06-04

### Added
- QA 质量分析框架：基于真实世界的四角色 LLM 评审团（叙事评论家、Agent 架构师、Prompt 工程师、一致性审计）
- 质量分析 API：`POST /api/qa/analyze`（触发分析）、`GET /api/qa/analyses`（分析历史）
- 质量分析 UI：世界详情页「质量分析」按钮、分析报告详情页（维度评分 + 诊断问题）
- 新增 3 个 LLM 场景：QA_ARCHITECT、QA_PROMPT_ENGINEER、QA_CONSISTENCY_AUDITOR
- 新增 4 个 prompt 模板：qa-narrative-critic、qa-architect、qa-prompt-engineer、qa-consistency-auditor
- 新增数据库表：QAAnalysis、QADimensionResult、QADiagnosisIssue
- **一键安装脚本**：`install.sh`（macOS/Linux）和 `install.ps1`（Windows），支持自动检测/安装 PostgreSQL
- **预编译包下载**：用户无需 Docker，直接下载运行
- **Git Subtree 管理公开仓库**：公开仓库内容在 `public-repo/` 目录中有版本控制

### Changed
- QA 评估引擎从合成测试数据方案重构为真实世界单回合分析方案
- 叙事评论家改用 `resolvePrompt()` 从文件系统读取 prompt 模板
- 综合评分改用 LLM 生成的 issues 替换硬编码诊断模板
- LLM 场景总数从 17 个增至 20 个，prompt 模板从 23 个增至 27 个
- **推演性能优化**：动态步数上限（角色数×3 + 事件子步骤），性能提升 70%+
- **叙事质量提升**：Narrator 覆盖所有角色、包含对话、行动优先
- **UI 文案统一**："位置"改为"地点"
- **CI workflow 优化**：sync-and-release 直接构建预编译包，避免 artifacts 下载网络问题
- **Next.js standalone 输出**：添加 `output: "standalone"` 配置，支持独立部署

### Fixed
- Director newLocation 描述从"位置ID"改为"位置名称"，修复角色位置显示为 entity ID 的 bug
- Director reason 必须与 nextActorId 一致，修复角色名不匹配问题
- 物品所有者显示角色名而非 entityId
- 原始数据查看按钮点击冒泡导致卡片折叠
- PrismaPg SASL 密码解析错误（测试环境）
- 价值观处理器 JSON 解析 bug
- **公开仓库文件变空白**：使用 Git Subtree 替代手动 API 同步，避免上传空内容
- **预编译包文件名不一致**：统一使用 `enspirit-vX.Y.Z-platform-arch.tar.gz` 格式
- **Next.js standalone 目录不存在**：添加 `output: "standalone"` 配置

### Changed (Breaking)
- **Prompt 存储从 DB 改为文件系统**：移除 `PromptTemplate` 表，prompt 存储在 `prompts/<name>/system.md` + `user.md`
- **版本管理由 Git 负责**：移除 DB 版本管理（version、isActive 字段），查看 `git log prompts/<name>/` 获取历史
- **LLMCallLog 关联方式变更**：`promptTemplateId`（FK）改为 `promptTemplateName`（字符串）
- **管理后台简化**：移除版本浏览/对比/激活功能，改为直接编辑文件
- **公开仓库管理方式变更**：从手动 API 同步改为 Git Subtree（`public-repo/` 目录）

## [v0.1.8] - 2026-05-23

### Added
- 首回合自动分隔角色位置，支持多场景并行推进
- 发布管线：CI 预检门禁（类型检查/lint/测试）+ 容器冒烟测试 + 公共仓库文件自动同步
- CHANGELOG.md（Keep a Changelog 格式），CI 自动提取版本条目作为 GitHub Release 正文
- 本地发布准备脚本 `scripts/release-prep.sh`

### Changed
- LLM 调用日志统一为新 API（`logLLMCall` / `updateLLMCallLog` + `loggedGenerateText` 包装器）
- 清理废弃的模型注册表文件，`LLMProvider.provider` 加默认值
- `.claude/rules/release.md` 抽取发布流程文档，CLAUDE.md 瘦身到 177 行

### Fixed
- Director prompt System/User 职责分离——规则入 System，动态数据入 User
- Narrator prompt System/User 职责分离——前文回顾移入 User
- `D:\APP\enspirit_release\docker-compose.yml` 修复：postgres 镜像名、卷路径、硬编码密码、.env 变量对齐

## [v0.1.6] - 2026-05-17

### Fixed
- Docker 镜像 `AUTH_SECRET` 自动生成改用 Node.js 而非 openssl（Alpine 无 openssl）

## [v0.1.5] - 2026-05-17

### Fixed
- entrypoint 移除 Prisma 7 已废弃的 `--skip-generate` 标志

## [v0.1.4] - 2026-05-17

### Fixed
- 生产镜像缺少 `prisma.config.ts` 导致 `db push` 失败

## [v0.1.3] - 2026-05-17

### Fixed
- 还原 schema 中的 datasource url —— Prisma 7 改用 `prisma.config.ts` 管理连接

## [v0.1.2] - 2026-05-17

### Fixed
- Docker 构建阶段设置虚拟 `DATABASE_URL` 使 `prisma generate` 通过

## [v0.1.1] - 2026-05-17

### Added
- 双仓库（私有开发 + 公共发布）安全边界文档

### Changed
- 分支名 `master` → `main`
- 明确双仓库各自文档职责

### Fixed
- Prisma schema 显式 datasource url 支持 `db push`

## [v0.1.0] - 2026-05-17

### Added
- 世界构建向导——LLM 对话式创建世界，自动生成角色画像
- 角色创建（灵魂铸造师）——LLM 对话式创建角色，OCEAN 五因素人格 + 核心价值观 + 人生经历
- 事件驱动因果链仿真引擎 v2.0——Director 编排 + 角色自主行动 + Narrator 合成叙事
- 观察剧场——双面板实时观测叙事流和世界状态，支持事件注入与回合分支
- 角色记忆系统——LLM 第一人称记忆生成 + recency×importance 粗筛 + LLM 相关性检索
- 世界备份与分支——完整快照 + 分支创建 + 回合重启 + 一键重置
- NPC 激活——从叙事中识别并激活非玩家角色
- 角色人际关系系统——非对称双向关系 + 信任度 + 角色定位
- 后台任务系统——推演/精修持久化为 DB 后台任务，支持重试与进度查询
- 叙事精修——单回合叙事可手动精修与撤回，精修记录可复用
- 管理后台——仪表盘/模型管理/场景分配/Prompt 管理/LLM 调用日志/系统配置
- LLM 场景管理系统——11 个场景统一解析，支持多模型分配
- Prompt 工程系统——20 个模板存 DB，支持 CLI 优化迭代，管理后台在线编辑
- 墨韵（Ink Rhythm）设计系统——纸张纹理 + 衬线字体 + 暖色调
- Docker 容器化部署——多阶段构建 + PostgreSQL + GHCR 发布
