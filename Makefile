# SView - SVG Viewer & PWA Launcher with XQR Integration
# Makefile for project management

# Variables
PROJECT_NAME = sview
VERSION = 1.0.0
RUST_VERSION = 1.70
NODE_VERSION = 18

# Directories
SRC_DIR = src
GUI_DIR = gui
DIST_DIR = dist
TARGET_DIR = target
EXAMPLES_DIR = examples
DOCS_DIR = docs

# Build configurations
CARGO_FLAGS = --release --all-features
NPM_FLAGS = --production

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
PURPLE = \033[0;35m
CYAN = \033[0;36m
NC = \033[0m # No Color

# Default target
.PHONY: all
all: help

# Help
.PHONY: help
help:
	@echo "$(BLUE)🧠 SView - SVG Viewer & PWA Launcher$(NC)"
	@echo "$(PURPLE)🔗 XQR Integration Enabled$(NC)"
	@echo "=================================="
	@echo ""
	@echo "$(GREEN)📦 Build commands:$(NC)"
	@echo "  make build              - Build CLI application"
	@echo "  make build-gui          - Build GUI application"
	@echo "  make build-all          - Build both CLI and GUI"
	@echo "  make release            - Build optimized release"
	@echo ""
	@echo "$(GREEN)🧪 Development:$(NC)"
	@echo "  make dev                - Run in development mode"
	@echo "  make dev-gui            - Run GUI in development mode"
	@echo "  make test               - Run all tests"
	@echo "  make test-coverage      - Run tests with coverage"
	@echo "  make lint               - Run linters"
	@echo "  make format             - Format code"
	@echo ""
	@echo "$(GREEN)📦 Installation:$(NC)"
	@echo "  make install            - Install locally"
	@echo "  make install-deps       - Install dependencies"
	@echo "  make uninstall          - Uninstall"
	@echo ""
	@echo "$(GREEN)🔧 Maintenance:$(NC)"
	@echo "  make clean              - Clean build artifacts"
	@echo "  make clean-cache        - Clean cache"
	@echo "  make update             - Update dependencies"
	@echo "  make check              - Check project health"
	@echo ""
	@echo "$(GREEN)📚 Documentation:$(NC)"
	@echo "  make docs               - Generate documentation"
	@echo "  make docs-serve         - Serve documentation locally"
	@echo "  make examples           - Create example files"
	@echo ""
	@echo "$(GREEN)🚀 Distribution:$(NC)"
	@echo "  make package            - Create distribution packages"
	@echo "  make docker             - Build Docker image"
	@echo "  make publish            - Publish to registries"

# Check requirements
.PHONY: check-requirements
check-requirements:
	@echo "$(BLUE)📋 Checking requirements...$(NC)"
	@command -v rustc >/dev/null 2>&1 || { echo "$(RED)❌ Rust not found$(NC)"; exit 1; }
	@command -v cargo >/dev/null 2>&1 || { echo "$(RED)❌ Cargo not found$(NC)"; exit 1; }
	@echo "$(GREEN)✅ Rust $(shell rustc --version) found$(NC)"
	@if command -v node >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Node.js $(shell node --version) found$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Node.js not found - GUI will not be available$(NC)"; \
	fi
	@echo ""

# Install dependencies
.PHONY: install-deps
install-deps: check-requirements
	@echo "$(BLUE)📦 Installing dependencies...$(NC)"
	@cargo --version
	@if [ -f "$(GUI_DIR)/package.json" ]; then \
		cd $(GUI_DIR) && npm install; \
		echo "$(GREEN)✅ Node.js dependencies installed$(NC)"; \
	fi
	@echo "$(GREEN)✅ Dependencies installed$(NC)"
	@echo ""

# Build CLI application
.PHONY: build
build: install-deps
	@echo "$(BLUE)🔧 Building CLI application...$(NC)"
	@cargo build $(CARGO_FLAGS)
	@echo "$(GREEN)✅ CLI build completed$(NC)"
	@echo "📍 Binary location: $(TARGET_DIR)/release/$(PROJECT_NAME)"
	@echo ""

# Build GUI application
.PHONY: build-gui
build-gui: install-deps
	@echo "$(BLUE)🎨 Building GUI application...$(NC)"
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm run build; \
		echo "$(GREEN)✅ GUI build completed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  GUI directory not found$(NC)"; \
	fi
	@echo ""

# Build everything
.PHONY: build-all
build-all: build build-gui
	@echo "$(GREEN)✅ All components built successfully$(NC)"
	@echo ""

# Development mode
.PHONY: dev
dev: install-deps
	@echo "$(BLUE)🚀 Starting development mode...$(NC)"
	@cargo run -- --help

# GUI development mode
.PHONY: dev-gui
dev-gui: install-deps
	@echo "$(BLUE)🎨 Starting GUI development server...$(NC)"
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm run dev; \
	else \
		echo "$(RED)❌ GUI directory not found$(NC)"; \
	fi

# Run tests
.PHONY: test
test:
	@echo "$(BLUE)🧪 Running tests...$(NC)"
	@cargo test --all-features
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm test; \
	fi
	@echo "$(GREEN)✅ Tests completed$(NC)"
	@echo ""

# Test coverage
.PHONY: test-coverage
test-coverage:
	@echo "$(BLUE)📊 Running test coverage...$(NC)"
	@cargo install cargo-tarpaulin --locked
	@cargo tarpaulin --all-features --out html --output-dir coverage/
	@echo "$(GREEN)✅ Coverage report generated in coverage/$(NC)"
	@echo ""

# Linting
.PHONY: lint
lint:
	@echo "$(BLUE)🔍 Running linters...$(NC)"
	@cargo clippy --all-features -- -D warnings
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm run lint; \
	fi
	@echo "$(GREEN)✅ Linting completed$(NC)"
	@echo ""

# Format code
.PHONY: format
format:
	@echo "$(BLUE)📝 Formatting code...$(NC)"
	@cargo fmt
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm run format; \
	fi
	@echo "$(GREEN)✅ Code formatted$(NC)"
	@echo ""

# Install locally
.PHONY: install
install: build
	@echo "$(BLUE)📦 Installing SView locally...$(NC)"
	@mkdir -p ~/.local/bin
	@mkdir -p ~/.sview/{cache,config,logs}
	@cp $(TARGET_DIR)/release/$(PROJECT_NAME) ~/.local/bin/
	@if [ -f "$(TARGET_DIR)/release/$(PROJECT_NAME)-gui" ]; then \
		cp $(TARGET_DIR)/release/$(PROJECT_NAME)-gui ~/.local/bin/; \
	fi
	@echo "$(GREEN)✅ SView installed to ~/.local/bin/$(NC)"
	@echo "💡 Add ~/.local/bin to your PATH if not already done"
	@echo "   export PATH=\"$$HOME/.local/bin:$$PATH\""
	@echo ""

# Uninstall
.PHONY: uninstall
uninstall:
	@echo "$(BLUE)🗑️  Uninstalling SView...$(NC)"
	@rm -f ~/.local/bin/$(PROJECT_NAME)
	@rm -f ~/.local/bin/$(PROJECT_NAME)-gui
	@rm -rf ~/.sview
	@echo "$(GREEN)✅ SView uninstalled$(NC)"
	@echo ""

# Clean build artifacts
.PHONY: clean
clean:
	@echo "$(BLUE)🧹 Cleaning build artifacts...$(NC)"
	@cargo clean
	@rm -rf $(DIST_DIR)
	@if [ -d "$(GUI_DIR)/dist" ]; then \
		rm -rf $(GUI_DIR)/dist; \
	fi
	@if [ -d "$(GUI_DIR)/node_modules" ]; then \
		rm -rf $(GUI_DIR)/node_modules; \
	fi
	@echo "$(GREEN)✅ Cleaned$(NC)"
	@echo ""

# Clean cache
.PHONY: clean-cache
clean-cache:
	@echo "$(BLUE)🧹 Cleaning cache...$(NC)"
	@rm -rf ~/.sview/cache/*
	@cargo clean
	@if command -v npm >/dev/null 2>&1; then \
		npm cache clean --force; \
	fi
	@echo "$(GREEN)✅ Cache cleaned$(NC)"
	@echo ""

# Update dependencies
.PHONY: update
update:
	@echo "$(BLUE)🔄 Updating dependencies...$(NC)"
	@cargo update
	@if [ -f "$(GUI_DIR)/package.json" ]; then \
		cd $(GUI_DIR) && npm update; \
	fi
	@echo "$(GREEN)✅ Dependencies updated$(NC)"
	@echo ""

# Check project health
.PHONY: check
check: check-requirements
	@echo "$(BLUE)🔍 Checking project health...$(NC)"
	@cargo check --all-features
	@cargo audit
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm audit; \
	fi
	@echo "$(GREEN)✅ Project health check completed$(NC)"
	@echo ""

# Generate documentation
.PHONY: docs
docs:
	@echo "$(BLUE)📚 Generating documentation...$(NC)"
	@cargo doc --all-features --no-deps
	@mkdir -p $(DOCS_DIR)
	@if command -v mdbook >/dev/null 2>&1; then \
		mdbook build $(DOCS_DIR); \
	else \
		echo "$(YELLOW)⚠️  mdbook not found - install with: cargo install mdbook$(NC)"; \
	fi
	@echo "$(GREEN)✅ Documentation generated$(NC)"
	@echo "📍 View at: target/doc/$(PROJECT_NAME)/index.html"
	@echo ""

# Serve documentation locally
.PHONY: docs-serve
docs-serve: docs
	@echo "$(BLUE)🌐 Serving documentation...$(NC)"
	@echo "$(CYAN)📖 Opening http://localhost:3000$(NC)"
	@if command -v mdbook >/dev/null 2>&1; then \
		mdbook serve $(DOCS_DIR) --port 3000; \
	else \
		python3 -m http.server 3000 -d target/doc; \
	fi

# Create example files
.PHONY: examples
examples:
	@echo "$(BLUE)📁 Creating example files...$(NC)"
	@mkdir -p $(EXAMPLES_DIR)
	
	@# Simple SVG chart
	@cat > $(EXAMPLES_DIR)/simple-chart.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300">
  <rect width="400" height="300" fill="#f8f9fa"/>
  <text x="200" y="30" text-anchor="middle" font-family="Arial" font-size="18" fill="#333">Sales Chart</text>
  <rect x="50" y="200" width="40" height="80" fill="#4CAF50"/>
  <rect x="120" y="150" width="40" height="130" fill="#2196F3"/>
  <rect x="190" y="100" width="40" height="180" fill="#FF9800"/>
  <rect x="260" y="170" width="40" height="110" fill="#E91E63"/>
  <text x="70" y="295" text-anchor="middle" font-size="12" fill="#666">Q1</text>
  <text x="140" y="295" text-anchor="middle" font-size="12" fill="#666">Q2</text>
  <text x="210" y="295" text-anchor="middle" font-size="12" fill="#666">Q3</text>
  <text x="280" y="295" text-anchor="middle" font-size="12" fill="#666">Q4</text>
</svg>
EOF

	@# XQR Enhanced Dashboard
	@cat > $(EXAMPLES_DIR)/xqr-dashboard.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" 
     xmlns:xqr="http://xqr.ai/schema/v1"
     xqr:enhanced="true" width="800" height="600" viewBox="0 0 800 600">
  <metadata>
    <xqr:memory>
      <xqr:factual>{"user": "demo", "preferences": {"theme": "dark"}}</xqr:factual>
      <xqr:working>{"currentView": "dashboard"}</xqr:working>
    </xqr:memory>
    <xqr:config>
      {"version": "1.0", "interactive": true, "pwa_capable": true, "memory_enabled": true}
    </xqr:config>
  </metadata>
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#667eea"/>
      <stop offset="100%" stop-color="#764ba2"/>
    </linearGradient>
  </defs>
  <rect width="800" height="600" fill="url(#bgGradient)"/>
  <rect x="0" y="0" width="800" height="80" fill="rgba(255,255,255,0.1)"/>
  <text x="40" y="50" font-family="Arial" font-size="24" fill="white" font-weight="bold">🧠 XQR Dashboard</text>
  <g xqr:interactive="true" xqr:data-binding="sales_data">
    <rect x="50" y="120" width="300" height="200" fill="rgba(255,255,255,0.9)" rx="10"/>
    <text x="200" y="145" text-anchor="middle" font-family="Arial" font-size="16" fill="#333">Interactive Sales Data</text>
  </g>
  <script type="application/javascript">
    window.xqrMemory = {
      factual: { user: "demo", preferences: { theme: "dark" } },
      working: { currentView: "dashboard" },
      episodic: [], semantic: []
    };
    console.log('🧠 XQR Enhanced Dashboard initialized');
  </script>
</svg>
EOF

	@# Interactive Pong Game
	@cat > $(EXAMPLES_DIR)/pong-game.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" 
     xmlns:xqr="http://xqr.ai/schema/v1"
     xqr:enhanced="true" width="600" height="400" viewBox="0 0 600 400">
  <metadata>
    <xqr:memory>
      <xqr:factual>{"highScore": 0, "player": "guest"}</xqr:factual>
      <xqr:working>{"gameState": "ready", "score": 0}</xqr:working>
    </xqr:memory>
  </metadata>
  <rect width="600" height="400" fill="#1a1a1a"/>
  <line x1="300" y1="0" x2="300" y2="400" stroke="#333" stroke-width="2" stroke-dasharray="10,10"/>
  <rect id="leftPaddle" x="20" y="150" width="10" height="100" fill="white"/>
  <rect id="rightPaddle" x="570" y="150" width="10" height="100" fill="white"/>
  <circle id="ball" cx="300" cy="200" r="8" fill="white"/>
  <text x="300" y="30" font-family="Arial" font-size="18" fill="white" text-anchor="middle">🧠 XQR Pong - Click to Start</text>
  <script type="application/javascript">
    console.log('🎮 XQR Pong Game loaded - click to start!');
  </script>
</svg>
EOF

	@echo "$(GREEN)✅ Example files created in $(EXAMPLES_DIR)/$(NC)"
	@echo "📁 Files:"
	@echo "  - simple-chart.svg        (Basic SVG chart)"
	@echo "  - xqr-dashboard.svg       (XQR Enhanced dashboard)"
	@echo "  - pong-game.svg           (Interactive game)"
	@echo ""

# Release build
.PHONY: release
release: clean test build-all
	@echo "$(BLUE)🚀 Creating release build...$(NC)"
	@mkdir -p $(DIST_DIR)
	@cp $(TARGET_DIR)/release/$(PROJECT_NAME) $(DIST_DIR)/
	@if [ -f "$(TARGET_DIR)/release/$(PROJECT_NAME)-gui" ]; then \
		cp $(TARGET_DIR)/release/$(PROJECT_NAME)-gui $(DIST_DIR)/; \
	fi
	@cp README.md $(DIST_DIR)/
	@cp LICENSE $(DIST_DIR)/
	@echo "$(GREEN)✅ Release build completed$(NC)"
	@echo "📦 Distribution files in $(DIST_DIR)/$(NC)"
	@echo ""

# Create distribution packages
.PHONY: package
package: release
	@echo "$(BLUE)📦 Creating distribution packages...$(NC)"
	
	@# Linux package
	@tar -czf $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-linux-x86_64.tar.gz -C $(DIST_DIR) .
	
	@# Create .deb package structure
	@mkdir -p $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/DEBIAN
	@mkdir -p $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/usr/bin
	@mkdir -p $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/usr/share/applications
	@mkdir -p $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/usr/share/doc/$(PROJECT_NAME)
	
	@# Control file for .deb
	@cat > $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/DEBIAN/control << EOF
Package: $(PROJECT_NAME)
Version: $(VERSION)
Section: utils
Priority: optional
Architecture: amd64
Maintainer: XQR Team <team@xqr.ai>
Description: SVG Viewer & PWA Launcher with XQR Integration
 SView is an advanced tool for managing, viewing and running SVG files
 as PWA applications with XQR memory system integration.
EOF
	
	@# Copy files to .deb structure
	@cp $(DIST_DIR)/$(PROJECT_NAME) $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/usr/bin/
	@cp README.md $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/usr/share/doc/$(PROJECT_NAME)/
	@cp LICENSE $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION)/usr/share/doc/$(PROJECT_NAME)/
	
	@# Build .deb package
	@if command -v dpkg-deb >/dev/null 2>&1; then \
		dpkg-deb --build $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION); \
		mv $(DIST_DIR)/deb/$(PROJECT_NAME)_$(VERSION).deb $(DIST_DIR)/; \
		echo "$(GREEN)✅ .deb package created$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  dpkg-deb not found - skipping .deb package$(NC)"; \
	fi
	
	@# Create AppImage (Linux)
	@if command -v appimagetool >/dev/null 2>&1; then \
		mkdir -p $(DIST_DIR)/appimage/$(PROJECT_NAME).AppDir/usr/bin; \
		cp $(DIST_DIR)/$(PROJECT_NAME) $(DIST_DIR)/appimage/$(PROJECT_NAME).AppDir/usr/bin/; \
		echo "[Desktop Entry]\nName=SView\nExec=$(PROJECT_NAME)\nIcon=$(PROJECT_NAME)\nType=Application\nCategories=Utility;" > $(DIST_DIR)/appimage/$(PROJECT_NAME).AppDir/$(PROJECT_NAME).desktop; \
		appimagetool $(DIST_DIR)/appimage/$(PROJECT_NAME).AppDir $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-x86_64.AppImage; \
		echo "$(GREEN)✅ AppImage created$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  appimagetool not found - skipping AppImage$(NC)"; \
	fi
	
	@echo "$(GREEN)✅ Distribution packages created$(NC)"
	@echo ""

# Docker build
.PHONY: docker
docker:
	@echo "$(BLUE)🐳 Building Docker image...$(NC)"
	@cat > Dockerfile << 'EOF'
FROM rust:1.70 as builder
WORKDIR /app
COPY . .
RUN cargo build --release --all-features

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    chromium-browser \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/sview /usr/local/bin/
COPY --from=builder /app/examples /usr/share/sview/examples
EXPOSE 8080
CMD ["sview", "serve", "--port", "8080"]
EOF
	@docker build -t $(PROJECT_NAME):$(VERSION) .
	@docker tag $(PROJECT_NAME):$(VERSION) $(PROJECT_NAME):latest
	@echo "$(GREEN)✅ Docker image built$(NC)"
	@echo "🐳 Run with: docker run -p 8080:8080 $(PROJECT_NAME):latest"
	@echo ""

# Publish to registries
.PHONY: publish
publish: package
	@echo "$(BLUE)📤 Publishing to registries...$(NC)"
	
	@# Cargo publish
	@echo "Publishing to crates.io..."
	@cargo publish --dry-run
	@read -p "Publish to crates.io? (y/N): " confirm; \
	if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then \
		cargo publish; \
		echo "$(GREEN)✅ Published to crates.io$(NC)"; \
	fi
	
	@# npm publish (if GUI exists)
	@if [ -d "$(GUI_DIR)" ]; then \
		echo "Publishing GUI to npm..."; \
		cd $(GUI_DIR) && npm publish --dry-run; \
		read -p "Publish GUI to npm? (y/N): " confirm; \
		if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then \
			cd $(GUI_DIR) && npm publish; \
			echo "$(GREEN)✅ Published GUI to npm$(NC)"; \
		fi; \
	fi
	
	@# Docker Hub publish
	@read -p "Publish to Docker Hub? (y/N): " confirm; \
	if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then \
		docker push $(PROJECT_NAME):$(VERSION); \
		docker push $(PROJECT_NAME):latest; \
		echo "$(GREEN)✅ Published to Docker Hub$(NC)"; \
	fi
	
	@echo "$(GREEN)✅ Publishing completed$(NC)"
	@echo ""

# Benchmark
.PHONY: benchmark
benchmark: build
	@echo "$(BLUE)⚡ Running benchmarks...$(NC)"
	@cargo bench
	@echo "$(GREEN)✅ Benchmarks completed$(NC)"
	@echo ""

# Security audit
.PHONY: audit
audit:
	@echo "$(BLUE)🔒 Running security audit...$(NC)"
	@cargo audit
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm audit; \
	fi
	@echo "$(GREEN)✅ Security audit completed$(NC)"
	@echo ""

# Demo mode
.PHONY: demo
demo: examples install
	@echo "$(BLUE)🎬 Starting demo mode...$(NC)"
	@echo ""
	@echo "$(CYAN)📋 Listing example SVG files:$(NC)"
	@$(PROJECT_NAME) ls $(EXAMPLES_DIR)
	@echo ""
	@echo "$(CYAN)🚀 Launching XQR Dashboard:$(NC)"
	@$(PROJECT_NAME) $(EXAMPLES_DIR)/xqr-dashboard.svg &
	@sleep 2
	@echo ""
	@echo "$(CYAN)🎮 Launching Pong Game:$(NC)"
	@$(PROJECT_NAME) $(EXAMPLES_DIR)/pong-game.svg &
	@sleep 2
	@echo ""
	@echo "$(GREEN)🎉 Demo started! Check your browser windows.$(NC)"
	@echo ""

# Performance test
.PHONY: perf-test
perf-test: build examples
	@echo "$(BLUE)⚡ Running performance tests...$(NC)"
	@echo ""
	@echo "$(CYAN)📊 Scanning performance:$(NC)"
	@time $(PROJECT_NAME) ls $(EXAMPLES_DIR) > /dev/null
	@echo ""
	@echo "$(CYAN)🚀 Launch performance:$(NC)"
	@time $(PROJECT_NAME) $(EXAMPLES_DIR)/simple-chart.svg --dry-run
	@echo ""
	@echo "$(GREEN)✅ Performance tests completed$(NC)"
	@echo ""

# Watch mode for development
.PHONY: watch
watch:
	@echo "$(BLUE)👀 Starting file watch mode...$(NC)"
	@if command -v cargo-watch >/dev/null 2>&1; then \
		cargo watch -x 'run -- ls'; \
	else \
		echo "$(YELLOW)💡 Install cargo-watch for better experience: cargo install cargo-watch$(NC)"; \
		while true; do \
			inotifywait -e modify $(SRC_DIR)/**/*.rs 2>/dev/null && cargo run -- ls; \
		done; \
	fi

# CI/CD simulation
.PHONY: ci
ci: check-requirements lint test build audit
	@echo "$(GREEN)✅ CI/CD pipeline simulation completed successfully$(NC)"
	@echo ""

# Quick start for new users
.PHONY: quickstart
quickstart: install-deps examples install
	@echo "$(BLUE)🚀 SView Quick Start$(NC)"
	@echo "==================="
	@echo ""
	@echo "$(GREEN)✅ SView installed successfully!$(NC)"
	@echo ""
	@echo "$(CYAN)📖 Quick commands to try:$(NC)"
	@echo "  $(PROJECT_NAME) ls                                    # List SVG files"
	@echo "  $(PROJECT_NAME) $(EXAMPLES_DIR)/simple-chart.svg      # Launch simple chart"
	@echo "  $(PROJECT_NAME) $(EXAMPLES_DIR)/xqr-dashboard.svg     # Launch XQR dashboard"
	@echo "  $(PROJECT_NAME) $(EXAMPLES_DIR)/pong-game.svg         # Launch game"
	@echo "  $(PROJECT_NAME) --help                                # Show help"
	@echo ""
	@echo "$(PURPLE)🧠 XQR Features:$(NC)"
	@echo "  • Memory system for intelligent file management"
	@echo "  • PWA launcher for web-app experience" 
	@echo "  • Multi-language code execution"
	@echo "  • Cross-platform compatibility"
	@echo ""
	@echo "$(YELLOW)💡 Next steps:$(NC)"
	@echo "  1. Try the demo: make demo"
	@echo "  2. Read docs: make docs-serve"
	@echo "  3. Create your own SVG files with XQR enhancement"
	@echo ""

# Development environment setup
.PHONY: dev-setup
dev-setup: check-requirements
	@echo "$(BLUE)🔧 Setting up development environment...$(NC)"
	@rustup component add clippy rustfmt
	@cargo install cargo-watch cargo-audit cargo-tarpaulin
	@if command -v npm >/dev/null 2>&1; then \
		npm install -g @electron/rebuild electron-builder; \
	fi
	@echo "$(GREEN)✅ Development environment ready$(NC)"
	@echo ""

# Version bump
.PHONY: version-bump
version-bump:
	@echo "$(BLUE)📈 Version bump$(NC)"
	@echo "Current version: $(VERSION)"
	@read -p "New version: " new_version; \
	sed -i "s/version = \"$(VERSION)\"/version = \"$new_version\"/g" Cargo.toml; \
	sed -i "s/VERSION = $(VERSION)/VERSION = $new_version/g" Makefile; \
	sed -i "s/\"version\": \"$(VERSION)\"/\"version\": \"$new_version\"/g" package.json 2>/dev/null || true; \
	echo "$(GREEN)✅ Version bumped to $new_version$(NC)"

# Show project status
.PHONY: status
status:
	@echo "$(BLUE)📊 Project Status$(NC)"
	@echo "=================="
	@echo ""
	@echo "$(CYAN)📦 Project Info:$(NC)"
	@echo "  Name: $(PROJECT_NAME)"
	@echo "  Version: $(VERSION)"
	@echo "  Rust Version: $(shell rustc --version 2>/dev/null || echo 'Not installed')"
	@echo "  Node Version: $(shell node --version 2>/dev/null || echo 'Not installed')"
	@echo ""
	@echo "$(CYAN)📁 Directory Status:$(NC)"
	@echo "  Source files: $(shell find $(SRC_DIR) -name '*.rs' | wc -l) Rust files"
	@echo "  Examples: $(shell find $(EXAMPLES_DIR) -name '*.svg' 2>/dev/null | wc -l) SVG files"
	@echo "  Tests: $(shell find . -name '*test*.rs' | wc -l) test files"
	@echo ""
	@echo "$(CYAN)🔧 Build Status:$(NC)"
	@if [ -f "$(TARGET_DIR)/release/$(PROJECT_NAME)" ]; then \
		echo "  CLI Binary: ✅ Built"; \
		echo "  Binary size: $(du -h $(TARGET_DIR)/release/$(PROJECT_NAME) | cut -f1)"; \
	else \
		echo "  CLI Binary: ❌ Not built"; \
	fi
	@if [ -f "$(TARGET_DIR)/release/$(PROJECT_NAME)-gui" ]; then \
		echo "  GUI Binary: ✅ Built"; \
	else \
		echo "  GUI Binary: ❌ Not built"; \
	fi
	@echo ""

# All-in-one target for complete setup
.PHONY: setup
setup: dev-setup quickstart
	@echo "$(GREEN)🎉 Complete setup finished!$(NC)"
	@echo "$(CYAN)🚀 You're ready to use SView!$(NC)"
	@echo ""