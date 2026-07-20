# [SPEC] Split cross-validate into deterministic consensus tool + bounded semantic sub-agent

- **Status:** DRAFT
- **Branch Pattern:** `spec/cross-validate-consensus-tool`

## Problem

The cross-validate task card (`.opencode/skills/adversarial-audit/tasks/cross-validate.md`) implements consensus determination as an LLM-mediated process. The deterministc consensus table (lines 163-169) is prose pretending to be policy — an LLM reads it and "applies" it through reasoning, which means it can also *override* it through reasoning.

**Concrete failure:** Gemma4 auditor returned `UNVERIFIED` (a result value not in the allowed enum `PASS, FAIL, AUDIT_FAIL, LIMITED-EVIDENCE, FABRICATED`). The consensus table has no row for `UNVERIFIED`. The cross-validate LLM filled the gap by inventing a rule: "UNVERIFIED is a tool-context error, not an evidence-absence finding" — and overrode it to PASS, producing a false-PASS despite the monotonic non-increasing invariant. The subsequent self-consistency gate (Step 5.7, same LLM) scanned for "revision applied", "already fixed", "pragmatically" — didn't match "tool-context error" — and passed.

**Root cause:** The card mixes deterministic work (YAML parsing, field validation, enum enforcement, consensus lookup) with semantic work (evidence type checks, dark pattern detection, sycophancy detection) in the same LLM sub-agent. The LLM can always "reason around" deterministic rules because they're implemented as advisory prose, not code.

### Five Structural Issues

| # | Issue | Location |
|---|-------|----------|
| 1 | `UNVERIFIED` has no row in the consensus table | lines 163-169 |
| 2 | `UNVERIFIED` not in the allowed result enum | line 138 |
| 3 | Same-LLM self-correction (LLM self-certification anti-pattern) | Steps 5.5, 5.7 |
| 4 | Enumerated rationalization patterns don't cover actual rationalization | line 264 |
| 5 | No deterministic output validation anywhere — every gate is LLM-mediated | entire card |

## Solution Architecture

Split cross-validate into two layers:

```
                          ┌──────────────────────────────┐
                          │  resolve-models (orchestrator)│
                          │  task(auditor-1)              │
                          │  task(auditor-2)              │
                          │  → 2 YAML verdict files       │
                          └──────────┬───────────────────┘
                                     │
                          ┌──────────▼───────────────────┐
                          │  consensus-gate (checked-in   │
                          │  tool, deterministic)         │
                          │                               │
                          │  Reads: auditor YAMLs         │
                          │  Hardcoded case statement:    │
                          │    PASS+PASS → PASS           │
                          │    any FAIL  → FAIL           │
                          │    AUDIT_FAIL/LIMITED/FAB     │
                          │       → BLOCKED               │
                          │    any value not in enum      │
                          │       → FAIL (catch-all)      │
                          │  Writes: consensus.yaml        │
                          └──────────┬───────────────────┘
                                     │
                          ┌──────────▼───────────────────┐
                          │  semantic-check sub-agent     │
                          │  (LLM, bounded scope)         │
                          │                               │
                          │  Reads: auditor YAMLs +       │
                          │    consensus.yaml             │
                          │  Checks: evidence type,       │
                          │    dark patterns, sycophancy  │
                          │  If violation → override to   │
                          │    FAIL in findings           │
                          │  Returns: result contract     │
                          │    (YAML)                     │
                          └──────────────────────────────┘
```

The LLM never touches the consensus table. The deterministic tool handles all YAML parsing, field validation, enum enforcement, and consensus computation. The semantic sub-agent gets pre-computed `{SC-1: FAIL, SC-2: PASS, ...}` and can only **add** failures (evidence type mismatch, dark patterns), never convert a FAIL to PASS. The monotonic invariant is enforced by the tool.

### Layer 1: `.opencode/tools/consensus-gate` (checked-in tool)

A deterministic bash+Python script at `.opencode/tools/consensus-gate` — the single authoritative consensus engine.

**Input:** Two YAML verdict file paths (the same auditor artifact files already produced by auditor sub-agents).

**Format each verdict file (unchanged from current):**

