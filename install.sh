#!/bin/bash
# install.sh - Skrypt instalacyjny SView

set -e

echo "🧠 SView - SVG Viewer & PWA Launcher"
echo "🔗 XQR Integration Enabled"
echo "=================================="
echo

# Sprawdź system operacyjny
OS=$(uname -s)
ARCH=$(uname -m)

echo "Wykryto system: $OS $ARCH"

# Sprawdź wymagania
check_requirements() {
    echo "📋 Sprawdzanie wymagań..."

    # Sprawdź Rust
    if ! command -v rustc &> /dev/null; then
        echo "❌ Rust nie jest zainstalowany"
        echo "💡 Zainstaluj Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        exit 1
    fi

    # Sprawdź Node.js (dla GUI)
    if ! command -v node &> /dev/null; then
        echo "⚠️  Node.js nie jest zainstalowany - GUI może nie działać"
        echo "💡 Zainstaluj Node.js: https://nodejs.org/"
    fi

    # Sprawdź przeglądarki
    BROWSER_FOUND=false
    for browser in chromium google-chrome firefox; do
        if command -v $browser &> /dev/null; then
            echo "✅ Znaleziono przeglądarkę: $browser"
            BROWSER_FOUND=true
            break
        fi
    done

    if [ "$BROWSER_FOUND" = false ]; then
        echo "⚠️  Nie znaleziono przeglądarki - PWA może nie działać"
        echo "💡 Zainstaluj chromium lub firefox"
    fi

    echo "✅ Sprawdzanie wymagań zakończone"
    echo
}

# Instalacja SView
install_sview() {
    echo "🔧 Instalowanie SView..."

    # Kompilacja z optymalizacjami
    echo "⚙️  Kompilowanie..."
    cargo build --release --all-features

    # Tworzenie katalogów
    mkdir -p ~/.sview/{cache,config,logs}
    mkdir -p ~/.local/bin

    # Kopiowanie binariów
    cp target/release/sview ~/.local/bin/
    if [ -f target/release/sview-gui ]; then
        cp target/release/sview-gui ~/.local/bin/
    fi

    # Tworzenie domyślnej konfiguracji
    cat > ~/.sview/config/config.toml << EOF
[general]
version = "1.0.0"
scan_depth = 10
cache_thumbnails = true

[browser]
command = "chromium"
flags = ["--app", "--new-window", "--disable-web-security"]

[performance]
parallel_scan = true
max_threads = 0  # 0 = auto-detect
memory_liApache = "512MB"

[xqr]
enabled = true
memory_encryption = true
auto_enhance = false

[security]
encryption_algorithm = "AES-256-GCM"
key_derivation = "Argon2id"
audit_trail = true

[languages]
supported = ["javascript", "python", "rust", "go", "ruby", "php"]

[ui]
default_columns = 4
default_view = "grid"
theme = "auto"
EOF

    # Dodanie do PATH
    if ! grep -q "~/.local/bin" ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo "✅ Dodano ~/.local/bin do PATH w ~/.bashrc"
    fi

    # Tworzenie linków symbolicznych dla łatwego dostępu
    ln -sf ~/.local/bin/sview /usr/local/bin/sview 2>/dev/null || true

    echo "✅ SView zainstalowany pomyślnie!"
    echo
}

# Instalacja dodatków GUI
install_gui() {
    echo "🎨 Instalowanie interfejsu graficznego..."

    if command -v node &> /dev/null; then
        # Instalacja Electron dla GUI
        npm install -g electron

        # Tworzenie aplikacji Electron
        mkdir -p ~/.sview/gui

        # package.json dla Electron
        cat > ~/.sview/gui/package.json << EOF
{
  "name": "sview-gui",
  "version": "1.0.0",
  "description": "SView Graphical Interface",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder"
  },
  "dependencies": {
    "electron": "^27.0.0"
  },
  "devDependencies": {
    "electron-builder": "^24.0.0"
  }
}
EOF

        # main.js dla Electron
        cat > ~/.sview/gui/main.js << 'EOF'
const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        },
        icon: path.join(__dirname, 'assets', 'icon.png')
    });

    // Load the React GUI (compiled to static files)
    mainWindow.loadFile('dist/index.html');

    if (process.env.NODE_ENV === 'development') {
        mainWindow.webContents.openDevTools();
    }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

