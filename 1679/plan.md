# Implementation Plan: #1679 — Orchestrator MUST revise defective sub-agent deliverables

> **Plan for SPEC-FIX #1679.** See `.issues/1679/spec.md` for the full spec.

## Authorization

| Field | Value |
|-------|-------|
| **Authorization Scope** | `for_implementation` |
| **Halt At** | `verification_complete` |
| **PR Strategy** | `stacked` |
| **Pipeline Phase** | Phase 1 → Phase 2 → Phase 3 |

## Dependency Graph

```
Phase 1 (critical rules) ──→ Phase 2 (remediation protocol) ──→ Phase 3 (behavioral tests)
       │                                                              │
       └─────────────────── no dependency ───────────────────────────┘
```

Phase 1 and Phase 2 are independent (both modify different files). Phase 3 depends on Phase 1 (tests verify the rules exist).

## Items

### Phase 1: Add Critical Rules to `000-critical-rules.md`

| Item | Description | Dependency | SCs |
|------|-------------|------------|-----|
| 1.1 | Add critical-rules-071 prose entry (revision-not-replacement) in Tier 2 section after critical-rules-066 | None | SC-1 |
| 1.2 | Add critical-rules-072 prose entry (no-inline-fix) in Tier 2 section after critical-rules-071 | 1.1 | SC-2 |
| 1.3 | Add yaml+symbolic definitions for critical-rules-071 and critical-rules-072 at end of yaml block | None | SC-3 |

#### Item 1.1 — Add critical-rules-071 prose (Tier 2)

**RED:** Content-verification test: `grep -q 'critical-rules-071' .opencode/guidelines/000-critical-rules.md` → FAIL

**GREEN:** Insert after line 966 (end of critical-rules-066 prose):

```
### [critical-rules-071] Revision-Not-Replacement — defective sub-agent deliverables MUST be revised, not replaced
When a sub-agent returns a defective deliverable (spec, plan, or other artifact), the orchestrator MUST revise the existing deliverable via the appropriate pipeline (spec-creation for specs, writing-plans for plans). The orchestrator MUST NOT create a replacement artifact (new issue, new file) unless revision is structurally impossible (e.g., the original issue was deleted).

#### 🚫 FORBIDDEN

- Creating a new issue or file to replace a defective sub-agent deliverable
- Orphaning the original deliverable by creating a replacement

#### ✅ REQUIRED

- Revise the existing deliverable via the appropriate pipeline
- Dispatch `spec-creation --task revise` for defective specs
- Dispatch `writing-plans --task update` for defective plans
- If revision is structurally impossible, document rationale in an issue comment before creating a replacement

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Creating replacement artifact for defective deliverable | Orphans original issue, breaks cross-references, wastes issue numbers |
| Inline-fixing instead of dispatching revision | Bypasses pipeline quality gates, produces defective output |
```

**Verification:** `grep -q 'critical-rules-071' .opencode/guidelines/000-critical-rules.md`

#### Item 1.2 — Add critical-rules-072 prose (Tier 2)

**RED:** `grep -q 'critical-rules-072' .opencode/guidelines/000-critical-rules.md` → FAIL

**GREEN:** Insert after critical-rules-071 prose:

```
### [critical-rules-072] No-Inline-Fix — orchestrator MUST NOT inline-fix defective sub-agent output
When a sub-agent returns a defective deliverable, the orchestrator MUST NOT attempt to fix the defective artifact directly via `github_issue_write`, file edit, or any other direct mutation. The orchestrator MUST dispatch a revision task to the appropriate pipeline (spec-creation --task revise for specs, writing-plans --task update for plans).

#### 🚫 FORBIDDEN

- Editing a defective spec/plan directly via `github_issue_write`
- Editing a defective file directly via file edit tools
- Any direct mutation of a sub-agent's defective output

#### ✅ REQUIRED

- Dispatch revision task to the appropriate pipeline
- `spec-creation --task revise` for defective specs
- `writing-plans --task update` for defective plans
- `implementation-pipeline` for defective code deliverables

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Inline-fixing defective sub-agent output | Bypasses pipeline quality gates, produces output lacking pipeline context and discipline |
```

