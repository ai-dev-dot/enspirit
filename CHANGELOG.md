# Changelog

本项目的所有重要变更记录。格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]

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