// IPC handlers
ipcMain.handle('scan-svg-files', async () => {
    return new Promise((resolve, reject) => {
        const sview = spawn('sview', ['ls', '--json']);
        let data = '';

        sview.stdout.on('data', (chunk) => {
            data += chunk;
        });

        sview.on('close', (code) => {
            if (code === 0) {
                try {
                    resolve(JSON.parse(data));
                } catch (e) {
                    reject(e);
                }
            } else {
                reject(new Error(`sview exited with code ${code}`));
            }
        });
    });
});

ipcMain.handle('launch-svg-pwa', async (event, filePath) => {
    spawn('sview', [filePath], { detached: true });
});
EOF

        echo "✅ GUI zainstalowany pomyślnie!"
    else
        echo "⚠️  Node.js nie jest zainstalowany - pomijanie GUI"
    fi
    echo
}

# Tworzenie plików desktop dla integracji z systemem
create_desktop_integration() {
    echo "🖥️  Tworzenie integracji z systemem..."

    # .desktop file dla SView
    mkdir -p ~/.local/share/applications

    cat > ~/.local/share/applications/sview.desktop << EOF
[Desktop Entry]
Name=SView
Comment=SVG Viewer & PWA Launcher with XQR Integration
Exec=sview %f
Icon=sview
Terminal=false
Type=Application
Categories=Graphics;Viewer;Development;
MimeType=image/svg+xml;
StartupNotify=true
Keywords=svg;viewer;pwa;xqr;
EOF

    # MIME type association
    cat > ~/.local/share/mime/packages/sview.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    <mime-type type="application/xqr">
        <comment>XQR Enhanced Document</comment>
        <glob pattern="*.xqr"/>
        <icon name="sview"/>
    </mime-type>
</mime-info>
EOF

    # Aktualizacja bazy MIME
    update-mime-database ~/.local/share/mime 2>/dev/null || true
    update-desktop-database ~/.local/share/applications 2>/dev/null || true

    echo "✅ Integracja z systemem utworzona!"
    echo
}

