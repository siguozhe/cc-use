#!/bin/bash

# Claude Code 完整安装与配置脚本
# 适用于 Ubuntu / Debian 系 Linux（使用 bash）
# 包含：nvm、Node.js LTS、Claude Code 安装及 API 配置

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
echo "Claude Code 完整安装与配置脚本"
echo "========================================"
echo

# ============================================
# 第一部分：环境检查
# ============================================

print_blue "========================================"
print_blue "第一部分：环境检查"
print_blue "========================================"
echo

# 检测 git
print_green "检测 git..."
if command -v git &> /dev/null; then
    GIT_VER=$(git --version | cut -d' ' -f3)
    print_yellow "git 已安装: $GIT_VER"
else
    print_red "⚠️  警告: git 未找到"
    print_yellow "  建议安装: sudo apt install git"
fi
echo

# 检测 Python
print_green "检测 Python..."
PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    PYTHON_VER=$($PYTHON_CMD --version | cut -d' ' -f2)
    print_yellow "Python3 已安装: $PYTHON_VER"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    PYTHON_VER=$($PYTHON_CMD --version | cut -d' ' -f2)
    print_yellow "Python 已安装: $PYTHON_VER"
else
    print_red "⚠️  警告: Python 未找到"
    print_yellow "  建议安装: sudo apt install python3"
fi
echo

# 检测 curl
print_green "检测 curl..."
if ! command -v curl &> /dev/null; then
    print_red "错误：未找到 curl，请先安装 curl"
    print_yellow "  安装命令: sudo apt install curl"
    exit 1
fi
CURL_VER=$(curl --version | head -1 | cut -d' ' -f2)
print_yellow "curl 已安装: $CURL_VER"
echo

# 检测系统架构
print_green "检测系统架构..."
ARCH=$(uname -m)
OS=$(uname -s)
print_yellow "系统: $OS / $ARCH"
echo

# ============================================
# 第二部分：安装 nvm
# ============================================

print_blue "========================================"
print_blue "第二部分：安装 nvm"
print_blue "========================================"
echo

NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    print_yellow "检测到 nvm 已存在于 $NVM_DIR"
else
    print_green "正在安装 nvm ..."

    # 多源 fallback 安装 nvm
    NVM_SOURCES=(
        "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh"
        "https://ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh"
        "https://mirror.ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh"
    )

    NVM_INSTALLED=0
    for source in "${NVM_SOURCES[@]}"; do
        print_yellow "尝试从 $source 下载..."
        if curl -f -s "$source" -o /tmp/nvm-install.sh; then
            print_green "下载成功，正在安装..."
            bash /tmp/nvm-install.sh
            rm -f /tmp/nvm-install.sh
            NVM_INSTALLED=1
            break
        else
            print_red "下载失败"
        fi
    done

    if [ $NVM_INSTALLED -ne 1 ]; then
        print_red "所有 nvm 安装源都失败了！"
        print_yellow "请手动安装 nvm: https://github.com/nvm-sh/nvm"
        exit 1
    fi
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
echo

# ============================================
# 第三部分：安装 Node.js LTS
# ============================================

print_blue "========================================"
print_blue "第三部分：安装 Node.js LTS"
print_blue "========================================"
echo

# 设置 Node.js 镜像源列表
NODE_MIRRORS=(
    "official|https://nodejs.org/dist/"
    "taobao|https://npmmirror.com/mirrors/node/"
    "huawei|https://repo.huaweicloud.com/nodejs/"
    "ustc|https://mirrors.ustc.edu.cn/nodejs-release/"
)

print_green "正在检查/安装最新的 Node.js LTS 版本..."

# 先尝试官方源
NODE_INSTALLED=0
for mirror_entry in "${NODE_MIRRORS[@]}"; do
    IFS='|' read -r mirror_name mirror_url <<< "$mirror_entry"

    if [ "$mirror_name" != "official" ]; then
        print_yellow "切换到 $mirror_name 镜像..."
        export NVM_NODEJS_ORG_MIRROR="$mirror_url"
    fi

    print_green "尝试从 $mirror_name 源安装..."
    if nvm install --lts; then
        NODE_INSTALLED=1
        print_green "Node.js LTS 从 $mirror_name 源安装成功！"
        break
    else
        print_red "从 $mirror_name 源安装失败"
    fi
done

if [ $NODE_INSTALLED -ne 1 ]; then
    print_red "所有 Node.js 安装源都失败了！"
    print_yellow "请检查网络连接或手动安装 Node.js"
    exit 1
fi

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
echo

# ============================================
# 第四部分：安装 Claude Code
# ============================================

print_blue "========================================"
print_blue "第四部分：安装 Claude Code"
print_blue "========================================"
echo

if command -v claude &> /dev/null; then
    CLAUDE_VER=$(claude --version 2>/dev/null || echo "已安装")
    print_yellow "Claude Code 已安装：$CLAUDE_VER"
    read -p "是否重新安装? (y/N): " REINSTALL
    if [[ "$(echo "$REINSTALL" | tr '[:lower:]' '[:upper:]')" == "Y" ]]; then
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

# ============================================
# 第五部分：API 配置
# ============================================

print_blue "========================================"
print_blue "第五部分：API 配置"
print_blue "========================================"
echo

# 检查 cc-config.py 是否存在
if [ -f "$CC_CONFIG" ] && [ -n "$PYTHON_CMD" ]; then
    print_green "使用 cc-config.py 进行配置..."
    echo

    # 运行 cc-config.py
    TEMP_ENV=$(mktemp /tmp/claude-env.XXXXXX)

    "$PYTHON_CMD" "$CC_CONFIG" 2>&1 | tee /dev/stderr | awk '/##CC_ENV_START##/,/##CC_ENV_END##/' > "$TEMP_ENV"

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
        print_green "安装与配置完成！"
        print_green "========================================"
        echo
        print_yellow "注意：为了使 nvm 在新终端中生效，请执行以下操作之一："
        print_yellow "  1. 关闭并重新打开所有终端"
        print_yellow "  2. 在当前终端中运行：source ~/.bashrc"
        echo

        if [ -n "$ANTHROPIC_API_KEY" ]; then
            echo "启动 Claude Code..."
            echo "================================================"
            echo
            exec claude
        fi
        exit 0
    else
        rm -f "$TEMP_ENV"
        print_red "cc-config.py 配置未完成"
    fi
else
    print_yellow "cc-config.py 或 Python 不可用，跳过配置部分"
    print_yellow "请运行 cc.sh 进行配置"
fi

echo
print_green "========================================"
print_green "安装完成！"
print_green "========================================"
echo
print_yellow "请运行 cc.sh 进行 API 配置"
echo
