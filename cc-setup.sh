#!/bin/bash

# Claude Code 完整安装与配置脚本
# 适用于 Ubuntu / Debian 系 Linux（使用 bash）
# 安装优先级：Node.js（必须）> Python（强烈建议）> nvm（可选，仅当 Node.js 未安装时使用）

# 设置 UTF-8 编码
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CC_CONFIG="$SCRIPT_DIR/cc-config.py"

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
echo "Claude Code Installation & Configuration"
echo "========================================"
echo

# ============================================
# 第一部分：环境检查
# ============================================

print_blue "========================================"
print_blue "Part 1: Environment Check"
print_blue "========================================"
echo

# 检测 curl（安装依赖，必须）
print_green "Checking curl..."
if ! command -v curl &> /dev/null; then
    print_red "Error: curl not found, please install curl first"
    print_yellow "  Install: sudo apt install curl"
    exit 1
fi
CURL_VER=$(curl --version | head -1 | cut -d' ' -f2)
print_yellow "curl found: $CURL_VER"
echo

# 检测 git
print_green "Checking git..."
if command -v git &> /dev/null; then
    GIT_VER=$(git --version | cut -d' ' -f3)
    print_yellow "git found: $GIT_VER"
else
    print_yellow "Warning: git not found"
    print_yellow "  Recommended: sudo apt install git"
fi
echo

# 检测系统架构
print_green "Checking system architecture..."
ARCH=$(uname -m)
OS=$(uname -s)
print_yellow "System: $OS / $ARCH"
echo

# ============================================
# 第二部分：Node.js 检测与安装（必须）
# 优先检测系统已有的 Node.js，没有才通过 nvm 安装
# ============================================

print_blue "========================================"
print_blue "Part 2: Node.js (Required)"
print_blue "========================================"
echo

NODE_READY=0

# 先检查系统是否已有 Node.js
if command -v node &> /dev/null; then
    NODE_VER=$(node --version)
    # 提取主版本号，检查是否 >= 18
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v//' | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -ge 18 ] 2>/dev/null; then
        print_green "Node.js found: $NODE_VER (meets requirement >= v18)"
        NPM_VER=$(npm --version 2>/dev/null || echo "not found")
        print_yellow "npm version: $NPM_VER"
        NODE_READY=1
    else
        print_yellow "Node.js found: $NODE_VER (too old, need >= v18)"
    fi
fi

# 如果系统没有合适的 Node.js，通过 nvm 安装
if [ $NODE_READY -ne 1 ]; then
    print_yellow "Node.js >= v18 not found, will install via nvm..."
    echo

    # --- 安装 nvm（仅作为 Node.js 的安装手段）---
    print_green "Checking nvm..."
    NVM_DIR="$HOME/.nvm"
    if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
        print_yellow "nvm already installed at $NVM_DIR"
    else
        print_green "Installing nvm..."

        # 多源 fallback 安装 nvm
        NVM_SOURCES=(
            "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh"
            "https://ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh"
            "https://mirror.ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh"
        )

        NVM_INSTALLED=0
        for source in "${NVM_SOURCES[@]}"; do
            print_yellow "Trying $source ..."
            if curl -f -s "$source" -o /tmp/nvm-install.sh; then
                print_green "Download successful, installing..."
                bash /tmp/nvm-install.sh
                rm -f /tmp/nvm-install.sh
                NVM_INSTALLED=1
                break
            else
                print_red "Download failed"
            fi
        done

        if [ $NVM_INSTALLED -ne 1 ]; then
            print_red "All nvm installation sources failed!"
            print_yellow "Please install Node.js manually: https://nodejs.org/"
            print_yellow "Or install nvm manually: https://github.com/nvm-sh/nvm"
            exit 1
        fi
    fi

    # 加载 nvm 到当前 shell
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        . "$NVM_DIR/nvm.sh"
        print_green "nvm loaded"
    else
        print_red "Error: cannot load nvm.sh"
        exit 1
    fi
    echo

    # --- 通过 nvm 安装 Node.js LTS ---
    print_green "Installing Node.js LTS via nvm..."

    # Node.js 镜像源列表
    NODE_MIRRORS=(
        "official|https://nodejs.org/dist/"
        "taobao|https://npmmirror.com/mirrors/node/"
        "huawei|https://repo.huaweicloud.com/nodejs/"
        "ustc|https://mirrors.ustc.edu.cn/nodejs-release/"
    )

    NODE_INSTALLED=0
    for mirror_entry in "${NODE_MIRRORS[@]}"; do
        IFS='|' read -r mirror_name mirror_url <<< "$mirror_entry"

        if [ "$mirror_name" != "official" ]; then
            print_yellow "Switching to $mirror_name mirror..."
            export NVM_NODEJS_ORG_MIRROR="$mirror_url"
        fi

        print_green "Trying $mirror_name source..."
        if nvm install --lts; then
            NODE_INSTALLED=1
            print_green "Node.js LTS installed from $mirror_name!"
            break
        else
            print_red "Failed from $mirror_name"
        fi
    done

    if [ $NODE_INSTALLED -ne 1 ]; then
        print_red "All Node.js installation sources failed!"
        print_yellow "Please install Node.js manually: https://nodejs.org/"
        exit 1
    fi

    LTS_VERSION=$(nvm current)
    nvm alias default "$LTS_VERSION" 2>/dev/null || true
    NODE_READY=1
