## Root Cause

The GREEN sub-agent's VbC verification allows passing SCs that require execution-based evidence (e.g., `opencode-cli run` for behavioral tests) by substituting **structural analysis** — checking that code files exist — for **execution-based verification** — actually running the behavioral test against a real AI model.

Reported output:
> `⚠️ Cannot run in this environment (no node/opencode-cli); SC verified structurally`

This is a **proxy-evidence regression** (Bug #91 class). Structural analysis of source files cannot substitute for execution-based verification of behavioral test SCs. Three gaps enable this bypass:

### Gap 1: `verify.md` FORBIDDEN Outcomes table is incomplete

`verification-before-completion/tasks/verify.md` lines 221-231 list FORBIDDEN outcomes like "functionally equivalent", "close enough", "semantically similar", "works the same way", but does NOT include `"SC verified structurally"` / `"verified structurally"` as a prohibited proxy-evidence pattern.

### Gap 2: No universal pre-flight gate in sub-agent dispatch context

`divide-and-conquer/tasks/dispatch.md` Step 2 sub-agent prompt (lines 70-76) lists "Mandatory gates" (verify, checklist, review-prep) but has no pre-flight check requiring the sub-agent to verify that each SC's required verification tool is available in the current environment before attempting verification. Without this gate, a sub-agent encountering an unavailable tool invents proxy evidence instead of returning `BLOCKED`.

Gap 2 is universal — it applies to ALL execution-based SCs (CLI commands, pytest runs, typecheckers, linters, API calls), not just `opencode-cli run` for behavioral tests.

### Gap 3: No critical violation for structural-substitution

`000-critical-rules.md` has no rule stating that substituting structural analysis for execution-based SC verification is a critical violation. The agent lacks a rule it can be caught violating.

## Fix Approach

### Change 1: `verification-before-completion/tasks/verify.md`

**1a. Add to FORBIDDEN Outcomes table** (after line 228):

| Pattern | Why FORBIDDEN |
| -- | -- |
| `"SC verified structurally"` | Structural analysis of code is not execution-based verification of behavior. An SC requiring runtime execution (test pass, CLI output, API response) cannot be satisfied by reading file contents. |
| `"verified structurally"` | Same as above — any variant of "structurally verified" used as PASS for an execution-required SC is proxy evidence. |
| `"Cannot run in this environment"` | Tool unavailability does not convert execution SCs to structural SCs. Report MISSING EVIDENCE. |

**1b. Add Execution Gate section** after line 239 (after "Enforcement" subsection):

**Execution Gate — Pre-Flight Check (MANDATORY):**

Before per-SC evidence collection, the sub-agent MUST verify that each SC's verification tool exists in the current environment:
- For each SC, identify the tool/command required for its verification (e.g., `opencode-cli run`, `pytest`, `ruff`, `uv run`, etc.)
- If ANY SC requires a tool that does not exist or cannot execute in this environment → do NOT attempt proxy evidence. Report each unverifiable SC as `MISSING EVIDENCE`.
- Structural analysis (reading files, checking for presence of code) is NOT a substitute for execution-based verification of behavioral or runtime SCs.
- This gate applies universally to ALL SCs requiring execution, not only behavioral tests.

**If the sub-agent returns MISSING EVIDENCE due to tool unavailability, the orchestrator routes to the resolution protocol — HALT and inform the user, request tool installation, or accept scope reduction.**

### Change 2: `divide-and-conquer/tasks/dispatch.md`

**Insert pre-flight gate in Step 2 sub-agent prompt** (after line 73, before "Mandatory gates"):

```
0. **Pre-flight verification gate:** Before any implementation or verification work, verify each SC's required verification tool exists in this environment. If ANY SC requires a tool that is unavailable, return `status: BLOCKED` with a list of unverifiable SCs and the specific missing verification tools. Do NOT attempt structural substitution — an SC requiring execution evidence (test pass, CLI output, API response) cannot be satisfied by reading file contents.
```

**Add parallel entry in Step 1 build-dispatch-context MANDATORY items** (after line 48):

```
- SC verification tool requirements are checked before dispatch — FATAL if ANY SC cannot be verified in this environment
```

### Change 3: `000-critical-rules.md`

**Add critical violation section after `# Critical Violation: Secret Exfiltration in Agent Output`:**

**Critical Violation: Substituting Structural Verification for Execution-Based SC Verification**

**⚠️ Reporting structural analysis of source files as PASS for a success criterion that requires execution-based evidence is a CRITICAL GUIDELINE VIOLATION.**

An SC that requires runtime execution (CLI output, test pass, API response, behavioral test run) cannot be satisfied by structural analysis. Patterns like `"SC verified structurally"`, `"verified structurally"`, or `"Cannot run in this environment; SC verified structurally"` used as PASS for an execution-required SC are proxy evidence (Bug #91 class).

- 🚫 FORBIDDEN: Reporting `"SC verified structurally"` as PASS for any SC requiring execution-based evidence
- 🚫 FORBIDDEN: Substituting file-existence checks for test-execution results
- 🚫 FORBIDDEN: Claiming PASS for behavioral test SCs without actual `opencode-cli run` execution
- 🚫 FORBIDDEN: Any variant of "structurally verified" substituting for execution evidence
- ✅ REQUIRED: When a required verification tool is unavailable, report the SC as `MISSING EVIDENCE` → HALT
- ✅ REQUIRED: Structural analysis is valid ONLY for structural SCs (yaml+symbolic block presence, file structure checks)
- ✅ REQUIRED: This applies universally — ALL execution-based SCs, not only behavioral tests

**AUTHORITY:** `065-verification-honesty.md` Proactive Verification, `verify.md` Per-SC Evidence Table, Bug #91 proxy-evidence regression, Bug #105 metadata-as-evidence

**Add yaml+symbolic rule:**

```yaml+symbolic
  - id: critical-rules-047
    title: "Substituting structural verification for execution-based SC verification is proxy evidence"
    conditions:
      all:
        - "execution_based_verification_required == true"
        - "structural_analysis_used_as_substitute == true"
        - "reported_as == 'PASS'"
    actions:
      - HALT
      - REQUIRE_EXECUTION_EVIDENCE
    conflicts_with: [verification-honesty-001, verification-honesty-004]
    requires: []
    triggers: [verification-before-completion, divide-and-conquer]
    source: "000-critical-rules.md §Substituting Structural Verification for Execution-Based SC Verification"
```

## Success Criteria

1. `"SC verified structurally"` and `"verified structurally"` are listed as FORBIDDEN outcomes in `verify.md` per-SC evidence table
2. `"Cannot run in this environment"` is listed as FORBIDDEN — tool unavailability does not convert execution SCs to structural SCs
3. Execution Gate section exists in `verify.md` mandating pre-flight tool-availability check before per-SC evidence collection
4. Pre-flight verification gate is inserted into `dispatch.md` sub-agent prompt (Step 2) — sub-agents must check tool availability and return `BLOCKED` if any SC cannot be verified
5. Pre-flight gate is also listed in `dispatch.md` Step 1 mandatory verification items before dispatch
6. Critical violation section exists in `000-critical-rules.md` for structural-substitution as proxy evidence
7. yaml+symbolic rule `critical-rules-047` exists in `000-critical-rules.md`
8. Behavioral test: GREEN sub-agent presented with a behavioral test SC and no `opencode-cli run` tool returns `MISSING EVIDENCE` or `BLOCKED`, not `PASS`
9. Behavioral test: GREEN sub-agent presented with a `pytest`-requiring SC and no `pytest` returns `MISSING EVIDENCE` or `BLOCKED`, not `PASS` — verifying universal applicability

---
