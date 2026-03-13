chcp 65001 >nul
@echo off
setlocal EnableDelayedExpansion

:: ============================================
:: Claude Code 完整安装与配置脚本 (Windows)
:: 安装优先级：Node.js（必须）> Python（强烈建议）> nvm（可选，仅当 Node.js 未安装时使用）
:: ============================================

cls

echo ========================================
echo Claude Code Installation ^& Configuration
echo ========================================
echo.

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "CC_CONFIG=%SCRIPT_DIR%cc-config.py"

:: ============================================
:: 第一部分：环境检查
:: ============================================

call :print_blue "========================================"
call :print_blue "Part 1: Environment Check"
call :print_blue "========================================"
echo.

:: --- 检查管理员权限 ---
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :print_yellow "Note: Running as administrator is recommended for nvm-windows installation"
    echo.
)

:: --- 检查下载工具 ---
call :print_green "Checking download tools..."
set "DOWNLOAD_CMD="
where curl >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "DOWNLOAD_CMD=curl"
    call :print_yellow "curl found"
) else (
    where powershell >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "DOWNLOAD_CMD=powershell"
        call :print_yellow "PowerShell found (will use as download tool)"
    ) else (
        call :print_red "Error: Neither curl nor PowerShell found, cannot continue"
        pause
        exit /b 1
    )
)

:: --- 检查 git ---
call :print_green "Checking git..."
where git >nul 2>&1
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('git --version 2^>nul') do (
        call :print_yellow "git found: %%i"
    )
) else (
    call :print_yellow "Warning: git not found"
    call :print_yellow "  Recommended: https://git-scm.com/downloads"
)
echo.

:: ============================================
:: 第二部分：Node.js 检测与安装（必须）
:: 优先检测系统已有的 Node.js，没有才通过 nvm 安装
:: ============================================

call :print_blue "========================================"
call :print_blue "Part 2: Node.js (Required)"
call :print_blue "========================================"
echo.

set "NODE_READY=0"

:: 先检查系统是否已有 Node.js
where node >nul 2>&1
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('node --version 2^>nul') do set "NODE_VER=%%i"
    :: 提取主版本号，检查是否 >= 18
    set "NODE_VER_NUM=!NODE_VER:v=!"
    for /f "tokens=1 delims=." %%a in ("!NODE_VER_NUM!") do set "NODE_MAJOR=%%a"
    if !NODE_MAJOR! GEQ 18 (
        call :print_green "Node.js found: !NODE_VER! (meets requirement >= v18)"
        for /f "tokens=*" %%i in ('npm --version 2^>nul') do (
            call :print_yellow "npm version: %%i"
        )
        set "NODE_READY=1"
    ) else (
        call :print_yellow "Node.js found: !NODE_VER! (too old, need >= v18)"
    )
)

:: 如果系统没有合适的 Node.js，通过 nvm-windows 安装
if !NODE_READY! equ 0 (
    call :print_yellow "Node.js >= v18 not found, will install via nvm-windows..."
    echo.

    :: --- 检查/安装 nvm-windows ---
    call :print_green "Checking nvm-windows..."
    where nvm >nul 2>&1
    if !ERRORLEVEL! equ 0 (
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
            call :print_yellow "Then run this script again after installation"
            explorer.exe "%TEMP%"
            pause
            exit /b 0
        ) else (
            call :print_red "Download failed"
            call :print_yellow "Please install Node.js manually: https://nodejs.org/"
            call :print_yellow "Or install nvm-windows: https://github.com/coreybutler/nvm-windows/releases"
            pause
            exit /b 1
        )
    )

    :: --- 通过 nvm 安装 Node.js LTS ---
    call :print_green "Installing Node.js LTS via nvm..."

    :: 先尝试官方源
    nvm install lts
    if !ERRORLEVEL! equ 0 (
        call :print_green "Node.js LTS installed from official source"
        goto :nvm_node_done
    )

    :: 尝试淘宝镜像
    call :print_yellow "Official source failed, trying Taobao mirror..."
    nvm node_mirror https://npmmirror.com/mirrors/node/
    nvm npm_mirror https://npmmirror.com/mirrors/npm/
    nvm install lts
    if !ERRORLEVEL! equ 0 (
        call :print_green "Node.js LTS installed from Taobao mirror"
        goto :nvm_node_done
    )

    :: 尝试华为云镜像
    call :print_yellow "Taobao mirror failed, trying Huawei Cloud mirror..."
    nvm node_mirror https://repo.huaweicloud.com/nodejs/
    nvm npm_mirror https://repo.huaweicloud.com/npm/
    nvm install lts
    if !ERRORLEVEL! equ 0 (
        call :print_green "Node.js LTS installed from Huawei Cloud mirror"
        goto :nvm_node_done
    )

    :: 尝试中科大镜像
    call :print_yellow "Huawei Cloud mirror failed, trying USTC mirror..."
    nvm node_mirror https://mirrors.ustc.edu.cn/nodejs-release/
    nvm npm_mirror https://mirrors.ustc.edu.cn/npm/
    nvm install lts
    if !ERRORLEVEL! equ 0 (
        call :print_green "Node.js LTS installed from USTC mirror"
        goto :nvm_node_done
    )

    :: 所有源都失败
    call :print_red "All installation sources failed!"
    call :print_yellow "Please install Node.js manually: https://nodejs.org/"
    pause
    exit /b 1

    :nvm_node_done
    nvm use lts
    set "NODE_READY=1"
)

