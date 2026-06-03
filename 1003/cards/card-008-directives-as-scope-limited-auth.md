# Card 008: Directives as Scope-Limited Authorization

## Date
2026-06-03

## Predecessor
Card-007

## The Model

A directive ("research issue X", "implement feature Y", "investigate bug Z") IS a form of authorization — but its scope is bounded by the directive's verb and noun.

| Directive Verb | Authorization Scope | Bounded To |
|---------------|-------------------|------------|
| "Research" | Research/read only | Reading issue, web search, creating findings, discussion. NOT tool source analysis, NOT reverse-engineering. |
| "Investigate" | Observe + report | Observing behavior as black-box, reporting findings. NOT reading source to understand internals. |
| "Implement" | Execute + dispatch | Calling skill() and task() with contracted params. NOT pre-reading skill files or analysis. |
| "Design" / "Plan" | Spec + plan creation | Brainstorming, writing spec/plan issues. NOT implementation, NOT pre-reading. |
| "Review" | Read + evaluate | Reading code/docs and forming judgment. NOT modification. |
| "Fix" | Diagnose + remediate | Dispatch to systematic-debugging skill. NOT inline patch. |

## The Violation in #1003

The prompt used "investigate" with explicit constraints ("behavior first, code only as post-bug-confirmation"). The agent parsed "investigate" as "reverse-engineer" — overflowing the directive's scope.

**Root cause:** The agent's learned reflex maps "investigate" to "understand internals" rather than "observe behavior." This is a prompt-word polarization problem.

## Implication for Behavioral Tests

Behavioral test prompts that use "investigate" will consistently trigger reverse-engineering. The fix is to use different directive words for the behavioral observation phase:

| Instead of | Use | Effect |
|-----------|-----|--------|
| "Investigate whether the tool handles X" | "Observe what happens when you run the tool with X" | Triggers observation, not reverse-engineering |
| "Research the bug in Y" | "Test Y and report what you see" | Triggers behavioral observation |
| "Look into why Z fails" | "Run Z, observe the output, report findings" | Triggers clean-room observation |

## Two-Layer Fix

1. **Directive-scope discipline**: The agent must learn to bound its actions by the directive's verb. "Investigate" → observe behavior, not read source. This is a prompt-level instruction change.

2. **Prompt hygiene**: Behavioral test infrastructure should avoid the word "investigate" entirely. Use "observe" / "test" / "run-and-report" vocabulary that maps to the black-box observation reflex.