#!/bin/bash

# Claude Code 完整安装与配置脚本
# 适用于 Ubuntu / Debian 系 Linux（使用 bash）
# 包含：nvm、Node.js LTS、Claude Code 安装及 API 配置

set -e  # 遇到错误立即退出

# 设置UTF-8编码
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 颜色输出函数
print_green() {
    echo -e "\033[0;32m$1\033[0m"
}
print_red() {
    echo -e "\033[0;31m$1\033[0m"
}
print_yellow() {
    echo -e "\033[0;33m$1\033[0m"
}
print_blue() {
    echo -e "\033[0;34m$1\033[0m"
}

# 清屏
clear

echo "========================================"
echo "Claude Code 完整安装与配置脚本"
echo "========================================"
echo

# ============================================
# 第一部分：环境检查与安装
# ============================================

# 检查 curl 是否可用
if ! command -v curl &> /dev/null; then
    print_red "错误：未找到 curl，请先安装 curl（例如：sudo apt install curl）"
    exit 1
fi

# --- 安装 nvm ---
NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    print_yellow "检测到 nvm 已存在于 $NVM_DIR"
else
    print_green "正在安装 nvm ..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
fi

# 加载 nvm 到当前 shell
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    print_green "nvm 已加载"
else
    print_red "错误：无法加载 nvm.sh，请检查 nvm 安装"
    exit 1
fi

# --- 安装 Node.js LTS ---
print_green "正在检查/安装最新的 Node.js LTS 版本..."
nvm install --lts

LTS_VERSION=$(nvm current)
print_green "Node.js 版本：$LTS_VERSION"

# 设置该版本为默认版本
nvm alias default "$LTS_VERSION" 2>/dev/null || true

# 验证 Node.js
NODE_PATH=$(which node)
NODE_VER=$(node --version)
NPM_VER=$(npm --version)
print_green "Node 路径：$NODE_PATH"
print_green "Node 版本：$NODE_VER | npm 版本：$NPM_VER"

# --- 安装 Claude Code ---
print_blue "----------------------------------------"
if command -v claude &> /dev/null; then
    CLAUDE_VER=$(claude --version 2>/dev/null || echo "已安装")
    print_yellow "Claude Code 已安装：$CLAUDE_VER"
    read -p "是否重新安装? (y/N): " REINSTALL
    if [[ "$(echo $REINSTALL | tr '[:lower:]' '[:upper:]')" == "Y" ]]; then
        print_green "正在更新 Claude Code..."
        npm install -g @anthropic-ai/claude-code@latest
    fi
else
    print_green "正在安装 Claude Code..."
    npm install -g @anthropic-ai/claude-code@latest
fi

if command -v claude &> /dev/null; then
    print_green "Claude Code 安装成功！"
else
    print_red "Claude Code 安装失败，请检查网络连接或手动安装"
fi

echo
print_blue "========================================"
print_blue "第二部分：API 配置"
print_blue "========================================"
echo

# ============================================
# 第二部分：API 配置
# ============================================

# --- 基础配置文件检查与创建 ---
CLAUDE_JSON="$HOME/.claude.json"

if [ ! -f "$CLAUDE_JSON" ]; then
    echo '{"hasCompletedOnboarding": true}' > "$CLAUDE_JSON"
    echo "Created base configuration file: $CLAUDE_JSON"
else
    echo "Base configuration file exists: $CLAUDE_JSON"
fi

echo
echo "Please select your API provider:"
echo "  1. Zhipu AI (GLM)"
echo "  2. MiniMax (International)"
echo "  3. MiniMax (China)"
echo "  4. Kimi (Moonshot AI)"
echo "  5. Anthropic Official"
echo "  6. Fangzhou (Ark)"
echo "  7. Siliconflow"
echo "  8. DashScope (Qwen)"
echo "  9. Qianfan (Baidu)"
echo

# 读取用户选择
read -p "Enter your choice [1-9]: " CHOICE

