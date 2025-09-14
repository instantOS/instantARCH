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

//Todo answer enumm

struct InstallationEngine {
    steps: Vec<InstallationStep>,
    //Todo: hashmap with  answerss
}

impl InstallationEngine {
    fn get_bext_step(self) -> Option<StepId> {
        for step in self.steps {
            if step.condition.evaluate() {
                return step.id.clone()
            }
        }
    }
}


fn main() {
    println!("Hello, world!");
}
