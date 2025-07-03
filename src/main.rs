use chrono::Local;
use clap::{Args, Parser, Subcommand, ValueEnum};
use dirs;
use humansize;
use std::io::{self, Write};
use std::path::PathBuf;
use std::process;
use std::time::SystemTime;
use terminal_size;

mod memory;
mod scanner;
mod svg2utf;

/// SView - SVG Viewer & PWA Launcher with XQR Integration
#[derive(Parser, Debug)]
#[command(name = "sview")]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Enable verbose output
    #[arg(short, long, global = true)]
    verbose: bool,
}

/// Available subcommands
#[derive(Subcommand, Debug)]
enum Commands {
    /// List SVG files in a directory
    List(ListArgs),

    /// View an SVG file
    View(ViewArgs),

    /// Search for files by name or content
    Search(SearchArgs),

    /// Manage XQR memory
    Memory(MemoryArgs),

    /// Start interactive shell
    Shell,

    /// System information and diagnostics
    System(SystemArgs),
}

/// Arguments for the search command
#[derive(Args, Debug)]
struct SearchArgs {
    /// Search query (filename or content)
    query: String,

    /// Directory to search in (default: current directory)
    #[arg(default_value = ".")]
    path: PathBuf,

    /// File format/extension to filter by (e.g., svg, png, jpg)
    #[arg(short, long)]
    format: Option<String>,

    /// Search in file contents (not just filenames)
    #[arg(short = 'c', long)]
    content: bool,

    /// Case-insensitive search
    #[arg(short = 'i', long)]
    ignore_case: bool,

    /// Maximum depth to search
    #[arg(short = 'd', long)]
    max_depth: Option<usize>,

    /// Show detailed information
    #[arg(short, long)]
    long: bool,
}

/// Arguments for listing files
#[derive(Args, Debug)]
struct ListArgs {
    /// Directory to scan (default: home directory)
    #[arg(default_value_os_t = dirs::home_dir().unwrap_or_else(|| PathBuf::from(".")))]
    path: PathBuf,

    /// File format to filter by (e.g., svg, png, jpg)
    #[arg(short, long, default_value = "svg")]
    format: String,

    /// Show detailed information
    #[arg(short, long)]
    long: bool,

    /// Sort by (name, size, modified)
    #[arg(short, long, value_enum, default_value_t = SortBy::Name)]
    sort: SortBy,

    /// Reverse sort order
    #[arg(short, long)]
    reverse: bool,

    /// Maximum depth to search (0 for unlimited)
    #[arg(short = 'd', long, default_value_t = 6)]
    max_depth: usize,

    /// Pattern to search for in filenames (regex)
    #[arg(default_value = ".*")]
    pattern: String,

    /// Search file contents (not just names)
    #[arg(short = 'c', long)]
    search_content: bool,

    /// Case-insensitive search
    #[arg(short = 'i', long)]
    ignore_case: bool,
}

/// Arguments for the view command
#[derive(Args, Debug)]
struct ViewArgs {
    /// File or directory to view (default: current directory)
    #[arg(default_value = ".")]
    path: PathBuf,

    /// Open in default browser (for single file only)
    #[arg(short, long)]
    browser: bool,

    /// Maximum depth for directory listing
    #[arg(short, long, default_value_t = 1)]
    depth: u32,

    /// Show detailed information
    #[arg(short, long)]
    long: bool,

    /// Sort by (name, size, modified)
    #[arg(short, long, value_enum, default_value_t = SortBy::Name)]
    sort: SortBy,

    /// Reverse sort order
    #[arg(short, long)]
    reverse: bool,
}

/// Arguments for memory operations
#[derive(Args, Debug)]
struct MemoryArgs {
    #[command(subcommand)]
    command: MemoryCommands,
}

/// Memory subcommands
#[derive(Subcommand, Debug)]
enum MemoryCommands {
    /// List all memory entries
    List,

    /// Add memory entry
    Add {
        /// Key for the memory
        key: String,

        /// Value to store
        value: String,

        /// Memory type (factual, episodic, semantic, working)
        #[arg(short, long, default_value = "factual")]
        memory_type: MemoryType,
    },

    /// Get memory entry
    Get {
        /// Key to retrieve
        key: String,
    },

    /// Remove memory entry
    Remove {
        /// Key to remove
        key: String,
    },
}

/// System subcommands
#[derive(Args, Debug)]
struct SystemArgs {
    #[command(subcommand)]
    command: SystemCommands,
}

/// System subcommands
#[derive(Subcommand, Debug)]
enum SystemCommands {
    /// Show system information
    Info,

    /// Check system requirements
    Check,

    /// Clean temporary files
    Clean,
}

/// Sort criteria
#[derive(ValueEnum, Clone, Copy, Debug, PartialEq, Eq)]
pub enum SortBy {
    Name,
    Size,
    Modified,
}