# --- 根据选择设置变量 ---
case $CHOICE in
    1)
        PROVIDER="ZhipuAI"
        BASE_URL="https://open.bigmodel.cn/api/anthropic"
        MODEL="glm-4.7"
        ;;
    2)
        PROVIDER="MiniMax_Intl"
        BASE_URL="https://api.minimax.io/anthropic"
        MODEL="MiniMax-M2.1"
        ;;
    3)
        PROVIDER="MiniMax_CN"
        BASE_URL="https://api.minimaxi.com/anthropic"
        MODEL="MiniMax-M2.1"
        ;;
    4)
        PROVIDER="Kimi"
        BASE_URL="https://api.moonshot.cn/anthropic/"
        MODEL="kimi-k2-turbo-preview"
        ;;
    5)
        PROVIDER="Anthropic"
        BASE_URL="https://api.anthropic.com"
        MODEL="claude-3-5-sonnet-20241022"
        ;;
    6)
        PROVIDER="Fangzhou"
        BASE_URL="https://ark.cn-beijing.volces.com/api/coding"
        MODEL="ark-code-latest"
        ;;
    7)
        PROVIDER="Siliconflow"
        BASE_URL="https://api.siliconflow.cn/"
        MODEL="Pro/MiniMaxAI/MiniMax-M2.5"
        ;;
    8)
        PROVIDER="DashScope"
        BASE_URL="https://coding.dashscope.aliyuncs.com/apps/anthropic"
        MODEL="qwen3.5-plus"
        ;;
    9)
        PROVIDER="Qianfan"
        BASE_URL="https://qianfan.baidubce.com/anthropic/coding"
        MODEL="qianfan-code-latest"
        ;;
    *)
        echo "Invalid selection."
        read -p "Press Enter to exit..."
        exit 1
        ;;
esac

echo
echo "========================================"
echo "Configuration Summary"
echo "========================================"
echo "Provider: $PROVIDER"
echo "Base URL: $BASE_URL"
echo "Model: $MODEL"
echo "========================================"

# API Key 输入
echo
echo "Please enter your API Key:"
# 尝试从现有配置中读取默认 API Key
DEFAULT_KEY=""
if [ -f "$CLAUDE_JSON" ]; then
    DEFAULT_KEY=$(grep -o '"anthropic_api_key"[[:space:]]*:[[:space:]]*"[^"]*"' "$CLAUDE_JSON" | cut -d'"' -f4 2>/dev/null || echo "")
fi

if [ -n "$DEFAULT_KEY" ]; then
    read -p "API Key [default: $DEFAULT_KEY]: " INPUT_KEY
    # 如果用户直接按回车，使用默认值
    API_KEY="${INPUT_KEY:-$DEFAULT_KEY}"
else
    read -p "API Key: " API_KEY
fi

# 如果还是为空，使用硬编码的备用值
if [ -z "$API_KEY" ]; then
    echo "Warning: No API Key provided. Using fallback key."
    API_KEY="bcff1f1c1afb408e9fd3f2791d20793b.kqjL0iiOg1zRTf57"
fi

echo
echo "Using API Key: ${API_KEY:0:10}...${API_KEY: -4}"

# Primary API Key 输入（用于 ~/.claude/config.json）
echo
echo "Please enter your Primary API Key (for config.json):"
CONFIG_JSON_PATH="$HOME/.claude/config.json"
DEFAULT_PRIMARY_KEY=""
if [ -f "$CONFIG_JSON_PATH" ]; then
    DEFAULT_PRIMARY_KEY=$(grep -o '"primaryApiKey"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_JSON_PATH" | cut -d'"' -f4 2>/dev/null || echo "")
fi

if [ -n "$DEFAULT_PRIMARY_KEY" ]; then
    read -p "Primary API Key [default: $DEFAULT_PRIMARY_KEY]: " INPUT_PRIMARY_KEY
    PRIMARY_API_KEY="${INPUT_PRIMARY_KEY:-$DEFAULT_PRIMARY_KEY}"
else
    read -p "Primary API Key: " PRIMARY_API_KEY
fi

# 如果为空，使用 API_KEY 作为备用
if [ -z "$PRIMARY_API_KEY" ]; then
    echo "Warning: No Primary API Key provided. Using API Key as fallback."
    PRIMARY_API_KEY="$API_KEY"
fi

echo
echo "Using Primary API Key: ${PRIMARY_API_KEY:0:10}...${PRIMARY_API_KEY: -4}"
echo

echo "WARNING: This will update the API configuration!"
read -p "Continue? (Y/N): " CONFIRM

# 转换为大写并判断
if [ "$(echo $CONFIRM | tr '[:lower:]' '[:upper:]')" != "Y" ]; then
    echo "Configuration cancelled."
    read -p "Press Enter to exit..."
    exit 0
fi

# --- 使用 Python 合并更新配置文件 ---
echo "Updating configuration files..."

# 1. 更新 .claude.json（只更新 API 配置，保留其他所有配置）
if command -v python3 &> /dev/null; then
    python3 << PYTHON_SCRIPT
import json

claude_json_path = "$CLAUDE_JSON"
new_config = {
    "anthropic_api_key": "$API_KEY",
    "anthropic_base_url": "$BASE_URL",
    "model": "$MODEL",
    "provider": "$PROVIDER",
    "hasCompletedOnboarding": True
}

# 读取现有配置
try:
    with open(claude_json_path, 'r') as f:
        existing_config = json.load(f)
except:
    existing_config = {}

# 更新 API 配置字段
for key, value in new_config.items():
    existing_config[key] = value

# 写回文件
with open(claude_json_path, 'w') as f:
    json.dump(existing_config, f, indent=2, ensure_ascii=False)
PYTHON_SCRIPT
    echo "Configuration file updated (preserved existing config): $CLAUDE_JSON"
else
    echo "Warning: python3 not found. Using fallback update."
    # Fallback: 完全覆盖（会丢失其他配置）
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
fi

# 2. 更新用户目录的 settings.json（只更新模型 API 部分，保留其他配置）
SETTINGS_JSON="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$SETTINGS_JSON")"

