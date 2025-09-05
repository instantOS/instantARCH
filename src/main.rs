type StepId = String;

struct InstallationStep {
    id: StepId,
    input: InputType,
    condition: StepCondition
}

enum InputType {
    Toggle{default: bool},
    Input{default: Option<String>}
}

enum StepCondition {
    Always
}

impl StepCondition {
    fn evaluate(self, engine: &InstallationEngine) -> bool{
        match self {
            StepCondition::Always => true
        }
    }
}

struct InstallationEngine {
    steps: Vec<InstallationStep>,
}

impl InstallationEngine {
    fn get_bext_step(self) -> Option<&mut InstallationStep> {
        for step in self.steps {

        }
    }
}


fn main() {
    println!("Hello, world!");
}