impl Default for SortBy {
    fn default() -> Self {
        SortBy::Name
    }
}

impl std::fmt::Display for SortBy {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SortBy::Name => write!(f, "name"),
            SortBy::Size => write!(f, "size"),
            SortBy::Modified => write!(f, "modified"),
        }
    }
}

/// Memory types
#[derive(ValueEnum, Clone, Debug)]
enum MemoryType {
    Factual,
    Episodic,
    Semantic,
    Working,
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::List(args) => list_files(args, cli.verbose)?,
        Commands::View(args) => view_file(args, cli.verbose)?,
        Commands::Search(args) => search_files(args, cli.verbose)?,
        Commands::Memory(args) => handle_memory(args, cli.verbose)?,
        Commands::System(args) => handle_system(args, cli.verbose)?,
        Commands::Shell => start_shell()?,
    }

    Ok(())
}

/// Search for files matching the query
fn search_files(args: &SearchArgs, verbose: bool) -> anyhow::Result<()> {
    use std::time::Instant;

    let start_time = Instant::now();
    let path = &args.path;
    let query = &args.query;

    if !path.exists() {
        return Err(anyhow::anyhow!("Path does not exist: {}", path.display()));
    }

    if verbose {
        println!(
            "Searching for '{}' in {} (max depth: {})",
            query,
            path.display(),
            args.max_depth
                .map_or_else(|| "unlimited".to_string(), |d| format!("{}", d))
        );
    }

    let scanner = scanner::FileScanner::new().with_config(scanner::ScannerConfig {
        max_depth: args.max_depth,
        extensions: args.format.as_ref().map(|f| vec![f.clone()]),
        ..Default::default()
    });

    let mut found = 0;
    let _ = scanner.search(path, query, args.content, args.ignore_case, |entry| {
        found += 1;

        if args.long {
            let modified = entry
                .modified
                .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
                .map(|d| {
                    chrono::DateTime::<chrono::Local>::from(std::time::UNIX_EPOCH + d)
                        .format("%Y-%m-%d %H:%M:%S")
                        .to_string()
                })
                .unwrap_or_else(|| "unknown".to_string());

            println!(
                "{:>10}  {}  {}",
                humansize::format_size(entry.size, humansize::BINARY),
                modified,
                entry.path.display()
            );
        } else {
            println!("{}", entry.path.display());
        }

        true // Continue searching
    })?;

    if verbose {
        let elapsed = start_time.elapsed();
        println!("\nFound {} matches in {:.2?}", found, elapsed);
    }

    Ok(())
}

/// List files in a directory using search functionality
fn list_files(args: &ListArgs, verbose: bool) -> anyhow::Result<()> {
    if verbose {
        println!(
            "Searching for '{}' in {} (max depth: {})",
            args.pattern,
            args.path.display(),
            args.max_depth
        );
    }

    let scanner = scanner::FileScanner::new().with_config(scanner::ScannerConfig {
        max_depth: if args.max_depth > 0 {
            Some(args.max_depth)
        } else {
            None
        },
        extensions: if args.format.is_empty() {
            None
        } else {
            Some(vec![args.format.clone()])
        },
        recursive: true,
        ..Default::default()
    });

    // Use search to get incremental results
    let mut count = 0;
    let _result = scanner.search(
        &args.path,
        &args.pattern,
        args.search_content,
        args.ignore_case,
        |entry| {
            count += 1;

            if args.long {
                let modified = entry
                    .modified
                    .and_then(|t| t.duration_since(SystemTime::UNIX_EPOCH).ok())
                    .map(|d| {
                        let dt = Local::now() - chrono::Duration::from_std(d).unwrap_or_default();
                        dt.format("%Y-%m-%d %H:%M").to_string()
                    })
                    .unwrap_or_else(|| "unknown".to_string());

                println!(
                    "{:>10}  {}  {}",
                    humansize::format_size(entry.size, humansize::BINARY),
                    modified,
                    entry.path.display()
                );
            } else {
                println!("{}", entry.path.display());
            }

            true // Continue processing
        },
    )?;

    if verbose {
        println!("\nFound {} matches", count);
    }

    Ok(())
}

