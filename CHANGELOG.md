# Changelog | 更新日志

All notable changes will be documented in this file.

---

## [1.0.6] - 2026-04-03

### Security | 安全修复

- **移除硬编码路径** - 修复 `~/.openclaw/skills/tavily/apikey` 硬编码问题，改为读取脚本同目录下的 `apikey` 文件
- **简化脚本结构** - 移除复杂的额度管理逻辑，改用 Tavily API 原生 `api_key` 参数
- **VirusTotal 报毒修复** - 移除了被标记的可疑行为特征（外部文件读取、复杂状态管理）

### Added | 新增

- **blocklist 黑名单过滤** - 新增 `blocklist/` 目录，支持过滤低质量源

---

## [1.0.5] - 2026-04-03

### Added | 新增

- **搜索结果黑名单过滤** - 新增 `blocklist/` 目录，包含域名黑名单和过滤脚本
