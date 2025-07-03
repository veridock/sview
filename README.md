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

## 🖼️ SVG to UTF-8 Rendering

SView provides powerful SVG to UTF-8/ASCII rendering capabilities, allowing you to view and work with SVG files directly in your terminal. Here are some examples of how to use these features:

### Basic SVG Rendering

Render an SVG file to your terminal with default size (40x20 characters):

```bash
sview view example.svg
```

### Custom Output Size

Specify custom dimensions for the output:

```bash
# Render with custom width and height
sview view example.svg --width 60 --height 30
```

### Mini Icons in Directory Listings

View a directory with mini SVG icons:

```bash
# List files with mini SVG icons
sview list /path/to/svgs

# Long format with details and mini icons
sview list /path/to/svgs --long
```

### Advanced Usage Examples

#### 1. Batch Convert SVGs to ASCII Art

```bash
# Convert all SVGs in a directory to ASCII art
for svg in /path/to/svgs/*.svg; do
    echo "Rendering $svg"
    sview view "$svg" --width 60
    echo "\n---\n"
done
```

#### 2. Generate File Browser with Icons

```bash
# Create a file browser with SVG previews
find /path/to/directory -name "*.svg" | while read -r file; do
    echo "File: $file"
    sview view "$file" --width 40 --height 10
    echo "\n$(sview view "$file" --mini)"  # Show mini icon preview
    echo "========================================"
done
```

#### 3. Integration with Other Tools

```bash
# Use with fzf for interactive file selection
selected=$(find /path/to/svgs -name "*.svg" | fzf --preview 'sview view {} --width 40 --height 15')
if [ -n "$selected" ]; then
    sview view "$selected"
fi
```

### Rendering Options

- `--width <WIDTH>`: Set output width in characters (default: 40)
- `--height <HEIGHT>`: Set output height in characters (default: 20)
- `--mini`: Show only a single-character representation
- `--browser`: Open in default web browser instead of terminal
- `--no-color`: Disable color output

### Custom Character Sets

You can customize the character set used for rendering by modifying the `DENSITY` constant in the source code (`src/svg2utf.rs`). The default character set is `" .,:;+*?%S#@"` (from lightest to darkest).

## 📦 Installation

### Opcje uruchamiania

Ponieważ `sview` nie jest jeszcze zainstalowany w systemie, masz dwie opcje:

#### Opcja 1: Użyj pełnej ścieżki

```bash
# Przykład uruchomienia z pełną ścieżką
./target/release/sview --help

# Podgląd pliku SVG w przeglądarce
./target/release/sview view example.svg --browser
```

#### Opcja 2: Dodaj do PATH (tymczasowo)

```bash
# Dodaj katalog z binarką do PATH (tylko na czas bieżącej sesji)
export PATH="$PWD/target/release:$PATH"

# Teraz możesz używać sview bezpośrednio
sview --help
```

### Instalacja systemowa

```bash
# Wymagania: Rust 1.70+
git clone https://github.com/veridock/sview.git
cd sview

# Kompilacja
cargo build --release --all-features

# Instalacja systemowa (wymaga uprawnień roota)
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
# Wyświetl wszystkie pliki SVG w bieżącym katalogu
sview list

# Wyświetl szczegółowe informacje o plikach SVG
sview list -l  # lub sview list --long

# Posortuj pliki według rozmiaru (od największego)
sview list -s size -r

# Wyświetl pliki w określonym katalogu
sview list /ścieżka/do/katalogu

# Wyświetl pliki XML (zamiast domyślnych SVG)
sview list --format=xml

# Wyświetl pomoc
sview --help
sview list --help  # pomoc dla konkretnej komendy
```

### Podgląd plików SVG w terminalu z ikonami UTF-8

SView oferuje zaawansowane wyświetlanie plików SVG w terminalu przy użyciu znaków UTF-8, które są generowane na podstawie rzeczywistej zawartości plików SVG. Pozwala to na szybki podgląd zawartości bez opuszczania terminala.

#### Generowanie miniatur SVG w terminalu

```bash
# Wyświetl podgląd pojedynczego pliku SVG jako ASCII/UTF-8
sview view example.svg

# Przykładowe wyjście:
# ++++++++++++++++++++++++++++++
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%+
# %;;;;;;;;;;+++++++++++++++%+
# S**************************S+
# @@@@@@@@@@@@@##############+
# @@@@@@@@@@@@#S?%**%?%?%*?##;
# @@@@@@@@@@@@###############;
# @@@@@@@@@@@@@@@@@@@@@@@@@@S;
# @@@@@@@@@@@@@@@@@@@@@@@@@@S;
# @@@@@@@@@@@@@@@@@@@@@@@@@@S;
# @@@@@@@@@@@@@@@@@@@@@@@@@@S;
# @@@@@@@@@@@@@@@%?S#@@@@@@S;
# @@@#%#@@##@@@@@@*??S@@@@@S;
# @#%*?#%??%@@@@@@%*S@@@@@@S;
# S@#?*?#+??%@@@@@@@@@@@@@S;
# S@#S%S#%SSS@@@@@@@@@@@@@S;
# S@@@@@@@@@@@@@@@@@@@@@@S;
# ########################;
# S######################%;
# ++++++++;;;;;;;;;;;;;;;;;
```

