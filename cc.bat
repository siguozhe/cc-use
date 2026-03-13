@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

cls

echo ========================================
echo Claude Code Configuration Script
echo ========================================

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "CC_CONFIG=%SCRIPT_DIR%cc-config.py"

:: 检查 cc-config.py 是否存在
if not exist "%CC_CONFIG%" (
    echo ❌ Error: cc-config.py not found
    echo    Expected location: %CC_CONFIG%
    pause
    exit /b 1
)

:: 查找 Python
set "PYTHON_CMD="
where python >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "PYTHON_CMD=python"
) else (
    where python3 >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "PYTHON_CMD=python3"
    )
)

if not defined PYTHON_CMD (
    goto :fallback_mode
)

:: 检查 Python 是否能运行
%PYTHON_CMD% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Error: Python execution failed
    pause
    exit /b 1
)

:: 运行 cc-config.py
:: stderr 给用户看交互提示，stdout 的环境变量块重定向到文件
set "TEMP_ENV=%TEMP%\claude-env.txt"
%PYTHON_CMD% "%CC_CONFIG%" > "%TEMP_ENV%"

:: 检查是否成功获取环境变量
findstr "##CC_ENV_START##" "%TEMP_ENV%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo.
    echo Configuration not completed
    del "%TEMP_ENV%" 2>nul
    pause
    exit /b 1
)

:: 解析环境变量
set "ANTHROPIC_API_KEY="
set "ANTHROPIC_BASE_URL="
set "ANTHROPIC_DEFAULT_HAIKU_MODEL="
set "ANTHROPIC_DEFAULT_SONNET_MODEL="
set "ANTHROPIC_DEFAULT_OPUS_MODEL="
set "CLAUDE_CODE_ADDITIONAL_REQUEST_BODY="

for /f "tokens=1,* delims==" %%a in ('findstr "ANTHROPIC" "%TEMP_ENV%"') do (
    set "%%a=%%b"
)
for /f "tokens=1,* delims==" %%a in ('findstr "CLAUDE" "%TEMP_ENV%"') do (
    set "%%a=%%b"
)

del "%TEMP_ENV%" 2>nul

:: 检查是否有配置
if not defined ANTHROPIC_API_KEY (
    echo.
    echo ❌ Error: No valid configuration obtained
    pause
    exit /b 1
)

echo.
echo ========================================
echo Starting Claude Code...
echo ========================================
echo.

:: 启动 Claude Code
claude

pause
exit /b 0

:: ============================================
:: 降级模式：无 Python 时的简单配置
:: ============================================
:fallback_mode
echo.
echo ⚠️  Warning: Python not found, entering fallback mode
echo.
echo Fallback mode limitations:
echo   - No API Key caching
echo   - No multiple model selection
echo   - No last used memory
echo.
echo Recommend installing Python for full functionality:
echo   Download: https://www.python.org/downloads/
echo.
set /p "CONFIRM_FALLBACK=Continue with fallback mode? (y/N): "
if /i not "!CONFIRM_FALLBACK!"=="Y" (
    echo Configuration cancelled
    pause
    exit /b 0
)
echo.
echo Starting fallback configuration mode...
echo.
echo Please select API provider:
echo   1. Zhipu AI (GLM)
echo   2. MiniMax (International)
echo   3. MiniMax (China)
echo   4. Kimi (Moonshot AI)
echo   5. Anthropic Official
echo   6. Fangzhou (Ark)
echo   7. Siliconflow
echo   8. DashScope (Qwen)
echo   9. Qianfan (Baidu)
echo   10. PPChat (Claude Code Proxy)
echo   11. DashScope Pay (Qwen)
echo.
set /p "CHOICE=Enter your choice [1-11]: "