**Verification:** `grep -q 'critical-rules-072' .opencode/guidelines/000-critical-rules.md`

#### Item 1.3 — Add yaml+symbolic definitions

**RED:** `grep -A 15 'critical-rules-071' .opencode/guidelines/000-critical-rules.md | grep -q 'tier: 2'` → FAIL

**GREEN:** Append after the last yaml+symbolic rule (critical-rules-dispatch-gate-canonical, ends at line 2327):

```yaml
  - id: critical-rules-071
    tier: 2
    title: "Revision-Not-Replacement — defective sub-agent deliverables MUST be revised, not replaced"
    conditions:
      all:
        - "sub_agent_deliverable_defective == true"
        - "replacement_created_instead_of_revision == true"
    actions:
      - HALT
      - REQUIRE_REVISION
    conflicts_with: []
    requires: []
    triggers: [implementation-pipeline, approval-gate]
    source: "000-critical-rules.md §critical-rules-071"

  - id: critical-rules-072
    tier: 2
    title: "No-Inline-Fix — orchestrator MUST NOT inline-fix defective sub-agent output"
    conditions:
      all:
        - "sub_agent_deliverable_defective == true"
        - "inline_fix_attempted == true"
    actions:
      - HALT
      - REQUIRE_DISPATCH_TO_REVISION_PIPELINE
    conflicts_with: []
    requires: []
    triggers: [implementation-pipeline, approval-gate]
    source: "000-critical-rules.md §critical-rules-072"
```

**Verification:** `grep -A 15 'critical-rules-071' .opencode/guidelines/000-critical-rules.md | grep -q 'tier: 2'`

### Phase 2: Update Remediation Protocol

| Item | Description | Dependency | SCs |
|------|-------------|------------|-----|
| 2.1 | Add defective-deliverable revision routing to `implementation-pipeline/tasks/pipeline-executor.md` remediation protocol section | None | SC-4 |

#### Item 2.1 — Add revision routing to remediation protocol

**RED:** `grep -q 'defective.*deliverable\|revision.*routing' .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` → FAIL

**GREEN:** Insert a new subsection "Defective Deliverable Revision Routing" after the existing "Remediation Routing" section (after line 235, before "Session Resume Rule"):

```markdown
### Defective Deliverable Revision Routing

When a sub-agent returns a defective deliverable (spec, plan, or code artifact), the orchestrator MUST route to revision — NOT inline-fix or replace:

- [ ] 1. **Classify defect type** — determine if the defective deliverable is a spec, plan, or code artifact
- [ ] 2. **Route to revision pipeline**:
   - Spec defect → dispatch `spec-creation --task revise` with the defective issue number
   - Plan defect → dispatch `writing-plans --task update` with the defective plan issue number
   - Code defect → dispatch `implementation-pipeline` with the defective step label
- [ ] 3. **No inline fixes** — the orchestrator MUST NOT edit the defective deliverable directly
- [ ] 4. **No replacements** — the orchestrator MUST NOT create a new issue or file to replace the defective deliverable
- [ ] 5. **Structural impossibility exception** — if revision is structurally impossible (original issue deleted), the orchestrator MAY create a replacement but MUST document the rationale in an issue comment
```

