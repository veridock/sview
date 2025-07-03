# SView - SVG Viewer & PWA Launcher with sView Integration
# Makefile for project management

# Variables
export PROJECT_NAME = sview
export VERSION = 1.0.0
export RUST_VERSION = 1.70
export NODE_VERSION = 18

# Directories
export SRC_DIR = src
export GUI_DIR = gui
export DIST_DIR = dist
export TARGET_DIR = target
export EXAMPLES_DIR = examples
export DOCS_DIR = docs

# Build configuration
export CARGO_FLAGS = --release --no-default-features --features=encryption,watch
export NPM_FLAGS = --production
export RUSTFLAGS = -C target-cpu=native

# Scripts directory
SCRIPTS_DIR = scripts

# Colors for output
export RED = \033[0;31m
export GREEN = \033[0;32m
export YELLOW = \033[0;33m
export BLUE = \033[0;34m
export PURPLE = \033[0;35m
export CYAN = \033[0;36m
export NC = \033[0m # No Color

# Default target
.PHONY: all
all: help

# Help
.PHONY: help
help:
	@echo "$(BLUE)🧠 SView - SVG Viewer & PWA Launcher$(NC)"
	@echo "$(PURPLE)🔗 sView Integration Enabled$(NC)"
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
	@$(SCRIPTS_DIR)/check_requirements.sh

# Install dependencies
.PHONY: install-deps
install-deps:
	@$(SCRIPTS_DIR)/install_deps.sh

# Build CLI application
.PHONY: build
build:
	@$(SCRIPTS_DIR)/build_cli.sh

# Build GUI application
.PHONY: build-gui
build-gui:
	@$(SCRIPTS_DIR)/build_gui.sh

# Build everything
.PHONY: build-all
build-all: build
	@echo "$(GREEN)✅ CLI built successfully$(NC)"
	@echo ""

# Development mode
.PHONY: dev
dev:
	@echo "$(BLUE)🚀 Starting development server...$(NC)"
	@cargo watch -x run

# GUI development mode
.PHONY: dev-gui
dev-gui:
	@echo "$(BLUE)🚀 Starting GUI development server...$(NC)"
	@cd $(GUI_DIR) && npm run dev

# Run tests
.PHONY: test
test:
	@$(SCRIPTS_DIR)/run_tests.sh

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "$(BLUE)📊 Running tests with coverage...$(NC)"
	@$(SCRIPTS_DIR)/run_tests.sh --coverage

# Run linters
.PHONY: lint
lint:
	@echo "$(BLUE)🔍 Running linters...$(NC)"
	@cargo clippy -- -D warnings
	@if [ -d "$(GUI_DIR)" ]; then \
		echo "$(YELLOW)Running ESLint...$(NC)"; \
		cd $(GUI_DIR) && npx eslint . --ext .js,.jsx,.ts,.tsx; \
	fi

# Format code
.PHONY: format
format:
	@echo "$(BLUE)🎨 Formatting code...$(NC)"
	@cargo fmt --all
	@if [ -d "$(GUI_DIR)" ]; then \
		echo "$(YELLOW)Formatting frontend code...$(NC)"; \
		cd $(GUI_DIR) && npx prettier --write .; \
	fi

# Install locally
.PHONY: install
install:
	@$(SCRIPTS_DIR)/install.sh

# Uninstall
.PHONY: uninstall
uninstall:
	@echo "$(BLUE)🗑️  Uninstalling SView...$(NC)"
	@rm -f ~/.local/bin/$(PROJECT_NAME)
	@rm -rf ~/.sview
	@echo "$(GREEN)✅ SView has been uninstalled$(NC)"

# Clean build artifacts
.PHONY: clean
clean:
	@$(SCRIPTS_DIR)/clean.sh

# Clean cache
.PHONY: clean-cache
clean-cache:
	@echo "$(BLUE)🧹 Cleaning cache...$(NC)"
	@cargo clean
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && rm -rf node_modules; \
	fi

# Update dependencies
.PHONY: update
update:
	@echo "$(BLUE)🔄 Updating dependencies...$(NC)"
	@cargo update
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm update; \
	fi

# Check project health
.PHONY: check
check:
	@echo "$(BLUE)🔍 Checking project health...$(NC)"
	@cargo check
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm audit; \
	fi

# Generate documentation
.PHONY: docs
docs:
	@echo "$(BLUE)📚 Generating documentation...$(NC)"
	@cargo doc --no-deps
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && npm run docs; \
	fi

# Serve documentation locally
.PHONY: docs-serve
docs-serve:
	@echo "$(BLUE)🌐 Serving documentation at http://localhost:3000$(NC)"
	@cd target/doc && python3 -m http.server 3000

# Create example files
.PHONY: examples
examples:
	@$(SCRIPTS_DIR)/generate_examples.sh
	@# sView Enhanced Dashboard
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '<svg xmlns="http://www.w3.org/2000/svg"' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '     xmlns:sview="http://sview.veridock.com/schema/v1"' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '     sview:enhanced="true" width="800" height="600" viewBox="0 0 800 600">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <metadata>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <sview:memory>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <sview:factual>{"user": "demo", "preferences": {"theme": "dark"}}</sview:factual>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <sview:working>{"currentView": "dashboard"}</sview:working>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </sview:memory>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <sview:config>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      {"version": "1.0", "interactive": true, "pwa_capable": true, "memory_enabled": true}' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </sview:config>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  </metadata>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <defs>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <stop offset="0%" stop-color="#667eea"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <stop offset="100%" stop-color="#764ba2"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </linearGradient>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  </defs>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <rect width="800" height="600" fill="url(#bgGradient)"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <rect x="0" y="0" width="800" height="80" fill="rgba(255,255,255,0.1)"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <text x="40" y="50" font-family="Arial" font-size="24" fill="white" font-weight="bold">🧠 sView Dashboard</text>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <g sview:interactive="true" sview:data-binding="sales_data">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="40" y="120" width="720" height="400" rx="10" fill="rgba(255,255,255,0.9)" stroke="#e2e8f0" stroke-width="1"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <text x="60" y="160" font-family="Arial" font-size="20" fill="#2d3748">Sales Overview</text>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <line x1="60" y1="180" x2="740" y2="180" stroke="#e2e8f0" stroke-width="1"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <!-- Chart content would be dynamically populated by sView -->' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="100" y="250" width="40" height="200" fill="#4fd1c5" rx="2">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <animate attributeName="height" from="0" to="200" dur="1s" fill="freeze"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </rect>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="200" y="300" width="40" height="150" fill="#4fd1c5" rx="2">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <animate attributeName="height" from="0" to="150" dur="1s" fill="freeze" begin="0.2s"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </rect>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="300" y="200" width="40" height="250" fill="#4fd1c5" rx="2">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <animate attributeName="height" from="0" to="250" dur="1s" fill="freeze" begin="0.4s"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </rect>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="400" y="150" width="40" height="300" fill="#4fd1c5" rx="2">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <animate attributeName="height" from="0" to="300" dur="1s" fill="freeze" begin="0.6s"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </rect>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="500" y="220" width="40" height="230" fill="#4fd1c5" rx="2">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <animate attributeName="height" from="0" to="230" dur="1s" fill="freeze" begin="0.8s"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </rect>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="600" y="180" width="40" height="270" fill="#4fd1c5" rx="2">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '      <animate attributeName="height" from="0" to="270" dur="1s" fill="freeze" begin="1s"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    </rect>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  </g>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <g sview:interactive="true" sview:onclick="showDetails('"'"'performance'"'"')">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="40" y="550" width="350" height="30" rx="4" fill="rgba(255,255,255,0.2)" stroke="#e2e8f0" stroke-width="1"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <text x="60" y="572" font-family="Arial" font-size="14" fill="white">🔍 Click for Performance Details</text>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  </g>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  <g sview:interactive="true" sview:onclick="showDetails('"'"'settings'"'"')">' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <rect x="430" y="550" width="330" height="30" rx="4" fill="rgba(255,255,255,0.2)" stroke="#e2e8f0" stroke-width="1"/>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '    <text x="450" y="572" font-family="Arial" font-size="14" fill="white">⚙️ Configure Dashboard Settings</text>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '  </g>' >> $(EXAMPLES_DIR)/sview-dashboard.svg
	@echo '</svg>' >> $(EXAMPLES_DIR)/sview-dashboard.svg

	@# Interactive Pong Game
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(EXAMPLES_DIR)/pong-game.svg
	@echo '<svg xmlns="http://www.w3.org/2000/svg"' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '     xmlns:sview="http://sview.veridock.com/schema/v1"' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '     sview:enhanced="true" width="600" height="400" viewBox="0 0 600 400">' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <metadata>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '    <sview:memory>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '      <sview:factual>{"highScore": 0, "player": "guest"}</sview:factual>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '      <sview:working>{"gameState": "ready", "score": 0}</sview:working>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '    </sview:memory>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  </metadata>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <rect width="600" height="400" fill="#1a1a1a"/>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <line x1="300" y1="0" x2="300" y2="400" stroke="#333" stroke-width="2" stroke-dasharray="10,10"/>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <rect id="leftPaddle" x="20" y="150" width="10" height="100" fill="white"/>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <rect id="rightPaddle" x="570" y="150" width="10" height="100" fill="white"/>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <circle id="ball" cx="300" cy="200" r="8" fill="white"/>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <text x="300" y="30" font-family="Arial" font-size="18" fill="white" text-anchor="middle">🧠 sView Pong - Click to Start</text>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  <script type="application/javascript">' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '    console.log('"'"'🎮 sView Pong Game loaded - click to start!'"'"');' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '    document.querySelector('"'"'svg'"'"').addEventListener('"'"'click'"'"', () => {' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '      const event = new CustomEvent('"'"'sview:interaction'"'"', {' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '        detail: { type: '"'"'game_start'"'"', player: '"'"'user'"'"' }' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '      });' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '      document.dispatchEvent(event);' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '    });' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '  </script>' >> $(EXAMPLES_DIR)/pong-game.svg
	@echo '</svg>' >> $(EXAMPLES_DIR)/pong-game.svg

	@# Minimal Memory Example
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '<svg xmlns="http://www.w3.org/2000/svg"' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '     xmlns:sview="http://sview.veridock.com/schema/v1"' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '     sview:enhanced="true" width="400" height="200" viewBox="0 0 400 200">' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '  <metadata>' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '    <sview:memory>' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '      <sview:factual>{"type": "minimal"}</sview:factual>' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '    </sview:memory>' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '  </metadata>' >> $(EXAMPLES_DIR)/minimal-memory.svg
	@echo '</svg>' >> $(EXAMPLES_DIR)/minimal-memory.svg

	@echo "$(GREEN)✅ Example files created in $(EXAMPLES_DIR)/$(NC)"
	@echo "📁 Files:"
	@echo "  - simple-chart.svg        (Basic SVG chart)"
	@echo "  - sview-dashboard.svg       (sView Enhanced dashboard)"
	@echo "  - pong-game.svg           (Interactive game)"
	@echo ""

# Release build
.PHONY: release
release: clean test build-all
	@$(SCRIPTS_DIR)/create_release.sh

# Create distribution packages
.PHONY: package
package: build-all
	@$(SCRIPTS_DIR)/package_release.sh

# Docker build
.PHONY: docker
docker:
	@$(SCRIPTS_DIR)/build_docker.sh
	@echo 'COPY --from=builder /app/examples /usr/share/sview/examples' >> Dockerfile
	@echo 'EXPOSE 8080' >> Dockerfile
	@echo 'WORKDIR /data' >> Dockerfile
	@echo 'ENTRYPOINT ["sview", "serve"]' >> Dockerfile
	@echo 'CMD ["--port", "8080"]' >> Dockerfile
	@docker build -t $(PROJECT_NAME):$(VERSION) .
	@docker tag $(PROJECT_NAME):$(VERSION) $(PROJECT_NAME):latest
	@echo "$(GREEN)✅ Docker image built$(NC)"
	@echo "🐳 Run with: docker run -p 8080:8080 $(PROJECT_NAME):latest"
	@echo ""

# Publish to registries
.PHONY: publish
publish:
	@$(SCRIPTS_DIR)/publish.sh
# Push changes to remote repository
.PHONY: push
push:
	@$(SCRIPTS_DIR)/push.sh
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
# Run security audit
.PHONY: audit
audit:
	@$(SCRIPTS_DIR)/run_audit.sh
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
	@echo "$(CYAN)🚀 Launching sView Dashboard:$(NC)"
	@$(PROJECT_NAME) $(EXAMPLES_DIR)/sview-dashboard.svg &
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
	@echo "  $(PROJECT_NAME) $(EXAMPLES_DIR)/sview-dashboard.svg     # Launch sView dashboard"
	@echo "  $(PROJECT_NAME) $(EXAMPLES_DIR)/pong-game.svg         # Launch game"
	@echo "  $(PROJECT_NAME) --help                                # Show help"
	@echo ""
	@echo "$(PURPLE)🧠 sView Features:$(NC)"
	@echo "  • Memory system for intelligent file management"
	@echo "  • PWA launcher for web-app experience" 
	@echo "  • Multi-language code execution"
	@echo "  • Cross-platform compatibility"
	@echo ""
	@echo "$(YELLOW)💡 Next steps:$(NC)"
	@echo "  1. Try the demo: make demo"
	@echo "  2. Read docs: make docs-serve"
	@echo "  3. Create your own SVG files with sView enhancement"
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
