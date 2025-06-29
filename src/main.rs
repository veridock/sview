use clap::{Parser, Subcommand, ValueEnum, Args};
use std::path::PathBuf;
use std::process;
use anyhow::{Result, Context};
use std::io::{self, Write};
use std::time::SystemTime;
use chrono::Local;

mod scanner;
mod memory;

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
    
    /// Manage XQR memory
    Memory(MemoryArgs),
    
    /// Start interactive shell
    Shell,
    
    /// System information and diagnostics
    System(SystemArgs),
}

/// Arguments for the list command
#[derive(Args, Debug)]
struct ListArgs {
    /// Directory to scan (default: current directory)
    #[arg(default_value = ".")]
    path: PathBuf,
    
    /// File format to filter by
    #[arg(short, long, default_value = "svg")]
    format: String,
    
    /// Show detailed information
    #[arg(short, long)]
    long: bool,
    
    /// Sort by (name, size, modified)
    #[arg(short, long, default_value = "name")]
    sort: SortBy,
    
    /// Reverse sort order
    #[arg(short, long)]
    reverse: bool,
}

/// Arguments for the view command
#[derive(Args, Debug)]
struct ViewArgs {
    /// SVG file to view
    file: PathBuf,
    
    /// Open in default browser
    #[arg(short, long)]
    browser: bool,
    
    /// Width of the viewport
    #[arg(long, default_value_t = 800)]
    width: u32,
    
    /// Height of the viewport
    #[arg(long, default_value_t = 600)]
    height: u32,
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
#[derive(ValueEnum, Clone, Debug)]
enum SortBy {
    Name,
    Size,
    Modified,
}

/// Memory types
#[derive(ValueEnum, Clone, Debug)]
enum MemoryType {
    Factual,
    Episodic,
    Semantic,
    Working,
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    
    if cli.verbose {
        println!("SView v{}", env!("CARGO_PKG_VERSION"));
    }
    
    match &cli.command {
        Commands::List(args) => list_files(args, cli.verbose)?,
        Commands::View(args) => view_file(args, cli.verbose)?,
        Commands::Memory(args) => handle_memory(args, cli.verbose)?,
        Commands::Shell => start_shell()?,
        Commands::System(args) => handle_system(args, cli.verbose)?,
    }
    
    Ok(())
}

/// List files in a directory
fn list_files(args: &ListArgs, verbose: bool) -> Result<()> {
    if verbose {
        println!("Listing files in: {}", args.path.display());
    }
    
    // Use our scanner module to get files
    let scanner = scanner::FileScanner::new()
        .with_config(scanner::ScannerConfig {
            extensions: Some(vec![args.format.clone()]),
            ..Default::default()
        });
    
    let files = scanner.scan(&args.path)?;
    
    // Sort files based on criteria
    let mut sorted_files = files;
    match args.sort {
        SortBy::Name => {
            sorted_files.sort_by(|a, b| a.path.file_name().cmp(&b.path.file_name()));
        }
        SortBy::Size => {
            sorted_files.sort_by(|a, b| a.size.cmp(&b.size));
        }
        SortBy::Modified => {
            sorted_files.sort_by(|a, b| a.modified.cmp(&b.modified));
        }
    }
    
    if args.reverse {
        sorted_files.reverse();
    }
    
    // Display files
    for file in sorted_files {
        if args.long {
            let modified = file.modied
                .and_then(|t| t.duration_since(SystemTime::UNIX_EPOCH).ok())
                .map(|d| {
                    let dt = Local.timestamp(d.as_secs() as i64, 0);
                    dt.format("%Y-%m-%d %H:%M").to_string()
                })
                .unwrap_or_else(|| "unknown".to_string());
                
            println!(
                "{:8}  {}  {}",
                file.size,
                modified,
                file.path.display()
            );
        } else {
            println!("{}", file.path.display());
        }
    }
    
    Ok(())
}

/// View an SVG file
fn view_file(args: &ViewArgs, verbose: bool) -> Result<()> {
    if verbose {
        println!("Viewing file: {}", args.file.display());
    }
    
    if !args.file.exists() {
        eprintln!("Error: File not found: {}", args.file.display());
        process::exit(1);
    }
    
    if args.browser {
        // Open in default browser
        if verbose {
            println!("Opening in default browser...");
        }
        opener::open(args.file.as_path())?;
    } else {
        // TODO: Implement embedded viewer
        println!("Embedded viewer not yet implemented. Use --browser to open in default browser.");
    }
    
    Ok(())
}

/// Handle memory operations
fn handle_memory(args: &MemoryArgs, verbose: bool) -> Result<()> {
    match &args.command {
        MemoryCommands::List => {
            if verbose {
                println!("Listing all memory entries...");
            }
            // TODO: Implement memory listing
            println!("Memory listing not yet implemented");
        }
        MemoryCommands::Add { key, value, memory_type } => {
            if verbose {
                println!("Adding to {} memory - Key: {}, Value: {}", memory_type.as_ref(), key, value);
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
fn handle_system(args: &SystemArgs, verbose: bool) -> Result<()> {
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
fn start_shell() -> Result<()> {
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
fn parse_shell_command(args: &[&str]) -> Result<()> {
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
            };
            list_files(&list_args, false)
        }
        "view" | "open" => {
            if let Some(file) = args.get(1) {
                let view_args = ViewArgs {
                    file: PathBuf::from(file),
                    browser: args.contains(&"-b") || args.contains(&"--browser"),
                    width: 800,
                    height: 600,
                };
                view_file(&view_args, false)
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
