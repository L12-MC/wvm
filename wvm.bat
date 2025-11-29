@echo off
REM WVM Installer for Windows
REM Clones, builds, and installs wslang and wpm

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
    echo Please run as administrator.
    pause
    exit /b 1
)

echo Installation directory: %INSTALL_DIR%
echo Binary directory: %BIN_DIR%
echo.

REM Remove existing installation for clean install
if exist "%INSTALL_DIR%" (
    echo Removing existing installation...
    rmdir /s /q "%INSTALL_DIR%"
    echo + Cleaned up old installation
)

REM Create directories
echo Setting up directories...
mkdir "%BIN_DIR%"
mkdir "%TEMP_DIR%"

REM Repositories
set repos[0].name=wslang
set repos[0].url=https://github.com/L12-MC/wslang.git
set repos[1].name=wpm
set repos[1].url=https://github.com/L12-MC/wpm.git

REM Process each repository
for /L %%i in (0,1,1) do (
    echo.
    echo --- Processing !repos[%%i].name! ---
    
    set "repo_name=!repos[%%i].name!"
    set "repo_url=!repos[%%i].url!"
    set "repo_dir=%TEMP_DIR%\!repo_name!"
    
    REM Clone repository (fetch latest version)
    echo Cloning latest version of !repo_name! from !repo_url!...
    git clone --depth 1 --branch main "!repo_url!" "!repo_dir!" >nul 2>&1
    if !errorLevel! neq 0 (
        git clone --depth 1 --branch master "!repo_url!" "!repo_dir!" >nul 2>&1
        if !errorLevel! neq 0 (
            git clone --depth 1 "!repo_url!" "!repo_dir!"
            if !errorLevel! neq 0 (
                echo X Failed to clone !repo_name!
                goto :continue_loop
            )
        )
    )
    echo + Clone successful
    
    REM Show latest commit info
    cd /d "!repo_dir!"
    for /f "delims=" %%c in ('git log -1 --format^="%%h - %%s"') do echo   Latest commit: %%c
    cd /d "%~dp0"
    
    cd /d "!repo_dir!"
    
    set build_success=0
    
    REM Look for build script
    if exist "build.bat" (
        echo Found build.bat, building !repo_name!...
        call build.bat
        if !errorLevel! equ 0 (
            echo + Build successful
            set build_success=1
        ) else (
            echo ! Build script failed, trying manual compilation...
        )
    ) else (
        echo ! No build.bat found, trying manual compilation...
    )
    
    REM If build failed, try manual Dart compilation
    if !build_success! equ 0 (
        REM Check for Dart files
        if exist "*.dart" (
            echo Attempting manual Dart compilation for !repo_name!...
            if not exist "build" mkdir "build"
            
            REM Find main dart file
            set "main_file="
            if exist "bin\!repo_name!.dart" (
                set "main_file=bin\!repo_name!.dart"
            ) else if exist "!repo_name!.dart" (
                set "main_file=!repo_name!.dart"
            ) else if exist "bin\main.dart" (
                set "main_file=bin\main.dart"
            ) else if exist "main.dart" (
                set "main_file=main.dart"
            )
            
            if defined main_file (
                echo Found dart file: !main_file!
                set "output=build\!repo_name!.exe"
                dart compile exe "!main_file!" -o "!output!"
                if !errorLevel! equ 0 (
                    echo + Manual compilation successful
                    set build_success=1
                ) else (
                    echo X Manual compilation failed for !repo_name!
                )
            ) else (
                echo X Could not find main dart file
            )
        )
    )
    
    REM If still failed, skip this repo
    if !build_success! equ 0 (
        echo X All build attempts failed for !repo_name!
        cd /d "%~dp0"
        goto :continue_loop
    )
    
    REM Find and copy executables
    echo Looking for executables...
    set found_exe=0
    
    REM Search in common locations
    for %%d in (bin build out target .) do (
        if exist "%%d" (
            for %%f in ("%%d\*.exe") do (
                set "src_file=%%f"
                set "filename=%%~nxf"
                
                REM Skip non-executable files
                echo !filename! | findstr /i /r "\.bat$ \.cmd$" >nul
                if not !errorLevel! equ 0 (
                    REM Determine target filename with renaming
                    set "target_name=!filename!"
                    
                    REM Rename ws-*.exe to wslang.exe
                    echo !filename! | findstr /i /r "^ws-.*\.exe$" >nul
                    if !errorLevel! equ 0 (
                        set "target_name=wslang.exe"
                    )
                    
                    REM Rename wpm-*.exe to wpm.exe
                    echo !filename! | findstr /i /r "^wpm-.*\.exe$" >nul
                    if !errorLevel! equ 0 (
                        set "target_name=wpm.exe"
                    )
                    
                    copy "%%f" "%BIN_DIR%\!target_name!" >nul 2>&1
                    if !errorLevel! equ 0 (
                        if "!filename!" neq "!target_name!" (
                            echo + Copied and renamed: !filename! -^> !target_name!
                        ) else (
                            echo + Copied executable: !filename!
                        )
                        set found_exe=1
                    )
                )
            )
        )
    )
    
    if !found_exe! equ 0 (
        echo ! No executables found for !repo_name!
    )
    
    cd /d "%~dp0"
    
    :continue_loop
)

REM Clean up temp directory
echo.
echo Cleaning up temporary files...
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"

REM Add to PATH
echo.
echo Adding %BIN_DIR% to system PATH...

REM Get current PATH
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "CURRENT_PATH=%%b"

REM Check if already in PATH
echo !CURRENT_PATH! | findstr /C:"%BIN_DIR%" >nul
if !errorLevel! equ 0 (
    echo + %BIN_DIR% is already in PATH
) else (
    REM Add to PATH
    set "NEW_PATH=!CURRENT_PATH!;%BIN_DIR%"
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "!NEW_PATH!" /f >nul
    if !errorLevel! equ 0 (
        echo + Added to system PATH
        echo ! You may need to restart your terminal or computer for PATH changes to take effect
    ) else (
        echo X Failed to add to PATH. Please add manually: %BIN_DIR%
    )
)

REM Broadcast environment change
setx PATH "%BIN_DIR%;%PATH%" >nul 2>&1

REM Display results
echo.
echo ================================
echo Installation Complete!
echo ================================
echo.
echo Installed to: %BIN_DIR%
echo.
echo Installed programs:
if exist "%BIN_DIR%\*" (
    for %%f in ("%BIN_DIR%\*.exe") do (
        echo   - %%~nxf
    )
) else (
    echo   (none)
)

echo.
echo To use the installed programs, restart your terminal or computer.
echo.
echo Usage examples:
echo   wslang.exe program.ws
echo   wpm.exe install package
echo.

pause
