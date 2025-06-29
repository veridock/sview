use std::path::{Path, PathBuf};
use std::collections::HashSet;
use std::sync::{Arc, Mutex};
use std::time::{Duration, SystemTime};
use std::fs;
use anyhow::{Result, Context};
use notify::{Config, Event as FsEvent, EventKind, RecommendedWatcher, RecursiveMode, Watcher};
use serde::{Serialize, Deserialize};
use walkdir::WalkDir;

/// Represents a file system entry (file or directory)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FileEntry {
    pub path: PathBuf,
    pub is_dir: bool,
    pub size: u64,
    pub modified: Option<SystemTime>,
    pub file_type: Option<String>,
}

/// Configuration for the file scanner
#[derive(Debug, Clone)]
pub struct ScannerConfig {
    pub recursive: bool,
    pub max_depth: Option<usize>,
    pub extensions: Option<Vec<String>>,
    pub min_size: Option<u64>,
    pub max_size: Option<u64>,
    pub exclude_dirs: Vec<String>,
}

impl Default for ScannerConfig {
    fn default() -> Self {
        Self {
            recursive: true,
            max_depth: None,
            extensions: None,
            min_size: None,
            max_size: None,
            exclude_dirs: vec![".git".to_string(), "node_modules".to_string()],
        }
    }
}

/// Main scanner implementation
pub struct FileScanner {
    config: ScannerConfig,
    watched_paths: Arc<Mutex<HashSet<PathBuf>>>,
}

impl FileScanner {
    /// Create a new FileScanner with default configuration
    pub fn new() -> Self {
        Self {
            config: ScannerConfig::default(),
            watched_paths: Arc::new(Mutex::new(HashSet::new())),
        }
    }
    
    /// Search for files matching a query with incremental results
    pub fn search<P, F>(
        &self, 
        path: P, 
        query: &str, 
        search_content: bool,
        ignore_case: bool,
        mut callback: F,
    ) -> Result<usize> 
    where
        P: AsRef<Path>,
        F: FnMut(&FileEntry) -> bool,
    {
        let path = path.as_ref();
        if !path.exists() {
            return Err(anyhow::anyhow!("Path does not exist: {}", path.display()));
        }

        let query = if ignore_case {
            query.to_lowercase()
        } else {
            query.to_string()
        };

        let mut count = 0;
        let mut walker = WalkDir::new(path);
        
        // Apply configuration to walker
        if let Some(depth) = self.config.max_depth {
            walker = walker.max_depth(depth);
        }
        
        if !self.config.recursive {
            walker = walker.max_depth(1);
        }

        for entry in walker.into_iter().filter_map(Result::ok) {
            // Skip directories in exclude list
            if entry.file_type().is_dir() {
                if self.config.exclude_dirs.iter().any(|dir| {
                    entry.path().to_string_lossy().contains(dir)
                }) {
                    continue;
                }
                continue;
            }


            // Check file extension if specified
            if let Some(extensions) = &self.config.extensions {
                if let Some(ext) = entry.path().extension() {
                    let ext_str = ext.to_string_lossy().to_string();
                    if !extensions.iter().any(|e| e.eq_ignore_ascii_case(&ext_str)) {
                        continue;
                    }
                } else {
                    continue;
                }
            }

            // Get file metadata
            let metadata = match fs::metadata(entry.path()) {
                Ok(m) => m,
                Err(_) => continue,
            };

            // Check size filters
            let size = metadata.len();
            if let Some(min) = self.config.min_size {
                if size < min { continue; }
            }
            if let Some(max) = self.config.max_size {
                if size > max { continue; }
            }

            // Create file entry
            let file_entry = FileEntry {
                path: entry.path().to_path_buf(),
                is_dir: false,
                size,
                modified: metadata.modified().ok(),
                file_type: entry.path().extension()
                    .and_then(|ext| ext.to_str())
                    .map(|s| s.to_string()),
            };

            // Check if filename matches
            let file_name = entry.file_name().to_string_lossy();
            let matches = if ignore_case {
                file_name.to_lowercase().contains(&query)
            } else {
                file_name.contains(&query)
            };

            if matches {
                count += 1;
                if !callback(&file_entry) {
                    break;
                }
                continue;
            }

            // If we should search in file contents
            if search_content && size < 10_000_000 { // Skip large files
                if let Ok(mut file) = fs::File::open(entry.path()) {
                    let mut contents = String::new();
                    if file.read_to_string(&mut contents).is_ok() {
                        let search_text = if ignore_case {
                            contents.to_lowercase()
                        } else {
                            contents
                        };
                        
                        if search_text.contains(&query) {
                            count += 1;
                            if !callback(&file_entry) {
                                break;
                            }
                        }
                    }
                }
            }
        }


        Ok(count)
    }

    /// Configure the scanner with custom settings
    pub fn with_config(mut self, config: ScannerConfig) -> Self {
        self.config = config;
        self
    }

