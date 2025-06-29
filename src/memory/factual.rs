use std::collections::HashMap;

pub struct FactualMemory {
    facts: HashMap<String, String>,
}

impl FactualMemory {
    pub fn new() -> Self {
        FactualMemory {
            facts: HashMap::new(),
        }
    }

    pub fn store(&mut self, key: String, value: String) {
        self.facts.insert(key, value);
    }

    pub fn retrieve(&self, key: &str) -> Option<&String> {
        self.facts.get(key)
    }

    pub fn remove(&mut self, key: &str) -> Option<String> {
        self.facts.remove(key)
    }

    pub fn clear(&mut self) {
        self.facts.clear();
    }
}
