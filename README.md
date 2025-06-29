# 🧠 SView - SVG Viewer & PWA Launcher

**XQR Integration Enabled** | **Universal File System** | **Cross-Platform**

![SView Logo](https://img.shields.io/badge/SView-1.0.0-blue?style=for-the-badge&logo=svg)
![XQR Integration](https://img.shields.io/badge/XQR-Enhanced-purple?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-green?style=for-the-badge)

SView to zaawansowane narzędzie do zarządzania, przeglądania i uruchamiania plików SVG jako aplikacje PWA (Progressive Web Apps) z integracją systemu pamięci XQR. Projekt łączy w sobie szybkość natywnych aplikacji Rust z możliwościami nowoczesnych technologii webowych.

## 🚀 Główne funkcje

### 📂 Zarządzanie plikami SVG
- **Szybkie skanowanie** - Efektywne przeszukiwanie dysku z wykorzystaniem parallel processing
- **Inteligentne miniaturki** - Automatyczne generowanie ikon UTF-8 na podstawie zawartości SVG
- **Integracja z systemem** - Natywna integracja z systemami Linux/Windows/macOS
- **Obsługa XQR** - Rozpoznawanie i obsługa plików SVG z rozszerzeniami XQR

### 🧠 System pamięci XQR
- **Factual Memory** - Długotrwała pamięć preferencji i ustawień
- **Episodic Memory** - Historia interakcji z plikami i aplikacjami  
- **Semantic Memory** - Relacje semantyczne między plikami
- **Working Memory** - Tymczasowa pamięć sesji

### 🌐 Uruchamianie PWA
- **Tryb aplikacji** - Uruchamianie SVG jako pełnoprawne aplikacje PWA
- **Offline support** - Możliwość pracy bez połączenia internetowego
- **Responsywny interfejs** - Automatyczne dostosowanie do różnych rozmiarów ekranów
- **Native look & feel** - Interfejs przypominający natywne aplikacje

### ⚡ Obsługa języków programowania
- **JavaScript/Node.js** - Bezpośrednie uruchamianie kodu JS
- **Python** - Wykonywanie skryptów Python
- **Rust** - Kompilacja i uruchamianie kodu Rust
- **Go, Ruby, PHP** - Wsparcie dla dodatkowych języków

## 📦 Instalacja

### Automatyczna instalacja (Linux/macOS)

```bash
# Pobierz i uruchom skrypt instalacyjny
curl -sSL https://raw.githubusercontent.com/xqr/sview/main/install.sh | bash

# Lub sklonuj repozytorium i uruchom lokalnie
git clone https://github.com/xqr/sview.git
cd sview
chmod +x install.sh
./install.sh
```

### Manualna instalacja

```bash
# Wymagania: Rust 1.70+, Node.js 18+ (opcjonalnie)
git clone https://github.com/xqr/sview.git
cd sview

# Kompilacja
cargo build --release --all-features

# Kopiowanie do systemu
sudo cp target/release/sview /usr/local/bin/
mkdir -p ~/.sview/{cache,config,logs}

# Konfiguracja (opcjonalnie)
cp config/default.toml ~/.sview/config/config.toml
```

### Instalacja z package managera

```bash
# Arch Linux (AUR)
yay -S sview

# Ubuntu/Debian (przyszła wersja)
sudo apt install sview

# macOS (Homebrew)
brew install xqr/tap/sview

# Windows (Chocolatey)
choco install sview
```

## 🎯 Użycie

### Podstawowe komendy

```bash
# Wyświetl wszystkie pliki SVG z miniaturkami
sview ls

# Uruchom konkretny plik jako PWA
sview dashboard.svg
sview /home/user/projects/chart.svg

# Uruchom interfejs graficzny
sview --grid
sview-gui  # jeśli zainstalowany

# Pomoc
sview --help
sview --version
```

### Zaawansowane opcje

```bash
# Skanowanie z ograniczeniem głębokości
sview ls --depth 5

# Eksport listy plików
sview ls --export json > files.json
sview ls --export csv > files.csv

# Filtrowanie według typu
sview ls --xqr-only          # Tylko pliki XQR-enhanced
sview ls --interactive       # Tylko interaktywne SVG
sview ls --pwa-capable      # Tylko SVG z możliwością PWA

# Uruchamianie kodu w różnych językach
sview exec javascript "console.log('Hello from JS!')"
sview exec python "print('Hello from Python!')"
sview exec rust "fn main() { println!(\"Hello from Rust!\"); }"

# Praca z pamięcią XQR
sview memory --store "user_preference" "dark_theme"
sview memory --recall "user_preference"
sview memory --export json > my_memory.json

# Tryb watch - monitorowanie zmian
sview watch ~/projects/
```

### Praca z plikami XQR

```bash
# Tworzenie nowego pliku XQR
sview create --template dashboard --name "my-dashboard"

# Konwersja SVG do XQR
sview convert input.svg --output enhanced.xqr

# Walidacja pliku XQR
sview validate my-file.xqr

# Optymalizacja
sview optimize --compress --encrypt my-file.xqr
```

## 🎨 Interfejs graficzny

SView oferuje zarówno interfejs konsolowy, jak i graficzny:

### Funkcje GUI
- **Grid/Lista** - Przełączanie między widokami siatki i listy
- **Podgląd na żywo** - Miniaturki generowane w czasie rzeczywistym
- **Wyszukiwanie** - Filtrowanie plików według nazwy i ścieżki
- **Statistyki** - Informacje o liczbie plików, rozmiarze, typach
- **Drag & Drop** - Przeciąganie plików do aplikacji
- **Batch operations** - Operacje na wielu plikach jednocześnie

### Uruchamianie GUI

```bash
# Electron-based GUI
sview-gui

# Web-based interface
sview serve --port 8080
# Następnie otwórz http://localhost:8080

# System tray mode (Linux/Windows)
sview --tray
```

## 🔧 Konfiguracja

### Główny plik konfiguracji (`~/.sview/config/config.toml`)

```toml
[general]
version = "1.0.0"
scan_depth = 10              # Maksymalna głębokość skanowania
cache_thumbnails = true      # Cachowanie miniaturek
auto_update = true          # Automatyczne aktualizacje

[browser]
command = "chromium"        # Komenda przeglądarki
flags = [                   # Flagi uruchamiania
    "--app",
    "--new-window", 
    "--disable-web-security",
    "--allow-file-access-from-files"
]

[performance]
parallel_scan = true        # Równoległe skanowanie
max_threads = 0            # 0 = auto-detect
memory_liApache = "512MB"     # LiApache pamięci
cache_size = "100MB"       # Rozmiar cache

[xqr]
enabled = true             # Obsługa XQR
memory_encryption = true   # Szyfrowanie pamięci
auto_enhance = false       # Automatyczne ulepszanie SVG
compression = "gzip"       # Algorytm kompresji

[security]
encryption_algorithm = "AES-256-GCM"
key_derivation = "Argon2id"
audit_trail = true         # Dziennik audytu
data_classification = "internal"

[languages]
supported = [
    "javascript", "python", "rust", 
    "go", "ruby", "php", "bash"
]

[ui]
default_columns = 4        # Domyślna liczba kolumn
default_view = "grid"      # "grid" lub "list"
theme = "auto"             # "light", "dark", "auto"
animations = true          # Animacje interfejsu

[paths]
scan_paths = [             # Ścieżki do skanowania
    "~/Documents",
    "~/Projects", 
    "~/Desktop"
]
exclude_paths = [          # Wykluczenia
    "node_modules",
    ".git",
    "target"
]
```

### Zmienne środowiskowe

```bash
export SVIEW_CONFIG_DIR="~/.sview"
export SVIEW_CACHE_DIR="~/.sview/cache"
export SVIEW_LOG_LEVEL="info"
export SVIEW_BROWSER="firefox"
export SVIEW_PARALLEL_THREADS="8"
```

## 📊 Przykłady użycia

### 1. Prosty wykres SVG

```xml
<!-- simple-chart.svg -->
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300">
  <rect width="400" height="300" fill="#f8f9fa"/>
  <text x="200" y="30" text-anchor="middle" font-family="Arial" font-size="18">
    Sales Chart
  </text>
  
  <!-- Data bars -->
  <rect x="50" y="200" width="40" height="80" fill="#4CAF50"/>
  <rect x="120" y="150" width="40" height="130" fill="#2196F3"/>
  <rect x="190" y="100" width="40" height="180" fill="#FF9800"/>
  <rect x="260" y="170" width="40" height="110" fill="#E91E63"/>
</svg>
```

Uruchomienie:
```bash
sview simple-chart.svg
```

### 2. XQR Enhanced Dashboard

```xml
<!-- dashboard.svg -->
<svg xmlns="http://www.w3.org/2000/svg" 
     xmlns:xqr="http://xqr.ai/schema/v1"
     xqr:enhanced="true" width="800" height="600">
  
  <metadata>
    <xqr:memory>
      <xqr:factual>{"user": "demo", "preferences": {"theme": "dark"}}</xqr:factual>
      <xqr:working>{"currentView": "dashboard"}</xqr:working>
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
  
  <!-- Interactive content -->
  <g xqr:interactive="true" xqr:data-binding="sales_data">
    <!-- Dashboard widgets -->
  </g>
  
  <script type="application/javascript">
    // XQR Enhanced functionality
    window.xqrMemory = {
      factual: { user: "demo", preferences: { theme: "dark" } },
      working: { currentView: "dashboard" },
      episodic: [],
      semantic: []
    };
    
    console.log('🧠 XQR Enhanced Dashboard initialized');
  </script>
</svg>
```

### 3. Interaktywna gra

```xml
<!-- pong-game.svg -->
<svg xmlns="http://www.w3.org/2000/svg" 
     xmlns:xqr="http://xqr.ai/schema/v1"
     xqr:enhanced="true" width="600" height="400">
  
  <metadata>
    <xqr:memory>
      <xqr:factual>{"highScore": 0, "player": "guest"}</xqr:factual>
      <xqr:working>{"gameState": "ready", "score": 0}</xqr:working>
    </xqr:memory>
  </metadata>
  
  <!-- Game elements -->
  <rect width="600" height="400" fill="#1a1a1a"/>
  <rect id="leftPaddle" x="20" y="150" width="10" height="100" fill="white"/>
  <rect id="rightPaddle" x="570" y="150" width="10" height="100" fill="white"/>
  <circle id="ball" cx="300" cy="200" r="8" fill="white"/>
  
  <script type="application/javascript">
    // Simple Pong game implementation
    // ... (game logic)
  </script>
</svg>
```

## 🧠 System pamięci XQR

### Typy pamięci

1. **Factual Memory** - Długotrwała wiedza faktyczna
   - Preferencje użytkownika
   - Ustawienia aplikacji
   - Dane konfiguracyjne

2. **Episodic Memory** - Historia wydarzeń w czasie
   - Historia uruchamianych plików
   - Interakcje użytkownika
   - Kontekst sesji

3. **Semantic Memory** - Relacje semantyczne
   - Embeddingi wektorowe
   - Powiązania między plikami
   - Kategorie i tagi

4. **Working Memory** - Pamięć robocza sesji
   - Bieżący stan aplikacji
   - Tymczasowe dane
   - Kontekst zadania

### API pamięci

```bash
# Przechowywanie w pamięci
sview memory store factual "user_theme" "dark"
sview memory store episodic "file_opened" "dashboard.svg"

# Wyszukiwanie w pamięci
sview memory recall "user_theme"
sview memory search "dashboard" --type semantic

# Eksport/import pamięci
sview memory export --format json > memory_backup.json
sview memory import memory_backup.json

# Analiza pamięci
sview memory analyze --stats
sview memory compress --threshold 0.8
```

## 🛡️ Bezpieczeństwo

### Szyfrowanie danych

SView używa nowoczesnych algorytmów szyfrowania:

- **AES-256-GCM** - Szyfrowanie symetryczne
- **Argon2id** - Derywacja kluczy
- **Ed25519** - Podpisy cyfrowe
- **X25519** - Wymiana kluczy

### Konfiguracja bezpieczeństwa

```toml
[security]
encryption_algorithm = "AES-256-GCM"
key_derivation = "Argon2id"
key_rotation = true
hardware_security = true    # HSM/TEE gdy dostępne

[privacy]
data_classification = "internal"
retention_policy = "1_year"
anonymization = true
audit_trail = true

[compliance]
gdpr = true
hipaa = false
sox = false
```

### Audyt bezpieczeństwa

```bash
# Sprawdzenie bezpieczeństwa
sview security audit

# Rotacja kluczy
sview security rotate-keys

# Sprawdzenie integralności
sview security verify --all

# Raport bezpieczeństwa
sview security report > security_report.json
```

## 🚀 Wydajność

### Optymalizacje

- **Parallel processing** - Wielowątkowe skanowanie dysku
- **Lazy loading** - Ładowanie na żądanie
- **Caching** - Inteligentne cachowanie wyników
- **Memory mapping** - Efektywne zarządzanie pamięcią
- **SIMD optimizations** - Optymalizacje wektorowe

### Benchmarki

| Operacja | Czas | Uwagi |
|----------|------|-------|
| Skanowanie 1000 plików | < 100ms | SSD, parallel |
| Generowanie miniaturki | < 5ms | Cache miss |
| Uruchomienie PWA | < 200ms | Cold start |
| Wyszukiwanie semantyczne | < 50ms | 1000 embeddings |

### Monitoring wydajności

```bash
# Statystyki wydajności
sview perf stats

# Profiling
sview perf profile --duration 30s

# Benchmark
sview perf benchmark --iterations 100

# Monitoring zasobów
sview perf monitor --live
```

## 🔌 Rozszerzenia i pluginy

### Dostępne pluginy

1. **Cloud Sync** - Synchronizacja z chmurą
2. **AI Integration** - Integracja z modelami AI
3. **Version Control** - Kontrola wersji plików
4. **Collaboration** - Współpraca w czasie rzeczywistym
5. **Export Formats** - Dodatkowe formaty eksportu

### Instalacja pluginów

```bash
# Instalacja z repozytorium
sview plugin install cloud-sync
sview plugin install ai-integration

# Instalacja lokalnie
sview plugin install ./my-plugin.spx

# Lista pluginów
sview plugin list

# Konfiguracja
sview plugin config cloud-sync --provider aws
```

### Tworzenie własnych pluginów

```rust
// Plugin API
use sview_plugin::{Plugin, PluginResult, PluginCapability};

#[derive(Debug)]
pub struct MyPlugin;

impl Plugin for MyPlugin {
    fn name(&self) -> &str { "my-plugin" }
    fn version(&self) -> &str { "1.0.0" }
    
    fn capabilities(&self) -> Vec<PluginCapability> {
        vec![
            PluginCapability::FileFormatSupport,
            PluginCapability::MemoryProvider,
        ]
    }
    
    fn execute(&self, command: PluginCommand) -> PluginResult {
        // Plugin logic
        Ok(PluginResponse::Success)
    }
}
```

## 📚 API Reference

### CLI API

```bash
sview [OPTIONS] [FILE] [SUBCOMMAND]

OPTIONS:
    -h, --help       Pomoc
    -V, --version    Wersja
    -v, --verbose    Tryb verbose
    -q, --quiet      Tryb cichy
    --config <FILE>  Plik konfiguracji

SUBCOMMANDS:
    ls              Lista plików SVG
    exec            Wykonaj kod
    memory          Operacje pamięci
    config          Konfiguracja
    plugin          Zarządzanie pluginami
    server          Uruchom serwer web
    watch           Monitoruj zmiany
```

### REST API (tryb serwera)

```bash
# Uruchom serwer
sview serve --port 8080 --api

# Endpointy API
GET    /api/files           # Lista plików
POST   /api/files/:id/run   # Uruchom plik
GET    /api/memory          # Dane pamięci
POST   /api/memory          # Zapisz w pamięci
GET    /api/stats           # Statystyki
```

### JavaScript API (w PWA)

```javascript
// XQR Memory API
const memory = window.xqrMemory;

// Zapisz w pamięci
memory.store('factual', 'user_preference', { theme: 'dark' });

// Odczytaj z pamięci
const preference = memory.recall('factual', 'user_preference');

// Historia
memory.episodic.push({
  timestamp: new Date().toISOString(),
  event: 'user_action',
  data: { action: 'button_click', target: 'save' }
});

// Wyszukiwanie semantyczne
const results = await memory.semanticSearch('dashboard', 0.8);
```

## 🔄 CI/CD i Development

### Struktura projektu

```
sview/
├── src/                    # Kod źródłowy Rust
│   ├── main.rs            # Główny plik CLI
│   ├── scanner.rs         # Moduł skanowania
│   ├── launcher.rs        # Moduł uruchamiania PWA
│   ├── memory/            # System pamięci XQR
│   └── gui.rs             # Interfejs graficzny
├── gui/                   # Frontend React
│   ├── src/
│   ├── public/
│   └── package.json
├── plugins/               # Pluginy
├── examples/              # Przykładowe pliki
├── tests/                 # Testy
├── docs/                  # Dokumentacja
├── scripts/               # Skrypty pomocnicze
├── Cargo.toml            # Konfiguracja Rust
├── package.json          # Konfiguracja Node.js
└── README.md
```

### Development setup

```bash
# Sklonuj repozytorium
git clone https://github.com/xqr/sview.git
cd sview

# Zainstaluj zależności
cargo build
npm install

# Uruchom w trybie development
cargo run -- ls
npm run dev  # dla GUI

# Testy
cargo test
npm test

# Formatowanie kodu
cargo fmt
npm run format

# Linting
cargo clippy
npm run lint
```

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - run: cargo test --all-features
      
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    steps:
      - uses: actions/checkout@v3
      - run: cargo build --release
      
  release:
    if: startsWith(github.ref, 'refs/tags/')
    needs: [test, build]
    runs-on: ubuntu-latest
    steps:
      - run: cargo publish
```

## 🤝 Współpraca

### Jak pomóc

1. **Zgłaszanie błędów** - Używaj GitHub Issues
2. **Propozycje funkcji** - Feature requests
3. **Kod** - Pull requests
4. **Dokumentacja** - Ulepsz dokumentację
5. **Testy** - Dodaj testy automatyczne
6. **Tłumaczenia** - Pomóż w lokalizacji

### Guidelines

- Używaj conventional comApaches
- Pisz testy dla nowego kodu
- Aktualizuj dokumentację
- Śledź code style (rustfmt)
- Sprawdź z clippy przed PR

### Roadmapa

**v1.1 (Q3 2025)**
- [ ] Integracja z AI models (OpenAI, Anthropic)
- [ ] Cloud synchronization
- [ ] Mobile app (React Native)
- [ ] Plugin marketplace

**v1.2 (Q4 2025)**
- [ ] Real-time collaboration
- [ ] Version control integration
- [ ] Advanced analytics
- [ ] Enterprise features

**v2.0 (2026)**
- [ ] Distributed memory system
- [ ] Blockchain integration
- [ ] VR/AR support
- [ ] Quantum-ready encryption

## 📄 Licencja

Apache License - zobacz [LICENSE](LICENSE) dla szczegółów.

## 🙏 Podziękowania

- **XQR Team** - Podstawowa architektura i specyfikacja
- **Rust Community** - Wsparcie techniczne
- **SVG Working Group** - Standardy SVG
- **PWA Community** - Best practices

## 📞 Kontakt

- **Website**: https://sview.xqr.ai
- **Documentation**: https://docs.sview.xqr.ai
- **GitHub**: https://github.com/xqr/sview
- **Discord**: https://discord.gg/xqr-sview
- **Email**: team@xqr.ai

---

**SView** - Where SVG meets PWA meets AI 🚀🧠✨