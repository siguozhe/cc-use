# Claude Code 一键安装与配置脚本

一套 Claude Code 的一键安装和 API 配置脚本，支持 Linux/macOS 和 Windows，内置 11 个 API 提供商。

## 功能特性

1. **多源 fallback 下载**：nvm 和 Node.js 安装支持多个源（官方 + 国内镜像），自动切换
2. **完善的环境检测**：自动检测 git、Python、curl、系统架构等依赖
3. **API Key 缓存**：每个提供商的 API Key 缓存在 `~/.claude/provider-keys.json`（文件权限 600）
4. **上次选择记忆**：记住上次使用的提供商和模型，下次运行时作为默认选项
5. **多模型选择**：每个提供商支持多个预设模型 + 自定义模型输入
6. **API Key 掩码显示**：显示时只展示前 6 位和后 4 位（如 `sk-QRoh...1jyk`）
7. **降级模式**：无 Python 环境时自动进入简化配置流程

---

## 快速开始

### 环境要求

> **注意**：脚本使用 Python 进行核心配置管理。
>
> - **推荐**：安装 Python 3.6+ 以获得完整功能（配置缓存、多模型选择、上次记忆）
> - **无 Python**：脚本会进入降级模式（简单配置，无缓存，无模型选择）

**Python 快速安装**：

