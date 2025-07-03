use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::io::{self, Write};
use serde::{Deserialize, Serialize};
use clap::{App, Arg, SubCommand};
use walkdir::WalkDir;
use rayon::prelude::*;
use base64::{Engine as _, engine::general_purpose};

#[derive(Debug, Serialize, Deserialize)]
struct SvgFile {
    path: PathBuf,
    name: String,
    size: u64,
    modified: std::time::SystemTime,
    thumbnail: String, // UTF-8 icon representation
    is_sview_enhanced: bool,
    metadata: Option<sViewMetadata>,
}

#[derive(Debug, Serialize, Deserialize)]
struct sViewMetadata {
    version: String,
    memory_enabled: bool,
    pwa_capable: bool,
    interactive: bool,
}

struct SviewConfig {
    home_dir: PathBuf,
    cache_dir: PathBuf,
    browser_command: String,
    supported_languages: Vec<String>,
}

impl Default for SviewConfig {
    fn default() -> Self {
        let home = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
        Self {
            home_dir: home.clone(),
            cache_dir: home.join(".sview/cache"),
            browser_command: "chromium".to_string(),
            supported_languages: vec![
                "javascript".to_string(), "python".to_string(), "rust".to_string(),
                "go".to_string(), "ruby".to_string(), "php".to_string(),
            ],
        }
    }
}

struct SvgScanner {
    config: SviewConfig,
}

impl SvgScanner {
    fn new() -> Self {
        Self {
            config: SviewConfig::default(),
        }
    }

    /// Efektywne skanowanie ext4 - używa parallel walkdir dla prędkości
    fn scan_svg_files(&self) -> Result<Vec<SvgFile>, Box<dyn std::error::Error>> {
        println!("🔍 Skanowanie plików SVG w: {:?}", self.config.home_dir);

        let svg_files: Result<Vec<_>, _> = WalkDir::new(&self.config.home_dir)
            .follow_links(false)
            .max_depth(10) // Ograniczenie głębokości dla wydajności
            .into_iter()
            .par_bridge() // Parallel processing
            .filter_map(|entry| {
                let entry = entry.ok()?;
                let path = entry.path();

                // Szybki filtr po rozszerzeniu
                if path.extension()?.to_str()? == "svg" {
                    Some(path.to_path_buf())
                } else {
                    None
                }
            })
            .map(|path| self.process_svg_file(path))
            .collect();

        svg_files
    }

    fn process_svg_file(&self, path: PathBuf) -> Result<SvgFile, Box<dyn std::error::Error>> {
        let metadata = fs::metadata(&path)?;
        let content = fs::read_to_string(&path)?;

        // Sprawdź czy to plik sView-enhanced
        let is_sview_enhanced = content.contains("xmlns:sview=") || content.contains("sview:enhanced=");
        let sview_metadata = if is_sview_enhanced {
            Some(self.extract_sview_metadata(&content))
        } else {
            None
        };

        // Generuj miniaturę UTF
        let thumbnail = self.generate_utf_thumbnail(&content, &path)?;

        Ok(SvgFile {
            name: path.file_stem()
                .and_then(|s| s.to_str())
                .unwrap_or("unknown")
                .to_string(),
            path,
            size: metadata.len(),
            modified: metadata.modified()?,
            thumbnail,
            is_sview_enhanced,
            metadata: sview_metadata,
        })
    }

    fn extract_sview_metadata(&self, content: &str) -> sViewMetadata {
        sViewMetadata {
            version: "1.0".to_string(), // TODO: Extract from content
            memory_enabled: content.contains("memory:system"),
            pwa_capable: content.contains("manifest") || content.contains("service-worker"),
            interactive: content.contains("interactive=") || content.contains("onclick"),
        }
    }

    /// Generuje miniaturę SVG jako icon UTF-8
    fn generate_utf_thumbnail(&self, content: &str, path: &Path) -> Result<String, Box<dyn std::error::Error>> {
        // Prosta heurystyka do generowania ikon UTF na podstawie zawartości SVG
        let icon = if content.contains("<circle") {
            "🔵" // Koło
        } else if content.contains("<rect") {
            "🟪" // Prostokąt
        } else if content.contains("<path") {
            "🎨" // Ścieżka/rysunek
        } else if content.contains("interactive") || content.contains("script") {
            "⚡" // Interaktywny
        } else if content.contains("sview:") {
            "🧠" // sView enhanced
        } else if content.contains("text") {
            "📄" // Tekst
        } else if content.contains("image") {
            "🖼️" // Obraz
        } else {
            "📊" // Domyślny
        };

        Ok(icon.to_string())
    }
}

