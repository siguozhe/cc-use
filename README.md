# Claude Code 一键安装与配置脚本

一套 Claude Code 的一键安装和 API 配置脚本，支持 Linux/macOS 和 Windows，内置 9 个 API 提供商。

---

## 快速开始

### 一句话总结

这是一套 Claude Code 的一键安装和 API 配置脚本，支持 Linux/macOS 和 Windows，内置 9 个 API 提供商。

### 30秒上手

- **首次安装**：运行 `cc-setup.sh` (Linux/macOS) 或 `cc-setup.bat` (Windows)
- **日常切换**：运行 `cc.sh` 或 `cc.bat` 切换 API 提供商

### 目录结构

```
cc/
├── cc.sh          # Linux/macOS - API 配置切换
├── cc-setup.sh    # Linux/macOS - 完整安装 + 配置
├── cc.bat         # Windows - API 配置切换
└── cc-setup.bat   # Windows - 完整安装 + 配置
```

---

## 文件概览

### 文件对比表

| 文件名 | 平台 | 功能 | 适用场景 |
|--------|------|------|----------|
| `cc.sh` | Linux/macOS | 仅 API 配置切换 | 已安装 Claude Code，只需切换 API |
| `cc-setup.sh` | Linux/macOS | 完整安装 + 配置 | 首次安装，或需要重新安装环境 |
| `cc.bat` | Windows | 仅 API 配置切换 | 已安装 Claude Code，只需切换 API |
| `cc-setup.bat` | Windows | 完整安装 + 配置 | 首次安装，或需要重新安装环境 |

### 选择指南

```
你需要做什么？
├── 首次安装 Claude Code
│   ├── Linux/macOS → 使用 cc-setup.sh
│   └── Windows → 使用 cc-setup.bat
└── 切换 API 提供商
    ├── Linux/macOS → 使用 cc.sh
    └── Windows → 使用 cc.bat
```

---

## 详细使用

### cc-setup.sh / cc-setup.bat（首次安装）

**功能**：
- 检查并安装 nvm (Linux/macOS) 或 nvm-windows (Windows)
- 安装 Node.js LTS
- 安装 Claude Code (`npm install -g @anthropic-ai/claude-code`)
- 配置 API 提供商
- 启动 Claude Code

**脚本流程**：

```
cc-setup.sh/bat 执行流程
│
├─ 第一阶段：环境检查与安装
│  ├─ 1. 检查 curl 是否可用
│  ├─ 2. 检查/安装 nvm
│  │   └─ 如已存在则跳过，否则下载安装
│  ├─ 3. 加载 nvm 到当前 shell
│  ├─ 4. 安装 Node.js LTS (nvm install --lts)
│  ├─ 5. 验证 Node.js 和 npm
│  └─ 6. 检查/安装 Claude Code
│      └─ 如已安装则询问是否重新安装
│
├─ 第二阶段：API 配置
│  ├─ 1. 创建/检查 ~/.claude.json 基础配置
│  ├─ 2. 显示 9 个 API 提供商选项供选择
│  ├─ 3. 用户选择提供商 (1-9)
│  ├─ 4. 设置对应 Base URL 和 Model
│  ├─ 5. 输入 API Key（可回车使用默认值）
│  ├─ 6. 输入 Primary API Key（第一次随便输入，第二次可回车使用默认值）
│  └─ 7. 用户确认是否继续
│
├─ 第三阶段：配置文件更新
│  ├─ 1. 更新 ~/.claude.json
│  │   └─ 使用 Python 合并更新，保留其他配置
│  ├─ 2. 更新 ~/.claude/settings.json
│  │   └─ 更新 env 字段（ANTHROPIC_AUTH_TOKEN 等）
│  │   └─ Siliconflow 选项自动添加 thinking 参数
│  └─ 3. 更新 ~/.claude/config.json
│      └─ 更新 primaryApiKey
│
└─ 第四阶段：启动 Claude Code
   ├─ 设置环境变量 (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL)
   └─ 执行 claude 启动程序
```

**Linux/macOS 使用步骤**：
```bash
# 1. 赋予执行权限
chmod +x cc-setup.sh

# 2. 运行脚本
./cc-setup.sh

# 3. 按提示选择 API 提供商并输入 API Key
```

**Windows 使用步骤**：
```cmd
:: 双击运行，或在命令行中执行
cc-setup.bat
```

---

### cc.sh / cc.bat（日常切换）

**功能**：
- 快速切换 API 提供商
- 更新三个配置文件
- 启动 Claude Code

**脚本流程**：

