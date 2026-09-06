## Purpose

Defines the concrete reference-program suite that grades a player's submitted evaluator in the Interpreter track's main workspace, the data `advanced-project-sandboxes`' Interpreter Track Evaluation Workspace requirement assumes exists.

## ADDED Requirements

### Requirement: Reference Program Suite Coverage
The reference-program suite SHALL include at least one program exercising each MVP-subset construct (definitions, `lambda`, conditionals, procedure application, quotation), and at least one program each specifically designed to trigger, in a correct player evaluator, an unbound-variable error, an arity-mismatch error, and a non-procedure-application error.

#### Scenario: MVP constructs are represented
- **WHEN** the reference-program suite is assembled
- **THEN** every MVP-subset construct has at least one reference program exercising it

#### Scenario: Each required error category has a triggering program
- **WHEN** the reference-program suite is assembled
- **THEN** it includes a program that references an undefined variable, a program that calls an interpreted procedure with the wrong number of arguments, and a program that applies a non-procedure value

### Requirement: Reference Programs Supplied as Pre-Parsed Data With Expected Printed Output
Each reference program SHALL be stored as pre-parsed Scheme data (not raw source text), paired with its expected printed output, so the harness can supply it directly to a submitted evaluator per `advanced-project-sandboxes`' "Reference programs are provided pre-parsed" scenario.

#### Scenario: A reference program pairs data with expected output
- **WHEN** a reference program is added to the suite
- **THEN** it is stored as already-read Scheme data together with the exact output a correct evaluator must print for it

### Requirement: Correct Evaluator Passes, Incorrect Evaluator Fails With Detail
Running the reference suite through a correct player evaluator SHALL produce printed output matching every program's expected output. Running it through an evaluator missing one of the three required error detections SHALL fail specifically on that error category's program, rather than passing spuriously or failing unrelated programs.

#### Scenario: Correct evaluator passes every reference program
- **WHEN** a correct player evaluator is graded against the reference suite
- **THEN** its printed output matches the expected output for every program in the suite

#### Scenario: Evaluator missing arity checking fails the arity-mismatch program
- **WHEN** a player evaluator that does not detect arity mismatches is graded against the reference suite
- **THEN** grading fails specifically on the arity-mismatch reference program, while programs unrelated to arity checking still pass
