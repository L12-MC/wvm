@echo off@echo off

REM WVM Installer for WindowsREM WVM Installer for Windows

REM Downloads and installs pre-built wslang and wpm executablesREM Clones, builds, and installs wslang and wpm



setlocal enabledelayedexpansionsetlocal enabledelayedexpansion



echo ================================echo ================================

echo WVM - Wslang and WPM Installerecho WVM - Wslang and WPM Installer

echo ================================echo ================================

echo.echo.



REM ConfigurationREM Configuration

set "INSTALL_DIR=C:\Program Files\wvm"set "INSTALL_DIR=C:\Program Files\wvm"

set "BIN_DIR=%INSTALL_DIR%\bin"set "BIN_DIR=%INSTALL_DIR%\bin"

set "TEMP_DIR=%INSTALL_DIR%\temp"set "TEMP_DIR=%INSTALL_DIR%\temp"



REM Check for admin rightsREM Check for admin rights

net session >nul 2>&1net session >nul 2>&1

if %errorLevel% neq 0 (if %errorLevel% neq 0 (

    echo Error: This script requires administrator privileges.    echo Error: This script requires administrator privileges.

    echo Please run as administrator.    echo Please run as administrator.

    pause    pause

    exit /b 1    exit /b 1

))



echo Installation directory: %INSTALL_DIR%echo Installation directory: %INSTALL_DIR%

echo Binary directory: %BIN_DIR%echo Binary directory: %BIN_DIR%

echo.echo.



REM Remove existing installation for clean installREM Remove existing installation for clean install

if exist "%INSTALL_DIR%" (if exist "%INSTALL_DIR%" (

    echo Removing existing installation...    echo Removing existing installation...

    rmdir /s /q "%INSTALL_DIR%"    rmdir /s /q "%INSTALL_DIR%"

    echo + Cleaned up old installation    echo + Cleaned up old installation

    echo.)

)

REM Create directories

REM Create directoriesecho Setting up directories...

echo Setting up directories...mkdir "%BIN_DIR%"

mkdir "%BIN_DIR%"mkdir "%TEMP_DIR%"

mkdir "%TEMP_DIR%"

REM Repositories

REM Release URLsset repos[0].name=wslang

set "WSLANG_URL=https://github.com/L12-MC/wslang/releases/download/v1.0.3/ws-windows.exe"set repos[0].url=https://github.com/L12-MC/wslang.git

set "WPM_URL=https://github.com/L12-MC/wpm/releases/download/v2.0/wpm.exe"set repos[1].name=wpm

set repos[1].url=https://github.com/L12-MC/wpm.git

echo Detected platform: Windows

echo.REM Process each repository

