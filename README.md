# Tavily Search Skill

🚀 高性能网络搜索工具，基于 Tavily API，支持搜索结果黑名单过滤。

[ ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) ](LICENSE)

---

## ✨ 功能特性

- **智能搜索** - 调用 Tavily API 返回结构化搜索结果
- **实时额度** - 每次搜索后自动查询账户额度信息
- **黑名单过滤** - 自动过滤百度、CSDN、简书等低质量内容农场
- **安全传参** - 查询参数通过 jq -n 传递，彻底避免 Shell Injection
- **轻量无状态** - 无配置文件，无缓存，依赖少

---

## 📖 使用方法

### 前置配置

**API Key 设置（二选一）：**

1. 环境变量：
```bash
export TAVILY_API_KEY="你的API Key"
```

2. 文件方式（项目根目录创建 apikey 文件）：
```bash
echo "你的API Key" > apikey
chmod 600 apikey
```

获取 API Key：https://app.tavily.com/api-keys

### 目录结构

```
Tavily-Search-Skill/
├── search.sh              ← 搜索入口脚本
├── SKILL.md               ← Skill 配置（供 OpenClaw 读取）
├── _meta.json             ← 元数据
├── apikey                 ← API Key 文件（用户创建，不上传）
├── blocklist/
│   ├── blocklist.json     ← 黑名单域名列表
│   └── filter_blocklist.py ← 过滤脚本
└── LICENSE
```

### 基本搜索

```bash
./search.sh "搜索关键词"
```

### 指定结果数量

```bash
# 默认返回 5 条
./search.sh "关键词" 10
```

### 包含图片

```bash
./search.sh "关键词" 5 true
```

---

## 🚫 黑名单过滤

搜索结果自动过滤低质量域名。过滤信息写入 stderr，不出现在 JSON 输出中：

```
[BLOCKLIST] Filtered 3 results
```

当前屏蔽域名：baidu.com csdn.net jianshu.com toutiao.com mp.sohu.com

### 查看当前黑名单

```bash
cat blocklist/blocklist.json
```

### 添加黑名单域名

更新 blocklist/blocklist.json，填写根域名即自动匹配所有子域名：

```json
{
  "blocked": [
    {"domain": "baidu.com", "reason": "百度搜索"},
    {"domain": "csdn.net", "reason": "CSDN"}
  ]
}
```

---

## ⚠️ 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| **未配置 API Key** | 输出错误信息并退出 |
| **HTTP 错误（4xx/5xx）** | 输出 JSON 格式错误信息并退出 |

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
    "plan": "Researcher",
    "total": 1000,
    "used": 15,
    "remaining": 985
  },
  "response_time": "0.5s"
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| query | String | 搜索关键词 |
| results | Array | 搜索结果列表 |
| results[].title | String | 结果标题 |
| results[].url | String | 结果链接 |
| results[].content | String | 结果摘要 |
| quota_info.plan | String | 当前套餐 |
| quota_info.total | Number | 额度上限 |
| quota_info.used | Number | 已使用额度 |
| quota_info.remaining | Number | 剩余额度 |
| response_time | String | 响应时间（秒） |

---

## 🔧 依赖

- curl
- jq

安装依赖：

```bash
# Ubuntu / Debian
sudo apt-get install curl jq

# macOS
brew install curl jq

# Alpine
apk add curl jq
```

---

## 📄 许可

MIT License - 详见 LICENSE。
