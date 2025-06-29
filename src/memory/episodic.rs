use std::collections::VecDeque;
use chrono::prelude::*;

pub struct EpisodicMemory {
    events: VecDeque<(DateTime<Local>, String)>,
    max_size: usize,
}

impl EpisodicMemory {
    pub fn new(max_size: usize) -> Self {
        EpisodicMemory {
            events: VecDeque::new(),
            max_size,
        }
    }

    pub fn record_event(&mut self, event: String) {
        let now = Local::now();
        self.events.push_back((now, event));
        
        if self.events.len() > self.max_size {
            self.events.pop_front();
        }
    }

    pub fn get_recent_events(&self, count: usize) -> Vec<(DateTime<Local>, String)> {
        self.events
            .iter()
            .rev()
            .take(count)
            .map(|&(time, ref event)| (time, event.clone()))
            .collect()
    }

    pub fn get_events_between(&self, start: DateTime<Local>, end: DateTime<Local>) -> Vec<(DateTime<Local>, String)> {
        self.events
            .iter()
            .filter(|&&(time, _)| time >= start && time <= end)
            .map(|&(time, ref event)| (time, event.clone()))
            .collect()
    }
}
