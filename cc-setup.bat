﻿chcp 65001 >nul
@echo off
setlocal EnableDelayedExpansion

:: ============================================
:: Claude Code Complete Installation and Configuration Script for Windows
:: Includes: nvm-windows, Node.js LTS, Claude Code installation and API configuration
:: ============================================

cls

echo ========================================
echo Claude Code Complete Installation and Configuration Script
echo ========================================
echo.

:: Color output functions (implemented via PowerShell)
call :print_green "Part 1: Environment Check and Installation"
echo ========================================
echo.

:: --- Check admin privileges ---
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :print_yellow "Note: Running as administrator is recommended for nvm-windows installation"
    echo.
)

:: --- Check curl or PowerShell ---
where curl >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "DOWNLOAD_CMD=curl"
) else (
    where powershell >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "DOWNLOAD_CMD=powershell"
    ) else (
        call :print_red "Error: curl or PowerShell not found, cannot continue installation"
        pause
        exit /b 1
    )
)

:: --- Check nvm-windows ---
call :print_green "Checking nvm-windows..."
where nvm >nul 2>&1
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('nvm version 2^>nul') do set "NVM_VER=%%i"
    call :print_yellow "nvm-windows already installed: !NVM_VER!"
) else (
    call :print_green "Downloading nvm-windows..."
    set "NVM_INSTALLER=%TEMP%\nvm-setup.zip"

    if "!DOWNLOAD_CMD!"=="curl" (
        curl -L -o "!NVM_INSTALLER!" "https://github.com/coreybutler/nvm-windows/releases/download/1.2.2/nvm-setup.zip"
    ) else (
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/coreybutler/nvm-windows/releases/download/1.2.2/nvm-setup.zip' -OutFile '!NVM_INSTALLER!'"
    )

    if exist "!NVM_INSTALLER!" (
        call :print_green "Download complete: !NVM_INSTALLER!"
        call :print_yellow "Please run the installer manually to install nvm-windows"
        call :print_yellow "Run this script again after installation is complete"
        explorer.exe "%TEMP%"
        pause
        exit /b 0
    ) else (
        call :print_red "Download failed, please install nvm-windows manually"
        echo Download URL: https://github.com/coreybutler/nvm-windows/releases
        pause
        exit /b 1
    )
)

:: --- Install Node.js LTS ---
call :print_green "Checking/installing Node.js LTS..."

:: Ensure nvm is available
where nvm >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :print_red "nvm not properly installed or terminal needs restart"
    call :print_yellow "Please install nvm-windows and reopen terminal before running this script"
    pause
    exit /b 1
)

:: Install LTS version
nvm install lts
if %ERRORLEVEL% neq 0 (
    call :print_red "Node.js LTS installation failed"
    pause
    exit /b 1
)

:: Use LTS version
nvm use lts

:: Get version info
for /f "tokens=*" %%i in ('node --version 2^>nul') do set "NODE_VER=%%i"
for /f "tokens=*" %%i in ('npm --version 2^>nul') do set "NPM_VER=%%i"
for /f "tokens=*" %%i in ('where node 2^>nul') do set "NODE_PATH=%%i"

call :print_green "Node path: !NODE_PATH!"
call :print_green "Node version: !NODE_VER! | npm version: !NPM_VER!"

:: --- Install Claude Code ---
echo.
call :print_green "----------------------------------------"
where claude >nul 2>&1
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('claude --version 2^>nul') do set "CLAUDE_VER=%%i"
    call :print_yellow "Claude Code already installed: !CLAUDE_VER!"
    set /p "REINSTALL=Reinstall? (y/N): "
    if /i "!REINSTALL!"=="Y" (
        call :print_green "Updating Claude Code..."
        call npm install -g @anthropic-ai/claude-code@latest
    )
) else (
    call :print_green "Installing Claude Code..."
    call npm install -g @anthropic-ai/claude-code@latest
)

where claude >nul 2>&1
if %ERRORLEVEL% equ 0 (
    call :print_green "Claude Code installed successfully!"
) else (
    call :print_red "Claude Code installation failed, please check network connection or install manually"
    call :print_yellow "Manual installation: npm install -g @anthropic-ai/claude-code"
)

