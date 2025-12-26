#!/bin/bash
# WVM Installer for Linux/macOS
# Downloads and installs pre-built wslang and wpm executables

echo "================================"
echo "WVM - Wslang and WPM Installer"
echo "================================"
echo ""

# Configuration
INSTALL_DIR="$HOME/.wvm"
BIN_DIR="$INSTALL_DIR/bin"
TEMP_DIR="$INSTALL_DIR/temp"

# Detect shell config file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="$HOME/.profile"
fi

echo "Installation directory: $INSTALL_DIR"
echo "Binary directory: $BIN_DIR"
echo "Shell configuration: $SHELL_CONFIG"
echo ""

# Remove existing installation for clean install
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing existing installation..."
    rm -rf "$INSTALL_DIR"
    echo "✓ Cleaned up old installation"
    echo ""
fi

# Create directories
echo "Setting up directories..."
mkdir -p "$BIN_DIR"
mkdir -p "$TEMP_DIR"

# Detect platform
PLATFORM=$(uname -s)
case "$PLATFORM" in
    Linux*)
        PLATFORM_NAME="Linux"
        WSLANG_ASSET_PATTERN="^wslang$"
        WPM_ASSET_PATTERN="^wpm$"
        ;;
    Darwin*)
        PLATFORM_NAME="macOS"
        WSLANG_ASSET_PATTERN="^wslang$"
        WPM_ASSET_PATTERN="^wpm$"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        PLATFORM_NAME="Windows (Git Bash)"
        WSLANG_ASSET_PATTERN="^(ws-windows\.exe|wslang\.exe)$"
        WPM_ASSET_PATTERN="^wpm\.exe$"
        ;;
    *)
        echo "Error: Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

echo "Detected platform: $PLATFORM_NAME"
echo ""

# Check for download tool
if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget"
elif command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl"
else
    echo "Error: Neither wget nor curl is available"
    echo "Please install wget or curl to continue"
    exit 1
fi

WSLANG_URL="https://github.com/L12-MC/wslang/releases/latest/download/wslang-linux"
WPM_URL="https://github.com/L12-MC/wpm/releases/latest/download/wpm"

# Download wslang
echo "--- Downloading wslang ---"
echo "URL: $WSLANG_URL"
if [ "$DOWNLOAD_CMD" = "wget" ]; then
    wget -q --show-progress -O "$TEMP_DIR/wslang" "$WSLANG_URL"
else
    curl -L -# -o "$TEMP_DIR/wslang" "$WSLANG_URL"
fi

if [ $? -eq 0 ] && [ -f "$TEMP_DIR/wslang" ]; then
    # If Windows asset is an .exe, name appropriately
    if [[ "$PLATFORM_NAME" == "Windows (Git Bash)" ]] && [[ "$WSLANG_URL" =~ \.exe$ ]]; then
        mv "$TEMP_DIR/wslang" "$BIN_DIR/wslang"
    else
        mv "$TEMP_DIR/wslang" "$BIN_DIR/wslang"
        chmod +x "$BIN_DIR/wslang"
    fi
    echo "✓ Installed wslang"
else
    echo "✗ Failed to download wslang"
fi
echo ""

# Download wpm
echo "--- Downloading wpm ---"
echo "URL: $WPM_URL"
if [ "$DOWNLOAD_CMD" = "wget" ]; then
    wget -q --show-progress -O "$TEMP_DIR/wpm" "$WPM_URL"
else
    curl -L -# -o "$TEMP_DIR/wpm" "$WPM_URL"
fi

if [ $? -eq 0 ] && [ -f "$TEMP_DIR/wpm" ]; then
    if [[ "$PLATFORM_NAME" == "Windows (Git Bash)" ]] && [[ "$WPM_URL" =~ \.exe$ ]]; then
        mv "$TEMP_DIR/wpm" "$BIN_DIR/wpm.exe"
    else
        mv "$TEMP_DIR/wpm" "$BIN_DIR/wpm"
        chmod +x "$BIN_DIR/wpm"
    fi
    echo "✓ Installed wpm"
else
    echo "✗ Failed to download wpm"
fi
echo ""

# Clean up temp directory
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# Check if PATH already contains bin directory
if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
    echo ""
    echo "✓ $BIN_DIR is already in PATH"
else
    # Add to PATH in shell config
    echo ""
    echo "Adding $BIN_DIR to PATH in $SHELL_CONFIG..."
    
    # Check if the export line already exists in the file
    if grep -q "export PATH=\"\$PATH:$BIN_DIR\"" "$SHELL_CONFIG" 2>/dev/null; then
        echo "✓ PATH entry already exists in $SHELL_CONFIG"
    else
        echo "" >> "$SHELL_CONFIG"
        echo "# Added by WVM installer" >> "$SHELL_CONFIG"
        echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$SHELL_CONFIG"
        echo "✓ Added to $SHELL_CONFIG"
    fi
    
    # Export for current session
    export PATH="$PATH:$BIN_DIR"
    echo "✓ Added to current session PATH"
fi

# Display results
echo ""
echo "================================"
echo "Installation Complete!"
echo "================================"
echo ""
echo "Installed to: $BIN_DIR"
echo ""
echo "Installed programs:"
if [ -d "$BIN_DIR" ] && [ "$(ls -A $BIN_DIR 2>/dev/null)" ]; then
    for file in "$BIN_DIR"/*; do
        if [ -f "$file" ]; then
            file_size=$(du -h "$file" | cut -f1)
            echo "  - $(basename "$file") ($file_size)"
        fi
    done
else
    echo "  (none)"
fi

echo ""
echo "To use the installed programs:"
echo "  1. Restart your terminal, or"
echo "  2. Run: source $SHELL_CONFIG"
echo ""
echo "Usage examples:"
echo "  wslang program.ws"
echo "  wpm install package"
echo ""