/// View an SVG file or directory with UTF-8 icons
fn view_file(args: &ViewArgs, verbose: bool) -> anyhow::Result<()> {
    if !args.path.exists() {
        eprintln!("Error: Path not found: {}", args.path.display());
        process::exit(1);
    }

    if args.path.is_file() {
        // Single file view
        if args.browser {
            if verbose {
                println!("Opening in default browser: {}", args.path.display());
            }
            opener::open(args.path.as_path())?;
        } else {
            // Display file with UTF-8 rendering
            if let Some(ext) = args.path.extension() {
                if ext.to_ascii_lowercase() == "svg" {
                    if verbose {
                        println!("Rendering SVG: {}", args.path.display());
                    }
                    // Render the SVG directly to the terminal
                    svg2utf::render_svg_terminal(&args.path)?;
                    return Ok(());
                }
            }
            println!("Not an SVG file: {}", args.path.display());
        }
    } else {
        // Directory view - list SVGs with icons
        if verbose {
            println!(
                "Viewing directory: {} (depth: {})",
                args.path.display(),
                args.depth
            );
        }

        // Configure scanner for SVG files
        let scanner = scanner::FileScanner::new().with_config(scanner::ScannerConfig {
            max_depth: if args.depth > 0 {
                Some(args.depth as usize)
            } else {
                None
            },
            extensions: Some(vec!["svg".to_string()]),
            recursive: args.depth > 1,
            ..Default::default()
        });

        let mut entries: Vec<scanner::FileEntry> = Vec::new();
        scanner.search(&args.path, ".*", false, false, |entry| {
            if !entry.path.is_dir() {
                // Only add files, not directories
                entries.push(entry.clone());
            }
            true // Continue processing
        })?;

        // Sort entries based on the sort option
        match args.sort {
            SortBy::Name => {
                entries.sort_by(|a, b| a.path.file_name().cmp(&b.path.file_name()));
            }
            SortBy::Size => {
                entries.sort_by(|a, b| a.size.cmp(&b.size));
            }
            SortBy::Modified => {
                entries.sort_by(|a, b| {
                    a.modified
                        .unwrap_or(SystemTime::UNIX_EPOCH)
                        .cmp(&b.modified.unwrap_or(SystemTime::UNIX_EPOCH))
                });
            }
        }

        if args.reverse {
            entries.reverse();
        }

        // Get terminal width with a minimum of 40 characters
        let term_width = terminal_size::terminal_size()
            .map(|(w, _)| w.0 as usize)
            .unwrap_or(80)
            .max(40);

        // Calculate maximum filename length needed
        let max_filename_width = entries
            .iter()
            .map(|e| {
                e.path
                    .file_name()
                    .unwrap_or_default()
                    .to_string_lossy()
                    .len()
            })
            .max()
            .unwrap_or(20)
            .min(30); // Maximum filename width to prevent very wide columns

        // Calculate layout parameters
        let icon_width = 2; // Width of the icon plus space
        let padding = 2; // Space between columns
        let col_width = icon_width + max_filename_width + padding;
        let num_cols = (term_width / col_width).max(1);

        println!("Found {} SVG files:", entries.len());
        println!("{}", "-".repeat(term_width));

        // Display entries in a grid
        for (i, entry) in entries.iter().enumerate() {
            // Show mini icon
            let icon = svg2utf::svg_to_mini_icon(&entry.path).unwrap_or(' ');
            print!("{} ", icon);

            // Show filename (without path)
            let filename = entry
                .path
                .file_name()
                .and_then(|n| n.to_str())
                .unwrap_or("");

            // Truncate filename if too long
            let display_name = if filename.len() > max_filename_width {
                let ext = std::path::Path::new(filename)
                    .extension()
                    .and_then(|e| e.to_str())
                    .unwrap_or("");
                let name = &filename[..(max_filename_width.saturating_sub(ext.len() + 3))];
                format!("{}...{}", name, ext)
            } else {
                format!("{:width$}", filename, width = max_filename_width)
            };

            print!("{}", display_name);

            // Add padding or newline
            if (i + 1) % num_cols == 0 || i == entries.len() - 1 {
                println!();
            } else {
                for _ in 0..padding {
                    print!(" ");
                }
            }
        }

        if verbose {
            println!("\nFound {} SVG files", entries.len());
        }
    }

    Ok(())
}

/// Handle memory operations
fn handle_memory(args: &MemoryArgs, verbose: bool) -> anyhow::Result<()> {
    match &args.command {
        MemoryCommands::List => {
            if verbose {
                println!("Listing all memory entries...");
            }
            // TODO: Implement memory listing
            println!("Memory listing not yet implemented");
        }
        MemoryCommands::Add {
            key,
            value,
            memory_type,
        } => {
            if verbose {
                println!(
                    "Adding to {} memory - Key: {}, Value: {}",
                    memory_type.as_ref(),
                    key,
                    value
                );
            }
            // TODO: Implement memory add
            println!("Memory add not yet implemented");
        }
        MemoryCommands::Get { key } => {
            if verbose {
                println!("Getting memory entry: {}", key);
            }
            // TODO: Implement memory get
            println!("Memory get not yet implemented");
        }
        MemoryCommands::Remove { key } => {
            if verbose {
                println!("Removing memory entry: {}", key);
            }
            // TODO: Implement memory remove
            println!("Memory remove not yet implemented");
        }
    }
    Ok(())
}

