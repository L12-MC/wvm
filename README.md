# WVM - Wslang and WPM Manager

A build and installation manager for [wslang](https://github.com/L12-MC/wslang.git) and [wpm](https://github.com/L12-MC/wpm.git) packages.

## Features

- **Clean installation**: Removes existing installation before installing
- **Pre-built binaries**: Downloads ready-to-use executables from GitHub releases
- **Fast installation**: No compilation needed, just download and install
- **Cross-platform**: Automatically detects your platform (Linux, macOS, Windows)
- **Simple**: No build tools or dependencies required (except wget/curl)
- Installs all binaries to a single directory
  - Linux/macOS: `~/.wvm/bin`
  - Windows: `C:\Program Files\wvm\bin`
- Automatically adds to PATH
- Supports both wget and curl for downloading

## Prerequisites

- Internet connection for downloading executables
- Linux/macOS: wget or curl (usually pre-installed)
- Windows: curl or PowerShell (pre-installed on modern Windows)
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

3. **Detects Platform**
   - Automatically identifies your operating system
   - Selects the correct pre-built executable

4. **Downloads Pre-built Executables**
   - **wslang v1.0.3** from GitHub releases
   - **wpm v2.0** from GitHub releases
   - Uses wget or curl (Linux/macOS) or curl/PowerShell (Windows)
   - Shows download progress

5. **Installs Executables**
   - Copies downloaded binaries to bin directory
   - Sets executable permissions (Linux/macOS)
   - Clean, consistent names: `wslang` and `wpm` (`.exe` on Windows)

6. **Updates PATH**
   - Linux/macOS: Adds to `~/.bashrc` or `~/.zshrc`
   - Windows: Adds to system PATH (requires admin)

7. **Cleanup**
   - Removes temporary download directory

## Updating to Latest Version

To update to a newer release, simply run the installer again:

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
- Download the latest release binaries
- Reinstall everything
- Update your PATH if needed

**Note**: The installer downloads specific release versions (wslang v1.0.3, wpm v2.0). To install different versions, you can modify the URLs in the script.

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