fi

# 最终验证 Node.js
if [ $NODE_READY -ne 1 ]; then
    print_red "Error: Node.js is required but not available"
    print_yellow "Please install Node.js (>= v18): https://nodejs.org/"
    exit 1
fi

NODE_PATH=$(which node)
NODE_VER=$(node --version)
NPM_VER=$(npm --version)
print_green "Node path: $NODE_PATH"
print_green "Node: $NODE_VER | npm: $NPM_VER"
echo

# ============================================
# 第三部分：Python 检测（强烈建议）
# Python 用于 cc-config.py 高级配置功能
# ============================================

print_blue "========================================"
print_blue "Part 3: Python (Strongly Recommended)"
print_blue "========================================"
echo

PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    PYTHON_VER=$($PYTHON_CMD --version | cut -d' ' -f2)
    print_green "Python3 found: $PYTHON_VER"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    PYTHON_VER=$($PYTHON_CMD --version | cut -d' ' -f2)
    print_green "Python found: $PYTHON_VER"
else
    print_yellow "Warning: Python not found"
    print_yellow "  Python is strongly recommended for full configuration features"
    print_yellow "  (API key caching, multiple model selection, last used memory)"
    print_yellow "  Install: sudo apt install python3"
    echo
    print_yellow "You can still proceed, but configuration will be limited."
fi
echo

# ============================================
# 第四部分：安装 Claude Code
# ============================================

print_blue "========================================"
print_blue "Part 4: Install Claude Code"
print_blue "========================================"
echo

if command -v claude &> /dev/null; then
    CLAUDE_VER=$(claude --version 2>/dev/null || echo "installed")
    print_yellow "Claude Code already installed: $CLAUDE_VER"
    read -p "Reinstall? (y/N): " REINSTALL
    if [[ "$(echo "$REINSTALL" | tr '[:lower:]' '[:upper:]')" == "Y" ]]; then
        print_green "Updating Claude Code..."
        npm install -g @anthropic-ai/claude-code@latest
    fi
else
    print_green "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code@latest
fi

if command -v claude &> /dev/null; then
    print_green "Claude Code installed successfully!"
else
    print_red "Claude Code installation failed, please check network or install manually"
fi
echo

# ============================================
# 第五部分：API 配置
# ============================================

print_blue "========================================"
print_blue "Part 5: API Configuration"
print_blue "========================================"
echo

# 优先使用 cc-config.py（需要 Python）
if [ -f "$CC_CONFIG" ] && [ -n "$PYTHON_CMD" ]; then
    print_green "Using cc-config.py for configuration..."
    echo

    # 运行 cc-config.py 一次：stderr 显示给用户（交互提示），stdout 捕获环境变量
    TEMP_ENV=$(mktemp /tmp/claude-env.XXXXXX)

    "$PYTHON_CMD" "$CC_CONFIG" > "$TEMP_ENV"

    # 检查是否成功获取环境变量
    if grep -q "##CC_ENV_START##" "$TEMP_ENV"; then
        # 解析环境变量
        export ANTHROPIC_API_KEY=""
        export ANTHROPIC_BASE_URL=""

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
            esac
        done < "$TEMP_ENV"

        rm -f "$TEMP_ENV"

        echo
        print_green "========================================"
        print_green "Installation & Configuration Complete!"
        print_green "========================================"
        echo
        print_yellow "Note: To make nvm available in new terminals:"
        print_yellow "  1. Close and reopen all terminals"
        print_yellow "  2. Or run: source ~/.bashrc"
        echo

        if [ -n "$ANTHROPIC_API_KEY" ]; then
            echo "Starting Claude Code..."
            echo "================================================"
            echo
            exec claude
        fi
        exit 0
    else
        rm -f "$TEMP_ENV"
        print_red "cc-config.py configuration not completed"
    fi
elif [ ! -f "$CC_CONFIG" ]; then
    print_yellow "cc-config.py not found, skipping advanced configuration"
    print_yellow "Please run cc.sh for API configuration"
elif [ -z "$PYTHON_CMD" ]; then
    print_yellow "Python not available, skipping advanced configuration"
    print_yellow "Install Python for full configuration features, then run cc.sh"
fi

echo
print_green "========================================"
print_green "Installation Complete!"
print_green "========================================"
echo
print_yellow "Please run cc.sh for API configuration"
echo
