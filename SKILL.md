---
name: tavily
description: 调用 Tavily API 进行高质量搜索，支持实时额度管理和付费模式控制。用于需要网络搜索时。
---

# Tavily Search Skill

快速调用 Tavily API 进行搜索。

## 使用方法

```bash
# 基础搜索
./skills/tavily/search.sh "你的搜索关键词"

# 指定结果数量（默认5条）
./skills/tavily/search.sh "关键词" 10

# 包含图片
./skills/tavily/search.sh "关键词" 5 true
```

## 配置

API key 已内置于脚本中。如需更换，编辑 `search.sh` 中的 `TAVILY_API_KEY` 变量。

## 限制

- 每月 1000 次请求
- 每次搜索最多返回 20 条结果
