#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Claude Code Configuration Engine
统一管理 API 提供商、模型选择和密钥缓存
"""

import sys
import json
import os
import getpass
import platform


# ==================== 配置定义 ====================
PROVIDERS = [
    {
        "id": "DeepSeek",
        "name": "DeepSeek (Anthropic API)",
        "base_url": "https://api.deepseek.com/anthropic",
        "default_model": "deepseek-v4-pro",
        "models": [
            "deepseek-v4-pro",
            "deepseek-flash",
            # 旧名，仍可调用（自动路由到 V4.1-Flash）
            "deepseek-v4-flash"
        ],
        "haiku_model": "deepseek-flash",
        "subagent_model": "deepseek-flash",
        "effort_level": "max",
        "auto_compact_window": 1000000
    },
    {
        "id": "ZhipuAI",
        "name": "Zhipu AI (GLM)",
        "base_url": "https://open.bigmodel.cn/api/anthropic",
        "default_model": "glm-5.4[1m]",
        "models": [
            "glm-5.4[1m]", "glm-5.4",
            "glm-5.3[1m]", "glm-5.3", "glm-5.3-flash[1m]", "glm-5.3-flash",
            "glm-5.3-flashx",
            "glm-5.1", "glm-5", "glm-4.7", "glm-4.6", "glm-4.5", "glm-4.5-air"
        ],
        "haiku_model": "glm-5.3-flash",
        "auto_compact_window": 1000000
    },
    {
        "id": "Kimi",
        "name": "Kimi (Moonshot AI)",
        "base_url": "https://api.moonshot.cn/anthropic/",
        "default_model": "kimi-k3",
        "models": [
            "kimi-k3", "kimi-k3.1-pro",
            "kimi-k2.7-code", "kimi-k2.7-code-highspeed", "kimi-k2.6"
        ]
    },
    {
        "id": "Anthropic",
        "name": "Anthropic Official",
        "base_url": "https://api.anthropic.com",
        "default_model": "claude-opus-5-5",
        "models": [
            "claude-opus-5-5", "claude-sonnet-5-5", "claude-haiku-5-5",
            "claude-fable-5-2", "claude-opus-5", "claude-sonnet-5"
        ]
    },
    {
        "id": "Fangzhou",
        "name": "Fangzhou (Ark) Agent Plan",
        "base_url": "https://ark.cn-beijing.volces.com/api/plan",
        "default_model": "ark-code-latest",
        "models": [
            "ark-code-latest", "doubao-seed-evolving", "doubao-seed-2.1-pro",
            "doubao-seed-2.1-lite", "doubao-seed-2.0-mini",
            "glm-5.3", "glm-5.3-flash",
            "deepseek-v4.1-flash", "deepseek-v4.1-flash-economy",
            "deepseek-v4-flash", "deepseek-v4-pro",
            "kimi-k3.1-pro", "kimi-k2.8-preview"
        ],
        "auto_compact_window": 1000000
    },
    {
        "id": "Siliconflow",
        "name": "Siliconflow",
        "base_url": "https://api.siliconflow.cn/",
        "default_model": "Pro/zai-org/GLM-5.3",
        "models": [
            "Pro/zai-org/GLM-5.3", "Pro/zai-org/GLM-5.3-Flash",
            "Pro/deepseek-ai/DeepSeek-V4.1-Flash", "Pro/deepseek-ai/DeepSeek-V4-Pro",
            "Pro/moonshotai/Kimi-K3", "Pro/moonshotai/Kimi-K2.7-Code",
            "Qwen/Qwen3.8-27B"
        ]
    },
    {
        "id": "DashScope",
        "name": "DashScope (Qwen)",
        "base_url": "https://coding.dashscope.aliyuncs.com/apps/anthropic",
        "default_model": "qwen3.7-plus",
        "models": [
            "qwen3.7-plus", "qwen3.6-plus", "qwen3.5-plus",
            "qwen3-coder-next", "qwen3-coder-plus", "qwen3-max-2026-01-23",
            "glm-5.3", "glm-5", "kimi-k2.5", "glm-4.7"
        ]
    },
    {
        "id": "Qianfan",
        "name": "Qianfan (Baidu) Token Plan",
        "base_url": "https://qianfan.baidubce.com/anthropic/tokenplan/personal",
        "default_model": "qianfan-code-latest",
        "models": [
            "qianfan-code-latest",
            "ernie-5.5-flash-preview", "ernie-light-dt-1.0",
            "glm-5.3", "glm-5.2", "glm-5.1", "glm-5.3-flash",
            "deepseek-v4.1-flash", "deepseek-v4.1-flash-1017",
            "deepseek-v4-pro", "deepseek-v4-pro-0813", "deepseek-v4-flash-0731",
            "unlimited-ocr-2"
        ]
    },
    {
        "id": "PPChat",
        "name": "PPChat (Claude Code Proxy)",
        "base_url": "https://code.ppchat.vip",
        "default_model": "claude-sonnet-5-5",
        "models": [
            "claude-sonnet-5-5", "claude-opus-5-5", "claude-haiku-5-5",
            "claude-fable-5-2"
        ]
    },
    {
        "id": "DashScope_Pay",
        "name": "DashScope Pay (Qwen)",
        "base_url": "https://dashscope.aliyuncs.com/apps/anthropic",
        "default_model": "qwen3.8-max",
        "models": [
            "qwen3.8-max", "qwen3.8-flash", "qwen3.8-27b",
            "qwen3.7-plus", "qwen3.7-max", "qwen3.7-flash",
            "qwen3-coder-next", "qwen3-coder-plus",
            "glm-5.3", "deepseek-v4-pro"
        ]
    },
    {
        "id": "CLIProxyAPI",
        "name": "CLI Proxy API (本地 2222)",
        "base_url": "http://127.0.0.1:2222",
        "default_model": "qwen3-max",
        "models": [
            "qwen3-max", "deepseek-v3", "deepseek-v3.2",
            "kimi-k2", "gemini-3-pro-preview"
        ]
    }
]


# ==================== 工具函数 ====================
def print_stderr(*args, **kwargs):
    """输出到 stderr（用户可见）"""
    print(*args, file=sys.stderr, **kwargs)


def print_prompt(text):
    """打印带前缀的提示"""
    print_stderr(f"❯ {text}")


def mask_api_key(key):
    """掩码显示 API Key"""
    if len(key) <= 10:
        return key
    return f"{key[:6]}...{key[-4:]}"


def get_cache_dir():
    """获取缓存目录"""
    if platform.system() == "Windows":
        return os.path.join(os.getenv("USERPROFILE"), ".claude")
    else:
        return os.path.join(os.getenv("HOME"), ".claude")


def get_cache_file():
    """获取缓存文件路径"""
    cache_dir = get_cache_dir()
    os.makedirs(cache_dir, exist_ok=True)
    return os.path.join(cache_dir, "provider-keys.json")


def load_cache():
    """加载缓存"""
    cache_file = get_cache_file()
    if not os.path.exists(cache_file):
        return {"_last_provider": None}

    try:
        with open(cache_file, "r", encoding="utf-8") as f:
            cache = json.load(f)
        # 确保结构正确
        if "_last_provider" not in cache:
            cache["_last_provider"] = None
        return cache
    except Exception as e:
        print_stderr(f"警告: 加载缓存失败 - {e}")
        return {"_last_provider": None}


def save_cache(cache):
    """保存缓存"""
    cache_file = get_cache_file()
    try:
        with open(cache_file, "w", encoding="utf-8") as f:
            json.dump(cache, f, ensure_ascii=False, indent=2)
        # 设置文件权限为 600
        if platform.system() != "Windows":
            os.chmod(cache_file, 0o600)
    except Exception as e:
        print_stderr(f"警告: 保存缓存失败 - {e}")


def get_config_paths():
    """获取配置文件路径"""
    if platform.system() == "Windows":
        user_dir = os.getenv("USERPROFILE")
    else:
        user_dir = os.getenv("HOME")

    return {
        "claude_json": os.path.join(user_dir, ".claude.json"),
        "settings_json": os.path.join(get_cache_dir(), "settings.json"),
        "config_json": os.path.join(get_cache_dir(), "config.json")
    }


def update_claude_json(provider, model, api_key):
    """更新 .claude.json"""
    paths = get_config_paths()
    try:
        if os.path.exists(paths["claude_json"]):
            with open(paths["claude_json"], "r", encoding="utf-8") as f:
                config = json.load(f)
        else:
            config = {}
        config.update({
            "anthropic_api_key": api_key,
            "anthropic_base_url": provider["base_url"],
            "model": model,
            "provider": provider["id"],
            "hasCompletedOnboarding": True
        })
        with open(paths["claude_json"], "w", encoding="utf-8") as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        print_stderr(f"✅ 更新成功: {paths['claude_json']}")
    except Exception as e:
        print_stderr(f"❌ 更新失败 {paths['claude_json']}: {e}")


def update_settings_json(provider, model, api_key):
    """更新 settings.json"""
    paths = get_config_paths()
    try:
        if os.path.exists(paths["settings_json"]):
            with open(paths["settings_json"], "r", encoding="utf-8") as f:
                config = json.load(f)
        else:
            config = {}
        if "env" not in config:
            config["env"] = {}

        # 基础环境变量
        env = {
            "ANTHROPIC_AUTH_TOKEN": api_key,
            "ANTHROPIC_BASE_URL": provider["base_url"],
            "ANTHROPIC_DEFAULT_SONNET_MODEL": model,
            "ANTHROPIC_DEFAULT_OPUS_MODEL": model,
            "CLAUDE_CODE_ATTRIBUTION_HEADER": "0"
        }

        # Haiku 模型：provider 显式指定 haiku_model 时使用，否则用主模型
        if provider.get("haiku_model"):
            env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = provider["haiku_model"]
        else:
            env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = model

        # Siliconflow 特殊配置 - 启用思考模式
        if provider["id"] == "Siliconflow":
            env["CLAUDE_CODE_ADDITIONAL_REQUEST_BODY"] = '{"thinking":{"type":"enabled"}}'
        else:
            config["env"].pop("CLAUDE_CODE_ADDITIONAL_REQUEST_BODY", None)

        # DeepSeek 特殊配置
        if provider["id"] == "DeepSeek":
            # Subagent 模型
            if provider.get("subagent_model"):
                env["CLAUDE_CODE_SUBAGENT_MODEL"] = provider["subagent_model"]
            # Effort level
            if provider.get("effort_level"):
                env["CLAUDE_CODE_EFFORT_LEVEL"] = provider["effort_level"]
        else:
            config["env"].pop("CLAUDE_CODE_SUBAGENT_MODEL", None)
            config["env"].pop("CLAUDE_CODE_EFFORT_LEVEL", None)

        # 自动压缩窗口（通用：支持 DeepSeek/ZhipuAI 等）
        if provider.get("auto_compact_window"):
            env["CLAUDE_CODE_AUTO_COMPACT_WINDOW"] = str(provider["auto_compact_window"])
        else:
            config["env"].pop("CLAUDE_CODE_AUTO_COMPACT_WINDOW", None)

        # 移除旧的 contextManagement 配置（改用环境变量）
        config.pop("contextManagement", None)

        config["env"].update(env)
        with open(paths["settings_json"], "w", encoding="utf-8") as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        print_stderr(f"✅ 更新成功: {paths['settings_json']}")
        if provider.get("auto_compact_window"):
            print_stderr(f"   已启用大上下文支持（压缩窗口 {provider['auto_compact_window']//1000}k）")
    except Exception as e:
        print_stderr(f"❌ 更新失败 {paths['settings_json']}: {e}")


def update_config_json(api_key):
    """更新 config.json"""
    paths = get_config_paths()
    try:
        if os.path.exists(paths["config_json"]):
            with open(paths["config_json"], "r", encoding="utf-8") as f:
                config = json.load(f)
        else:
            config = {}
        config["primaryApiKey"] = api_key
        with open(paths["config_json"], "w", encoding="utf-8") as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        print_stderr(f"✅ 更新成功: {paths['config_json']}")
    except Exception as e:
        print_stderr(f"❌ 更新失败 {paths['config_json']}: {e}")


def print_provider_list():
    """打印 provider 列表"""
    print_stderr()
    print_stderr("请选择 API 提供商:")
    for i, provider in enumerate(PROVIDERS, 1):
        print_stderr(f"  {i}. {provider['name']}")


def print_model_list(provider):
    """打印 model 列表"""
    print_stderr()
    print_stderr(f"可选模型 for {provider['name']}:")
    for i, model in enumerate(provider["models"], 1):
        print_stderr(f"  {i}. {model}")
    print_stderr("  0. 自定义模型")


# ==================== 交互流程 ====================
def select_provider(cache):
    """选择 provider"""
    print_provider_list()
    # 获取默认选择
    last_provider = cache.get("_last_provider")
    # 忽略已被移除的 provider（如 GCLI2API / MiniMax）
    if last_provider and not any(p["id"] == last_provider for p in PROVIDERS):
        last_provider = None
    if last_provider:
        # 找到 index
        default_idx = None
        for i, provider in enumerate(PROVIDERS, 1):
            if provider["id"] == last_provider:
                default_idx = i
                break
        if default_idx:
            print_prompt(f"[默认: {default_idx} ({last_provider})]")

    while True:
        try:
            user_input = input()
            if not user_input and last_provider:
                return next(p for p in PROVIDERS if p["id"] == last_provider)
            idx = int(user_input)
            if 1 <= idx <= len(PROVIDERS):
                return PROVIDERS[idx - 1]
            print_stderr(f"请输入 1-{len(PROVIDERS)} 的数字")
        except ValueError:
            print_stderr("请输入有效的数字")


def select_model(provider, cache):
    """选择 model"""
    print_model_list(provider)
    # 获取默认选择
    provider_cache = cache.get(provider["id"], {})
    last_model = provider_cache.get("last_model", provider["default_model"])

    if last_model in provider["models"]:
        default_idx = provider["models"].index(last_model) + 1
    else:
        default_idx = None  # 自定义模型

    if default_idx:
        print_prompt(f"[默认: {default_idx} ({last_model})]")
    else:
        print_prompt(f"[默认: {last_model} (自定义)]")

    while True:
        try:
            user_input = input()
            if not user_input:
                return last_model

            idx = int(user_input)
            if idx == 0:
                print_stderr()
                print_prompt("请输入自定义模型名称:")
                return input().strip()
            if 1 <= idx <= len(provider["models"]):
                return provider["models"][idx - 1]
            print_stderr(f"请输入 0-{len(provider['models'])} 的数字")
        except ValueError:
            print_stderr("请输入有效的数字")


def input_api_key(provider, cache):
    """输入 API Key"""
    provider_cache = cache.get(provider["id"], {})
    saved_key = provider_cache.get("api_key")

    print_stderr()
    if saved_key:
        print_prompt(f"API Key [默认: {mask_api_key(saved_key)}]:")
    else:
        print_prompt("请输入 API Key:")

    user_input = input().strip()
    if user_input:
        return user_input
    if saved_key:
        return saved_key

    # 必须输入
    while True:
        print_prompt("API Key 不能为空，请重新输入:")
        user_input = input().strip()
        if user_input:
            return user_input


# ==================== 主流程 ====================
def main():
    # 1. 加载缓存
    cache = load_cache()

    # 2. 选择 Provider
    print_stderr()
    print_stderr("=" * 40)
    print_stderr("Claude Code 配置助手")
    print_stderr("=" * 40)
    provider = select_provider(cache)

    # 3. 选择 Model
    model = select_model(provider, cache)

    # 4. 输入 API Key
    api_key = input_api_key(provider, cache)

    # 5. 确认信息
    print_stderr()
    print_stderr("=" * 40)
    print_stderr("配置确认")
    print_stderr("=" * 40)
    print_stderr(f"Provider: {provider['name']}")
    print_stderr(f"Base URL: {provider['base_url']}")
    print_stderr(f"Model: {model}")
    print_stderr(f"API Key: {mask_api_key(api_key)}")
    print_stderr("=" * 40)

    print_stderr()
    while True:
        print_prompt("是否确认？(Y/n):")
        confirm = input().strip().lower()
        if not confirm or confirm == "y":
            break
        if confirm == "n":
            print_stderr("配置取消")
            return

    # 6. 更新缓存
    cache["_last_provider"] = provider["id"]
    if provider["id"] not in cache:
        cache[provider["id"]] = {}
    cache[provider["id"]]["api_key"] = api_key
    cache[provider["id"]]["last_model"] = model
    save_cache(cache)

    # 7. 更新配置文件
    print_stderr()
    print_stderr("正在更新配置文件...")
    update_claude_json(provider, model, api_key)
    update_settings_json(provider, model, api_key)
    update_config_json(api_key)

    # 8. 输出环境变量块（供 shell 脚本读取）
    print_stderr()
    print_stderr("✅ 配置完成！")
    print()  # 空行分隔用户可见输出和机器可读输出
    print("##CC_ENV_START##")
    print(f"ANTHROPIC_API_KEY={api_key}")
    print(f"ANTHROPIC_BASE_URL={provider['base_url']}")
    print(f"ANTHROPIC_DEFAULT_SONNET_MODEL={model}")
    print(f"ANTHROPIC_DEFAULT_OPUS_MODEL={model}")
    print("CLAUDE_CODE_ATTRIBUTION_HEADER=0")
    # Haiku 模型
    if provider.get("haiku_model"):
        print(f"ANTHROPIC_DEFAULT_HAIKU_MODEL={provider['haiku_model']}")
    else:
        print(f"ANTHROPIC_DEFAULT_HAIKU_MODEL={model}")
    # DeepSeek 特殊配置
    if provider["id"] == "DeepSeek":
        if provider.get("subagent_model"):
            print(f"CLAUDE_CODE_SUBAGENT_MODEL={provider['subagent_model']}")
        if provider.get("effort_level"):
            print(f"CLAUDE_CODE_EFFORT_LEVEL={provider['effort_level']}")
    # 通用：自动压缩窗口（DeepSeek/ZhipuAI 等）
    if provider.get("auto_compact_window"):
        print(f"CLAUDE_CODE_AUTO_COMPACT_WINDOW={provider['auto_compact_window']}")
    # Siliconflow 特殊配置
    if provider["id"] == "Siliconflow":
        print('CLAUDE_CODE_ADDITIONAL_REQUEST_BODY={"thinking":{"type":"enabled"}}')
    print("##CC_ENV_END##")


if __name__ == "__main__":
    main()
