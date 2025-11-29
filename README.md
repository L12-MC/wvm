# WVM - Wslang and WPM Manager

A build and installation manager for [wslang](https://github.com/L12-MC/wslang.git) and [wpm](https://github.com/L12-MC/wpm.git) packages.

## Features

- **Clean installation**: Removes existing installation before installing
- **Latest version**: Always fetches the most recent code from repositories
- Automatically clones the latest versions of wslang and wpm
- Shows commit information for verification
- Runs each project's own build script (build.sh or build.bat)
- Falls back to manual Dart compilation if build scripts fail
- Builds in temporary directories, copies only executables
- Automatically renames executables for consistency:
  - `ws-linux` → `wslang` (or `ws-macos` → `wslang`)
  - `wpm-linux` → `wpm` (or `wpm.exe` → `wpm.exe`)
- Installs all binaries to a single directory
  - Linux/macOS: `~/.wvm/bin`
  - Windows: `C:\Program Files\wvm\bin`
- Automatically adds to PATH

## Prerequisites

- Git installed
- Internet connection for cloning repositories
- Linux/macOS: bash shell
- Windows: Administrator privileges (for PATH modification)

## Quick Installation

### Linux/macOS

```bash
chmod +x wvm.sh
./wvm.sh
```

The script will automatically:
1. Clone the repositories to temporary directories
2. Run each project's build script
3. Copy executables to `~/.wvm/bin`
4. Add `~/.wvm/bin` to your PATH
5. Clean up temporary files

After installation, restart your terminal or run:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Windows

Right-click and select "Run as Administrator":
```cmd
wvm.bat
```

The script will automatically:
1. Clone the repositories to temporary directories
2. Run each project's build script
3. Copy executables to `C:\Program Files\wvm\bin`
4. Add the directory to system PATH
5. Clean up temporary files

After installation, restart your terminal or computer.

## What the Script Does

1. **Clean Installation**
   - Removes existing `~/.wvm` (Linux/macOS) or `C:\Program Files\wvm` (Windows) directory
   - Ensures fresh installation every time

2. **Creates Installation Directory**
   - Linux/macOS: `~/.wvm/bin`
   - Windows: `C:\Program Files\wvm\bin`

3. **Clones Latest Repositories**
   - wslang from https://github.com/L12-MC/wslang.git
   - wpm from https://github.com/L12-MC/wpm.git
   - Tries main branch, falls back to master, then default
   - Shows latest commit information

4. **Builds Each Project**
   - Looks for `build.sh` (Linux/macOS) or `build.bat` (Windows)
   - Falls back to `Makefile` if available
   - Builds in temporary directory

4. **Installs Executables**
   - Searches for compiled executables in `bin/`, `build/`, `out/`, `target/`, and root
   - Copies only executables (not source files)
   - Automatically renames for consistency (ws-linux → wslang, wpm-linux → wpm)
   - Makes them executable on Linux/macOS

5. **Updates PATH**
   - Linux/macOS: Adds to `~/.bashrc` or `~/.zshrc`
   - Windows: Adds to system PATH (requires admin)

6. **Cleanup**
   - Removes all temporary build directories

## Updating to Latest Version

Simply run the installer again to update to the latest versions:

### Linux/macOS
```bash
./wvm.sh
```

### Windows
```cmd
wvm.bat (as Administrator)
```

The script will:
- Remove the old installation
- Fetch the latest code
- Rebuild and reinstall everything
- Show you the latest commit for each package

## Manual Building (Optional)

If you want to build the Dart version of the installer:

### Linux/macOS

```bash
./build.sh
# or
make build
```

### Windows

```cmd
build.bat
```

This creates a standalone executable that can be distributed.

## Directory Structure

### Linux/macOS
```
~/.wvm/
├── bin/          # Installed executables
│   ├── wslang   # Well.. Simple language interpreter
│   └── wpm      # Well.. Simple package manager
└── temp/         # Temporary build directory (cleaned after install)
```

### Windows
```
C:\Program Files\wvm\
├── bin\          # Installed executables
│   ├── wslang.exe   # Well.. Simple language interpreter
│   └── wpm.exe      # Well.. Simple package manager
└── temp\         # Temporary build directory (cleaned after install)
```

## Troubleshooting

### Linux/macOS

**Permission denied:**
```bash
chmod +x wvm.sh
```

**PATH not updated:**
```bash
source ~/.bashrc  # or ~/.zshrc
```

**Git not found:**
```bash
sudo apt install git  # Debian/Ubuntu
sudo dnf install git  # Fedora
brew install git      # macOS
```

### Windows

**Access denied:**
- Right-click `wvm.bat` and select "Run as Administrator"

**PATH not working:**
- Restart your terminal or computer
- Or manually add `C:\Program Files\wvm\bin` to your PATH in System Properties

**Git not found:**
- Download and install Git from https://git-scm.com/download/win

## Uninstallation

### Linux/macOS

```bash
# Remove binaries
rm -rf ~/.wvm

# Remove from PATH (edit your shell config file)
nano ~/.bashrc  # or ~/.zshrc
# Remove the line: export PATH="$PATH:$HOME/.wvm/bin"
```

### Windows

1. Delete `C:\Program Files\wvm`
2. Remove `C:\Program Files\wvm\bin` from System PATH in System Properties

## License

See individual package repositories for license information.

## Project Files

- `wvm.sh` - Linux/macOS installer script
- `wvm.bat` - Windows installer script
- `wvm.dart` - Dart implementation (alternative)
- `build.sh` - Build script for Dart version (Linux/macOS)
- `build.bat` - Build script for Dart version (Windows)
- `Makefile` - Make targets for development
