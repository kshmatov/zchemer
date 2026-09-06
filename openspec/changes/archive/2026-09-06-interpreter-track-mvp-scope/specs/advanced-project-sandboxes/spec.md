## MODIFIED Requirements

### Requirement: Interpreter Track Evaluation Workspace
The Scheme Interpreter track SHALL let a player implement their own evaluator (`eval`/`apply`) in Scheme, over the MVP language subset (definitions, `lambda`, conditionals, procedure application, and quotation — excluding `call/cc` and any variable or data mutation for this MVP), and SHALL exercise that evaluator against the game's reference suite of sample programs, comparing the player's evaluator's printed output to each program's expected output.

#### Scenario: Custom evaluator is checked against sample programs
- **WHEN** a player submits their evaluator implementation for grading
- **THEN** the system runs the reference sample programs through the player's evaluator inside the sandbox and compares the results to the expected output for each

#### Scenario: Reference programs are provided pre-parsed
- **WHEN** a reference program is run through the player's evaluator
- **THEN** the program is supplied to the player's evaluator as already-parsed data via the host's reader, and the player's evaluator is not required to parse raw source text itself

#### Scenario: Grading compares printed output, not a return value
- **WHEN** a reference program's expected behavior is defined
- **THEN** it is defined in terms of what the program prints during evaluation, not the value its top-level expression evaluates to

#### Scenario: Using Racket's own evaluator is disallowed
- **WHEN** a player's submitted evaluator implementation directly invokes Racket's built-in `eval` (or an equivalent dynamic-evaluation escape hatch) instead of interpreting the reference program itself
- **THEN** the static check defined by `code-evaluation` blocks execution and reports that delegating evaluation is not allowed for this exercise

## ADDED Requirements

### Requirement: Minimal Interpreted-Program Error Detection
A correct player evaluator SHALL detect and report, rather than crash unrecoverably or silently continue with an incorrect result on, three error categories that are intrinsic to the evaluator itself: an unbound variable reference, an arity mismatch on an interpreted procedure call, and application of a non-procedure value. Errors originating from delegated primitive operations (for example, `car` on a non-pair) are outside this requirement, since they are already raised by the host primitives the evaluator delegates to.

#### Scenario: Evaluator correctly identifies an unbound variable
- **WHEN** a reference program references a variable that was never defined
- **THEN** a correct player evaluator reports this as an error rather than crashing unrecoverably or continuing with an incorrect value

#### Scenario: Evaluator correctly identifies an arity mismatch
- **WHEN** a reference program calls an interpreted procedure with the wrong number of arguments
- **THEN** a correct player evaluator reports this as an error rather than crashing unrecoverably or continuing with an incorrect value

#### Scenario: Evaluator correctly identifies a non-procedure application
- **WHEN** a reference program attempts to apply a non-procedure value as if it were a procedure
- **THEN** a correct player evaluator reports this as an error rather than crashing unrecoverably or continuing with an incorrect value
