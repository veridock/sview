use std::path::{Path, PathBuf};
use std::collections::HashSet;
use std::sync::{Arc, Mutex};
use std::time::{Duration, SystemTime};
use std::fs;
use anyhow::{Result, Context};
use notify::{Watcher, RecursiveMode, watcher, Event as FsEvent, EventKind};
use rayon::prelude::*;
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
        P: AsRef<Path>,
        F: Fn(Vec<FileEntry>) + Send + 'static,
    {
        let path = path.as_ref();
        if !path.exists() {
            return Err(anyhow::anyhow!("Path does not exist: {}", path.display()));
        }

        // Initial scan
        let initial_files = self.scan(path)?;
        callback(initial_files);

        // Set up file watcher
        let (tx, rx) = std::sync::mpsc::channel();
        let mut watcher = watcher(tx, Duration::from_secs(1))?;
        
        // Watch the directory
        watcher.watch(path, RecursiveMode::Recursive)?;
        self.watched_paths.lock().unwrap().insert(path.to_path_buf());

        // Spawn a thread to handle file system events
        std::thread::spawn(move || {
            for event in rx {
                match event {
                    Ok(FsEvent { kind: EventKind::Any, paths, .. }) => {
                        // On any change, rescan the directory
                        if let Ok(entries) = self.scan(path) {
                            callback(entries);
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