# 检查文件是否存在，如果不存在则创建基础结构
if [ ! -f "$SETTINGS_JSON" ]; then
    echo "{}" > "$SETTINGS_JSON"
fi

# 使用 Python 来合并 JSON，保留原有配置
if command -v python3 &> /dev/null; then
    python3 << PYTHON_SCRIPT
import json

settings_path = "$SETTINGS_JSON"
new_env = {
    "ANTHROPIC_AUTH_TOKEN": "$API_KEY",
    "ANTHROPIC_BASE_URL": "$BASE_URL",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "$MODEL",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "$MODEL",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "$MODEL"
}

# 读取现有配置
try:
    with open(settings_path, 'r') as f:
        settings = json.load(f)
except:
    settings = {}

# 更新 env 部分
if "env" not in settings:
    settings["env"] = {}

# 选项 7 (Siliconflow) 添加 thinking 参数，其他选项删除该参数
choice = "$CHOICE"
if choice == "7":
    new_env["CLAUDE_CODE_ADDITIONAL_REQUEST_BODY"] = '{"thinking":{"type":"enabled"}}'
else:
    # 其他选项移除该参数（如果存在）
    if "CLAUDE_CODE_ADDITIONAL_REQUEST_BODY" in settings["env"]:
        del settings["env"]["CLAUDE_CODE_ADDITIONAL_REQUEST_BODY"]

settings["env"].update(new_env)

# 写回文件
with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
PYTHON_SCRIPT
    echo "Settings file updated (preserved existing config): $SETTINGS_JSON"
else
    echo "Warning: python3 not found. Skipping settings.json update."
    echo "Please manually update: $SETTINGS_JSON"
fi

# 3. 更新 ~/.claude/config.json（primaryApiKey 配置）
CONFIG_JSON="$HOME/.claude/config.json"

if command -v python3 &> /dev/null; then
    python3 << PYTHON_SCRIPT
import json
import os

config_path = "$CONFIG_JSON"
primary_api_key = "$PRIMARY_API_KEY"

# 确保 .claude 目录存在
os.makedirs(os.path.dirname(config_path), exist_ok=True)

# 读取现有配置（如果存在）
if os.path.exists(config_path):
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        print(f"Config file exists: {config_path}")
    except:
        config = {}
else:
    config = {}
    print(f"Creating new config file: {config_path}")

# 更新 primaryApiKey
config["primaryApiKey"] = primary_api_key

# 写回文件
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print(f"primaryApiKey updated in: {config_path}")
PYTHON_SCRIPT
else
    # Fallback: 直接创建/覆盖
    mkdir -p "$(dirname "$CONFIG_JSON")"
    cat > "$CONFIG_JSON" << EOF
{
  "primaryApiKey": "$PRIMARY_API_KEY"
}
EOF
    echo "Config file created: $CONFIG_JSON"
fi

echo
print_green "========================================"
print_green "安装与配置完成！"
print_green "========================================"
print_green "Provider: $PROVIDER"
print_green "Model: $MODEL"
print_green "========================================"
echo
print_yellow "注意：为了使 nvm 在新终端中生效，请执行以下操作之一："
print_yellow "  1. 关闭并重新打开所有终端"
print_yellow "  2. 在当前终端中运行：source ~/.bashrc"
echo

echo "Starting Claude Code with $PROVIDER settings..."
echo "================================================"
echo

# 设置环境变量并启动claude
export ANTHROPIC_API_KEY="$API_KEY"
export ANTHROPIC_BASE_URL="$BASE_URL"
claude

# 等待用户输入后退出
read -p "Press Enter to exit..."