echo.
call :print_green "========================================"
call :print_green "Part 2: API Configuration"
call :print_green "========================================"
echo.

:: ============================================
:: Part 2: API Configuration
:: ============================================

:: --- Basic configuration file check and creation ---
set "CLAUDE_JSON=%USERPROFILE%\.claude.json"

if not exist "%CLAUDE_JSON%" (
    echo {"hasCompletedOnboarding": true} > "%CLAUDE_JSON%"
    echo Created base configuration file: %CLAUDE_JSON%
) else (
    echo Base configuration file exists: %CLAUDE_JSON%
)

echo.
echo Please select your API provider:
echo   1. Zhipu AI (GLM)
echo   2. MiniMax (International)
echo   3. MiniMax (China)
echo   4. Kimi (Moonshot AI)
echo   5. Anthropic Official
echo   6. Fangzhou (Ark)
echo   7. Siliconflow
echo   8. DashScope (Qwen)
echo   9. Qianfan (Baidu)
echo.

:: Read user choice
set /p "CHOICE=Enter your choice [1-9]: "

:: --- Set variables based on selection ---
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
) else (
    echo Invalid selection.
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

:: API Key input
echo.
echo Please enter your API Key:

:: Try to read default API Key from existing config
set "DEFAULT_KEY="
if exist "%CLAUDE_JSON%" (
    for /f "tokens=2 delims=:" %%a in ('findstr /C:"anthropic_api_key" "%CLAUDE_JSON%" 2^>nul') do (
        set "line=%%a"
        set "line=!line:"=!"
        set "line=!line: =!"
        set "line=!line:,=!"
        set "DEFAULT_KEY=!line!"
    )
)

if defined DEFAULT_KEY (
    set /p "INPUT_KEY=API Key [default: !DEFAULT_KEY!]: "
    if "!INPUT_KEY!"=="" (
        set "API_KEY=!DEFAULT_KEY!"
    ) else (
        set "API_KEY=!INPUT_KEY!"
    )
) else (
    set /p "API_KEY=API Key: "
)

:: If still empty, use hardcoded fallback value
if not defined API_KEY (
    echo Warning: No API Key provided. Using fallback key.
    set "API_KEY=bcff1f1c1afb408e9fd3f2791d20793b.kqjL0iiOg1zRTf57"
)

echo.
echo Using API Key: %API_KEY:~0,10%...%API_KEY:~-4%

:: Primary API Key input (for ~/.claude/config.json)
echo.
echo Please enter your Primary API Key (for config.json):
set "CONFIG_JSON_PATH=%USERPROFILE%\.claude\config.json"
set "DEFAULT_PRIMARY_KEY="
if exist "%CONFIG_JSON_PATH%" (
    for /f "tokens=2 delims=:" %%a in ('findstr /C:"primaryApiKey" "%CONFIG_JSON_PATH%" 2^>nul') do (
        set "line=%%a"
        set "line=!line:"=!"
        set "line=!line: =!"
        set "line=!line:,=!"
        set "DEFAULT_PRIMARY_KEY=!line!"
    )
)

if defined DEFAULT_PRIMARY_KEY (
    set /p "INPUT_PRIMARY_KEY=Primary API Key [default: !DEFAULT_PRIMARY_KEY!]: "
    if "!INPUT_PRIMARY_KEY!"=="" (
        set "PRIMARY_API_KEY=!DEFAULT_PRIMARY_KEY!"
    ) else (
        set "PRIMARY_API_KEY=!INPUT_PRIMARY_KEY!"
    )
) else (
    set /p "PRIMARY_API_KEY=Primary API Key: "
)

:: If empty, use API_KEY as fallback
if not defined PRIMARY_API_KEY (
    echo Warning: No Primary API Key provided. Using API Key as fallback.
    set "PRIMARY_API_KEY=%API_KEY%"
)

echo.
echo Using Primary API Key: %PRIMARY_API_KEY:~0,10%...%PRIMARY_API_KEY:~-4%
echo.

echo WARNING: This will update the API configuration!
set /p "CONFIRM=Continue? (Y/N): "

:: Convert to uppercase and judge
if /i not "%CONFIRM%"=="Y" (
    echo Configuration cancelled.
    pause
    exit /b 0
)

:: --- Use Python to merge and update config files ---
echo Updating configuration files...

:: Define config file paths (needed before Python script creation)
set "SETTINGS_JSON=%USERPROFILE%\.claude\settings.json"
set "CONFIG_JSON=%USERPROFILE%\.claude\config.json"

:: Check if Python is available
where python >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "PYTHON_CMD=python"
    goto :python_found_setup
)
where python3 >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "PYTHON_CMD=python3"
    goto :python_found_setup
)
set "PYTHON_CMD="
goto :update_configs_setup

