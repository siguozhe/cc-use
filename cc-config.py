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
        "id": "GCLI2API_Local",
        "name": "GCLI2API (本地 2223) - Gemini",
        "base_url": "http://127.0.0.1:2223/v1",
        "default_model": "gemini-2.5-pro",
        "models": [
            # GCLI 模式 - Gemini 系列
            "gemini-2.5-pro",
            "gemini-2.5-pro-high",
            "gemini-2.5-pro-search",
            "gemini-2.5-flash",
            "gemini-2.5-flash-thinking",
            "gemini-2.5-pro-medium",
            "gemini-2.5-flash-medium",
            "gemini-2.5-pro-low",
            "gemini-2.5-flash-low",
            "gemini-2.5-pro-minimal",
            "gemini-2.5-flash-minimal",
            "gemini-2.5-pro-max",
            "gemini-2.5-flash-max",
            # 其他
            "gemini-3-pro-preview",
            "gemini-3-flash-preview",
            "gemini-3.1-pro-preview",
            "gemini-3.1-flash-lite-preview",
            "chat_20706",
            "chat_23310"
        ]
    },
    {
        "id": "GCLI2API_Antigravity",
        "name": "GCLI2API Antigravity (本地 2223)",
        "base_url": "http://127.0.0.1:2223/antigravity",
        "default_model": "claude-sonnet-4-6",
        "models": [
            # Claude 系列
            "claude-sonnet-4-6",
            "claude-sonnet-4-6-thinking",
            "claude-opus-4-6",
            "claude-opus-4-6-thinking",
            # Gemini 系列
            "gemini-2.5-pro",
            "gemini-2.5-flash",
            "gemini-2.5-flash-thinking",
            "gemini-2.5-flash-lite",
            "gemini-3-pro-high",
            "gemini-3-pro-low",
            "gemini-3-flash",
            "gemini-3.1-pro-high",
            "gemini-3.1-pro-low",
            "gemini-3.1-flash-image",
            # 其他
            "gpt-oss-120b-medium"
        ]
    },
    {
        "id": "ZhipuAI",
        "name": "Zhipu AI (GLM)",
        "base_url": "https://open.bigmodel.cn/api/anthropic",
        "default_model": "glm-4.7",
        "models": [
            "glm-4.7", "glm-4.6", "glm-4.5", "glm-4.5-Air"
        ]
    },
    {
        "id": "MiniMax_Intl",
        "name": "MiniMax (International)",
        "base_url": "https://api.minimax.io/anthropic",
        "default_model": "MiniMax-M2.1",
        "models": [
            "MiniMax-M2.1", "MiniMax-M2.5", "MiniMax-M2"
        ]
    },
    {
        "id": "MiniMax_CN",
        "name": "MiniMax (China)",
        "base_url": "https://api.minimaxi.com/anthropic",
        "default_model": "MiniMax-M2.1",
        "models": [
            "MiniMax-M2.1", "MiniMax-M2.5", "MiniMax-M2"
        ]
    },
    {
        "id": "Kimi",
        "name": "Kimi (Moonshot AI)",
        "base_url": "https://api.moonshot.cn/anthropic/",
        "default_model": "kimi-k2-turbo-preview",
        "models": [
            "kimi-k2-turbo-preview", "kimi-pro", "kimi-max"
        ]
    },
    {
        "id": "Anthropic",
        "name": "Anthropic Official",
        "base_url": "https://api.anthropic.com",
        "default_model": "claude-3-5-sonnet-20241022",
        "models": [
            "claude-3-5-sonnet-20241022", "claude-3-opus-20240229",
            "claude-3-sonnet-20240229", "claude-3-haiku-20240307"
        ]
    },
    {
        "id": "Fangzhou",
        "name": "Fangzhou (Ark)",
        "base_url": "https://ark.cn-beijing.volces.com/api/coding",
        "default_model": "ark-code-latest",
        "models": [
            "ark-code-latest", "doubao-seed-2.0-code", "doubao-seed-2.0-pro",
            "doubao-seed-2.0-lite", "doubao-seed-code", "minimax-m2.5",
            "glm-4.7", "deepseek-v3.2", "kimi-k2.5"
        ]
    },
    {
        "id": "Siliconflow",
        "name": "Siliconflow",
        "base_url": "https://api.siliconflow.cn/",
        "default_model": "Pro/MiniMaxAI/MiniMax-M2.5",
        "models": [
            "Pro/MiniMaxAI/MiniMax-M2.5", "Pro/zai-org/GLM-5",
            "Pro/moonshotai/Kimi-K2.5", "Pro/zai-org/GLM-4.7",
            "Pro/deepseek-ai/DeepSeek-V3.2", "Qwen/Qwen3.5-397B-A17B"
        ]
    },
    {
        "id": "DashScope",
        "name": "DashScope (Qwen)",
        "base_url": "https://coding.dashscope.aliyuncs.com/apps/anthropic",
        "default_model": "qwen3.5-plus",
        "models": [
            "qwen3.5-plus", "kimi-k2.5", "glm-5", "MiniMax-M2.5",
            "qwen3-max-2026-01-23", "qwen3-coder-next", "qwen3-coder-plus", "glm-4.7"
        ]
    },
    {
        "id": "Qianfan",
        "name": "Qianfan (Baidu)",
        "base_url": "https://qianfan.baidubce.com/anthropic/coding",
        "default_model": "qianfan-code-latest",
        "models": [
            "qianfan-code-latest", "kimi-k2.5", "deepseek-v3.2",
            "glm-5", "minimax-m2.5"
        ]
    },
    {
        "id": "PPChat",
        "name": "PPChat (Claude Code Proxy)",
        "base_url": "https://code.ppchat.vip",
        "default_model": "claude-sonnet-4-6",
        "models": [
            "claude-sonnet-4-6", "claude-opus-4-6", "claude-haiku-4-5"
        ]
    },
    {
        "id": "DashScope_Pay",
        "name": "DashScope Pay (Qwen)",
        "base_url": "https://dashscope.aliyuncs.com/apps/anthropic",
        "default_model": "qwen3.5-plus",
        "models": [
            "qwen3.5-plus", "kimi-k2.5", "glm-5", "MiniMax-M2.5",
            "qwen3-max-2026-01-23", "qwen3-coder-next", "qwen3-coder-plus", "glm-4.7"
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
        env = {
            "ANTHROPIC_AUTH_TOKEN": api_key,
            "ANTHROPIC_BASE_URL": provider["base_url"],
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": model,
            "ANTHROPIC_DEFAULT_SONNET_MODEL": model,
            "ANTHROPIC_DEFAULT_OPUS_MODEL": model
        }
        # Siliconflow 特殊配置
        if provider["id"] == "Siliconflow":
            env["CLAUDE_CODE_ADDITIONAL_REQUEST_BODY"] = '{"thinking":{"type":"enabled"}}'
        else:
            config["env"].pop("CLAUDE_CODE_ADDITIONAL_REQUEST_BODY", None)
        config["env"].update(env)
        with open(paths["settings_json"], "w", encoding="utf-8") as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        print_stderr(f"✅ 更新成功: {paths['settings_json']}")
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
    print(f"ANTHROPIC_DEFAULT_HAIKU_MODEL={model}")
    print(f"ANTHROPIC_DEFAULT_SONNET_MODEL={model}")
    print(f"ANTHROPIC_DEFAULT_OPUS_MODEL={model}")
    if provider["id"] == "Siliconflow":
        print('CLAUDE_CODE_ADDITIONAL_REQUEST_BODY={"thinking":{"type":"enabled"}}')
    print("##CC_ENV_END##")


if __name__ == "__main__":
    main()