# Tworzenie przykładowych plików SVG
create_examples() {
    echo "📁 Tworzenie przykładowych plików..."

    mkdir -p ~/sview-examples

    # Prosty SVG
    cat > ~/sview-examples/simple-chart.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300">
  <rect width="400" height="300" fill="#f8f9fa"/>
  <text x="200" y="30" text-anchor="middle" font-family="Arial" font-size="18" fill="#333">Prosty wykres</text>

  <!-- Bars -->
  <rect x="50" y="200" width="40" height="80" fill="#4CAF50"/>
  <rect x="120" y="150" width="40" height="130" fill="#2196F3"/>
  <rect x="190" y="100" width="40" height="180" fill="#FF9800"/>
  <rect x="260" y="170" width="40" height="110" fill="#E91E63"/>

  <!-- Labels -->
  <text x="70" y="295" text-anchor="middle" font-size="12" fill="#666">Q1</text>
  <text x="140" y="295" text-anchor="middle" font-size="12" fill="#666">Q2</text>
  <text x="210" y="295" text-anchor="middle" font-size="12" fill="#666">Q3</text>
  <text x="280" y="295" text-anchor="middle" font-size="12" fill="#666">Q4</text>
</svg>
EOF

    # XQR Enhanced SVG
    cat > ~/sview-examples/xqr-dashboard.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xqr="http://xqr.ai/schema/v1"
     xqr:enhanced="true"
     width="800" height="600" viewBox="0 0 800 600">

  <metadata>
    <xqr:memory>
      <xqr:factual>{"preferences": {"theme": "dark"}, "user": "demo"}</xqr:factual>
      <xqr:working>{"currentView": "dashboard", "lastUpdate": "2025-06-29T10:00:00Z"}</xqr:working>
    </xqr:memory>

    <xqr:config>
      {
        "version": "1.0",
        "interactive": true,
        "pwa_capable": true,
        "memory_enabled": true
      }
    </xqr:config>
  </metadata>

  <!-- Background -->
  <rect width="800" height="600" fill="url(#bgGradient)"/>

  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#667eea"/>
      <stop offset="100%" stop-color="#764ba2"/>
    </linearGradient>
  </defs>

  <!-- Header -->
  <rect x="0" y="0" width="800" height="80" fill="rgba(255,255,255,0.1)"/>
  <text x="40" y="50" font-family="Arial" font-size="24" fill="white" font-weight="bold">🧠 XQR Dashboard</text>

  <!-- Interactive widgets -->
  <g xqr:interactive="true" xqr:data-binding="sales_data">
    <!-- Sales chart -->
    <rect x="50" y="120" width="300" height="200" fill="rgba(255,255,255,0.9)" rx="10"/>
    <text x="200" y="145" text-anchor="middle" font-family="Arial" font-size="16" fill="#333">Sales Data</text>

    <!-- Interactive bars -->
    <rect x="80" y="240" width="30" height="60" fill="#4CAF50" onclick="updateMemory('sales', 'Q1')"/>
    <rect x="130" y="220" width="30" height="80" fill="#2196F3" onclick="updateMemory('sales', 'Q2')"/>
    <rect x="180" y="200" width="30" height="100" fill="#FF9800" onclick="updateMemory('sales', 'Q3')"/>
    <rect x="230" y="210" width="30" height="90" fill="#E91E63" onclick="updateMemory('sales', 'Q4')"/>
  </g>

  <!-- Memory status indicator -->
  <g xqr:memory-indicator="true">
    <circle cx="750" cy="50" r="20" fill="rgba(0,255,0,0.3)" stroke="#00ff00" stroke-width="2"/>
    <text x="750" y="55" text-anchor="middle" font-size="12" fill="white">🧠</text>
  </g>

  <script type="application/javascript">
    <![CDATA[
    // XQR Enhanced functionality
    function updateMemory(category, value) {
      console.log('Updating XQR memory:', category, value);

      // Simulate memory update
      if (typeof xqrMemory !== 'undefined') {
        xqrMemory.working[category] = value;
        xqrMemory.episodic.push({
          timestamp: new Date().toISOString(),
          event: 'user_interaction',
          data: { category, value }
        });
      }
    }

    // Initialize XQR memory system
    window.xqrMemory = {
      factual: { preferences: { theme: "dark" }, user: "demo" },
      working: { currentView: "dashboard", lastUpdate: new Date().toISOString() },
      episodic: [],
      semantic: []
    };

    console.log('🧠 XQR Enhanced SVG initialized');
    ]]>
  </script>
</svg>
EOF

    # Interactive game SVG
    cat > ~/sview-examples/pong-game.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xqr="http://xqr.ai/schema/v1"
     xqr:enhanced="true"
     width="600" height="400" viewBox="0 0 600 400">

  <metadata>
    <xqr:memory>
      <xqr:factual>{"highScore": 0, "player": "guest"}</xqr:factual>
      <xqr:working>{"gameState": "ready", "score": 0}</xqr:working>
    </xqr:memory>
  </metadata>

  <!-- Game background -->
  <rect width="600" height="400" fill="#1a1a1a"/>

  <!-- Center line -->
  <line x1="300" y1="0" x2="300" y2="400" stroke="#333" stroke-width="2" stroke-dasharray="10,10"/>

  <!-- Paddles -->
  <rect id="leftPaddle" x="20" y="150" width="10" height="100" fill="white"/>
  <rect id="rightPaddle" x="570" y="150" width="10" height="100" fill="white"/>

  <!-- Ball -->
  <circle id="ball" cx="300" cy="200" r="8" fill="white"/>

  <!-- Score -->
  <text id="leftScore" x="150" y="50" font-family="monospace" font-size="36" fill="white" text-anchor="middle">0</text>
  <text id="rightScore" x="450" y="50" font-family="monospace" font-size="36" fill="white" text-anchor="middle">0</text>

  <!-- Game title -->
  <text x="300" y="30" font-family="Arial" font-size="18" fill="white" text-anchor="middle">🧠 XQR Pong</text>

  <script type="application/javascript">
    <![CDATA[
    // Simple Pong game with XQR memory
    let gameState = {
      ball: { x: 300, y: 200, vx: 3, vy: 2 },
      leftPaddle: { y: 150 },
      rightPaddle: { y: 150 },
      score: { left: 0, right: 0 },
      gameRunning: false
    };

    function updateGame() {
      if (!gameState.gameRunning) return;

      // Move ball
      gameState.ball.x += gameState.ball.vx;
      gameState.ball.y += gameState.ball.vy;

      // Ball collision with top/bottom
      if (gameState.ball.y <= 8 || gameState.ball.y >= 392) {
        gameState.ball.vy = -gameState.ball.vy;
      }

      // Ball collision with paddles
      if (gameState.ball.x <= 38 &&
          gameState.ball.y >= gameState.leftPaddle.y &&
          gameState.ball.y <= gameState.leftPaddle.y + 100) {
        gameState.ball.vx = -gameState.ball.vx;
      }

      if (gameState.ball.x >= 562 &&
          gameState.ball.y >= gameState.rightPaddle.y &&
          gameState.ball.y <= gameState.rightPaddle.y + 100) {
        gameState.ball.vx = -gameState.ball.vx;
      }

      // Score
      if (gameState.ball.x < 0) {
        gameState.score.right++;
        resetBall();
      } else if (gameState.ball.x > 600) {
        gameState.score.left++;
        resetBall();
      }

      // Update visuals
      document.getElementById('ball').setAttribute('cx', gameState.ball.x);
      document.getElementById('ball').setAttribute('cy', gameState.ball.y);
      document.getElementById('leftScore').textContent = gameState.score.left;
      document.getElementById('rightScore').textContent = gameState.score.right;

      // AI for right paddle
      gameState.rightPaddle.y += (gameState.ball.y - gameState.rightPaddle.y - 50) * 0.1;
      document.getElementById('rightPaddle').setAttribute('y', gameState.rightPaddle.y);
    }

    function resetBall() {
      gameState.ball.x = 300;
      gameState.ball.y = 200;
      gameState.ball.vx = -gameState.ball.vx;
    }

    // Mouse control for left paddle
    document.addEventListener('mousemove', (e) => {
      const rect = document.querySelector('svg').getBoundingClientRect();
      const y = ((e.clientY - rect.top) / rect.height) * 400 - 50;
      gameState.leftPaddle.y = Math.max(0, Math.min(300, y));
      document.getElementById('leftPaddle').setAttribute('y', gameState.leftPaddle.y);
    });

    // Start game on click
    document.addEventListener('click', () => {
      gameState.gameRunning = true;
      setInterval(updateGame, 16); // ~60fps
    });

    console.log('🎮 XQR Pong Game loaded - click to start!');
    ]]>
  </script>
</svg>
EOF

    echo "✅ Przykładowe pliki utworzone w ~/sview-examples/"
    echo
}