:: 最终验证 Node.js
where node >nul 2>&1
if !ERRORLEVEL! neq 0 (
    call :print_red "Error: Node.js is required but not available"
    call :print_yellow "Please install Node.js (>= v18): https://nodejs.org/"
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version 2^>nul') do set "NODE_VER=%%i"
for /f "tokens=*" %%i in ('npm --version 2^>nul') do set "NPM_VER=%%i"
for /f "tokens=*" %%i in ('where node 2^>nul') do set "NODE_PATH=%%i"
call :print_green "Node path: !NODE_PATH!"
call :print_green "Node: !NODE_VER! | npm: !NPM_VER!"
echo.

:: ============================================
:: 第三部分：Python 检测（强烈建议）
:: Python 用于 cc-config.py 高级配置功能
:: ============================================

call :print_blue "========================================"
call :print_blue "Part 3: Python (Strongly Recommended)"
call :print_blue "========================================"
echo.

set "PYTHON_CMD="
where python >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "PYTHON_CMD=python"
    for /f "tokens=*" %%i in ('python --version 2^>nul') do (
        call :print_green "Python found: %%i"
    )
) else (
    where python3 >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "PYTHON_CMD=python3"
        for /f "tokens=*" %%i in ('python3 --version 2^>nul') do (
            call :print_green "Python3 found: %%i"
        )
    ) else (
        call :print_yellow "Warning: Python not found"
        call :print_yellow "  Python is strongly recommended for full configuration features"
        call :print_yellow "  (API key caching, multiple model selection, last used memory)"
        call :print_yellow "  Download: https://www.python.org/downloads/"
        echo.
        call :print_yellow "You can still proceed, but configuration will be limited."
    )
)
echo.

:: ============================================
:: 第四部分：安装 Claude Code
:: ============================================

call :print_blue "========================================"
call :print_blue "Part 4: Install Claude Code"
call :print_blue "========================================"
echo.

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
    call :print_red "Claude Code installation failed, please check network or install manually"
    call :print_yellow "  Manual: npm install -g @anthropic-ai/claude-code"
)
echo.

:: ============================================
:: 第五部分：API 配置
:: 优先使用 cc-config.py（需要 Python），否则提示用 cc.bat
:: ============================================

call :print_blue "========================================"
call :print_blue "Part 5: API Configuration"
call :print_blue "========================================"
echo.

:: 检查 cc-config.py 和 Python 是否都可用
if not exist "%CC_CONFIG%" (
    call :print_yellow "cc-config.py not found, skipping advanced configuration"
    call :print_yellow "Please run cc.bat for API configuration"
    goto :install_complete
)

if not defined PYTHON_CMD (
    call :print_yellow "Python not available, skipping advanced configuration"
    call :print_yellow "Install Python for full features, then run cc.bat"
    goto :install_complete
)

:: 检查 Python 是否能运行
%PYTHON_CMD% --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :print_yellow "Python execution failed, skipping advanced configuration"
    goto :install_complete
)

call :print_green "Using cc-config.py for configuration..."
echo.

:: 运行 cc-config.py 一次：stderr 显示给用户（交互提示），stdout 捕获环境变量
set "TEMP_ENV=%TEMP%\claude-env.txt"
%PYTHON_CMD% "%CC_CONFIG%" > "%TEMP_ENV%"

:: 检查是否成功获取环境变量
findstr "##CC_ENV_START##" "%TEMP_ENV%" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    :: 解析环境变量
    set "ANTHROPIC_API_KEY="
    set "ANTHROPIC_BASE_URL="
    for /f "tokens=1,* delims==" %%a in ('findstr "ANTHROPIC" "%TEMP_ENV%"') do (
        set "%%a=%%b"
    )
    for /f "tokens=1,* delims==" %%a in ('findstr "CLAUDE" "%TEMP_ENV%"') do (
        set "%%a=%%b"
    )
    del "%TEMP_ENV%" 2>nul

    if defined ANTHROPIC_API_KEY (
        echo.
        call :print_green "========================================"
        call :print_green "Installation ^& Configuration Complete!"
        call :print_green "========================================"
        echo.
        call :print_yellow "Note: If nvm was installed, please reopen terminal for it to take effect"
        echo.
        echo Starting Claude Code...
        echo ================================================================
        echo.
        pause
        cls
        claude
        pause
        exit /b 0
    ) else (
        call :print_red "Error: No valid configuration obtained"
    )
) else (
    del "%TEMP_ENV%" 2>nul
    call :print_red "cc-config.py configuration not completed"
)

:install_complete
echo.
call :print_green "========================================"
call :print_green "Installation Complete!"
call :print_green "========================================"
echo.
call :print_yellow "Please run cc.bat for API configuration"
echo.
pause
exit /b 0

:: ============================================
:: 颜色输出函数
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