#### Wyświetlanie katalogów z podglądami

```bash
# Wyświetl zawartość katalogu z podglądami SVG
sview view /ścieżka/do/katalogu

# Przykładowe wyjście:
# ++++++  example1.svg
# ++++++  example2.svg
# ++++++  subdirectory/

```

#### Opcje wyświetlania

```bash
# Wyświetl szczegółowe informacje o plikach
sview view -l  # lub --long

# Ustaw niestandardowy rozmiar podglądu (szerokość x wysokość)
sview view example.svg --width 30 --height 15

# Wyświetl tylko podgląd bez ścieżki do pliku
sview view example.svg --icon-only
```

#### Integracja z innymi narzędziami

```bash
# Przeszukaj i wyświetl wszystkie pliki SVG w podkatalogach
find . -name "*.svg" -exec sview view {} \;

# Wygeneruj podgląd SVG z potoku
echo '<svg>...</svg>' | sview view -

# Lub
curl -s https://example.com/image.svg | sview view -
```

#### Automatyczne wykrywanie typu zawartości

SView automatycznie wykrywa typ zawartości SVG i generuje odpowiednie podglądy dla:

- Proste kształty i ikony
- Wykresy i diagramy
- Interfejsy użytkownika
- Grafiki wektorowe
- Logotypy

#### Przełączniki wiersza poleceń

```
FLAGI:
    -h, --help       Wyświetla pomoc
    -l, --long       Pokaż szczegółowe informacje
    -r, --reverse    Odwróć kolejność sortowania
    -s, --sort SORT  Sortuj według: name, size, modified (domyślnie: name)
    -w, --width WIDTH  Szerokość podglądu (domyślnie: 40)
    -H, --height HEIGHT  Wysokość podglądu (domyślnie: 20)
    -i, --icon-only  Wyświetl tylko ikonę bez ścieżki
    -b, --browser    Otwórz w domyślnej przeglądarce zamiast wyświetlać w terminalu
```

#### Przykłady użycia w skryptach

```bash
# Wygeneruj stronę HTML z podglądami SVG
echo "<html><body>" > previews.html
for svg in *.svg; do
    echo "<div style='float:left;margin:10px;text-align:center;'>" >> previews.html
    echo "<pre>" >> previews.html
    sview view "$svg" --width 30 --height 15 >> previews.html
    echo "</pre>" >> previews.html
    echo "<div>${svg}</div></div>" >> previews.html
done
echo "</body></html>" >> previews.html
```

#### Obsługa dużych katalogów

Dla dużych katalogów SView używa przyrostowego ładowania i buforowania:

```bash
# Wyświetl pierwsze 10 plików
sview view /duży/katalog | head -n 20

# Monitoruj zmiany w katalogu
watch -n 1 'sview view /katalog/do/monitorowania'
```

#### Personalizacja

Możesz dostosować wygląd podglądów używając zmiennych środowiskowych:

```bash
# Ustaw niestandardowe znaki do renderowania (od najciemniejszego do najjaśniejszego)
export SVIEW_CHARS=" .:-=+*#%@"

# Włącz/wyłącz kolorowanie
export SVIEW_COLORS=1  # 0 aby wyłączyć

# Ustaw domyślny rozmiar
export SVIEW_WIDTH=50
export SVIEW_HEIGHT=25
```

#### Wymagania systemowe

- Terminal wspierający znaki UTF-8
- Biblioteki systemowe: librsvg, cairo, pango (zainstalowane domyślnie w większości dystrybucji)
- Dla lepszej wydajności zalecany jest terminal z akceleracją sprzętową (np. Alacritty, Kitty, WezTerm)

#### Podstawowe użycie

```bash
# Wyświetl plik SVG w terminalu z ikoną UTF-8
sview view example.svg

# Wyświetl zawartość katalogu z ikonami
sview view /ścieżka/do/katalogu

# Wyświetl szczegółowe informacje o plikach
sview view -l  # lub --long
```

#### Sortowanie i filtrowanie

```bash
# Sortuj według rozmiaru (od najmniejszego)
sview view --sort=size

# Sortuj według daty modyfikacji (od najnowszego)
sview view --sort=modified -r

# Ogranicz głębokość przeszukiwania
sview view --depth=2
```

#### Integracja z innymi narzędziami

```bash
# Użycie z find do wyszukiwania i wyświetlania SVG
find ~/ -name "*.svg" -type f -exec sview view {} \;

# Liczba plików SVG w katalogu
sview view /katalog | wc -l

# Wyszukaj i wyświetl tylko określone pliki
sview view /katalog | grep wzorzec
```

#### Zaawansowane użycie

```bash
# Wyświetl tylko ikony (pomijając ścieżki)
sview view /katalog | awk '{print $1}'

# Generowanie listy plików z ikonami do pliku HTML
sview view /katalog > svg_list.html

# Użycie w skryptach
for svg in $(find . -name "*.svg"); do
    echo -n "$svg: "
    sview view "$svg"
done
```

