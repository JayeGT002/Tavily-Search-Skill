# Tavily Search Skill

🚀 High-quality web search tool powered by Tavily API, with search result blocklist filtering.

[ ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) ](LICENSE)

---

## ✨ Features

- **Smart Search** - Tavily API for structured search results
- **Real-time Quota** - Queries account quota on every search
- **Blocklist Filtering** - Automatically filters low quality content farm domains (Baidu, CSDN, Jianshu, etc.)
- **Safe Query Passing** - Query passed via `jq -n` to prevent Shell Injection
- **Lightweight & Stateless** - No config files, no caching, minimal dependencies

---

## 📖 Usage

### Setup

**API Key (choose one):**

1. Environment variable:
```bash
export TAVILY_API_KEY="your-api-key"
```

2. File (create `apikey` in project root):
```bash
echo "your-api-key" > apikey
chmod 600 apikey
```

Get API Key: https://app.tavily.com/api-keys

### Directory Structure

```
Tavily-Search-Skill/
├── search.sh              ← Search entry script
├── SKILL.md               ← Skill config (for OpenClaw)
├── _meta.json             ← Metadata
├── apikey                 ← API Key file (user creates, not committed)
├── blocklist/
│   ├── blocklist.json     ← Blocked domain list
│   └── filter_blocklist.py ← Filter script
└── LICENSE
```

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

---

## 🚫 Blocklist Filtering

Search results automatically filter low quality domains. Filter messages go to stderr (not in JSON output):

```
[BLOCKLIST] Filtered 3 results
```

Currently blocked domains: `baidu.com` `csdn.net` `jianshu.com` `toutiao.com` `mp.sohu.com`

### View Blocklist

```bash
cat blocklist/blocklist.json
```

### Add Blocked Domains

Update `blocklist/blocklist.json`. Root domains match all subdomains automatically:

```json
{
  "blocked": [
    {"domain": "baidu.com", "reason": "Baidu Search"},
    {"domain": "csdn.net", "reason": "CSDN"}
  ]
}
```

Adding `csdn.net` also blocks `blog.csdn.net`, `download.csdn.net`, etc.

---

## ⚠️ Error Handling

| Error | Behavior |
|-------|----------|
| **No API Key** | Prints error message and exits |
| **HTTP 4xx/5xx** | Prints JSON error and exits |

### Error Response Example

```json
{"error": "HTTP 401", "body": "..."}
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
    "plan": "Researcher",
    "total": 1000,
    "used": 15,
    "remaining": 985
  },
  "response_time": "0.5s"
}
```

### Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `query` | String | Search query |
| `results` | Array | Result list |
| `results[].title` | String | Result title |
| `results[].url` | String | Result URL |
| `results[].content` | String | Result snippet |
| `quota_info.plan` | String | Current plan |
| `quota_info.total` | Number | Total quota |
| `quota_info.used` | Number | Used quota |
| `quota_info.remaining` | Number | Remaining quota |
| `response_time` | String | Response time in seconds |

---

## 🔧 Dependencies

- `curl`
- `jq`

Install:

```bash
# Ubuntu / Debian
sudo apt-get install curl jq

# macOS
brew install curl jq

# Alpine
apk add curl jq
```

---

## 📄 License

MIT License - See [LICENSE](./LICENSE).