# Test instalacji
test_installation() {
    echo "🧪 Testowanie instalacji..."

    # Test podstawowej komendy
    if ~/.local/bin/sview --version; then
        echo "✅ Komenda sview działa poprawnie"
    else
        echo "❌ Problem z komendą sview"
        exit 1
    fi

    # Test skanowania
    echo "🔍 Testowanie skanowania..."
    ~/.local/bin/sview ls > /dev/null

    if [ $? -eq 0 ]; then
        echo "✅ Skanowanie działa poprawnie"
    else
        echo "❌ Problem ze skanowaniem"
        exit 1
    fi

    echo "✅ Wszystkie testy przeszły pomyślnie!"
    echo
}

# Główna funkcja instalacji
main() {
    echo "Rozpoczynam instalację SView..."
    echo

    check_requirements
    install_sview

    if command -v node &> /dev/null; then
        install_gui
    fi

    if [ "$OS" = "Linux" ]; then
        create_desktop_integration
    fi

    create_examples
    test_installation

    echo "🎉 SView został pomyślnie zainstalowany!"
    echo
    echo "📖 Jak zacząć:"
    echo "  sview ls                    - Listuj pliki SVG"
    echo "  sview ~/sview-examples/simple-chart.svg  - Uruchom przykład"
    echo "  sview --help               - Pomoc"
    echo
    echo "🎨 Interfejs graficzny:"
    echo "  sview-gui                  - Uruchom GUI (jeśli zainstalowany)"
    echo
    echo "📁 Przykładowe pliki: ~/sview-examples/"
    echo "⚙️  Konfiguracja: ~/.sview/config/config.toml"
    echo "📝 Logi: ~/.sview/logs/"
    echo
    echo "💡 Aby używać 'sview' z dowolnego miejsca, uruchom ponownie terminal"
    echo "   lub wykonaj: source ~/.bashrc"
}

# Uruchom instalację
main "$@"