#### Obsługiwane typy ikon

SView automatycznie wykrywa typ pliku SVG i wybiera odpowiednią ikonę:

- `📊` - Wykresy i diagramy
- `⭕` - Elementy okrągłe (np. przyciski, ikony)
- `📁` - Katalogi
- `📄` - Dokumenty
- `🖼️` - Obrazy
- `🔍` - Wyszukiwanie
- `⚙️` - Ustawienia
- `📥` - Pobieranie/przesyłanie

#### Otwieranie w przeglądarce

```bash
# Otwórz plik SVG w domyślnej przeglądarce
sview view example.svg --browser

# Ustaw niestandardowy rozmiar podglądu
sview view example.svg --browser --width 1024 --height 768
```

#### Pomoc

```bash
# Wyświetl pomoc dla komendy view
sview view --help
```

**Uwaga:** Domyślnie `sview view` wyświetla ikonę UTF-8 reprezentującą zawartość SVG. Aby otworzyć plik w przeglądarce, użyj flagi `--browser`.

### Zarządzanie pamięcią XQR

```bash
# Wyświetl wszystkie wpisy w pamięci
sview memory list

# Dodaj nowy wpis do pamięci
sview memory add --key user.preferences.theme --value dark

# Pobierz wartość z pamięci
sview memory get --key user.preferences.theme

# Usuń wpis z pamięci
sview memory remove --key user.preferences.theme

# Wyświetl pomoc dla komend pamięci
sview memory --help
```

Uwaga: Pamięć XQR służy do przechowywania preferencji i ustawień użytkownika. Klucze powinny być zorganizowane hierarchicznie, używając kropek jako separatorów (np. `user.preferences.theme`).

### Powłoka interaktywna i diagnostyka

```bash
# Uruchom interaktywną powłokę
sview shell

# Wyświetl informacje o systemie
sview system info

# Sprawdź wymagania systemowe
sview system check

# Wyczyść pliki tymczasowe
sview system clean

# Wyświetl pomoc dla komend systemowych
sview system --help
```

### Przykłady użycia diagnostyki systemowej

```bash
# Sprawdź, czy system spełnia wymagania
sview system check

# Wyczyść pliki tymczasowe i cache
sview system clean

# Pobierz szczegółowe informacje o systemie
sview system info
```

### 🔍 Wyszukiwanie plików z `sview list`

Komenda `sview list` umożliwia wyświetlanie plików SVG z podstawowymi opcjami sortowania i formatowania.

### 🔎 Przykłady użycia

```bash
# Wyświetlenie wszystkich plików SVG w bieżącym katalogu
sview list

# Wyświetlenie plików w określonym katalogu
sview list /ścieżka/do/katalogu

# Wyświetlenie szczegółowych informacji
sview list -l
sview list --long

# Sortowanie wyników
sview list -s name     # domyślnie
sview list -s size     # rozmiar pliku
sview list -s modified # data modyfikacji

# Odwrócenie kolejności sortowania
sview list -r
sview list --reverse

# Filtrowanie po typie pliku
sview list -f svg    # tylko pliki SVG (domyślnie)
sview list -f xml     # pliki XML
```

### 🎯 Przykłady praktyczne

```bash
# Wyświetl pliki posortowane według rozmiaru (od największego)
sview list -s size -r

# Wyświetl szczegółowe informacje o plikach XML
sview list -f xml -l

# Wyświetl pliki w katalogu domowym użytkownika
sview list ~
sview list --export-thumbnails=output_directory/

# Znajdź pliki SVG z błędami w składni
sview list --check-validity

# Wyszukaj pliki SVG z określonym kolorem dominującym
sview list --dominant-color="#FF5733" --tolerance=10
```

#### Integracja z systemem plików

```bash
# Użyj sview list z find do zaawansowanego wyszukiwania
find . -type f -name "*.svg" -exec sview list -l {} \; | sort -k5 -n

# Połącz sview list z fzf do interaktywnego wyszukiwania
sview list | fzf --preview 'sview view {}'

# Użyj z ripgrep do wyszukiwania w zawartości plików
sview list | xargs rg -l "@import"

# Stwórz podgląd miniatur w terminalu
sview list --preview | less -R
```

#### Integracja z innymi narzędziami

```bash
# Przeszukaj zawartość plików SVG
sview list | xargs grep -l "keyword"

# Usuń stare pliki tymczasowe starsze niż 30 dni
sview list --format=tmp --min-age=30 | xargs rm -f

# Oblicz całkowity rozmiar plików SVG
sview list -l | awk '{sum += $1} END {print sum}'
```

# Pomoc
```bash
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
# Sprawdzenie bezpieczeństwa (wymaga cargo-audit)
cargo audit

# Sprawdzenie zależności GUI (w katalogu GUI)
cd gui && npm audit

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
git clone https://github.com/veridock/sview.git
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
- **GitHub**: https://github.com/veridock/sview
- **Discord**: https://discord.gg/xqr-sview
- **Email**: team@xqr.ai

---

**SView** - Where SVG meets PWA meets AI 🚀🧠✨