```
cc.sh/cc.bat 执行流程
│
├─ 第一阶段：初始化
│  └─ 1. 创建/检查 ~/.claude.json 基础配置
│
├─ 第二阶段：选择 API 提供商
│  ├─ 1. 显示 9 个 API 提供商选项供选择
│  ├─ 2. 用户选择提供商 (1-9)
│  ├─ 3. 设置对应 Base URL 和 Model
│  ├─ 4. 输入 API Key（可回车使用默认值）
│  ├─ 5. 输入 Primary API Key（可回车使用默认值）
│  └─ 6. 用户确认是否继续
│
├─ 第三阶段：配置文件更新
│  ├─ 1. 更新 ~/.claude.json
│  │   └─ 使用 Python 合并更新，保留其他配置
│  ├─ 2. 更新 ~/.claude/settings.json
│  │   └─ 更新 env 字段（ANTHROPIC_AUTH_TOKEN 等）
│  │   └─ Siliconflow 选项自动添加 thinking 参数
│  └─ 3. 更新 ~/.claude/config.json
│      └─ 更新 primaryApiKey
│
└─ 第四阶段：启动 Claude Code
   ├─ 设置环境变量 (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL)
   └─ 执行 claude 启动程序
```

**Linux/macOS 使用步骤**：
```bash
chmod +x cc.sh
./cc.sh
```

**Windows 使用步骤**：
```cmd
cc.bat
```

---

## API 提供商列表

> **提示**：在同一厂商下，如需更换模型，可直接修改脚本中的 `MODEL` 变量值即可。

| 序号 | 提供商 | 模型名称 | Base URL |
|------|--------|----------|----------|
| 1 | Zhipu AI (智谱) | glm-4.7 | `https://open.bigmodel.cn/api/anthropic` |
| 2 | MiniMax (国际) | MiniMax-M2.1 | `https://api.minimax.io/anthropic` |
| 3 | MiniMax (中国) | MiniMax-M2.1 | `https://api.minimaxi.com/anthropic` |
| 4 | Kimi (月之暗面) | kimi-k2-turbo-preview | `https://api.moonshot.cn/anthropic/` |
| 5 | Anthropic 官方 | claude-3-5-sonnet-20241022 | `https://api.anthropic.com` |
| 6 | 火山方舟 (Ark) | ark-code-latest | `https://ark.cn-beijing.volces.com/api/coding` |
| 7 | Siliconflow | Pro/MiniMaxAI/MiniMax-M2.5 | `https://api.siliconflow.cn/` |
| 8 | 通义千问 (DashScope) | qwen3.5-plus | `https://coding.dashscope.aliyuncs.com/apps/anthropic` |
| 9 | 百度千帆 (Qianfan) | qianfan-code-latest | `https://qianfan.baidubce.com/anthropic/coding` |

**特殊说明**：
- **Siliconflow (选项 7)**：会自动添加 `CLAUDE_CODE_ADDITIONAL_REQUEST_BODY` 启用思考模式
- 其他选项：会自动移除该参数（如果存在）

---

## 配置文件详解

脚本会更新以下三个配置文件，**都会保留原有配置**：

### 1. `~/.claude.json`

**位置**：用户主目录下

**更新字段**：
```json
{
  "anthropic_api_key": "...",
  "anthropic_base_url": "...",
  "model": "...",
  "provider": "...",
  "hasCompletedOnboarding": true
}
```

---

### 2. `~/.claude/settings.json`

**位置**：`~/.claude/` 目录下

**更新 `env` 字段**：
```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "...",
    "ANTHROPIC_BASE_URL": "...",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "...",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "...",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "..."
  }
}
```

**特殊处理**：
- 选择 Siliconflow (选项7) 时会添加 `CLAUDE_CODE_ADDITIONAL_REQUEST_BODY`
- 其他选项会自动移除该参数

---

### 3. `~/.claude/config.json`

**位置**：`~/.claude/` 目录下

**更新字段**：
```json
{
  "primaryApiKey": "..."
}
```

---

## 常见问题 FAQ

### Q: 为什么需要两个 API Key？

A:
- **API Key**：用于 `~/.claude.json` 和 `~/.claude/settings.json`，主要用于 API 请求认证
- **Primary API Key**：用于 `~/.claude/config.json`，是 Claude Code 的主 API Key
- 如果输入相同，可以直接回车使用默认值（来自上一个输入）

---

### Q: nvm 或 Claude Code 命令找不到怎么办？

A:
- **Linux/macOS**：运行 `source ~/.bashrc` 或重新打开终端
- **Windows**：重新打开命令提示符（推荐以管理员身份运行）或重启电脑

---

### Q: 配置文件会被覆盖吗？

A: 不会！脚本使用 Python 合并更新，**只会更新相关字段，保留其他所有配置**。

---

### Q: Python 没安装怎么办？

A:
- 脚本会使用 fallback 方式（直接覆盖，可能丢失其他配置）
- 建议先安装 Python 3 以获得更好体验

---

### Q: 如何手动切换 API 提供商？

A: 再次运行 `cc.sh` 或 `cc.bat` 即可。

---

### Q: 如何在同一厂商下更换模型？

A: 脚本中每个提供商都预设了一个默认模型，如需更换同一厂商下的其他模型，可直接修改脚本文件中的 `MODEL` 变量值即可。例如，将 `glm-4.7` 改为同一厂商的其他模型名称。
