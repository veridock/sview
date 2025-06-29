# Installation Guide

## Prerequisites

Before installing SView, ensure you have the following installed on your system:

- **Rust** (1.70 or later) - [Install Rust](https://www.rust-lang.org/tools/install)
- **Node.js** (18.x or later) - [Download Node.js](https://nodejs.org/)
- **npm** (8.x or later) or **yarn**
- **Git** - [Install Git](https://git-scm.com/)

## Installation Methods

### Method 1: Using install.sh (Recommended)

The easiest way to install SView is by using the provided installation script:

```bash
# Clone the repository
git clone https://github.com/veridock/sview.git
cd sview

# Make the installation script executable
chmod +x install.sh

# Run the installation script
./install.sh
```

This script will:
1. Install all necessary dependencies
2. Build the Rust components
3. Install the GUI components
4. Set up system integration

### Method 2: Manual Installation

If you prefer to install manually, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/veridock/sview.git
   cd sview
   ```

2. **Build the Rust components**:
   ```bash
   cargo build --release
   ```

3. **Install the GUI components**:
   ```bash
   cd gui
   npm install
   npm run build
   cd ..
   ```

4. **Install the binary** (optional):
   ```bash
   # On Linux/macOS
   sudo cp target/release/sview /usr/local/bin/
   
   # On Windows (as Administrator)
   # copy target\release\sview.exe C:\Windows\System32\
   ```

## Verifying the Installation

After installation, verify that SView is working correctly:

```bash
sview --version
```

You should see output similar to:
```
sview 1.0.0
```

## Updating SView

To update an existing installation:

```bash
# Navigate to your sview directory
cd /path/to/sview

# Pull the latest changes
git pull

# Rebuild the project
cargo build --release

# Update GUI components
cd gui
npm install
npm run build
cd ..
```

## Uninstalling SView

To uninstall SView:

1. Remove the binary:
   ```bash
   # On Linux/macOS
   sudo rm /usr/local/bin/sview
   
   # On Windows
   # del C:\Windows\System32\sview.exe
   ```

2. Remove the installation directory:
   ```bash
   rm -rf /path/to/sview
   ```

## Troubleshooting

If you encounter any issues during installation, please check the following:

1. Ensure all dependencies are installed and up to date
2. Check that your system meets the minimum requirements
3. Verify that you have write permissions in the installation directory
4. Check the [Troubleshooting Guide](../troubleshooting.md) for common issues

If you're still having trouble, please [open an issue](https://github.com/veridock/sview/issues) with details about your system and the error message you're seeing.
