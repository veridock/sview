use std::path::Path;
use anyhow::Result;
use notify::{Watcher, RecursiveMode, watcher};
use std::sync::mpsc::channel;
use std::time::Duration;

pub fn scan(path: &str) -> Result<()> {
    let path = Path::new(path);
    if !path.exists() {
        return Err(anyhow::anyhow!("Path does not exist: {}", path.display()));
    }

    let (tx, rx) = channel();
    let mut watcher = watcher(tx, Duration::from_secs(1))?
        .watch(path, RecursiveMode::Recursive)?;

    loop {
        match rx.recv() {
            Ok(event) => {
                println!("File system event: {:?}", event);
                // Process file changes here
            }
            Err(e) => eprintln!("Watch error: {}", e),
        }
    }
}
