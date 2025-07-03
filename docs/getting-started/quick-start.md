# Quick Start Guide

This guide will help you get started with SView quickly. In just a few minutes, you'll be able to view and interact with SVG files using SView's powerful features.

## Basic Usage

### Viewing an SVG File

To view an SVG file, simply run:

```bash
sview path/to/your/file.svg
```

This will open the SVG in your default web browser as a PWA.

### Listing Available SVGs

To list all SVG files in a directory:

```bash
sview ls /path/to/svg/files
```

### Using the GUI

Launch the graphical interface with:

```bash
sview-gui
```

## Key Features

### 1. Interactive SVG Viewing

- Zoom in/out using mouse wheel or trackpad
- Pan by clicking and dragging
- Right-click for context menu

### 2. sView Memory Integration

Access the memory system with:

```bash
sview memory --list
```

### 3. Batch Processing

Process multiple SVGs at once:

```bash
sview process --input "*.svg" --output ./output --format png
```

## Example Workflow

1. **Explore SVGs in a directory**:
   ```bash
   sview ls ./examples
   ```

2. **View a specific SVG**:
   ```bash
   sview examples/simple-chart.svg
   ```

3. **Get SVG information**:
   ```bash
   sview info examples/simple-chart.svg
   ```

4. **Convert SVG to PNG**:
   ```bash
   sview convert examples/simple-chart.svg output.png
   ```

## Next Steps

- Learn about [advanced features](../user-guide/advanced-features.md)
- Explore the [sView Memory System](../user-guide/sview-memory.md)
- Check out the [API reference](../api/README.md) for developers