struct SvgLauncher {
    config: SviewConfig,
}

impl SvgLauncher {
    fn new() -> Self {
        Self {
            config: SviewConfig::default(),
        }
    }

    /// Uruchamia SVG jako aplikację PWA w przeglądarce
    fn launch_svg_as_pwa(&self, svg_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
        println!("🚀 Uruchamianie {} jako aplikacja PWA...", svg_path.display());

        // Stwórz tymczasowy HTML wrapper dla PWA
        let html_wrapper = self.create_pwa_wrapper(svg_path)?;
        let temp_html = self.config.cache_dir.join("temp_pwa.html");

        // Upewnij się, że katalog cache istnieje
        fs::create_dir_all(&self.config.cache_dir)?;
        fs::write(&temp_html, html_wrapper)?;

        // Uruchom w przeglądarce z flagami PWA
        let mut browser_cmd = Command::new(&self.config.browser_command);
        browser_cmd
            .arg("--app=file://".to_owned() + &temp_html.to_string_lossy())
            .arg("--new-window")
            .arg("--disable-web-security") // Dla lokalnych plików
            .arg("--allow-file-access-from-files");

        match browser_cmd.spawn() {
            Ok(_) => println!("✅ Aplikacja uruchomiona w przeglądarce"),
            Err(e) => {
                eprintln!("❌ Błąd uruchamiania przeglądarki: {}", e);
                println!("💡 Spróbuj zainstalować chromium lub zmienić browser_command w konfiguracji");
            }
        }

        Ok(())
    }

    fn create_pwa_wrapper(&self, svg_path: &Path) -> Result<String, Box<dyn std::error::Error>> {
        let svg_content = fs::read_to_string(svg_path)?;
        let svg_name = svg_path.file_stem()
            .and_then(|s| s.to_str())
            .unwrap_or("SVG App");

        // Sprawdź czy to sView enhanced SVG
        let is_sview = svg_content.contains("xmlns:sview=");

        let html = if is_sview {
            self.create_sview_pwa_wrapper(&svg_content, svg_name)
        } else {
            self.create_standard_pwa_wrapper(&svg_content, svg_name)
        };

        Ok(html)
    }

