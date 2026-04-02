# Changelog | 更新日志

All notable changes will be documented in this file.

---

## [1.0.5] - 2026-04-03

### Added | 新增

- **搜索结果黑名单过滤** - 新增 `blocklist/` 目录，包含域名黑名单和过滤脚本
  - `blocklist/blocklist.json` - 黑名单域名列表（支持子域名匹配）
  - `blocklist/filter_blocklist.py` - Python 过滤脚本
  - 搜索结果自动过滤百度、CSDN 等低质量源
  - 过滤结果在输出中显示 `[BLOCKLIST] Filtered N results`

### Changed | 变更

- **SKILL.md 更新** - 修复 YAML frontmatter 格式
- **GitHub 仓库结构** - 规范化目录，skill 本体移至 `Tavily-Search-Skill/` 子目录
- **README 完善** - 新增目录结构说明、黑名单使用指南

### Fixed | 修复

- 修复了 `blocklist` 从文件错误转为目录的问题

---

## [1.0.4] - 2026-04-02

### Added | 新增

- **付费模式切换** - `--toggle-paid-mode` 切换是否优先使用付费额度
- **零额度禁用** - 付费额度耗尽时自动禁用搜索功能
- **实时额度更新** - 移除 24 小时缓存，每次搜索后实时查询 API
- **免费/付费额度区分** - 分别显示套餐额度和 PayGo 额度

### Changed | 变更

- 状态文件迁移至 `/tmp/tavily_state/`
- 额度计算逻辑优化

---

## [1.0.3] - 2026-04-02

### Added | 新增

- 首次搜索时自动初始化 API 并保存额度信息

### Changed | 变更

- 优化错误处理，网络失败时自动重试

---

## [1.0.2] - 2026-04-02

### Added | 新增

- `--usage` 查询当前额度
- `--status` 查看插件状态

### Changed | 变更

- 改善 JSON 输出格式

---

## [1.0.1] - 2026-04-02

### Added | 新增

- 支持指定结果数量和图片搜索

### Fixed | 修复

- 修复 API Key 文件读取问题

---

## [1.0.0] - 2026-04-02

### Added | 新增

- Tavily Search Skill 初始版本
- 基本搜索功能
- 环境变量和 apikey 文件两种配置方式
