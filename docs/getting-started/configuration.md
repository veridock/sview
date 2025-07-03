# Configuration Guide

SView can be configured using a configuration file, environment variables, or command-line arguments. This guide explains all available configuration options.

## Configuration File

The main configuration file is located at `~/.config/sview/config.toml` on Linux/macOS or `%APPDATA%\sview\config.toml` on Windows.

### Example Configuration

```toml
[general]
# Enable or disable automatic updates
auto_update = true

# Default theme (light, dark, or system)
theme = "system"

# Language (en, pl, etc.)
language = "en"

[ui]
# Enable/disable animations
animations = true

# Default zoom level (1.0 = 100%)
default_zoom = 1.0

# Show/hide the status bar
show_status_bar = true

[memory]
# Enable/disable the sView memory system
enabled = true

# Memory cache size in MB
cache_size = 512

# Auto-save interval in seconds
auto_save_interval = 300

[files]
# Default directory to open
default_directory = "~/Documents/SVGs"

# File patterns to include (comma-separated)
include = "*.svg,*.svgz"

# File patterns to exclude (comma-separated)
exclude = "node_modules/**,.git/**"

[export]
# Default export format (png, jpg, pdf, etc.)
format = "png"

# Default export quality (1-100)
quality = 90

# Background color for transparent exports
background = "#FFFFFF"
```

## Environment Variables

You can override configuration settings using environment variables:

```bash
# Set the configuration directory
SVIEW_CONFIG_DIR="/path/to/config"

# Set the cache directory
SVIEW_CACHE_DIR="/path/to/cache"

# Set the log level (error, warn, info, debug, trace)
RUST_LOG=info

# Override specific settings
SVIEW_GENERAL_THEME=dark
SVIEW_UI_ANIMATIONS=false
```

## Command-Line Arguments

You can also pass configuration options as command-line arguments:

```bash
# Set the theme
sview --theme dark

# Disable animations
sview --no-animations

# Set a custom config file
sview --config /path/to/config.toml
```

## Configuration Precedence

Configuration values are loaded in the following order (last one wins):

1. Default values (hardcoded)
2. Configuration file values
3. Environment variables
4. Command-line arguments

## Logging

SView uses the `env_logger` crate for logging. You can control the log level using the `RUST_LOG` environment variable:

```bash
# Enable debug logging
RUST_LOG=debug sview

# Enable trace logging for specific modules
RUST_LOG=sview=debug,sview::memory=trace sview
```

## Troubleshooting

If you're having issues with your configuration:

1. Check the configuration file for syntax errors
2. Verify that environment variables are set correctly
3. Run with `--debug` flag to see detailed logs
4. Try resetting to defaults with `--reset-config`

For more help, see the [Troubleshooting Guide](../troubleshooting.md).
