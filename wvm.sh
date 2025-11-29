#!/bin/bash
# WVM Installer for Linux/macOS
# Clones, builds, and installs wslang and wpm

# Note: Not using set -e because we want to handle build failures gracefully

echo "================================"
echo "WVM - Wslang and WPM Installer"
echo "================================"
echo ""

# Configuration
INSTALL_DIR="$HOME/.wvm"
BIN_DIR="$INSTALL_DIR/bin"
TEMP_DIR="$INSTALL_DIR/temp"

# Repositories
REPOS=(
    "wslang:https://github.com/L12-MC/wslang.git"
    "wpm:https://github.com/L12-MC/wpm.git"
)

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

# Create directories
echo "Setting up directories..."
mkdir -p "$BIN_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Process each repository
for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r name url <<< "$repo_info"
    
    echo ""
    echo "--- Processing $name ---"
    
    repo_dir="$TEMP_DIR/$name"
    
    # Clone repository
    echo "Cloning $name from $url..."
    if git clone --depth 1 "$url" "$repo_dir"; then
        echo "✓ Clone successful"
    else
        echo "✗ Failed to clone $name"
        continue
    fi
    
    cd "$repo_dir"
    
    build_success=false
    
    # Look for build script
    if [ -f "build.sh" ]; then
        echo "Found build.sh, building $name..."
        chmod +x build.sh
        if ./build.sh; then
            echo "✓ Build successful"
            build_success=true
        else
            echo "⚠ Build script failed, trying manual compilation..."
        fi
    elif [ -f "Makefile" ]; then
        echo "Found Makefile, building $name..."
        if make build || make; then
            echo "✓ Build successful"
            build_success=true
        else
            echo "⚠ Makefile build failed, trying manual compilation..."
        fi
    else
        echo "⚠ No build script found, trying manual compilation..."
    fi
    
    # If build script failed or doesn't exist, try manual Dart compilation
    if [ "$build_success" = false ]; then
        # Check if there are any Dart files
        if ls *.dart 2>/dev/null || ls bin/*.dart 2>/dev/null; then
            echo "Attempting manual Dart compilation for $name..."
            mkdir -p build
            
            # Try to find the main dart file
            main_file=""
            if [ -f "bin/${name}.dart" ]; then
                main_file="bin/${name}.dart"
            elif [ -f "${name}.dart" ]; then
                main_file="${name}.dart"
            elif [ -f "bin/main.dart" ]; then
                main_file="bin/main.dart"
            elif [ -f "main.dart" ]; then
                main_file="main.dart"
            fi
            
            if [ -n "$main_file" ]; then
                echo "Found dart file: $main_file"
                # Detect platform for output name
                PLATFORM=$(uname -s)
                case "$PLATFORM" in
                    Linux*) output="build/${name}-linux" ;;
                    Darwin*) output="build/${name}-macos" ;;
                    *) output="build/${name}" ;;
                esac
                
                # Compile
                if dart compile exe "$main_file" -o "$output"; then
                    echo "✓ Manual compilation successful"
                    build_success=true
                else
                    echo "✗ Manual compilation failed for $name"
                fi
            else
                echo "✗ Could not find main dart file"
            fi
        fi
    fi
    
    # If still failed, skip this repo
    if [ "$build_success" = false ]; then
        echo "✗ All build attempts failed for $name"
        cd - > /dev/null
        continue
    fi
    
    # Find and copy executables
    echo "Looking for executables..."
    found_exe=false
    
    # Search in common locations
    for search_dir in bin build out target .; do
        if [ ! -d "$search_dir" ]; then
            continue
        fi
        
        for file in "$search_dir"/*; do
            if [ ! -f "$file" ]; then
                continue
            fi
            
            filename=$(basename "$file")
            
            # Skip common non-executable files
            if [[ "$filename" == *.sh ]] || \
               [[ "$filename" == *.bat ]] || \
               [[ "$filename" == *.dart ]] || \
               [[ "$filename" == *.java ]] || \
               [[ "$filename" == *.c ]] || \
               [[ "$filename" == *.cpp ]] || \
               [[ "$filename" == *.h ]] || \
               [[ "$filename" == *.md ]] || \
               [[ "$filename" == *.txt ]] || \
               [[ "$filename" == *.json ]] || \
               [[ "$filename" == *.yaml ]] || \
               [[ "$filename" == *.yml ]] || \
               [[ "$filename" == Makefile ]]; then
                continue
            fi
            
            # Check if executable
            if [ -x "$file" ]; then
                # Determine target filename with renaming
                target_name="$filename"
                
                # Rename ws-* to wslang
                if [[ "$filename" =~ ^ws-.* ]]; then
                    target_name="wslang"
                fi
                
                # Rename wpm-* to wpm
                if [[ "$filename" =~ ^wpm-.* ]]; then
                    target_name="wpm"
                fi
                
                cp "$file" "$BIN_DIR/$target_name"
                chmod +x "$BIN_DIR/$target_name"
                
                if [ "$filename" != "$target_name" ]; then
                    echo "✓ Copied and renamed: $filename -> $target_name"
                else
                    echo "✓ Copied executable: $filename"
                fi
                found_exe=true
            fi
        done
    done
    
    if [ "$found_exe" = false ]; then
        echo "⚠ No executables found for $name"
    fi
    
    cd - > /dev/null
done

# Clean up temp directory
echo ""
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
            echo "  - $(basename "$file")"
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