```yaml
---
criterion_id: "SC-1"
result: "PASS"
evidence: "<tool-call reference>"
explanation: "<reasoning>"
remediation: ""
next_step: "proceed"
---
---
criterion_id: "SC-2"
result: "FAIL"
evidence: "<tool-call reference>"
explanation: "<reasoning>"
remediation: "Add missing validation for X"
next_step: "re-evaluate"
---
```

**Consensus table (hardcoded switch/case, not prose):**

| Rule | Result |
|---|---|
| Both auditors return `PASS` | `consensus = PASS` |
| Either auditor returns `FAIL` (explicit) | `consensus = FAIL` |
| Either auditor returns `AUDIT_FAIL`, `LIMITED-EVIDENCE`, or `FABRICATED` | `consensus = BLOCKED` |
| Either auditor's verdict is missing (criterion not present) | `consensus = FAIL` with explanation `MISSING_VERDICT` |
| Either auditor's YAML is unparseable | `consensus = FAIL` for ALL criteria |
| **Any result value not in allowed enum** | `consensus = FAIL` — catch-all |
| Auditors disagree (one PASS, one non-PASS) | `consensus = FAIL` |

The catch-all row at the bottom is critical — it catches any result value the enum doesn't recognize (like `UNVERIFIED`) and maps it to FAIL. No LLM needs to invent a rule.

**Output (`consensus.yaml`):**

```yaml
overall_consensus: FAIL
next_step: remediate then re-audit
cross_validation:
  - criterion_id: SC-1
    auditor_1_result: PASS
    auditor_2_result: UNVERIFIED
    consensus: FAIL
    agreement: false
    evidence_type: behavioral
    auditor_1_evidence: "<ref>"
    auditor_2_evidence: "<ref>"
    evidence_type_mismatch: false
    dark_pattern_flags: []
disagreements:
  - criterion_id: SC-1
    auditor_1: PASS
    auditor_2: UNVERIFIED
warnings: []
```

### Layer 2: Semantic-check sub-agent (revised cross-validate.md)

The sub-agent that remains is **bounded** — it does not compute consensus, parse YAML, validate enums, or check field structure. It receives:

- The two auditor YAML files (for evidence references)
- The pre-computed `consensus.yaml` (for the verdict skeleton)
- The spec SCs from GitHub (for evidence type declarations)

**Scope of work:**

1. **Evidence type gate:** For each criterion, check whether each auditor's evidence type matches the declared type from the spec. If structural evidence was used for a behavioral SC, add `EVIDENCE_TYPE_MISMATCH` finding.
2. **Dark pattern detection:** Scan auditor explanations for authority framing, goal hijacking, forced action, sycophancy exploitation, continuity hooks.
3. **Merge findings:** Add any detected violations to the consensus.yaml structure — but NEVER downgrade a FAIL to PASS. Only add FAILs.

The sub-agent returns a YAML result contract (not JSON) via task return. The orchestrator has the final say — it can read the contract and route accordingly.

### Cross-validate.md Revision

The task file is restructured to document the two-layer pipeline rather than attempting to do everything inline. The file:

- Documents the procedure for the semantic-check sub-agent (evidence type, dark patterns only)
- Removes all deterministic steps (parsing, validation, consensus table)
- References the consensus-gate tool as a prerequisite
- Change result contract from JSON format to YAML format

**Structural changes to the file:**

| Section | Action |
|---------|--------|
| Lines 1-18 (Purpose + Entry Criteria) | Keep, update entry criteria to include consensus.yaml path |
| Lines 19-29 (Step 0: Fetch Spec) | Keep |
| Lines 31-67 (Pre-Inspection Classification Gate) | Move to semantic-check section |
| Lines 69-76 (Exit Criteria) | Keep |
| Lines 78-89 (Non-Recovery Gates) | Keep, update for new input types |
| Lines 91-172 (Steps 1-4) | **Remove entirely** — replaced by consensus-gate tool |
| Lines 175-234 (FAIL Terminal + Evidence Gate + Finding Types) | Keep, restructure as semantic-check scope |
| Lines 236-274 (Steps 5, 5.5, 5.7) | **Remove entirely** — no consensus computation, no self-check needed |
| Lines 276-291 (Step 6: Dark Pattern Enforcement) | Keep as part of semantic-check scope |
| Lines 292-338 (Step 7: Result Contract) | Update format to YAML |
| Lines 340-389 (Context Required + Red Flags + Routing) | Keep, update |