:: 根据选择设置变量
if "%CHOICE%"=="1" (
    set "PROVIDER=ZhipuAI"
    set "BASE_URL=https://open.bigmodel.cn/api/anthropic"
    set "MODEL=glm-4.7"
) else if "%CHOICE%"=="2" (
    set "PROVIDER=MiniMax_Intl"
    set "BASE_URL=https://api.minimax.io/anthropic"
    set "MODEL=MiniMax-M2.1"
) else if "%CHOICE%"=="3" (
    set "PROVIDER=MiniMax_CN"
    set "BASE_URL=https://api.minimaxi.com/anthropic"
    set "MODEL=MiniMax-M2.1"
) else if "%CHOICE%"=="4" (
    set "PROVIDER=Kimi"
    set "BASE_URL=https://api.moonshot.cn/anthropic/"
    set "MODEL=kimi-k2-turbo-preview"
) else if "%CHOICE%"=="5" (
    set "PROVIDER=Anthropic"
    set "BASE_URL=https://api.anthropic.com"
    set "MODEL=claude-3-5-sonnet-20241022"
) else if "%CHOICE%"=="6" (
    set "PROVIDER=Fangzhou"
    set "BASE_URL=https://ark.cn-beijing.volces.com/api/coding"
    set "MODEL=ark-code-latest"
) else if "%CHOICE%"=="7" (
    set "PROVIDER=Siliconflow"
    set "BASE_URL=https://api.siliconflow.cn/"
    set "MODEL=Pro/MiniMaxAI/MiniMax-M2.5"
) else if "%CHOICE%"=="8" (
    set "PROVIDER=DashScope"
    set "BASE_URL=https://coding.dashscope.aliyuncs.com/apps/anthropic"
    set "MODEL=qwen3.5-plus"
) else if "%CHOICE%"=="9" (
    set "PROVIDER=Qianfan"
    set "BASE_URL=https://qianfan.baidubce.com/anthropic/coding"
    set "MODEL=qianfan-code-latest"
) else if "%CHOICE%"=="10" (
    set "PROVIDER=PPChat"
    set "BASE_URL=https://code.ppchat.vip"
    set "MODEL=claude-sonnet-4-6"
) else if "%CHOICE%"=="11" (
    set "PROVIDER=DashScope_Pay"
    set "BASE_URL=https://dashscope.aliyuncs.com/apps/anthropic"
    set "MODEL=qwen3.5-plus"
) else (
    echo Invalid choice
    pause
    exit /b 1
)

echo.
echo ========================================
echo Configuration Summary
echo ========================================
echo Provider: !PROVIDER!
echo Base URL: !BASE_URL!
echo Model: !MODEL!
echo ========================================

:: API Key 输入
echo.
set /p "API_KEY=Enter API Key: "
if "!API_KEY!"=="" (
    echo ❌ API Key cannot be empty
    pause
    exit /b 1
)

:: Primary API Key 输入
echo.
set /p "PRIMARY_API_KEY=Enter Primary API Key: "
if "!PRIMARY_API_KEY!"=="" (
    set "PRIMARY_API_KEY=!API_KEY!"
)

echo.
set /p "CONFIRM=Continue? (Y/N): "
if /i not "!CONFIRM!"=="Y" (
    echo Configuration cancelled
    pause
    exit /b 1
)

:: 直接覆盖配置文件
set "CLAUDE_JSON=%USERPROFILE%\.claude.json"
set "SETTINGS_JSON=%USERPROFILE%\.claude\settings.json"
set "CONFIG_JSON=%USERPROFILE%\.claude\config.json"
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"

:: 更新 .claude.json
(
    echo {
    echo   "anthropic_api_key": "!API_KEY!",
    echo   "anthropic_base_url": "!BASE_URL!",
    echo   "model": "!MODEL!",
    echo   "provider": "!PROVIDER!",
    echo   "hasCompletedOnboarding": true
    echo }
) > "!CLAUDE_JSON!"
echo Configuration file updated: !CLAUDE_JSON!

:: 更新 settings.json
(
    echo {
    echo   "env": {
    echo     "ANTHROPIC_AUTH_TOKEN": "!API_KEY!",
    echo     "ANTHROPIC_BASE_URL": "!BASE_URL!",
    echo     "ANTHROPIC_DEFAULT_HAIKU_MODEL": "!MODEL!",
    echo     "ANTHROPIC_DEFAULT_SONNET_MODEL": "!MODEL!",
    echo     "ANTHROPIC_DEFAULT_OPUS_MODEL": "!MODEL!"
    echo   }
    echo }
) > "!SETTINGS_JSON!"

:: Siliconflow 的特殊处理需要 Python，降级模式忽略此参数
echo Settings file updated: !SETTINGS_JSON!

:: 更新 config.json
(
    echo {
    echo   "primaryApiKey": "!PRIMARY_API_KEY!"
    echo }
) > "!CONFIG_JSON!"
echo Config file updated: !CONFIG_JSON!

:: 设置环境变量并启动
set "ANTHROPIC_API_KEY=!API_KEY!"
set "ANTHROPIC_BASE_URL=!BASE_URL!"
echo.
echo ========================================
echo Starting Claude Code...
echo ========================================
echo.
pause
cls
claude
pause