    fn create_sview_pwa_wrapper(&self, svg_content: &str, app_name: &str) -> String {
        format!(r#"<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{}</title>

    <!-- PWA Manifest -->
    <link rel="manifest" href="data:application/json,{manifest}">
    <meta name="theme-color" content="#667eea">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">

    <!-- sView Enhanced Styles -->
    <style>
        body {{
            margin: 0;
            padding: 0;
            font-family: system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }}

        .sview-toolbar {{
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            padding: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
        }}

        .sview-content {{
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }}

        .svg-container {{
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 20px;
            max-width: 90vw;
            max-height: 80vh;
            overflow: auto;
        }}

        svg {{
            max-width: 100%;
            height: auto;
        }}

        .sview-memory-panel {{
            position: fixed;
            top: 60px;
            right: 20px;
            width: 300px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            display: none;
        }}

        .memory-active {{
            display: block !important;
        }}
    </style>
</head>
<body>
    <div class="sview-toolbar">
        <div>🧠 sView Enhanced: {}</div>
        <div>
            <button onclick="toggleMemory()" style="background: rgba(255,255,255,0.2); border: none; color: white; padding: 5px 10px; border-radius: 5px; cursor: pointer;">
                💾 Memory
            </button>
            <button onclick="downloadApp()" style="background: rgba(255,255,255,0.2); border: none; color: white; padding: 5px 10px; border-radius: 5px; cursor: pointer;">
                📱 Install
            </button>
        </div>
    </div>

    <div class="sview-content">
        <div class="svg-container">
            {}
        </div>
    </div>

    <div id="memoryPanel" class="sview-memory-panel">
        <h3>🧠 sView Memory System</h3>
        <div id="memoryContent">
            <p>Memory system initializing...</p>
        </div>
    </div>

    <!-- Service Worker dla PWA -->
    <script>
        // PWA Installation
        let deferredPrompt;

        window.addEventListener('beforeinstallprompt', (e) => {{
            e.preventDefault();
            deferredPrompt = e;
        }});

        function downloadApp() {{
            if (deferredPrompt) {{
                deferredPrompt.prompt();
                deferredPrompt.userChoice.then((choiceResult) => {{
                    if (choiceResult.outcome === 'accepted') {{
                        console.log('User accepted the install prompt');
                    }}
                    deferredPrompt = null;
                }});
            }} else {{
                alert('Aplikacja może być już zainstalowana lub instalacja nie jest dostępna');
            }}
        }}

        // sView Memory System
        let memorySystem = {{
            factual: {{}},
            episodic: [],
            semantic: [],
            working: {{}}
        }};

        function toggleMemory() {{
            const panel = document.getElementById('memoryPanel');
            panel.classList.toggle('memory-active');

            if (panel.classList.contains('memory-active')) {{
                updateMemoryPanel();
            }}
        }}

        function updateMemoryPanel() {{
            const content = document.getElementById('memoryContent');
            content.innerHTML = `
                <div>
                    <strong>Factual Memory:</strong><br>
                    <pre>${{JSON.stringify(memorySystem.factual, null, 2)}}</pre>
                </div>
                <div>
                    <strong>Working Memory:</strong><br>
                    <pre>${{JSON.stringify(memorySystem.working, null, 2)}}</pre>
                </div>
                <div>
                    <strong>Episodic Events:</strong> ${{memorySystem.episodic.length}}
                </div>
            `;
        }}

        // Inicjalizacja sView
        document.addEventListener('DOMContentLoaded', () => {{
            console.log('🧠 sView Enhanced SVG App initialized');

            // Simulated memory initialization
            memorySystem.working = {{
                currentTask: 'SVG App Running',
                startTime: new Date().toISOString(),
                userAgent: navigator.userAgent
            }};

            memorySystem.episodic.push({{
                timestamp: new Date().toISOString(),
                event: 'App launched',
                context: 'PWA mode'
            }});
        }});
    </script>
</body>
</html>"#,
            app_name,
            manifest = percent_encoding::utf8_percent_encode(
                &format!(r#"{{"name":"{}","short_name":"{}","start_url":"/","display":"standalone","background_color":"#667eea","theme_color":"#667eea"}}"#,
                app_name, app_name),
                percent_encoding::NON_ALPHANUMERIC
            ),
            app_name,
            svg_content
        )
    }

    fn create_standard_pwa_wrapper(&self, svg_content: &str, app_name: &str) -> String {
        format!(r#"<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{}</title>

    <!-- PWA Manifest -->
    <link rel="manifest" href="data:application/json,{manifest}">
    <meta name="theme-color" content="#4CAF50">
    <meta name="apple-mobile-web-app-capable" content="yes">

    <style>
        body {{
            margin: 0;
            padding: 20px;
            font-family: system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }}

        .svg-container {{
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 20px;
            max-width: 90vw;
            max-height: 90vh;
            overflow: auto;
        }}

        svg {{
            max-width: 100%;
            height: auto;
        }}
    </style>
</head>
<body>
    <div class="svg-container">
        {}
    </div>

    <script>
        // Basic PWA functionality
        let deferredPrompt;

        window.addEventListener('beforeinstallprompt', (e) => {{
            e.preventDefault();
            deferredPrompt = e;
        }});

        console.log('📊 Standard SVG App loaded');
    </script>
</body>
</html>"#,
            app_name,
            manifest = percent_encoding::utf8_percent_encode(
                &format!(r#"{{"name":"{}","short_name":"{}","start_url":"/","display":"standalone","background_color":"#4CAF50","theme_color":"#4CAF50"}}"#,
                app_name, app_name),
                percent_encoding::NON_ALPHANUMERIC
            ),
            svg_content
        )
    }

    /// Uruchamia kod w różnych językach programowania
    fn execute_language(&self, language: &str, code: &str) -> Result<(), Box<dyn std::error::Error>> {
        match language.to_lowercase().as_str() {
            "javascript" | "js" => {
                Command::new("node")
                    .arg("-e")
                    .arg(code)
                    .status()?;
            }
            "python" | "py" => {
                Command::new("python3")
                    .arg("-c")
                    .arg(code)
                    .status()?;
            }
            "rust" | "rs" => {
                // Dla Rust trzeba stworzyć tymczasowy plik
                let temp_file = self.config.cache_dir.join("temp.rs");
                fs::write(&temp_file, code)?;
                Command::new("rustc")
                    .arg(&temp_file)
                    .arg("-o")
                    .arg(self.config.cache_dir.join("temp"))
                    .status()?;
                Command::new(self.config.cache_dir.join("temp"))
                    .status()?;
            }
            _ => {
                eprintln!("❌ Nieobsługiwany język: {}", language);
                println!("✅ Obsługiwane języki: {:?}", self.config.supported_languages);
            }
        }
        Ok(())
    }
}

