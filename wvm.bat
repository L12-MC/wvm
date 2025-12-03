@echo off
REM WVM Installer for Windows
REM Downloads and installs pre-built wslang and wpm executables

setlocal enabledelayedexpansion

echo ================================
echo WVM - Wslang and WPM Installer
echo ================================
echo.

REM Configuration
set "INSTALL_DIR=C:\Program Files\wvm"
set "BIN_DIR=%INSTALL_DIR%\bin"
set "TEMP_DIR=%INSTALL_DIR%\temp"

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: This script requires administrator privileges.
    echo Please right-click this file and select "Run as Administrator"
    pause
    exit /b 1
)

echo Installation directory: %INSTALL_DIR%
echo Binary directory: %BIN_DIR%
echo.

REM Remove existing installation
if exist "%INSTALL_DIR%" (
    echo Removing existing installation...
    rmdir /s /q "%INSTALL_DIR%" 2>nul
    echo + Cleaned up old installation
    echo.
)

REM Create directories
echo Setting up directories...
mkdir "%INSTALL_DIR%" 2>nul
mkdir "%BIN_DIR%" 2>nul
mkdir "%TEMP_DIR%" 2>nul

REM Determine latest release asset URLs via GitHub API

echo Resolving latest release for wslang...

set "WSLANG_URL=https://github.com/L12-MC/wslang/releases/latest/download/wslang.exe"

set "WPM_URL=https://github.com/L12-MC/wpm/releases/latest/download/wpm.exe"

echo Resolved wslang URL: %WSLANG_URL%
echo Resolved wpm URL: %WPM_URL%

echo Detected platform: Windows
echo.

REM Check for curl
where curl >nul 2>&1
if %errorLevel% equ 0 (
    set "HAS_CURL=1"
    echo Download tool: curl
) else (
    set "HAS_CURL=0"
    echo Download tool: PowerShell
)
echo.

REM Download wslang
echo --- Downloading wslang ---
echo URL: %WSLANG_URL%
if "!HAS_CURL!"=="1" (
    curl -L --progress-bar -o "%TEMP_DIR%\wslang.exe" "%WSLANG_URL%"
) else (
    powershell -Command "Invoke-WebRequest -Uri '%WSLANG_URL%' -OutFile '%TEMP_DIR%\wslang.exe'"
)

if exist "%TEMP_DIR%\wslang.exe" (
    move /Y "%TEMP_DIR%\wslang.exe" "%BIN_DIR%\wslang.exe" >nul
    echo + Installed wslang.exe
) else (
    echo X Failed to download wslang
)
echo.

REM Download wpm
echo --- Downloading wpm ---
echo URL: %WPM_URL%
if "!HAS_CURL!"=="1" (
    curl -L --progress-bar -o "%TEMP_DIR%\wpm.exe" "%WPM_URL%"
) else (
    powershell -Command "Invoke-WebRequest -Uri '%WPM_URL%' -OutFile '%TEMP_DIR%\wpm.exe'"
)

if exist "%TEMP_DIR%\wpm.exe" (
    move /Y "%TEMP_DIR%\wpm.exe" "%BIN_DIR%\wpm.exe" >nul
    echo + Installed wpm.exe
) else (
    echo X Failed to download wpm
)
echo.

REM Clean up
echo Cleaning up temporary files...
rmdir /s /q "%TEMP_DIR%" 2>nul
echo.

REM Add to PATH
echo Adding to system PATH...
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "CURRENT_PATH=%%b"

echo !CURRENT_PATH! | findstr /C:"%BIN_DIR%" >nul
if !errorLevel! equ 0 (
    echo + Already in PATH
) else (
    set "NEW_PATH=!CURRENT_PATH!;%BIN_DIR%"
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "!NEW_PATH!" /f >nul
    echo + Added to PATH
    echo.
    echo IMPORTANT: Restart your terminal for PATH changes to take effect
)
echo.

REM Display results
echo ================================
echo Installation Complete!
echo ================================
echo.
echo Installed to: %BIN_DIR%
echo.
echo Installed programs:
for %%f in ("%BIN_DIR%\*.exe") do echo   - %%~nxf
echo.
echo Usage:
echo   wslang.exe program.ws
echo   wpm.exe install package
echo.

pause
