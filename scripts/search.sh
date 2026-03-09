
#!/bin/bash

# Tavily Search Script - Enhanced with quota management
# Usage: 
#   ./search.sh "query" [max_results] [include_images]
#   ./search.sh --usage                    # 查看额度使用情况
#   ./search.sh --toggle-paid-mode         # 切换付费模式开关
#   ./search.sh --status                   # 查看当前状态

TAVILY_API_KEY="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"
TAVILY_ENDPOINT="https://api.tavily.com/search"
TAVILY_USAGE_ENDPOINT="https://api.tavily.com/usage"

# 状态文件路径
STATE_DIR="/tmp/tavily_state"
STATE_FILE="$STATE_DIR/usage_state.json"
CONFIG_FILE="$STATE_DIR/config.json"
LAST_CHECK_FILE="$STATE_DIR/last_check.txt"

# 确保状态目录存在
mkdir -p "$STATE_DIR"

# 初始化配置文件
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << 'EOF'
{
  "paid_mode_enabled": false,
  "api_initialized_date": "2026-03-08",
  "free_quota_limit": 1000,
  "disable_when_paid_quota_zero": true
}
EOF
    fi
}

# 获取配置值
get_config() {
    local key="$1"
    if [ -f "$CONFIG_FILE" ]; then
        jq -r ".$key // empty" "$CONFIG_FILE" 2>/dev/null
    fi
}

# 设置配置值
set_config() {
    local key="$1"
    local value="$2"
    if [ -f "$CONFIG_FILE" ]; then
        jq ".$key = $value" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
}

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >&2
}

# 检查是否需要更新额度（每次搜索后都更新）
should_check_quota() {
    # 每次调用都返回0，表示需要更新额度
    # 之前的24小时缓存机制已移除，改为实时更新
    return 0
}

# 更新最后检查时间
update_last_check() {
    date '+%Y-%m-%d %H:%M:%S' > "$LAST_CHECK_FILE"
}

# 查询 API 额度
fetch_quota_from_api() {
    local response=$(curl -s -X GET "$TAVILY_USAGE_ENDPOINT" \
        -H "Authorization: Bearer $TAVILY_API_KEY" \
        --connect-timeout 10 \
        --max-time 15 2>/dev/null)
    
    if [ -n "$response" ] && echo "$response" | jq -e . > /dev/null 2>&1; then
        # 保存到状态文件
        echo "$response" | jq -c '.' > "$STATE_FILE"
        update_last_check
        echo "$response"
        return 0
    else
        return 1
    fi
}

# 获取当前额度状态（简化版：直接实时查询 API）
get_quota_status() {
    # 直接调用 API 获取最新额度（不依赖文件缓存）
    local response=$(curl -s -X GET "$TAVILY_USAGE_ENDPOINT" \
        -H "Authorization: Bearer $TAVILY_API_KEY" \
        --connect-timeout 10 \
        --max-time 15 2>/dev/null)
    
    if [ -n "$response" ] && echo "$response" | jq -e . > /dev/null 2>&1; then
        # 同时更新状态文件（供其他功能使用）
        echo "$response" | jq -c '.' > "$STATE_FILE" 2>/dev/null
        update_last_check
        echo "$response"
        return 0
    else
        # API 失败时尝试读取本地缓存
        if [ -f "$STATE_FILE" ]; then
            cat "$STATE_FILE"
            return 0
        fi
        return 1
    fi
}

# 解析额度信息
parse_quota_info() {
    local status="$1"
    local plan=$(echo "$status" | jq -r '.account.current_plan // "unknown"')
    local total_credits=$(echo "$status" | jq -r '.account.plan_limit // 1000')
    local used_credits=$(echo "$status" | jq -r '.account.plan_usage // 0')
    local paygo_usage=$(echo "$status" | jq -r '.account.paygo_usage // 0')
    local paygo_limit=$(echo "$status" | jq -r '.account.paygo_limit // 0')
    
    # 处理 null 值
    if [ "$total_credits" = "null" ]; then
        total_credits=1000
    fi
    if [ "$used_credits" = "null" ]; then
        used_credits=0
    fi
    if [ "$paygo_limit" = "null" ]; then
        paygo_limit=0
    fi
    if [ "$paygo_usage" = "null" ]; then
        paygo_usage=0
    fi
    
    # 计算剩余额度
    local plan_remaining=$((total_credits - used_credits))
    local paygo_remaining=0
    
    # 如果有付费额度
    if [ "$paygo_limit" != "0" ] && [ "$paygo_limit" != "null" ]; then
        paygo_remaining=$((paygo_limit - paygo_usage))
    fi
    
    local remaining=$((plan_remaining + paygo_remaining))
    
    echo "{\"plan\":\"$plan\",\"total\":$total_credits,\"used\":$used_credits,\"remaining\":$remaining,\"paygo_used\":$paygo_usage,\"paygo_limit\":$paygo_limit}"
}