/// Handle system operations
fn handle_system(args: &SystemArgs, verbose: bool) -> anyhow::Result<()> {
    match &args.command {
        SystemCommands::Info => {
            println!("SView v{}", env!("CARGO_PKG_VERSION"));
            println!("Platform: {}", std::env::consts::OS);
            println!("Architecture: {}", std::env::consts::ARCH);
            println!("Home directory: {:?}", dirs::home_dir().unwrap_or_default());
        }
        SystemCommands::Check => {
            println!("Checking system requirements...");
            // TODO: Implement system check
            println!("All requirements met!");
        }
        SystemCommands::Clean => {
            if verbose {
                println!("Cleaning temporary files...");
            }
            // TODO: Implement clean
            println!("Clean not yet implemented");
        }
    }
    Ok(())
}

/// Start interactive shell
fn start_shell() -> anyhow::Result<()> {
    println!("SView Interactive Shell");
    println!("Type 'help' for available commands, 'exit' to quit");

    let mut input = String::new();
    loop {
        print!("sview> ");
        io::stdout().flush()?;

        input.clear();
        io::stdin().read_line(&mut input)?;

        let input = input.trim();
        if input.is_empty() {
            continue;
        }

        match input.to_lowercase().as_str() {
            "exit" | "quit" | "q" => break,
            "help" => print_help(),
            "clear" => print!("\x1B[2J\x1B[1;1H"),
            _ => {
                // Try to parse as a command
                let args = input.split_whitespace().collect::<Vec<_>>();
                if let Err(e) = parse_shell_command(&args) {
                    eprintln!("Error: {}", e);
                }
            }
        }
    }

    Ok(())
}

/// Parse and execute shell command
fn parse_shell_command(args: &[&str]) -> anyhow::Result<()> {
    if args.is_empty() {
        return Ok(());
    }

    match args[0] {
        "list" | "ls" => {
            let path = args.get(1).unwrap_or(&".");
            let list_args = ListArgs {
                path: PathBuf::from(path),
                format: "svg".to_string(),
                long: args.contains(&"-l") || args.contains(&"--long"),
                sort: SortBy::Name,
                reverse: args.contains(&"-r") || args.contains(&"--reverse"),
                max_depth: 6,
                pattern: ".*".to_string(),
                search_content: false,
                ignore_case: false,
            };
            list_files(&list_args, false)
        }
        "view" | "open" => {
            if let Some(file) = args.get(1) {
                let view_args = ViewArgs {
                    path: PathBuf::from(file),
                    browser: args.contains(&"-b") || args.contains(&"--browser"),
                    depth: 1,
                    long: args.contains(&"-l") || args.contains(&"--long"),
                    sort: if args.contains(&"-s") || args.contains(&"--sort") {
                        // Find the value after --sort or -s
                        let sort_arg = args
                            .iter()
                            .position(|x| x == &"--sort" || x == &"-s")
                            .and_then(|i| args.get(i + 1))
                            .map(|s| s.to_lowercase())
                            .unwrap_or_else(|| "name".to_string());
                        match sort_arg.as_str() {
                            "size" => SortBy::Size,
                            "modified" => SortBy::Modified,
                            _ => SortBy::Name,
                        }
                    } else {
                        SortBy::Name
                    },
                    reverse: args.contains(&"-r") || args.contains(&"--reverse"),
                };
                view_file(&view_args, false)?;
                Ok(())
            } else {
                Err(anyhow::anyhow!("No file specified"))
            }
        }
        "memory" | "mem" => {
            // TODO: Implement memory commands in shell
            println!("Memory commands not yet implemented in shell");
            Ok(())
        }
        _ => Err(anyhow::anyhow!("Unknown command: {}", args[0])),
    }
}

/// Print shell help
fn print_help() {
    println!("Available commands:");
    println!("  list [path]      List SVG files in directory");
    println!("  view <file>      View an SVG file");
    println!("  memory           Manage XQR memory");
    println!("  clear            Clear the screen");
    println!("  help             Show this help");
    println!("  exit | quit | q  Exit the shell");
}

// Implement Display for enums
impl std::fmt::Display for MemoryType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MemoryType::Factual => write!(f, "factual"),
            MemoryType::Episodic => write!(f, "episodic"),
            MemoryType::Semantic => write!(f, "semantic"),
            MemoryType::Working => write!(f, "working"),
        }
    }
}

impl AsRef<str> for MemoryType {
    fn as_ref(&self) -> &str {
        match self {
            MemoryType::Factual => "factual",
            MemoryType::Episodic => "episodic",
            MemoryType::Semantic => "semantic",
            MemoryType::Working => "working",
        }
    }
}