## Change Control

### Files Created

| File | Purpose | Status |
|------|---------|--------|
| `.opencode/tools/consensus-gate` | Deterministic consensus engine (bash + yq or Python) | NEW |
| `.opencode/tests/enforcement/consensus-gate-*.sh` | Content-verification tests for the tool | NEW |

### Files Modified

| File | Change | Status |
|------|--------|--------|
| `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Remove deterministic steps, scope to semantic checks only, YAML result contract | MODIFIED |
| `.opencode/skills/adversarial-audit/SKILL.md` | Update pipeline documentation if it references cross-validate workflow | IF NEEDED |

### Files Unchanged

| File | Reason |
|------|--------|
| `.opencode/skills/adversarial-audit/tasks/resolve-models.md` | Still selects auditors, doesn't change |
| `.opencode/agents/auditor-*.md` | Auditor behavior unchanged |
| `.opencode/tools/resolve-models` | Unchanged |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `consensus-gate` tool exists at `.opencode/tools/consensus-gate`, is executable, accepts two YAML file paths as arguments, and writes `consensus.yaml` | structural |
| SC-2 | Tool hardcodes the consensus table — any result value not in `{PASS, FAIL, AUDIT_FAIL, LIMITED-EVIDENCE, FABRICATED}` maps to FAIL (catch-all). Verified by passing a YAML with `UNVERIFIED` and asserting output contains `consensus: FAIL` | behavioral |
| SC-3 | Two auditors both return PASS → consensus PASS. Verified by passing two PASS-only YAMLs | behavioral |
| SC-4 | One auditor returns FAIL → consensus FAIL. Verified by passing PASS+FAIL YAMLs | behavioral |
| SC-5 | Both auditors return AUDIT_FAIL → consensus BLOCKED | behavioral |
| SC-6 | Disagree (PASS + FAIL) → consensus FAIL | behavioral |
| SC-7 | Missing criterion from one auditor's verdict → FAIL for that criterion with MISSING_VERDICT | behavioral |
| SC-8 | Unparseable YAML → FAIL for ALL criteria | behavioral |
| SC-9 | cross-validate.md restructured: Step 1 (Validate Input), Step 2 (Read Verdicts), Step 3 (Consensus Table), Steps 5/5.5/5.7 (Self-Check) removed; replacement text references consensus-gate tool | structural |
| SC-10 | cross-validate.md result contract format changed from JSON to YAML | structural |
| SC-11 | Semantic-check sub-agent can only add FAILs, never convert FAIL to PASS. Verified by test where consensus.yaml says FAIL and sub-agent returns consensus PASS → orchestator discards as invalid | behavioral |
| SC-12 | Behavioral enforcement test: send a two-auditor prompt where one returns UNVERIFIED, verify cross-validate produces FAIL (not PASS, not BLOCKED) | behavioral |

## Key Design Decisions

1. **Why a checked-in tool, not a sub-agent writing a throwaway script?** A sub-agent writing a throwaway script on every invocation could introduce the same kind of bug it would have if it applied the table directly. A checked-in tool is versioned, has enforcement tests, and is deterministic across all sessions.

2. **Why YAML for everything?** Both auditors already produce YAML. The consensus tool outputs YAML. The semantic sub-agent reads YAML and returns YAML. JSON was an unnecessary format boundary — LLMs read YAML as easily as JSON, and keeping one format reduces translation surface.

3. **What prevents the semantic sub-agent from reversing a FAIL?** The orchestrator enforces monotonicity. If `consensus.yaml` says FAIL for SC-1 and the semantic sub-agent returns a contract saying PASS for SC-1, the orchestrator discards the semantic override and logs a warning. The deterministic tool is source of truth for consensus.

4. **What about BLOCKED?** The consensus tool outputs BLOCKED when both auditors return `AUDIT_FAIL`, `LIMITED-EVIDENCE`, or `FABRICATED`. The orchestrator reads `next_step` from the tool output and routes accordingly — no semantic processing needed.

## Related

- This spec is the direct result of the cross-validate false-PASS analysis
