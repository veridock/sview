use std::collections::HashMap;
use std::sync::Mutex;

pub struct SemanticMemory {
    concepts: Mutex<HashMap<String, Concept>>,
}

#[derive(Debug, Clone)]
pub struct Concept {
    pub name: String,
    pub attributes: HashMap<String, String>,
    pub relationships: HashMap<String, String>,
}

impl SemanticMemory {
    pub fn new() -> Self {
        SemanticMemory {
            concepts: Mutex::new(HashMap::new()),
        }
    }

    pub fn add_concept(&self, concept: Concept) {
        let mut concepts = self.concepts.lock().unwrap();
        concepts.insert(concept.name.clone(), concept);
    }

    pub fn get_concept(&self, name: &str) -> Option<Concept> {
        let concepts = self.concepts.lock().unwrap();
        concepts.get(name).cloned()
    }

    pub fn add_attribute(&self, concept_name: &str, attribute: String, value: String) {
        if let Some(concept) = self.get_concept(concept_name) {
            let mut updated_concept = concept;
            updated_concept.attributes.insert(attribute, value);
            self.add_concept(updated_concept);
        }
    }

    pub fn add_relationship(&self, concept_name: &str, related_concept: String, relation_type: String) {
        if let Some(concept) = self.get_concept(concept_name) {
            let mut updated_concept = concept;
            updated_concept.relationships.insert(related_concept, relation_type);
            self.add_concept(updated_concept);
        }
    }

    pub fn query_concepts(&self, attribute: &str, value: &str) -> Vec<Concept> {
        let concepts = self.concepts.lock().unwrap();
        concepts
            .values()
            .filter(|c| c.attributes.get(attribute).map_or(false, |v| v == value))
            .cloned()
            .collect()
    }
}