for /L %%i in (0,1,1) do (

REM Check for download tool    echo.

where curl >nul 2>&1    echo --- Processing !repos[%%i].name! ---

if %errorLevel% equ 0 (    

    set "DOWNLOAD_CMD=curl"    set "repo_name=!repos[%%i].name!"

) else (    set "repo_url=!repos[%%i].url!"

    where powershell >nul 2>&1    set "repo_dir=%TEMP_DIR%\!repo_name!"

    if %errorLevel% equ 0 (    

        set "DOWNLOAD_CMD=powershell"    REM Clone repository (fetch latest version)

    ) else (    echo Cloning latest version of !repo_name! from !repo_url!...

        echo Error: Neither curl nor PowerShell is available    git clone --depth 1 --branch main "!repo_url!" "!repo_dir!" >nul 2>&1

        echo Please ensure curl or PowerShell is installed    if !errorLevel! neq 0 (

        pause        git clone --depth 1 --branch master "!repo_url!" "!repo_dir!" >nul 2>&1

        exit /b 1        if !errorLevel! neq 0 (

    )            git clone --depth 1 "!repo_url!" "!repo_dir!"

)            if !errorLevel! neq 0 (

                echo X Failed to clone !repo_name!

REM Download wslang                goto :continue_loop

echo --- Downloading wslang ---            )

echo URL: %WSLANG_URL%        )

if "!DOWNLOAD_CMD!"=="curl" (    )

    curl -L -o "%TEMP_DIR%\wslang.exe" "%WSLANG_URL%"    echo + Clone successful

) else (    

    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%WSLANG_URL%' -OutFile '%TEMP_DIR%\wslang.exe'}"    REM Show latest commit info

)    cd /d "!repo_dir!"

    for /f "delims=" %%c in ('git log -1 --format^="%%h - %%s"') do echo   Latest commit: %%c

if exist "%TEMP_DIR%\wslang.exe" (    cd /d "%~dp0"

    move "%TEMP_DIR%\wslang.exe" "%BIN_DIR%\wslang.exe" >nul    

    echo + Installed wslang.exe    cd /d "!repo_dir!"

) else (    

    echo X Failed to download wslang    set build_success=0

)    

echo.    REM Look for build script

    if exist "build.bat" (

REM Download wpm        echo Found build.bat, building !repo_name!...

echo --- Downloading wpm ---        call build.bat

echo URL: %WPM_URL%        if !errorLevel! equ 0 (

if "!DOWNLOAD_CMD!"=="curl" (            echo + Build successful

    curl -L -o "%TEMP_DIR%\wpm.exe" "%WPM_URL%"            set build_success=1

) else (        ) else (

    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%WPM_URL%' -OutFile '%TEMP_DIR%\wpm.exe'}"            echo ! Build script failed, trying manual compilation...

)        )

    ) else (

if exist "%TEMP_DIR%\wpm.exe" (        echo ! No build.bat found, trying manual compilation...

    move "%TEMP_DIR%\wpm.exe" "%BIN_DIR%\wpm.exe" >nul    )

    echo + Installed wpm.exe    

) else (    REM If build failed, try manual Dart compilation

    echo X Failed to download wpm    if !build_success! equ 0 (

)        REM Check for Dart files

echo.        if exist "*.dart" (

            echo Attempting manual Dart compilation for !repo_name!...

REM Clean up temp directory            if not exist "build" mkdir "build"

echo Cleaning up temporary files...            

if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"            REM Find main dart file

            set "main_file="

REM Add to PATH            if exist "bin\!repo_name!.dart" (

echo.                set "main_file=bin\!repo_name!.dart"

echo Adding %BIN_DIR% to system PATH...            ) else if exist "!repo_name!.dart" (

                set "main_file=!repo_name!.dart"

REM Get current PATH            ) else if exist "bin\main.dart" (

for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "CURRENT_PATH=%%b"                set "main_file=bin\main.dart"

            ) else if exist "main.dart" (

REM Check if already in PATH                set "main_file=main.dart"

echo !CURRENT_PATH! | findstr /C:"%BIN_DIR%" >nul            )

if !errorLevel! equ 0 (            

    echo + %BIN_DIR% is already in PATH            if defined main_file (

) else (                echo Found dart file: !main_file!

    REM Add to PATH                set "output=build\!repo_name!.exe"

    set "NEW_PATH=!CURRENT_PATH!;%BIN_DIR%"                dart compile exe "!main_file!" -o "!output!"

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "!NEW_PATH!" /f >nul                if !errorLevel! equ 0 (

    if !errorLevel! equ 0 (                    echo + Manual compilation successful

        echo + Added to system PATH                    set build_success=1

        echo ! You may need to restart your terminal or computer for PATH changes to take effect                ) else (

    ) else (                    echo X Manual compilation failed for !repo_name!

        echo X Failed to add to PATH. Please add manually: %BIN_DIR%                )

    )            ) else (

)                echo X Could not find main dart file

            )

REM Broadcast environment change        )

setx PATH "%BIN_DIR%;%PATH%" >nul 2>&1    )

    

REM Display results    REM If still failed, skip this repo

echo.    if !build_success! equ 0 (

echo ================================        echo X All build attempts failed for !repo_name!

echo Installation Complete!        cd /d "%~dp0"

echo ================================        goto :continue_loop

echo.    )

echo Installed to: %BIN_DIR%    

echo.    REM Find and copy executables

echo Installed programs:    echo Looking for executables...

if exist "%BIN_DIR%\*.exe" (    set found_exe=0

    for %%f in ("%BIN_DIR%\*.exe") do (    

        echo   - %%~nxf    REM Search in common locations

    )    for %%d in (bin build out target .) do (

) else (        if exist "%%d" (

    echo   (none)            for %%f in ("%%d\*.exe") do (

)                set "src_file=%%f"

                set "filename=%%~nxf"

echo.                

echo To use the installed programs, restart your terminal or computer.                REM Skip non-executable files

echo.                echo !filename! | findstr /i /r "\.bat$ \.cmd$" >nul

echo Usage examples:                if not !errorLevel! equ 0 (

echo   wslang.exe program.ws                    REM Determine target filename with renaming

echo   wpm.exe install package                    set "target_name=!filename!"

echo.                    

                    REM Rename ws-*.exe to wslang.exe

pause                    echo !filename! | findstr /i /r "^ws-.*\.exe$" >nul

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