struct SviewCLI;

impl SviewCLI {
    /// Wyświetla listę plików SVG z ikonami UTF
    fn list_command() -> Result<(), Box<dyn std::error::Error>> {
        let scanner = SvgScanner::new();
        let svg_files = scanner.scan_svg_files()?;

        println!("\n📁 Znalezione pliki SVG:\n");

        for file in &svg_files {
            let sview_badge = if file.is_sview_enhanced { "🧠" } else { "  " };
            let size_kb = file.size / 1024;

            println!("{} {} {} {:>6} KB  {}",
                file.thumbnail,
                sview_badge,
                file.name,
                size_kb,
                file.path.display()
            );
        }

        println!("\n📊 Statystyki:");
        println!("• Łącznie plików SVG: {}", svg_files.len());
        println!("• sView Enhanced: {}", svg_files.iter().filter(|f| f.is_sview_enhanced).count());
        println!("• Standardowe SVG: {}", svg_files.iter().filter(|f| !f.is_sview_enhanced).count());

        Ok(())
    }

    fn run_command(file_path: &str) -> Result<(), Box<dyn std::error::Error>> {
        let launcher = SvgLauncher::new();
        let path = Path::new(file_path);

        if !path.exists() {
            eprintln!("❌ Plik nie istnieje: {}", file_path);
            return Ok(());
        }

        if path.extension().and_then(|s| s.to_str()) != Some("svg") {
            eprintln!("❌ To nie jest plik SVG: {}", file_path);
            return Ok(());
        }

        launcher.launch_svg_as_pwa(path)?;
        Ok(())
    }

    fn grid_command() -> Result<(), Box<dyn std::error::Error>> {
        println!("🎨 Uruchamianie interfejsu graficznego...");
        // TODO: Implementacja interfejsu graficznego (Electron/Tauri)
        println!("💡 Interfejs graficzny będzie dostępny w następnej wersji");
        Ok(())
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let matches = App::new("sview")
        .version("1.0.0")
        .about("🧠 SView - SVG Viewer & PWA Launcher with sView Integration")
        .author("sView Team")
        .arg(Arg::with_name("file")
            .help("Plik SVG do uruchomienia")
            .index(1))
        .subcommand(SubCommand::with_name("ls")
            .about("📋 Listuj wszystkie pliki SVG z miniaturami"))
        .subcommand(SubCommand::with_name("grid")
            .about("🎨 Uruchom interfejs graficzny"))
        .subcommand(SubCommand::with_name("exec")
            .about("⚡ Wykonaj kod w określonym języku")
            .arg(Arg::with_name("language")
                .help("Język programowania")
                .required(true)
                .index(1))
            .arg(Arg::with_name("code")
                .help("Kod do wykonania")
                .required(true)
                .index(2)))
        .get_matches();

    // Logo i informacje o aplikacji
    println!("🧠 SView v1.0.0 - SVG Viewer & PWA Launcher");
    println!("🔗 sView Integration Enabled\n");

    match matches.subcommand() {
        ("ls", Some(_)) => SviewCLI::list_command()?,
        ("grid", Some(_)) => SviewCLI::grid_command()?,
        ("exec", Some(exec_matches)) => {
            let language = exec_matches.value_of("language").unwrap();
            let code = exec_matches.value_of("code").unwrap();
            let launcher = SvgLauncher::new();
            launcher.execute_language(language, code)?;
        }
        _ => {
            if let Some(file_path) = matches.value_of("file") {
                SviewCLI::run_command(file_path)?;
            } else {
                // Bez argumentów - pokaż pomoc
                println!("Użycie:");
                println!("  sview <file.svg>     - Uruchom plik SVG jako aplikację PWA");
                println!("  sview ls             - Listuj wszystkie pliki SVG");
                println!("  sview grid           - Interfejs graficzny");
                println!("  sview exec <lang> <code> - Wykonaj kod");
                println!("\nPrzykłady:");
                println!("  sview examples.svg");
                println!("  sview ls");
                println!("  sview exec javascript 'console.log(\"Hello from JS!\")'");
            }
        }
    }

    Ok(())
}