    /// Scan a directory and return all matching files
    pub fn scan<P: AsRef<Path>>(&self, path: P) -> Result<Vec<FileEntry>> {
        let path = path.as_ref();
        if !path.exists() {
            return Err(anyhow::anyhow!("Path does not exist: {}", path.display()));
        }

        let mut walker = WalkDir::new(path);
        
        // Apply configuration to walker
        if let Some(depth) = self.config.max_depth {
            walker = walker.max_depth(depth);
        }
        
        if !self.config.recursive {
            walker = walker.max_depth(1);
        }

        // Filter and collect files in parallel
        let files: Vec<FileEntry> = walker
            .into_iter()
            .filter_map(Result::ok)
            .filter(|entry| {
                // Skip directories in exclude list
                if entry.file_type().is_dir() {
                    return !self.config.exclude_dirs.iter().any(|dir| {
                        entry.path().to_string_lossy().contains(dir)
                    });
                }
                true
            })
            .filter_map(|entry| {
                let metadata = fs::metadata(entry.path()).ok()?;
                
                // Skip if file doesn't match size filters
                if let Some(min) = self.config.min_size {
                    if metadata.len() < min {
                        return None;
                    }
                }
                
                if let Some(max) = self.config.max_size {
                    if metadata.len() > max {
                        return None;
                    }
                }

                // Check file extension
                if let Some(extensions) = &self.config.extensions {
                    let ext = entry.path().extension()
                        .and_then(|e| e.to_str())
                        .unwrap_or("").to_lowercase();
                    
                    if !extensions.iter().any(|e| e.to_lowercase() == ext) {
                        return None;
                    }
                }

                Some(FileEntry {
                    path: entry.path().to_path_buf(),
                    is_dir: entry.file_type().is_dir(),
                    size: metadata.len(),
                    modified: metadata.modified().ok(),
                    file_type: entry.path().extension()
                        .and_then(|e| e.to_str())
                        .map(|s| s.to_string()),
                })
            })
            .collect();

        Ok(files)
    }

    /// Watch a directory for changes and call the callback when changes are detected
    pub fn watch<P, F>(
        &self,
        path: P,
        callback: F,
    ) -> Result<()>
    where
        P: AsRef<Path> + Send + 'static,
        F: Fn(Vec<FileEntry>) + Send + 'static,
    {
        use std::sync::mpsc::channel;

        let path_buf = path.as_ref().to_path_buf();
        if !path_buf.exists() {
            return Err(anyhow::anyhow!("Path does not exist: {}", path_buf.display()));
        }

        // Initial scan
        let initial_files = self.scan(&path_buf)?;
        callback(initial_files);

        // Set up file watcher
        let (tx, rx) = channel();
        
        // Create watcher with debounce
        let mut watcher = RecommendedWatcher::new(
            move |res: Result<FsEvent, _>| {
                if let Ok(event) = res {
                    if let Err(e) = tx.send(event) {
                        eprintln!("Watch error: {}", e);
                    }
                }
            },
            Config::default().with_poll_interval(Duration::from_secs(1)),
        )?;

        // Watch the path
        watcher.watch(&path_buf, RecursiveMode::Recursive)?;
        
        // Spawn a thread to handle events
        let callback = Arc::new(std::sync::Mutex::new(callback));
        
        // Create a new thread with 'static lifetime
        std::thread::spawn(move || {
            for event in rx {
                match event.kind {
                    EventKind::Any | EventKind::Create(_) | EventKind::Modify(_) | EventKind::Remove(_) => {
                        // Create a new scanner for each event to avoid lifetime issues
                        let scanner = FileScanner::new();
                        // Rescan the directory and call the callback with the new file list
                        if let Ok(entries) = scanner.scan(&path_buf) {
                            if let Ok(cb) = callback.lock() {
                                cb(entries);
                            }
                        }
                    }
                    _ => {}
                }
            }
        });

        Ok(())
    }
}

impl Default for FileScanner {
    fn default() -> Self {
        Self::new()
    }
}

/// Utility function to get file metadata
pub fn get_file_metadata<P: AsRef<Path>>(path: P) -> Result<FileEntry> {
    let path = path.as_ref();
    let metadata = fs::metadata(path)
        .with_context(|| format!("Failed to get metadata for {}", path.display()))?;

    Ok(FileEntry {
        path: path.to_path_buf(),
        is_dir: metadata.is_dir(),
        size: metadata.len(),
        modified: metadata.modified().ok(),
        file_type: path.extension()
            .and_then(|e| e.to_str())
            .map(|s| s.to_string()),
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;
    use std::fs::File;
    use std::io::Write;

    #[test]
    fn test_scan_directory() -> Result<()> {
        // Create a temporary directory with test files
        let dir = tempdir()?;
        let file_path = dir.path().join("test.txt");
        let mut file = File::create(&file_path)?;
        writeln!(file, "Test content")?;

        // Create a subdirectory
        let sub_dir = dir.path().join("subdir");
        std::fs::create_dir(&sub_dir)?;
        let sub_file = sub_dir.join("subfile.txt");
        File::create(&sub_file)?;

        // Test scanner with default config
        let scanner = FileScanner::new();
        let files = scanner.scan(dir.path())?;
        
        // Should find both files and the subdirectory
        assert!(files.len() >= 2);
        
        // Test with non-recursive scan
        let config = ScannerConfig {
            recursive: false,
            ..Default::default()
        };
        let scanner = FileScanner::new().with_config(config);
        let files = scanner.scan(dir.path())?;
        
        // Should only find files in the root
        assert_eq!(files.len(), 1);
        
        Ok(())
    }

    #[test]
    fn test_file_metadata() -> Result<()> {
        let dir = tempdir()?;
        let file_path = dir.path().join("test_meta.txt");
        File::create(&file_path)?;
        
        let meta = get_file_metadata(&file_path)?;
        assert_eq!(meta.path, file_path);
        assert!(!meta.is_dir);
        assert!(meta.size == 0);
        assert!(meta.modified.is_some());
        
        Ok(())
    }
}