# 检查是否可以使用搜索（修复版：直接从 status 提取，避免 JSON 格式化问题）
validate_quota() {
    init_config
    
    local status=$(get_quota_status)
    if [ -z "$status" ]; then
        log_message "ERROR" "无法获取额度信息"
        return 1
    fi
    
    # 直接从原始 API 响应中提取值（避免 parse_quota_info 的格式化问题）
    # 使用 tr -d '\n' 清理可能的换行符
    local plan=$(echo "$status" | jq -r '.account.current_plan // "unknown"' | tr -d '\n')
    local total_credits=$(echo "$status" | jq -r '.account.plan_limit // 1000' | tr -d '\n')
    local used_credits=$(echo "$status" | jq -r '.account.plan_usage // 0' | tr -d '\n')
    local paygo_usage=$(echo "$status" | jq -r '.account.paygo_usage // 0' | tr -d '\n')
    local paygo_limit=$(echo "$status" | jq -r '.account.paygo_limit // 0' | tr -d '\n')
    
    # 处理 null 值
    [ "$total_credits" = "null" ] && total_credits=1000
    [ "$used_credits" = "null" ] && used_credits=0
    [ "$paygo_limit" = "null" ] && paygo_limit=0
    [ "$paygo_usage" = "null" ] && paygo_usage=0
    
    # 计算剩余额度
    local remaining=$((total_credits - used_credits))
    
    # 获取配置
    local paid_mode=$(get_config "paid_mode_enabled")
    local disable_when_zero=$(get_config "disable_when_paid_quota_zero")
    
    log_message "INFO" "当前计划: $plan, 剩余额度: $remaining"
    log_message "INFO" "付费模式: $paid_mode, 零额度禁用: $disable_when_zero"
    
    # 区分免费额度和付费额度
    local free_remaining=$remaining
    local paid_remaining=0
    
    # 如果有付费额度（PayGo），单独计算
    if [ "$paygo_limit" != "0" ] && [ -n "$paygo_limit" ]; then
        # 超过 1000 的部分视为付费额度
        if [ $remaining -gt 1000 ]; then
            free_remaining=1000
            paid_remaining=$((remaining - 1000))
        else
            paid_remaining=$((paygo_limit - paygo_usage))
            [ $paid_remaining -lt 0 ] && paid_remaining=0
        fi
    fi
    
    log_message "INFO" "免费额度: $free_remaining, 付费额度: $paid_remaining"
    
    # 检查开关和付费额度
    if [ "$paid_mode" = "true" ] && [ "$disable_when_zero" = "true" ] && [ $paid_remaining -le 0 ]; then
        log_message "ERROR" "付费额度为0且禁用开关已打开，停止使用 Tavily skill"
        echo "{\"error\":\"Paid quota exhausted and disable switch is ON\",\"free_remaining\":$free_remaining,\"paid_remaining\":$paid_remaining,\"status\":\"disabled\"}"
        return 1
    fi
    
    # 检查是否有任何额度
    if [ $remaining -le 0 ]; then
        log_message "ERROR" "额度已用完"
        echo "{\"error\":\"Quota exhausted\",\"remaining\":0,\"status\":\"disabled\"}"
        return 1
    fi
    
    # 额度预警
    if [ $remaining -lt 10 ]; then
        log_message "WARN" "⚠️ 额度严重不足，仅剩 $remaining credits"
    elif [ $remaining -lt 100 ]; then
        log_message "WARN" "⚠️ 额度不足，仅剩 $remaining credits"
    fi
    
    return 0
}

# 显示使用情况（修复版：直接从 status 提取）
show_usage() {
    init_config
    
    echo "=== Tavily API 额度使用情况 ==="
    echo ""
    
    local status=$(get_quota_status)
    if [ -n "$status" ]; then
        # 直接从原始 API 响应中提取值
        local plan=$(echo "$status" | jq -r '.account.current_plan // "unknown"')
        local total_credits=$(echo "$status" | jq -r '.account.plan_limit // 1000')
        local used_credits=$(echo "$status" | jq -r '.account.plan_usage // 0')
        
        # 处理 null 值
        [ "$total_credits" = "null" ] && total_credits=1000
        [ "$used_credits" = "null" ] && used_credits=0
        
        local remaining=$((total_credits - used_credits))
        
        echo "计划类型: $plan"
        echo "总额度: $total_credits credits"
        echo "已使用: $used_credits credits"
        echo "剩余: $remaining credits"
        echo ""
        
        # 显示上次更新时间
        if [ -f "$LAST_CHECK_FILE" ]; then
            echo "上次更新: $(cat "$LAST_CHECK_FILE")"
        fi
    else
        echo "无法获取额度信息"
    fi
    
    echo ""
    echo "=== 配置状态 ==="
    local paid_mode=$(get_config "paid_mode_enabled")
    local disable_when_zero=$(get_config "disable_when_paid_quota_zero")
    local init_date=$(get_config "api_initialized_date")
    
    echo "付费模式开关: $paid_mode"
    echo "零额度禁用: $disable_when_zero"
    echo "API初始化日期: $init_date"
}

