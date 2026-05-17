# Security Policy

## 报告漏洞

如果你发现安全漏洞，请**不要**通过公开的 Issue 报告。

请发送邮件至 **enspirit.app@gmail.com**，并包含：

- 漏洞的详细描述
- 复现步骤
- 受影响的版本

我们会在 48 小时内确认收到报告，并在 30 天内解决问题后公开致谢。

## 支持版本

| 版本 | 安全更新 |
|------|----------|
| latest | ✅ |

## 安全最佳实践（部署用户）

1. **修改默认密码**：修改 `docker-compose.yml` 中的 `POSTGRES_PASSWORD` 和 `AUTH_SECRET`
2. **使用 HTTPS**：生产环境请部署反向代理（Nginx / Caddy）并配置 SSL
3. **定期更新**：执行 `docker compose pull && docker compose up -d` 获取最新版本
4. **数据库备份**：定期备份 PostgreSQL 数据卷（`docker compose exec db pg_dump`）
