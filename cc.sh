#!/bin/bash

# Claude Code 配置脚本（包装器）
# 核心逻辑在 cc-config.py 中

# 设置脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CC_CONFIG="$SCRIPT_DIR/cc-config.py"

# 设置 UTF-8 编码
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 清屏
clear

echo "========================================"
echo "Claude Code Configuration Script"
echo "========================================"

# 检查 cc-config.py 是否存在
if [ ! -f "$CC_CONFIG" ]; then
    echo "❌ 错误: cc-config.py 未找到"
    echo "   期望位置: $CC_CONFIG"
    exit 1
fi

# 查找 Python
PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
fi

if [ -z "$PYTHON_CMD" ]; then
    echo ""
    echo "⚠️  警告: Python 未找到，进入降级模式"
    echo ""
    echo "降级模式功能限制:"
    echo "  - 无 API Key 缓存"
    echo "  - 无多模型选择"
    echo "  - 无上次使用记忆"
    echo ""
    echo "建议安装 Python 以获得完整功能:"
    echo "  Ubuntu/Debian: sudo apt install python3"
    echo "  macOS: brew install python3"
    echo ""
    read -p "是否继续使用降级模式？(y/N): " CONFIRM_FALLBACK
    if [ "$(echo "$CONFIRM_FALLBACK" | tr '[:lower:]' '[:upper:]')" != "Y" ]; then
        echo "配置取消"
        exit 0
    fi
    echo ""
    # 降级模式：简单配置（直接覆盖）
    echo "启动降级配置模式..."
    echo ""
    echo "请选择 API 提供商（降级模式）:"
    echo "  1. GCLI2API (本地 2223) - 编程推荐"
    echo "  2. GCLI2API Antigravity (本地 2223)"
    echo "  3. Zhipu AI (GLM)"
    echo "  4. MiniMax (International)"
    echo "  5. MiniMax (China)"
    echo "  6. Kimi (Moonshot AI)"
    echo "  7. Anthropic Official"
    echo "  8. Fangzhou (Ark)"
    echo "  9. Siliconflow"
    echo " 10. DashScope (Qwen)"
    echo " 11. Qianfan (Baidu)"
    echo " 12. PPChat (Claude Code Proxy)"
    echo " 13. DashScope Pay (Qwen)"
    echo " 14. CLI Proxy API (本地 2222)"
    echo ""
    read -p "Enter your choice [1-14]: " CHOICE

    # 根据选择设置变量
    case $CHOICE in
        1)
            PROVIDER="GCLI2API_Local"
            BASE_URL="http://127.0.0.1:2223/v1"
            MODEL="gemini-2.5-pro"
            ;;
        2)
            PROVIDER="GCLI2API_Antigravity"
            BASE_URL="http://127.0.0.1:2223/antigravity"
            MODEL="claude-sonnet-4-6"
            ;;
        3)
            PROVIDER="ZhipuAI"
            BASE_URL="https://open.bigmodel.cn/api/anthropic"
            MODEL="glm-4.7"
            ;;
        4)
            PROVIDER="MiniMax_Intl"
            BASE_URL="https://api.minimax.io/anthropic"
            MODEL="MiniMax-M2.1"
            ;;
        5)
            PROVIDER="MiniMax_CN"
            BASE_URL="https://api.minimaxi.com/anthropic"
            MODEL="MiniMax-M2.1"
            ;;
        6)
            PROVIDER="Kimi"
            BASE_URL="https://api.moonshot.cn/anthropic/"
            MODEL="kimi-k2-turbo-preview"
            ;;
        7)
            PROVIDER="Anthropic"
            BASE_URL="https://api.anthropic.com"
            MODEL="claude-3-5-sonnet-20241022"
            ;;
        8)
            PROVIDER="Fangzhou"
            BASE_URL="https://ark.cn-beijing.volces.com/api/coding"
            MODEL="ark-code-latest"
            ;;
        9)
            PROVIDER="Siliconflow"
            BASE_URL="https://api.siliconflow.cn/"
            MODEL="Pro/MiniMaxAI/MiniMax-M2.5"
            ;;
        10)
            PROVIDER="DashScope"
            BASE_URL="https://coding.dashscope.aliyuncs.com/apps/anthropic"
            MODEL="qwen3.5-plus"
            ;;
        11)
            PROVIDER="Qianfan"
            BASE_URL="https://qianfan.baidubce.com/anthropic/coding"
            MODEL="qianfan-code-latest"
            ;;
        12)
            PROVIDER="PPChat"
            BASE_URL="https://code.ppchat.vip"
            MODEL="claude-sonnet-4-6"
            ;;
        13)
            PROVIDER="DashScope_Pay"
            BASE_URL="https://dashscope.aliyuncs.com/apps/anthropic"
            MODEL="qwen3.5-plus"
            ;;
        14)
            PROVIDER="CLIProxyAPI"
            BASE_URL="http://127.0.0.1:2222"
            MODEL="qwen3-max"
            ;;
        *)
            echo "Invalid selection."
            exit 1
            ;;
    esac

    echo ""
    echo "========================================"
    echo "Configuration Summary"
    echo "========================================"
    echo "Provider: $PROVIDER"
    echo "Base URL: $BASE_URL"
    echo "Model: $MODEL"
    echo "========================================"

    # API Key 输入
    echo ""
    read -p "请输入 API Key: " API_KEY
    if [ -z "$API_KEY" ]; then
        echo "❌ API Key 不能为空"
        exit 1
    fi

    # Primary API Key 输入
    echo ""
    read -p "请输入 Primary API Key（用于 config.json）: " PRIMARY_API_KEY
    if [ -z "$PRIMARY_API_KEY" ]; then
        PRIMARY_API_KEY="$API_KEY"
    fi

    echo ""
    echo "确认继续？(Y/N): "
    read -p "" CONFIRM
    if [ "$(echo "$CONFIRM" | tr '[:lower:]' '[:upper:]')" != "Y" ]; then
        echo "配置取消"
        exit 0
    fi

    # 直接覆盖配置文件
    CLAUDE_JSON="$HOME/.claude.json"
    SETTINGS_JSON="$HOME/.claude/settings.json"
    CONFIG_JSON="$HOME/.claude/config.json"
    mkdir -p "$(dirname "$SETTINGS_JSON")" 2>/dev/null

    # 更新 .claude.json
    cat > "$CLAUDE_JSON" << EOF
{
  "anthropic_api_key": "$API_KEY",
  "anthropic_base_url": "$BASE_URL",
  "model": "$MODEL",
  "provider": "$PROVIDER",
  "hasCompletedOnboarding": true
}
EOF
    echo "Configuration file updated: $CLAUDE_JSON"

    # 更新 settings.json（降级模式：直接覆盖，不处理 Siliconflow 特殊参数）
    cat > "$SETTINGS_JSON" << EOF
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$API_KEY",
    "ANTHROPIC_BASE_URL": "$BASE_URL",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "$MODEL",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "$MODEL",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "$MODEL"
  }
}
EOF
    echo "Settings file updated: $SETTINGS_JSON (降级模式：需手动配置 Siliconflow thinking 参数)"

    # 更新 config.json
    cat > "$CONFIG_JSON" << EOF
{
  "primaryApiKey": "$PRIMARY_API_KEY"
}
EOF
    echo "Config file updated: $CONFIG_JSON"

    # 设置环境变量
    export ANTHROPIC_API_KEY="$API_KEY"
    export ANTHROPIC_BASE_URL="$BASE_URL"

    echo ""
    echo "========================================"
    echo "启动 Claude Code..."
    echo "========================================"
    echo ""

    exec claude
