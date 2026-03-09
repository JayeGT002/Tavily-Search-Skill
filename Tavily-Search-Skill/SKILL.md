---
name: Tavily-Search-Skill
description: 调用 Tavily API 进行高质量搜索，支持实时额度管理和付费模式控制。用于需要网络搜索时。
---

# Tavily Search Skill 🔍

调用 Tavily API 进行高质量网络搜索的 OpenClaw Skill。

## 功能特性

- **智能搜索** - 调用 Tavily API，返回结构化搜索结果
- **实时额度管理** - 每次搜索后自动更新额度
- **免费/付费额度区分** - 分别显示免费额度和付费额度
- **付费模式开关** - 可切换是否优先使用付费额度
- **完整错误处理** - 网络失败、额度不足等情况均有处理

## 使用方法

### 前置配置 ⚠️

**必须设置环境变量（需要用户自行配置）：**
```bash
export TAVILY_API_KEY="你的API Key"
```

获取 API Key: https://app.tavily.com/api-keys

> ⚠️ 注意：此 skill 需要用户提供自己的 Tavily API Key，不附带默认 key。

### 基本搜索

```bash
./search.sh "搜索关键词"
```

### 指定结果数量

```bash
./search.sh "关键词" 10
```

### 包含图片

```bash
./search.sh "关键词" 5 true
```

### 查看额度

```bash
./search.sh --usage
```

### 切换付费模式

```bash
./search.sh --toggle-paid-mode
```

### 查看状态

```bash
./search.sh --status
```

## 输出格式

搜索结果为 JSON 格式：

```json
{
  "query": "关键词",
  "results": [
    {
      "title": "结果标题",
      "url": "链接",
      "content": "摘要"
    }
  ],
  "quota_info": {
    "plan": "free",
    "total": 1000,
    "used": 15,
    "remaining": 985
  }
}
```

## 依赖

- `curl` - HTTP 请求
- `jq` - JSON 处理

## 限制

- 免费版每月 1000 次请求
- 每次搜索最多返回 20 条结果
