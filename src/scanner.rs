use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::fs;
use std::io::Read;
use std::path::{Path, PathBuf};
use std::time::SystemTime;
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
}

impl FileScanner {
    /// Create a new FileScanner with default configuration
    pub fn new() -> Self {
        Self {
            config: ScannerConfig::default(),
        }
    }

    /// Scan a directory and return all files matching the configuration
    pub fn scan<P: AsRef<Path>>(&self, path: P) -> Result<Vec<FileEntry>> {
        let path = path.as_ref();
        let mut entries = Vec::new();

        let walker = WalkDir::new(path).max_depth(if self.config.recursive {
            self.config.max_depth.unwrap_or(usize::MAX)
        } else {
            1
        });

        for entry in walker.into_iter().filter_map(Result::ok) {
            // Skip directories in exclude list
            if entry.file_type().is_dir() {
                if self.config.exclude_dirs.iter().any(|dir| {
                    entry.path().file_name().map_or(false, |name| {
                        name.to_string_lossy().eq_ignore_ascii_case(dir)
                    })
                }) {
                    continue;
                }
            }

            if let Ok(metadata) = entry.metadata() {
                let file_type = if entry.file_type().is_dir() {
                    Some("directory".to_string())
                } else if let Some(ext) = entry.path().extension() {
                    Some(ext.to_string_lossy().to_string())
                } else {
                    None
                };

                let entry = FileEntry {
                    path: entry.path().to_path_buf(),
                    is_dir: entry.file_type().is_dir(),
                    size: metadata.len(),
                    modified: metadata.modified().ok(),
                    file_type,
                };

                // Check size filters
                let size_ok = self.config.min_size.map_or(true, |min| entry.size >= min)
                    && self.config.max_size.map_or(true, |max| entry.size <= max);

                // Check extension filter
                let ext_ok = if let Some(exts) = &self.config.extensions {
                    entry
                        .path
                        .extension()
                        .and_then(|e| e.to_str())
                        .map_or(false, |e| exts.iter().any(|x| x.eq_ignore_ascii_case(e)))
                } else {
                    true
                };

                if size_ok && ext_ok {
                    entries.push(entry);
                }
            }
        }

        Ok(entries)
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
                    entry.path().file_name().map_or(false, |name| {
                        name.to_string_lossy().eq_ignore_ascii_case(dir)
                    })
                }) {
                    continue;
                }
                // Don't continue here - we want to process files in this directory
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
                if size < min {
                    continue;
                }
            }
            if let Some(max) = self.config.max_size {
                if size > max {
                    continue;
                }
            }

            // Create file entry
            let file_entry = FileEntry {
                path: entry.path().to_path_buf(),
                is_dir: false,
                size,
                modified: metadata.modified().ok(),
                file_type: entry
                    .path()
                    .extension()
                    .and_then(|ext| ext.to_str())
                    .map(|s| s.to_string()),
            };

            // Check if filename matches
            let file_name = entry.file_name().to_string_lossy();
            let matches = if query == ".*" {
                // Special case: .* matches all files
                true
            } else if ignore_case {
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
            if search_content && size < 10_000_000 {
                // Skip large files
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
}

impl Default for FileScanner {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
/// Get metadata for a file
pub fn get_file_metadata<P: AsRef<Path>>(path: P) -> Result<FileEntry> {
    let path = path.as_ref();
    let metadata = std::fs::metadata(path)?;

    let file_type = if metadata.is_dir() {
        Some("directory".to_string())
    } else {
        path.extension()
            .and_then(|e| e.to_str())
            .map(|s| s.to_string())
    };

    Ok(FileEntry {
        path: path.to_path_buf(),
        is_dir: metadata.is_dir(),
        size: metadata.len(),
        modified: metadata.modified().ok(),
        file_type,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs::File;
    use std::io::Write;
    use std::path::Path;
    use tempfile::tempdir;

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

        // Should only find the test file in the root (not directories or hidden files)
        let root_files: Vec<_> = files
            .iter()
            .filter(|f| {
                !f.is_dir
                    && f.path
                        .file_name()
                        .and_then(|n| n.to_str())
                        .map_or(false, |n| !n.starts_with('.'))
            })
            .collect();

        assert_eq!(
            root_files.len(),
            1,
            "Should only find the test file in root directory"
        );
        assert_eq!(
            root_files[0].path.file_name().unwrap().to_string_lossy(),
            "test.txt",
            "Should find the test.txt file"
        );

        Ok(())
    }

    #[test]
    fn test_file_metadata() -> Result<()> {
        let temp_dir = tempdir()?;
        let file_path = temp_dir.path().join("test.txt");
        let mut file = File::create(&file_path)?;
        write!(file, "test content")?;

        let metadata = get_file_metadata(&file_path)?;
        assert_eq!(metadata.path, file_path);
        assert!(metadata.size > 0);
        assert!(metadata.modified.is_some());
        assert!(!metadata.is_dir);

        // Test with Path and PathBuf
        let path_buf = file_path.clone();
        let path = path_buf.as_path();

        let metadata_from_path = get_file_metadata(path)?;
        assert_eq!(metadata_from_path.path, file_path);

        temp_dir.close()?;
        Ok(())
    }
}
