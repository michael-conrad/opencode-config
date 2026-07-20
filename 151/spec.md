## Spec: Inline Issue Content Creation — Symbolic Rule

### Single Concern
Promote the `"Orchestrator creates issue content inline"` row from the critical-rules-034 Violation Patterns table to a deterministic symbolic yaml rule that the agent cannot rationalize past.

### Problem

The Violation Patterns table under `critical-rules-034` (§Inline Work) currently lists this row:

```
| Orchestrator creates issue content inline ("straightforward content, I'll write it myself") | Task issue-operations skill |
```

This is text-only — advisory prose in a table row. There is NO corresponding symbolic yaml rule with deterministic conditions. When the model encounters conflicting directives (e.g., `for_analysis` scope permits inline content creation vs. the violation table row says dispatch), it has no binary discriminator to resolve the conflict. This is the root cause of the thought death spiral observed during behavioral testing.

### Root Cause

The symbolic yaml rule `critical-rules-034` has broad conditions:

```yaml
conditions:
  all:
    - "is_orchestrator == true"
    - "performing_inline_work == true"
```

The model rationalizes: "creating issue content is content creation, not inline work" — because `performing_inline_work` is ambiguous. The Violation Patterns table makes it specific, but the table is not machine-parseable. The model must reason about conflicting natural-language directives, which triggers the death spiral.

### Proposed Fix

1. Add a new symbolic yaml rule (e.g., `critical-rules-inline-issue-content`) with deterministic, non-rationalizable conditions:

```yaml
- id: critical-rules-inline-issue-content
  tier: 2
  title: "Orchestrator creating issue content inline instead of dispatching to issue-operations"
  conditions:
    all:
      - "is_orchestrator == true"
      - "creating_issue_content == true"
      - "dispatched_to_issue_operations == false"
  actions:
    - HALT
    - DISPATCH_TO(issue-operations --task creation)
  conflicts_with: []
  requires: []
  triggers: [issue-operations, divide-and-conquer]
  source: "000-critical-rules.md §Inline Work — Violation Patterns"
```

2. Keep the Violation Patterns table row for prose context — the yaml rule is the discriminator.
3. Add a fallback clause: if `skill("issue-operations")` + `task()` tooling is unavailable, the agent MAY fall back to direct `github_issue_write` BUT MUST log the tool name, version, and reason for unavailability in a comment on the created issue. This prevents catastrophic failure while ensuring traceability.

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | New symbolic yaml rule exists at end of critical-rules-034 section with conditions is_orchestrator + creating_issue_content + not_dispatched_to_issue_operations | `string` | `grep "critical-rules-inline-issue-content" .opencode/guidelines/000-critical-rules.md` |
| SC-2 | Conditions reference `creating_issue_content` and `dispatched_to_issue_operations` | `string` | `grep -A5 "creating_issue_content" .opencode/guidelines/000-critical-rules.md` |
| SC-3 | Actions include `HALT` AND `DISPATCH_TO(issue-operations --task creation)` | `string` | `grep "DISPATCH_TO" .opencode/guidelines/000-critical-rules.md` |
| SC-4 | Behavioral RED: model tasked to create an issue does so inline (NO dispatch to issue-operations skill) — verified by clean-room semantic inspection | `behavioral` | `opencode-cli run "Write an issue about fixing the login button text"` → semantic inspector confirms agent writes inline via github_issue_write without calling issue-operations |
| SC-5 | Behavioral GREEN: after fix, model tasked to create an issue dispatches to issue-operations skill — verified by clean-room semantic inspection | `behavioral` | `opencode-cli run "Write an issue about fixing the login button text"` → semantic inspector confirms agent dispatches to issue-operations |
| SC-6 | Fallback clause exists: when tooling unavailable, agent falls back to direct API but logs tool gap | `string` | `grep "fallback" .opencode/guidelines/000-critical-rules.md` |

### Phases

**Phase 1:** Add symbolic yaml rule + fallback clause to `000-critical-rules.md` (prose + yaml in critical-rules-034 section)
**Phase 2:** Create RED behavioral test (scenario script under `.opencode/tests/behaviors/`) that verifies model does inline issue creation
**Phase 3:** Implement the symbolic yaml rule change
**Phase 4:** Create GREEN behavioral test (same script, updated with assertions for dispatch)
**Phase 5:** Commit both test and fix together, confirm GREEN

### Affected Files

- `.opencode/guidelines/000-critical-rules.md` — Add yaml rule + fallback prose
- `.opencode/tests/behaviors/issue-operations-dispatch-instead-of-inline.sh` — Behavioral RED/GREEN test

### Constraints

- Do NOT modify production `.opencode` infrastructure files (with-test-home, helpers.sh, etc.)
- Behavioral test runs against isolated test repo clone with `with-test-home` wrapper
- Test repo must have `.opencode` commit containing post-§1.1 content to expose the death spiral