fi

# 检查 Python 是否能运行
"$PYTHON_CMD" --version >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 错误: Python 运行失败"
    exit 1
fi

# 运行 cc-config.py
# 注意: 用户提示在 stderr，环境变量在 stdout
# 我们使用临时文件捕获 stdout
TEMP_ENV=$(mktemp /tmp/claude-env.XXXXXX)

"$PYTHON_CMD" "$CC_CONFIG" 2>&1 | tee /dev/stderr | awk '/##CC_ENV_START##/,/##CC_ENV_END##/' > "$TEMP_ENV"

# 检查是否成功获取环境变量
if ! grep -q "##CC_ENV_START##" "$TEMP_ENV"; then
    echo ""
    echo "配置未完成"
    rm -f "$TEMP_ENV"
    exit 1
fi

# 解析环境变量
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=""
export ANTHROPIC_DEFAULT_HAIKU_MODEL=""
export ANTHROPIC_DEFAULT_SONNET_MODEL=""
export ANTHROPIC_DEFAULT_OPUS_MODEL=""
export CLAUDE_CODE_ADDITIONAL_REQUEST_BODY=""

while IFS= read -r line; do
    case "$line" in
        "##CC_ENV_START##"|"##CC_ENV_END##")
            continue
            ;;
        ANTHROPIC_API_KEY=*)
            export ANTHROPIC_API_KEY="${line#ANTHROPIC_API_KEY=}"
            ;;
        ANTHROPIC_BASE_URL=*)
            export ANTHROPIC_BASE_URL="${line#ANTHROPIC_BASE_URL=}"
            ;;
        ANTHROPIC_DEFAULT_HAIKU_MODEL=*)
            export ANTHROPIC_DEFAULT_HAIKU_MODEL="${line#ANTHROPIC_DEFAULT_HAIKU_MODEL=}"
            ;;
        ANTHROPIC_DEFAULT_SONNET_MODEL=*)
            export ANTHROPIC_DEFAULT_SONNET_MODEL="${line#ANTHROPIC_DEFAULT_SONNET_MODEL=}"
            ;;
        ANTHROPIC_DEFAULT_OPUS_MODEL=*)
            export ANTHROPIC_DEFAULT_OPUS_MODEL="${line#ANTHROPIC_DEFAULT_OPUS_MODEL=}"
            ;;
        CLAUDE_CODE_ADDITIONAL_REQUEST_BODY=*)
            export CLAUDE_CODE_ADDITIONAL_REQUEST_BODY="${line#CLAUDE_CODE_ADDITIONAL_REQUEST_BODY=}"
            ;;
    esac
done < "$TEMP_ENV"

rm -f "$TEMP_ENV"

# 检查是否有配置
if [ -z "$ANTHROPIC_API_KEY" ] || [ -z "$ANTHROPIC_BASE_URL" ]; then
    echo ""
    echo "❌ 错误: 未获取到有效配置"
    exit 1
fi

echo ""
echo "========================================"
echo "启动 Claude Code..."
echo "========================================"
echo ""

# 启动 Claude Code
exec claude
