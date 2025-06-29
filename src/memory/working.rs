use std::collections::HashMap;
use std::time::Duration;
use std::sync::{Arc, Mutex};
use std::thread;

#[derive(Clone)]
pub struct WorkingMemory {
    buffer: Arc<Mutex<HashMap<String, MemoryItem>>>,
    max_items: usize,
    timeout: Duration,
}

#[derive(Debug, Clone)]
struct MemoryItem {
    data: String,
    last_accessed: std::time::Instant,
}

impl WorkingMemory {
    pub fn new(max_items: usize, timeout_seconds: u64) -> Self {
        WorkingMemory {
            buffer: Arc::new(Mutex::new(HashMap::new())),
            max_items,
            timeout: Duration::from_secs(timeout_seconds),
        }
    }

    pub fn add(&self, key: String, data: String) {
        let mut buffer = self.buffer.lock().unwrap();
        
        // Remove oldest item if buffer is full
        if buffer.len() >= self.max_items {
            let oldest_key = buffer
                .iter()
                .min_by_key(|&(_, item)| item.last_accessed)
                .map(|(k, _)| k.clone());
            
            if let Some(oldest_key) = oldest_key {
                buffer.remove(&oldest_key);
            }
        }

        buffer.insert(key, MemoryItem {
            data,
            last_accessed: std::time::Instant::now(),
        });
    }

    pub fn get(&self, key: &str) -> Option<String> {
        let mut buffer = self.buffer.lock().unwrap();
        
        if let Some(item) = buffer.get_mut(key) {
            item.last_accessed = std::time::Instant::now();
            Some(item.data.clone())
        } else {
            None
        }
    }

    pub fn remove(&self, key: &str) {
        let mut buffer = self.buffer.lock().unwrap();
        buffer.remove(key);
    }

    pub fn clear(&self) {
        let mut buffer = self.buffer.lock().unwrap();
        buffer.clear();
    }

    pub fn start_cleanup_thread(&self) -> std::thread::JoinHandle<()> {
        // Clone the Arc that contains the Mutex
        let buffer = Arc::clone(&self.buffer);
        let timeout = self.timeout;

        thread::spawn(move || {
            loop {
                thread::sleep(timeout);
                
                // Lock the mutex and clean up old entries
                let mut buffer_guard = match buffer.lock() {
                    Ok(guard) => guard,
                    Err(poisoned) => {
                        // Try to recover from a poisoned lock
                        println!("Warning: Mutex was poisoned, attempting to recover...");
                        poisoned.into_inner()
                    }
                };
                
                let now = std::time::Instant::now();
                buffer_guard.retain(|_, item| {
                    now.duration_since(item.last_accessed) < timeout
                });
            }
        })
    }
}