:python_found_setup
:: Create temp Python script for updating configs
set "TEMP_PYTHON=%TEMP%\claude_config_update_setup.py"
echo import sys, json, os > "%TEMP_PYTHON%"
echo sys.stdout.reconfigure(encoding='utf-8') >> "%TEMP_PYTHON%"
echo. >> "%TEMP_PYTHON%"
echo # Update .claude.json >> "%TEMP_PYTHON%"
echo claude_json_path = r'%CLAUDE_JSON%' >> "%TEMP_PYTHON%"
echo new_config = { >> "%TEMP_PYTHON%"
echo     'anthropic_api_key': r'%API_KEY%', >> "%TEMP_PYTHON%"
echo     'anthropic_base_url': r'!BASE_URL!', >> "%TEMP_PYTHON%"
echo     'model': r'!MODEL!', >> "%TEMP_PYTHON%"
echo     'provider': r'!PROVIDER!', >> "%TEMP_PYTHON%"
echo     'hasCompletedOnboarding': True >> "%TEMP_PYTHON%"
echo } >> "%TEMP_PYTHON%"
echo if os.path.exists(claude_json_path): >> "%TEMP_PYTHON%"
echo     with open(claude_json_path, 'r', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo         existing_config = json.load(f) >> "%TEMP_PYTHON%"
echo else: >> "%TEMP_PYTHON%"
echo     existing_config = {} >> "%TEMP_PYTHON%"
echo existing_config.update(new_config) >> "%TEMP_PYTHON%"
echo with open(claude_json_path, 'w', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo     json.dump(existing_config, f, indent=2, ensure_ascii=False) >> "%TEMP_PYTHON%"
echo print('Updated:', claude_json_path) >> "%TEMP_PYTHON%"
echo. >> "%TEMP_PYTHON%"
echo # Update settings.json >> "%TEMP_PYTHON%"
echo settings_path = r'%USERPROFILE%\.claude\settings.json' >> "%TEMP_PYTHON%"
echo os.makedirs(os.path.dirname(settings_path), exist_ok=True) >> "%TEMP_PYTHON%"
echo if not os.path.exists(settings_path): >> "%TEMP_PYTHON%"
echo     with open(settings_path, 'w', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo         json.dump({}, f) >> "%TEMP_PYTHON%"
echo with open(settings_path, 'r', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo     settings = json.load(f) >> "%TEMP_PYTHON%"
echo if 'env' not in settings: >> "%TEMP_PYTHON%"
echo     settings['env'] = {} >> "%TEMP_PYTHON%"
echo new_env = { >> "%TEMP_PYTHON%"
echo     'ANTHROPIC_AUTH_TOKEN': r'%API_KEY%', >> "%TEMP_PYTHON%"
echo     'ANTHROPIC_BASE_URL': r'!BASE_URL!', >> "%TEMP_PYTHON%"
echo     'ANTHROPIC_DEFAULT_HAIKU_MODEL': r'!MODEL!', >> "%TEMP_PYTHON%"
echo     'ANTHROPIC_DEFAULT_SONNET_MODEL': r'!MODEL!', >> "%TEMP_PYTHON%"
echo     'ANTHROPIC_DEFAULT_OPUS_MODEL': r'!MODEL!' >> "%TEMP_PYTHON%"
echo } >> "%TEMP_PYTHON%"
echo if r'%CHOICE%' == '7': >> "%TEMP_PYTHON%"
echo     new_env['CLAUDE_CODE_ADDITIONAL_REQUEST_BODY'] = '{"thinking":{"type":"enabled"}}' >> "%TEMP_PYTHON%"
echo else: >> "%TEMP_PYTHON%"
echo     settings['env'].pop('CLAUDE_CODE_ADDITIONAL_REQUEST_BODY', None) >> "%TEMP_PYTHON%"
echo settings['env'].update(new_env) >> "%TEMP_PYTHON%"
echo with open(settings_path, 'w', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo     json.dump(settings, f, indent=2, ensure_ascii=False) >> "%TEMP_PYTHON%"
echo print('Updated:', settings_path) >> "%TEMP_PYTHON%"
echo. >> "%TEMP_PYTHON%"
echo # Update config.json >> "%TEMP_PYTHON%"
echo config_path = r'%USERPROFILE%\.claude\config.json' >> "%TEMP_PYTHON%"
echo os.makedirs(os.path.dirname(config_path), exist_ok=True) >> "%TEMP_PYTHON%"
echo if not os.path.exists(config_path): >> "%TEMP_PYTHON%"
echo     with open(config_path, 'w', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo         json.dump({}, f) >> "%TEMP_PYTHON%"
echo with open(config_path, 'r', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo     config = json.load(f) >> "%TEMP_PYTHON%"
echo config['primaryApiKey'] = r'%PRIMARY_API_KEY%' >> "%TEMP_PYTHON%"
echo with open(config_path, 'w', encoding='utf-8') as f: >> "%TEMP_PYTHON%"
echo     json.dump(config, f, indent=2, ensure_ascii=False) >> "%TEMP_PYTHON%"
echo print('Updated:', config_path) >> "%TEMP_PYTHON%"

:: Run the Python script
%PYTHON_CMD% "%TEMP_PYTHON%"
if %ERRORLEVEL% equ 0 (
    echo Configuration files updated successfully!
) else (
    echo Error updating configuration files
)
del "%TEMP_PYTHON%" 2>nul
goto :config_complete_setup

:update_configs_setup
:: Fallback: Python not found
echo Warning: Python not found. Using fallback update.
(
    echo {
    echo   "anthropic_api_key": "%API_KEY%",
    echo   "anthropic_base_url": "!BASE_URL!",
    echo   "model": "!MODEL!",
    echo   "provider": "!PROVIDER!",
    echo   "hasCompletedOnboarding": true
    echo }
) > "%CLAUDE_JSON%"
echo Configuration file updated: %CLAUDE_JSON%

:: Also create/update settings.json and config.json in fallback mode
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
if not exist "%SETTINGS_JSON%" echo {} > "%SETTINGS_JSON%"
(
    echo {
    echo   "primaryApiKey": "%PRIMARY_API_KEY%"
    echo }
) > "%CONFIG_JSON%"
echo Fallback update completed for settings.json and config.json

:config_complete_setup
echo.
call :print_green "========================================"
call :print_green "Installation and Configuration Complete!"
call :print_green "========================================"
call :print_green "Provider: !PROVIDER!"
call :print_green "Model: !MODEL!"
call :print_green "========================================"
echo.
call :print_yellow "Note: If nvm command is not available, please:"
call :print_yellow "  1. Reopen terminal (run as administrator)"
call :print_yellow "  2. Or restart computer to apply environment variables"
echo.

echo Starting Claude Code with !PROVIDER! settings...
echo ================================================================
echo.

pause

:: Set the environment variables and start claude
set "ANTHROPIC_API_KEY=%API_KEY%"
set "ANTHROPIC_BASE_URL=!BASE_URL!"
claude

:: ============================================
:: Color output functions
:: ============================================
:print_green
powershell -Command "Write-Host '%~1' -ForegroundColor Green"
goto :eof

:print_yellow
powershell -Command "Write-Host '%~1' -ForegroundColor Yellow"
goto :eof

:print_red
powershell -Command "Write-Host '%~1' -ForegroundColor Red"
goto :eof

:print_blue
powershell -Command "Write-Host '%~1' -ForegroundColor Blue"
goto :eof