# 切换付费模式
toggle_paid_mode() {
    init_config
    
    local current=$(get_config "paid_mode_enabled")
    local new_value="false"
    
    if [ "$current" = "false" ] || [ "$current" = "" ]; then
        new_value="true"
    fi
    
    set_config "paid_mode_enabled" "$new_value"
    echo "付费模式开关已切换为: $new_value"
}

# 显示状态
show_status() {
    init_config
    show_usage
}

# 执行搜索
perform_search() {
    local query="$1"
    local max_results="${2:-5}"
    local include_images="${3:-false}"
    local max_retries=2
    local retry_count=0
    
    # 先验证额度
    if ! validate_quota; then
        exit 1
    fi
    
    log_message "INFO" "开始搜索: '$query' (max_results=$max_results)"
    
    # 执行搜索（带重试）
    while [ $retry_count -le $max_retries ]; do
        if [ $retry_count -gt 0 ]; then
            log_message "INFO" "第 $retry_count 次重试..."
            sleep 1
        fi
        
        local response=$(curl -s -w "\n%{http_code}" -X POST "$TAVILY_ENDPOINT" \
            -H "Content-Type: application/json" \
            --connect-timeout 10 \
            --max-time 30 \
            -d "{
                \"api_key\": \"$TAVILY_API_KEY\",
                \"query\": \"$query\",
                \"max_results\": $max_results,
                \"include_images\": $include_images
            }" 2>/dev/null)
        
        local http_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | sed '$d')
        
        log_message "DEBUG" "HTTP状态码: $http_code"
        
        if [ "$http_code" = "200" ]; then
            if echo "$body" | jq -e . > /dev/null 2>&1; then
                if echo "$body" | jq -e '.error' > /dev/null 2>&1; then
                    local error_msg=$(echo "$body" | jq -r '.error')
                    log_message "ERROR" "API返回错误: $error_msg"
                    retry_count=$((retry_count + 1))
                    continue
                fi
                
                # 搜索成功，添加额度信息到输出
                local quota_status=$(get_quota_status)
                local quota_info=$(parse_quota_info "$quota_status")
                local remaining=$(echo "$quota_info" | jq -r '.remaining')
                
                log_message "INFO" "搜索成功 | 本次消耗: 1 credit | 剩余额度: $remaining credits"
                
                # 合并额度和搜索结果
                echo "$body" | jq --argjson quota "$quota_info" '{query: .query, results: .results, quota_info: $quota, response_time: .response_time}'
                exit 0
            else
                log_message "ERROR" "返回的不是有效JSON"
                retry_count=$((retry_count + 1))
                continue
            fi
        elif [ "$http_code" = "429" ]; then
            log_message "ERROR" "请求频率限制 (429)"
            retry_count=$((retry_count + 1))
            sleep 2
            continue
        elif [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
            log_message "ERROR" "API Key 无效 ($http_code)"
            echo "{\"error\":\"API Key invalid\",\"http_code\":$http_code,\"status\":\"failed\"}"
            exit 1
        else
            log_message "ERROR" "HTTP错误: $http_code"
            retry_count=$((retry_count + 1))
            continue
        fi
    done
    
    log_message "FATAL" "所有重试均失败"
    echo "{\"error\":\"All retries failed\",\"status\":\"failed\",\"retry_count\":$retry_count}"
    exit 1
}

# 主逻辑
main() {
    # 检查依赖
    if ! command -v curl &> /dev/null; then
        log_message "ERROR" "curl 未安装"
        echo '{"error":"curl is not installed","status":"failed"}'
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_message "ERROR" "jq 未安装"
        echo '{"error":"jq is not installed","status":"failed"}'
        exit 1
    fi
    
    # 处理命令参数
    case "$1" in
        --usage)
            show_usage
            ;;
        --toggle-paid-mode)
            toggle_paid_mode
            ;;
        --status)
            show_status
            ;;
        "")
            echo "用法:"
            echo "  $0 \"搜索关键词\" [结果数量] [是否包含图片:true/false]"
            echo "  $0 --usage                              # 查看额度使用情况"
            echo "  $0 --toggle-paid-mode                   # 切换付费模式开关"
            echo "  $0 --status                             # 查看当前状态"
            echo ""
            echo "示例:"
            echo "  $0 \"OpenClaw\" 5"
            exit 1
            ;;
        *)
            perform_search "$1" "$2" "$3"
            ;;
    esac
}

main "$@"