**Verification:** `grep -q 'defective.*deliverable\|revision.*routing' .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

### Phase 3: Behavioral Enforcement Tests

| Item | Description | Dependency | SCs |
|------|-------------|------------|-----|
| 3.1 | Create behavioral test: defective-deliverable-revision.sh | Phase 1 | SC-5, SC-7, SC-8 |
| 3.2 | Create behavioral test: defective-deliverable-no-inline-fix.sh | Phase 1 | SC-6, SC-7, SC-8 |

#### Item 3.1 — Behavioral test: revision-not-replacement

**RED:** `ls .opencode/tests/behaviors/defective-deliverable-revision.sh` → FAIL (file does not exist)

**GREEN:** Create `.opencode/tests/behaviors/defective-deliverable-revision.sh`:

```bash
#!/bin/bash
# Behavioral test: defective-deliverable-revision
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="defective-deliverable-revision"
SCENARIO_PROMPT="A sub-agent returned a defective spec for issue #42. The spec has incorrect success criteria. What do you do?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
```

**Verification:** `ls .opencode/tests/behaviors/defective-deliverable-revision.sh`

#### Item 3.2 — Behavioral test: no-inline-fix

**RED:** `ls .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh` → FAIL (file does not exist)

**GREEN:** Create `.opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh`:

```bash
#!/bin/bash
# Behavioral test: defective-deliverable-no-inline-fix
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="defective-deliverable-no-inline-fix"
SCENARIO_PROMPT="A sub-agent returned a defective plan for issue #42. The plan has incorrect phase ordering. What do you do?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
```

**Verification:** `ls .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh`

#### Item 3.3 — Verify stderr-based assertions in behavioral tests

**RED:** `grep -q 'assert_stderr_pattern' .opencode/tests/behaviors/defective-deliverable-revision.sh .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh` → FAIL

**GREEN:** Add stderr assertion helpers to both test files (after `behavior_run` call):

```bash
# Verify stderr contains revision dispatch (not replacement, not inline fix)
assert_stderr_pattern_present 'spec-creation --task revise\|writing-plans --task update' || true
assert_stderr_pattern_absent 'github_issue_write.*method=create\|new issue\|replacement' || true
```

**Verification:** `grep -q 'assert_stderr_pattern' .opencode/tests/behaviors/defective-deliverable-revision.sh .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh`

## Verification Gates

| Gate | Phase | What It Verifies | Method |
|------|-------|------------------|--------|
| V-1 | Phase 1 | critical-rules-071 prose exists | `grep -q 'critical-rules-071' .opencode/guidelines/000-critical-rules.md` |
| V-2 | Phase 1 | critical-rules-072 prose exists | `grep -q 'critical-rules-072' .opencode/guidelines/000-critical-rules.md` |
| V-3 | Phase 1 | Both rules have yaml+symbolic definitions with tier: 2 | `grep -A 15 'critical-rules-071' .opencode/guidelines/000-critical-rules.md \| grep -q 'tier: 2'` |
| V-4 | Phase 2 | Remediation protocol routes defective deliverables | `grep -q 'defective.*deliverable\|revision.*routing' .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` |
| V-5 | Phase 3 | Behavioral test file exists (revision) | `ls .opencode/tests/behaviors/defective-deliverable-revision.sh` |
| V-6 | Phase 3 | Behavioral test file exists (no-inline-fix) | `ls .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh` |
| V-7 | Phase 3 | Behavioral tests use stderr assertion helpers | `grep -q 'assert_stderr_pattern' .opencode/tests/behaviors/defective-deliverable-revision.sh .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh` |
| V-8 | Phase 3 | RED phase: tests fail before rule change | Run test → FAIL |
| V-9 | Phase 3 | GREEN phase: tests pass after rule change | Run test → PASS |

## Regression Invariants

1. Existing critical rules retain their tier, conditions, and actions unchanged.
2. Existing remediation protocol continues to handle non-defective sub-agent output identically.
3. All existing behavioral enforcement tests continue to pass.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Revision structurally impossible (original issue deleted) | Replacement permitted — document rationale in issue comment |
| Defective deliverable is code (not spec/plan) | Route to implementation-pipeline revision |
| Multiple defects in same deliverable | Single revision task covers all defects |
| Developer explicitly requests replacement | Developer override per Tier 2 — document in issue comment |