- **Linux**：`sudo apt install python3` (Debian/Ubuntu) 或 `sudo yum install python3` (CentOS/RHEL)
- **macOS**：`brew install python3` 或 [python.org/downloads](https://www.python.org/downloads/)
- **Windows**：[python.org/downloads](https://www.python.org/downloads/) 安装时勾选 "Add Python to PATH"

### 30 秒上手

- **首次安装**：运行 `cc-setup.sh` (Linux/macOS) 或 `cc-setup.bat` (Windows)
- **日常切换**：运行 `cc.sh` 或 `cc.bat` 切换 API 提供商/模型

---

## 目录结构

```
cc/
├── cc-setup.sh    # Linux/macOS - 完整安装 + 配置（nvm → Node.js → Claude Code → API 配置）
├── cc-setup.bat   # Windows - 完整安装 + 配置
├── cc.sh          # Linux/macOS - API 配置切换（调用 cc-config.py）
├── cc.bat         # Windows - API 配置切换（调用 cc-config.py）
├── cc-config.py   # 核心配置引擎（统一管理 provider/model/key）
├── nvm-setup.zip  # nvm-windows 离线安装包
└── README.md
```

### 文件对比

| 文件 | 平台 | 功能 | 适用场景 |
| ------ | ------ | ------ | ---------- |
| `cc-setup.sh` | Linux/macOS | 完整安装 + 配置 | 首次安装，或需要重新安装环境 |
| `cc-setup.bat` | Windows | 完整安装 + 配置 | 首次安装，或需要重新安装环境 |
| `cc.sh` | Linux/macOS | 仅 API 配置切换 | 已安装 Claude Code，只需切换 API |
| `cc.bat` | Windows | 仅 API 配置切换 | 已安装 Claude Code，只需切换 API |

```
你需要做什么？
├── 首次安装 Claude Code
│   ├── Linux/macOS → cc-setup.sh
│   └── Windows → cc-setup.bat
└── 切换 API 提供商/模型
    ├── Linux/macOS → cc.sh
    └── Windows → cc.bat
```

---

## 详细使用

### cc-setup.sh / cc-setup.bat（首次安装）

**安装流程**：

1. 环境检查（git、Python、curl、系统架构）
2. 安装 nvm（多源 fallback）
3. 安装 Node.js LTS（多镜像源 fallback）
4. 安装 Claude Code（`npm install -g @anthropic-ai/claude-code`）
5. 调用 `cc-config.py` 配置 API
6. 启动 Claude Code

**Linux/macOS**：
```bash
chmod +x cc-setup.sh
./cc-setup.sh
```

**Windows**：
```cmd
cc-setup.bat
```

---

### cc.sh / cc.bat（日常切换）

**功能**：

- 选择 API 提供商
- 选择模型（预设列表或自定义）
- 输入/复用 API Key
- 更新三个配置文件
- 启动 Claude Code

**Linux/macOS**：
```bash
chmod +x cc.sh
./cc.sh
```

**Windows**：
```cmd
cc.bat
```

---

## API 提供商列表

| 序号 | 提供商 | 默认模型 | 可选模型 | Base URL |
| ------ | -------- | ---------- | ---------- | ---------- |
| 1 | Zhipu AI (智谱) | glm-4.7 | glm-4.6, glm-4.5, glm-4.5-Air | `https://open.bigmodel.cn/api/anthropic` |
| 2 | MiniMax (国际) | MiniMax-M2.1 | MiniMax-M2.5, MiniMax-M2 | `https://api.minimax.io/anthropic` |
| 3 | MiniMax (中国) | MiniMax-M2.1 | MiniMax-M2.5, MiniMax-M2 | `https://api.minimaxi.com/anthropic` |
| 4 | Kimi (月之暗面) | kimi-k2-turbo-preview | kimi-pro, kimi-max | `https://api.moonshot.cn/anthropic/` |
| 5 | Anthropic 官方 | claude-3-5-sonnet-20241022 | claude-3-opus-20240229, claude-3-sonnet-20240229, claude-3-haiku-20240307 | `https://api.anthropic.com` |
| 6 | 火山方舟 (Ark) | ark-code-latest | doubao-seed-2.0-code, doubao-seed-2.0-pro, minimax-m2.5, glm-4.7, deepseek-v3.2, kimi-k2.5 | `https://ark.cn-beijing.volces.com/api/coding` |
| 7 | Siliconflow | Pro/MiniMaxAI/MiniMax-M2.5 | Pro/zai-org/GLM-5, Pro/moonshotai/Kimi-K2.5, Pro/zai-org/GLM-4.7, Pro/deepseek-ai/DeepSeek-V3.2, Qwen/Qwen3.5-397B-A17B | `https://api.siliconflow.cn/` |
| 8 | 通义千问 (DashScope) | qwen3.5-plus | kimi-k2.5, glm-5, MiniMax-M2.5, qwen3-max-2026-01-23, qwen3-coder-next, qwen3-coder-plus, glm-4.7 | `https://coding.dashscope.aliyuncs.com/apps/anthropic` |
| 9 | 百度千帆 (Qianfan) | qianfan-code-latest | kimi-k2.5, deepseek-v3.2, glm-5, minimax-m2.5 | `https://qianfan.baidubce.com/anthropic/coding` |
| 10 | PPChat (Claude Code 代理) | claude-sonnet-4-6 | claude-opus-4-6, claude-haiku-4-5 | `https://code.ppchat.vip` |
| 11 | 通义千问付费 (DashScope Pay) | qwen3.5-plus | kimi-k2.5, glm-5, MiniMax-M2.5, qwen3-max-2026-01-23, qwen3-coder-next, qwen3-coder-plus, glm-4.7 | `https://dashscope.aliyuncs.com/apps/anthropic` |

> 除预设模型外，每个提供商都支持输入自定义模型名称。

**特殊说明**：
- **Siliconflow (选项 7)**：会自动添加 `CLAUDE_CODE_ADDITIONAL_REQUEST_BODY` 启用思考模式
- **VS Code 插件用户**：如果使用 VS Code 插件，需要关闭 thinking 模式。请在 VS Code 设置中搜索 `claude-code.disableThinking` 并启用该选项，或在 `settings.json` 中添加：
  ```json
  {
    "claude-code.disableThinking": true
  }
  ```
- 其他选项会自动移除该参数（如果存在）

---

## 配置文件详解

脚本会更新以下三个配置文件。使用 Python 模式时**只更新相关字段，保留其他配置**；降级模式会直接覆盖。

### 1. `~/.claude.json`

```json
{
  "anthropic_api_key": "...",
  "anthropic_base_url": "...",
  "model": "...",
  "provider": "...",
  "hasCompletedOnboarding": true
}
```

### 2. `~/.claude/settings.json`

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

Siliconflow 选项会额外添加：
```json
{
  "env": {
    "CLAUDE_CODE_ADDITIONAL_REQUEST_BODY": "{\"thinking\":{\"type\":\"enabled\"}}"
  }
}
```

### 3. `~/.claude/config.json`

```json
{
  "primaryApiKey": "..."
}
```

---

## 常见问题 FAQ

### Q: nvm 或 Claude Code 命令找不到怎么办？

- **Linux/macOS**：运行 `source ~/.bashrc` 或重新打开终端
- **Windows**：重新打开命令提示符（推荐以管理员身份运行）或重启电脑

### Q: 配置文件会被覆盖吗？

Python 模式下不会，脚本使用 JSON 合并更新，只更新相关字段。降级模式（无 Python）会直接覆盖整个文件。

### Q: 如何在同一厂商下更换模型？

运行 `cc.sh` 或 `cc.bat`，选择对应厂商后会显示可选模型列表，也可以输入自定义模型名称。

### Q: API Key 会保存吗？

会。每个提供商的 Key 保存在 `~/.claude/provider-keys.json`（文件权限 600），下次选择同一提供商时自动填充。

### Q: 上次使用的提供商和模型会记住吗？

会。缓存在 `~/.claude/provider-keys.json` 中，下次运行时作为默认选项。

### Q: 降级模式和完整模式有什么区别？

| 功能 | 完整模式 (有 Python) | 降级模式 (无 Python) |
| ------ | --------------------- | --------------------- |
| API Key 缓存 | ✅ | ❌ |
| 多模型选择 | ✅ | ❌（仅默认模型） |
| 上次选择记忆 | ✅ | ❌ |
| 配置合并更新 | ✅ | ❌（直接覆盖） |
| Siliconflow 思考模式 | ✅ 自动配置 | ❌ 需手动配置 |
