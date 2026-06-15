## Summary

Standardize pipeline hand-off contracts with schema-enforced enforcement metadata (gate_result, verifier_identity, evidence_hash) and a Z3 pre-dispatch gate that structurally validates contract integrity before every task() call. This replaces prose-interpreted status fields with machine-checkable tri-state gates, catching soft-passes (#1023, #1027), sycophancy (#920, #936), evidence type mismatches (#916), and self-certifying work state files (#1194, #1198) at the structural level.

## Background

The current pipeline hand-off contracts carry routing metadata (sub-agent, phase, file) but zero enforcement metadata. The `status: DONE | BLOCKED | DONE_WITH_CONCERNS | OVERFLOW` field is prose-interpreted, not schema-enforced. No `gate_result`, `verifier_identity`, or `evidence_hash` fields exist. As a result:

1. **Orchestrator soft-passes FAIL** (#1023, #1027) — a sub-agent returning `DONE_WITH_CONCERNS` is treated as PASS because the orchestrator reads prose, not schema
2. **Z3 validates step position only** (#1021) — Z3 confirms the right step transitioned, but never whether the transition produced a valid artifact
3. **Single-agent audits produce sycophancy** (#920, #936) — a single `general` auditor evaluating a sub-agent from the same family produces consensus bias; no verifier identity check exists
4. **Cross-reference invalidation is a soft flag** (#1189) — a "warn but proceed" pattern that is structurally unenforceable
5. **Behavioral evidence type mismatch not caught at hand-off** (#916) — structural evidence submitted for behavioral SCs passes because no type-checking gate exists at the boundary
6. **Work state files are self-certifying prose** (#1194, #1198) — a sub-agent reports "verification complete" and the orchestrator trusts the prose without structural evidence

## Design

### Part 1: Standard Hand-Off Contract Schema

Every pipeline stage transition produces a YAML contract with mandatory enforcement fields:

```yaml
contract:
  phase: 
  source_step: 
  target_step: 
  gate:
    gate_result: PASS | FAIL | BLOCKED       # NEVER advisory, NEVER unset
    verdict_source:   # resolves to dispatched sub-agent type
    artifact_hashes:                          # evidence paths + hashes, mandatory for behavioral SCs
      - path: ./tmp/behavioral-evidence-SC-3.log
        sha256: abc123...
  evidence_types:                            # per-SC evidence type, for mismatch detection
    - sc_id: SC-3
      declared_type: behavioral
      actual_type: behavioral
  routing:
    next_dispatches: [, ...]
    reroute_on_blocked:             # explicit failover target
    max_retries: 3
```

Fields `gate.gate_result`, `gate.verdict_source`, and `gate.artifact_hashes` are **REQUIRED**. If any is missing or null, the contract is structurally invalid.

The `gate_result` field replaces the prose `status: DONE | BLOCKED` pattern with a schema-enforced tri-state that Z3 can inspect structurally. The `verdict_source` field resolves to the dispatched sub-agent's type family (e.g., `deepseek-flash`, `gemma4`, `qwen3.5`), enabling downstream verification that the correct auditor type produced the verdict. The `artifact_hashes` field pins behavioral evidence to their SHA256 hashes, preventing evidence deletion while the contract is active.

Contract files are written to `./tmp/contracts/-.yaml` and managed by the orchestrator's state file system. Each contract file corresponds to exactly one pipeline transition.

### Part 2: Z3 Gate Transition — Mandatory Pre-Dispatch

Before every `task()` call for the next pipeline step, the orchestrator MUST:

1. Read the previous step's hand-off contract YAML from `./tmp/contracts/`
2. Call `solve check` with a contract-validation theorem that tests:
   - `gate.gate_result == PASS` — FAIL or BLOCKED prevents transition SAT
   - `artifact_hashes` non-empty for every behavioral SC in `evidence_types[]` — missing evidence prevents SAT
   - `verdict_source` matches the authorized auditor type for that pipeline step — type mismatch prevents SAT
   - No `evidence_types[].declared_type != actual_type` — EVIDENCE_TYPE_MISMATCH prevents SAT
3. Only if `solve check` returns SAT: proceed to the next `task()` call
4. If UNSAT: the orchestrator MUST NOT dispatch. Remediation path: dispatch researcher sub-agent with the unsat core as context.

This is NOT a commit hook. It is a pre-dispatch gate in the orchestrator's loop. No hooks, no bypass surface. The Z3 theorem is defined in `.opencode/skills/solve/theorems/contract-validation.py` and loaded by the `solve` skill's `check` command.

**Theorem structure:**

```
Theorem: contract-validated
  Premises:
    contract.gate.gate_result ∈ {PASS}
    ∀ sc ∈ contract.evidence_types where sc.declared_type = behavioral:
      ∃ hash ∈ contract.gate.artifact_hashes
    contract.gate.verdict_source ∈ allowed_verdict_sources(step)
    ¬∃ mismatch ∈ contract.evidence_types:
      mismatch.declared_type ≠ mismatch.actual_type
  Conclusion:
    transition_allowed(contract.source_step, contract.target_step)
```

### Part 3: Verifier Identity at Dispatch Table Level

Every dispatch table row in every SKILL.md MUST include an `auditor_type` field:

```yaml
tasks:
  - step: spec-audit
    dispatch: sub-task
    auditor_type: dual_cross_family   # maps to resolve-models result contract
    subagent_type: from_resolve       # resolved per adversarial-audit DISPATCH_GATE
```

The `verdict_source` in the hand-off contract is set to the dispatched sub-agent's type family (e.g., `deepseek-flash`, `gemma4`, `qwen3.5`). Z3 rejects SAT if `verdict_source` doesn't match the dispatch table's `auditor_type` requirement.

This catches #1019/#1020 at the structural level: routing a `general` sub-agent to step 10 (which requires `dual_cross_family`) produces a verdict_source mismatch detected by Z3 before dispatch.

### Part 4: Contract Schema Linter (Pre-Dispatch Gate, Not Hook)

A `skildeck contract lint` subcommand that validates every contract YAML against the schema. Runs as a pre-dispatch gate in the orchestrator's `task()` loop (same call as Z3 check). Validates:

- All required fields present (`gate.gate_result`, `gate.verdict_source`, `gate.artifact_hashes`)
- `gate_result` is one of PASS/FAIL/BLOCKED (not null, not "advisory", not "warning")
- `artifact_hashes` paths resolve to existing files
- Every behavioral SC in `evidence_types[]` has a corresponding `artifact_hashes` entry
- No evidence type mismatch (declared vs actual)

The linter exits non-zero on structural invalidity. Non-zero exit = no dispatch. The linter is added to the `skildeck` tool and invoked by the orchestrator's dispatch loop before the Z3 theorem check.

## Supersession Map

| Issue | Supersession Type | Action |
|-------|------------------|--------|
| #1023 | Full | Close — contract schema enforces gate_result, no soft-pass possible |
| #1027 | Full | Close — same root cause, fixed by schema-enforced gate_result |
| #1021 | Full | Close — Z3 now validates artifact content via contract theorem |
| #936 | Full | Close — verifier identity check prevents single-agent consensus |
| #1189 | Full | Close — cross-reference invalidation now produces BLOCKED, not soft flag |
| #1194 | Full | Close — work state files replaced by schema-enforced contracts |
| #951 | Full | Close — contract schema provides the standard format these issues requested |
| #1198 | Partial | Retitle to "Contract-to-state wiring" — only the wiring between contract and state file remains |
| #909 | Partial | Add enforcement fields to per-step contracts — step structure unchanged, enforcement fields added |
| #955 | Partial | Standard schema replaces custom per-skill contracts — skill-specific fields remain |
| #954 | Partial | Frugal contract + solve gate — size limits still apply, enforcement adds ~5 fields |
| #1213 | Partial | Merge into contract schema linter — the linter subsumes the schema validation concern |
| #1019/#1020 | Partial | Dispatch routing still needs fix at source, but verifier identity catches it downstream |
| #1013 | Partial | artifact_hash protects evidence at hand-off boundary — deletion fix at cleanup remains separate |
| #912 | Partial | Coherence checking remains pre-dispatch — contract gates on evidence types |
| #920 | Partial | Sycophancy audit remains independent — structural contracts reduce bias surface |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Hand-off contract standard schema defined and enforced | `string + semantic` | grep for `gate_result`, `verdict_source`, `artifact_hashes` fields in skill files + sub-agent reads contract schema definition |
| SC-2 | Z3 gate transition mandatory before every task() dispatch | `behavioral` | opencode-cli run → stderr assertion shows `solve check` called before dispatch |
| SC-3 | gate_result = FAIL or BLOCKED prevents task() dispatch (Z3 UNSAT) | `behavioral` | opencode-cli run with scenario: FAIL contract → Z3 returns UNSAT → no dispatch |
| SC-4 | Missing artifact_hashes for behavioral SC prevents dispatch | `behavioral` | opencode-cli run with scenario: empty hashes → Z3 returns UNSAT → no dispatch |
| SC-5 | verdict_source mismatch against dispatch table auditor_type prevents dispatch | `behavioral` | opencode-cli run with scenario: wrong auditor type → Z3 returns UNSAT → no dispatch |
| SC-6 | Evidence type mismatch detected at hand-off boundary | `behavioral` | opencode-cli run with scenario: EVIDENCE_TYPE_MISMATCH in contract → lint FAIL → no dispatch |
| SC-7 | Contract schema linter runs as pre-dispatch gate, not hook | `string` | grep for `skildeck contract lint` invocation in pipeline task files (not in hooks/) |
| SC-8 | Superseded issues closed, partially superseded revised with scope comments | `structural` | GitHub issue state verification for each superseded issue (closed or relabeled) |
| SC-9 | All dispatch table rows have auditor_type field | `string` | grep for `auditor_type:` in all SKILL.md files — every dispatch row has it |
| SC-10 | Contract schema lint validates all required fields present | `behavioral` | opencode-cli run with scenario: missing `gate_result` → lint exits non-zero → no dispatch |
| SC-11 | REPLACED artifact_hash prevents evidence deletion at hand-off: behavioral evidence artifacts protected from deletion until after gate_result read | `behavioral` | opencode-cli run: verify tool refuses deletion of artifact_hashes-pinned files while contract is unresolved (gate_result not yet consumed by downstream step) |

Note: SC-11 replaces the #1013 concern at the hand-off boundary level (artifact hash protects evidence from deletion while contract is active). The separate deletion-at-cleanup issue remains for post-PR-merge cleanup.

## Non-Goals

- Not changing the 14-step pipeline structure (#909 structure remains)
- Not replacing trigger dispatch tables (#1210 is separate)
- Not replacing DISPATCH_GATE protocol (#1199 is separate)
- Not replacing plan writer dispatch table format (#1214 is separate)
- Not a commit hook — pre-dispatch gate only
- Not replacing sycophancy audit (#920 remains independent)