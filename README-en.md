# Tavily Search Skill

🚀 High-quality network search tool with real-time quota management and paid mode control.

[ ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) ](LICENSE)
[English](./README-en.md) | [中文](./README.md)

---

## ✨ Features

- **Smart Search** - Tavily API for high-quality structured results
- **Real-time Quota** - Auto-updates quota after every search (no 24h cache)
- **Free/Paid Quota** - Distinguish between free plan and PayGo credits
- **Paid Mode Toggle** - Switch to prioritize paid credits
- **Zero-quota Disable** - Auto-disable when paid quota exhausted
- **Error Handling** - Network failures, quota issues, invalid API keys

---

## 📖 Usage

### Prerequisites ⚠️

**Required: Set environment variable (user must provide their own)**
```bash
export TAVILY_API_KEY="your-api-key"
```

Get API Key: https://app.tavily.com/api-keys

> ⚠️ Note: This skill requires users to provide their own Tavily API Key. No default key included.

### Basic Search

```bash
./search.sh "search query"
```

### Specify Result Count

```bash
# Default: 5 results
./search.sh "query" 10
```

### Include Images

```bash
./search.sh "query" 5 true
```

### Check Usage

```bash
./search.sh --usage
```

### Toggle Paid Mode

```bash
./search.sh --toggle-paid-mode
```

### Check Status

```bash
./search.sh --status
```

---

## 💳 Quota Logic

### Free vs Paid Quota

| Type | Source | Description |
|------|--------|-------------|
| **Free** | Plan quota | 1000 credits/month |
| **Paid** | PayGo | Additional purchased credits |

### Real-time Update

- **Auto-update after each search** - No 24h cache, queries API in real-time
- State file: `/tmp/tavily_state/usage_state.json`

### Configuration

Config file: `/tmp/tavily_state/config.json`

```json
{
  "paid_mode_enabled": false,
  "api_initialized_date": "2026-03-08",
  "free_quota_limit": 1000,
  "disable_when_paid_quota_zero": true
}
```

| Config | Type | Description |
|--------|------|-------------|
| `paid_mode_enabled` | Boolean | Paid mode switch, true = prioritize paid credits |
| `api_initialized_date` | String | API init date |
| `free_quota_limit` | Number | Free quota limit, default 1000 |
| `disable_when_paid_quota_zero` | Boolean | Disable search when paid quota = 0 |

---

## ⚠️ Error Handling

| Error Type | Solution |
|------------|----------|
| **Network failure** | Auto-retry up to 2 times, 1s delay |
| **Quota exhausted** | Return error, stop if zero-quota disable is on |
| **Invalid API Key (401/403)** | Return error and exit |
| **Rate limit (429)** | Auto-retry, 2s delay |
| **JSON parse failure** | Handled by retry mechanism |

### Error Response Examples

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

## 📦 Output Format

### Success Response

```json
{
  "query": "OpenClaw",
  "results": [
    {
      "title": "OpenClaw - Documentation",
      "url": "https://docs.openclaw.ai",
      "content": "OpenClaw is..."
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

### Field Description

| Field | Type | Description |
|-------|------|-------------|
| `query` | String | Search query |
| `results` | Array | Result list |
| `results[].title` | String | Result title |
| `results[].url` | String | Result URL |
| `results[].content` | String | Result snippet |
| `quota_info` | Object | Quota info |
| `response_time` | String | Response time |

---

## 🔧 Dependencies

| Dependency | Install (Ubuntu/Debian) | Install (macOS) |
|------------|-------------------------|-----------------|
| curl | `sudo apt-get install curl` | `brew install curl` |
| jq | `sudo apt-get install jq` | `brew install jq` |

---

## 📄 License

This project is licensed under **MIT License** - See [LICENSE](./LICENSE).

---

## 🙏 Credits

- **[Tavily](https://tavily.com/)** - Search API
- **[OpenClaw](https://github.com/openclaw/openclaw)** - Agent Framework
- **[Siliconflow](https://siliconflow.cn)** - API Provider