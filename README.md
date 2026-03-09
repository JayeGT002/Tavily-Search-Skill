# Tavily Search Skill

🚀 高质量网络搜索工具，支持实时额度管理和付费模式控制。

[ ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) ](LICENSE)

[English](./README-en.md) | [中文](./README.md)

---

## ✨ 特性

- **智能搜索** - 调用 Tavily API 进行高质量搜索，返回结构化结果
- **实时额度管理** - 每次搜索后自动更新额度（移除24小时缓存）
- **免费/付费额度区分** - 分别显示免费额度和付费额度（PayGo）
- **付费模式开关** - 可切换是否优先使用付费额度
- **零额度禁用** - 付费额度为0时自动禁用（可配置）
- **完整错误处理** - 网络失败、额度不足、API Key 无效等情况均有处理

---

## 📖 使用方法

### 前置配置 ⚠️

**必须设置环境变量（需要用户自行配置）：**
```bash
export TAVILY_API_KEY="你的API Key"
```

获取 API Key: https://app.tavily.com/api-keys

> ⚠️ 注意：此 skill 需要用户提供自己的 Tavily API Key，不附带默认 key。

项目已发布至https://clawhub.ai/JayeGT002/tavily-search-skill

### 基本搜索

```bash
./search.sh "搜索关键词"
```

### 指定结果数量

```bash
# 默认返回5条结果
./search.sh "关键词" 10
```

### 包含图片

```bash
./search.sh "关键词" 5 true
```

### 额度查询

```bash
./search.sh --usage
```

### 付费模式切换

```bash
./search.sh --toggle-paid-mode
```

### 查看当前状态

```bash
./search.sh --status
```

---

## 💳 额度计算逻辑

### 免费额度 vs 付费额度

| 类型 | 来源 | 说明 |
|------|------|------|
| **免费额度** | 套餐额度（Plan） | 每月 1000 credits |
| **付费额度** | PayGo 额外购买 | 超出免费部分或额外购买的额度 |

### 实时更新机制

- **每次搜索后自动更新** - 不再使用24小时缓存，每次调用都会实时查询 API
- 状态文件 `/tmp/tavily_state/usage_state.json` 保存最新额度信息

### 配置项说明

配置文件位于 `/tmp/tavily_state/config.json`：

```json
{
  "paid_mode_enabled": false,
  "api_initialized_date": "2026-03-08",
  "free_quota_limit": 1000,
  "disable_when_paid_quota_zero": true
}
```

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `paid_mode_enabled` | Boolean | 付费模式开关，true 时优先使用付费额度 |
| `api_initialized_date` | String | API 初始化日期 |
| `free_quota_limit` | Number | 免费额度上限，默认 1000 |
| `disable_when_paid_quota_zero` | Boolean | 付费额度为0时是否禁用搜索 |

---

## ⚠️ 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| **网络失败** | 自动重试最多2次，每次间隔1秒 |
| **额度不足** | 返回错误信息，若开启零额度禁用则停止搜索 |
| **API Key 无效 (401/403)** | 返回错误并终止执行 |
| **请求频率限制 (429)** | 自动重试，间隔2秒 |
| **JSON 解析失败** | 重试机制处理 |

### 错误响应示例

```json
{
  "error": "Quota exhausted",
  "remaining": 0,
  "status": "disabled"
}
```

```json
{
  "error": "API Key invalid",
  "http_code": 401,
  "status": "failed"
}
```

---

## 📦 输出格式

### 成功响应

```json
{
  "query": "OpenClaw",
  "results": [
    {
      "title": "OpenClaw - 文档",
      "url": "https://docs.openclaw.ai",
      "content": "OpenClaw 是一个..."
    }
  ],
  "quota_info": {
    "plan": "free",
    "total": 1000,
    "used": 15,
    "remaining": 985,
    "paygo_used": 0,
    "paygo_limit": 0
  },
  "response_time": "0.5s"
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `query` | String | 搜索关键词 |
| `results` | Array | 搜索结果列表 |
| `results[].title` | String | 结果标题 |
| `results[].url` | String | 结果链接 |
| `results[].content` | String | 结果摘要 |
| `quota_info` | Object | 额度信息 |
| `response_time` | String | 响应时间 |

---

## 🔧 依赖说明

| 依赖 | 版本 | 说明 |
|------|------|------|
| `curl` | 任意版本 | HTTP 请求工具 |
| `jq` | 任意版本 | JSON 处理工具 |

安装依赖（Ubuntu/Debian）：

```bash
sudo apt-get install curl jq
```

安装依赖（macOS）：

```bash
brew install curl jq
```

---

## 📄 许可

本项目采用 **MIT 许可** - See [LICENSE](./LICENSE)。

---

## 🙏 特别感谢

- **[Tavily](https://tavily.com/)** - 提供强大的搜索 API
- **[OpenClaw](https://github.com/openclaw/openclaw)** - 提供 Agent 框架
- **[Siliconflow](https://siliconflow.cn)** - API提供商
