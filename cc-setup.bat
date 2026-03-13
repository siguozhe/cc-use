chcp 65001 >nul
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

:: --- Check environment dependencies ---
call :print_green "Checking environment dependencies..."

:: Check git
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :print_yellow "Git not found. It is recommended to install git for better experience"
    call :print_yellow "Download from: https://git-scm.com/downloads"
    echo.
) else (
    for /f "tokens=*" %%i in ('git --version 2^>nul') do (
        call :print_yellow "Git found: %%i"
    )
)

:: Check Python
set "PYTHON_CMD="
where python >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "PYTHON_CMD=python"
    for /f "tokens=*" %%i in ('python --version 2^>nul') do (
        call :print_yellow "Python found: %%i"
    )
) else (
    where python3 >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "PYTHON_CMD=python3"
        for /f "tokens=*" %%i in ('python3 --version 2^>nul') do (
            call :print_yellow "Python3 found: %%i"
        )
    ) else (
        call :print_yellow "Python not found. You can still use basic features"
        call :print_yellow "Download from: https://www.python.org/downloads/"
    )
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

:: Install LTS version with multiple sources fallback
call :print_green "Attempting to install Node.js LTS from official source..."
nvm install lts
if %ERRORLEVEL% equ 0 (
    call :print_green "Node.js LTS installed successfully from official source"
) else (
    call :print_yellow "Official source failed, trying Taobao mirror..."
    nvm node_mirror https://npmmirror.com/mirrors/node/
    nvm npm_mirror https://npmmirror.com/mirrors/npm/
    nvm install lts
    if %ERRORLEVEL% equ 0 (
        call :print_green "Node.js LTS installed successfully from Taobao mirror"
    ) else (
        call :print_yellow "Taobao mirror failed, trying Huawei Cloud mirror..."
        nvm node_mirror https://repo.huaweicloud.com/nodejs/
        nvm npm_mirror https://repo.huaweicloud.com/npm/
        nvm install lts
        if %ERRORLEVEL% equ 0 (
            call :print_green "Node.js LTS installed successfully from Huawei Cloud mirror"
        ) else (
            call :print_yellow "Huawei Cloud mirror failed, trying USTC mirror..."
            nvm node_mirror https://mirrors.ustc.edu.cn/nodejs-release/
            nvm npm_mirror https://mirrors.ustc.edu.cn/npm/
            nvm install lts
            if %ERRORLEVEL% equ 0 (
                call :print_green "Node.js LTS installed successfully from USTC mirror"
            ) else (
                call :print_red "All installation sources failed!"
                call :print_yellow "Please check your network connection or install Node.js manually"
                pause
                exit /b 1
            )
        )
    )
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

:: 检查 cc-config.py 是否存在
set "CC_CONFIG=%~dp0cc-config.py"
if exist "%CC_CONFIG%" (
    call :print_green "Using cc-config.py for configuration..."
    echo.

    :: 检查 Python 是否可用
    set "PYTHON_CMD="
    where python >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        set "PYTHON_CMD=python"
        goto :run_config
    )
    where python3 >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        set "PYTHON_CMD=python3"
        goto :run_config
    )
    call :print_yellow "Python not found, skipping configuration"
    call :print_yellow "Please run cc.bat for configuration"
    goto :install_complete
)

:run_config
:: 运行 cc-config.py
set "TEMP_ENV=%TEMP%\claude-env.txt"
%PYTHON_CMD% "%CC_CONFIG%" 2>&1 | findstr /v "##CC_ENV_START##" | findstr /v "##CC_ENV_END##"
%PYTHON_CMD% "%CC_CONFIG%" 2>nul | findstr /r "##CC_ENV_START##\|##CC_ENV_END##\|=" > "%TEMP_ENV%"

:: 检查是否成功获取环境变量
findstr "##CC_ENV_START##" "%TEMP_ENV%" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo.
    call :print_green "========================================"
    call :print_green "Installation and Configuration Complete!"
    call :print_green "========================================"
    echo.
    call :print_yellow "Note: For nvm to work in new terminals, please:"
    call :print_yellow "  1. Reopen terminal"
    call :print_yellow "  2. Or restart computer"
    echo.
    echo Starting Claude Code...
    echo ================================================================
    echo.
    pause
    cls
    :: 解析环境变量
    set "ANTHROPIC_API_KEY="
    for /f "tokens=1,* delims==" %%a in ('findstr "ANTHROPIC" "%TEMP_ENV%"') do (
        set "%%a=%%b"
    )
    if defined ANTHROPIC_API_KEY (
        set "ANTHROPIC_BASE_URL="
        for /f "tokens=1,* delims==" %%a in ('findstr "ANTHROPIC_BASE_URL" "%TEMP_ENV%"') do (
            set "%%a=%%b"
        )
        set "ANTHROPIC_API_KEY=!ANTHROPIC_API_KEY!"
        set "ANTHROPIC_BASE_URL=!ANTHROPIC_BASE_URL!"
        claude
    )
    del "%TEMP_ENV%" 2>nul
    exit /b 0
) else (
    del "%TEMP_ENV%" 2>nul
    call :print_red "cc-config.py configuration not completed"
)

:install_complete
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
