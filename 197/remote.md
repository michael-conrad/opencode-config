---
remote_issue: 197
remote_url: "https://github.com/michael-conrad/opencode-config/issues/197"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Summary

Standardize pipeline hand-off contracts with schema-enforced enforcement metadata (gate_result, verifier_identity, evidence_hash) and a Z3 pre-dispatch gate that structurally validates contract integrity before every task() call. This replaces prose-interpreted status fields with machine-checkable tri-state gates, catching soft-passes (#1023, #1027), sycophancy (#920, #936), evidence type mismatches (#916), and self-certifying work state files (#1194, #1198) at the structural level.

## Background

The current pipeline hand-off contracts carry routing metadata (sub-agent, phase, file) but zero enforcement metadata. The `status: DONE | BLOCKED | DONE_WITH_CONCERNS | OVERFLOW` field is prose-interpreted, not schema-enforced. No `gate_result`, `verifier_identity`, or `evidence_hash` fields exist. As a result:

1. **Orchestrator soft-passes FAIL** (#1023, #1027)
2. **Z3 validates step position only** (#1021)
3. **Single-agent audits produce sycophancy** (#920, #936)
4. **Cross-reference invalidation is a soft flag** (#1189)
5. **Behavioral evidence type mismatch not caught at hand-off** (#916)
6. **Work state files are self-certifying prose** (#1194, #1198)

## Design

### Part 1: Standard Hand-Off Contract Schema

### Part 2: Z3 Gate Transition — Mandatory Pre-Dispatch

### Part 3: Verifier Identity at Dispatch Table Level

### Part 4: Contract Schema Linter

## Supersession Map

| Issue | Supersession Type | Action |
|-------|------------------|--------|
| #1023 | Full | Close |
| #1027 | Full | Close |
| #1021 | Full | Close |
| #936 | Full | Close |
| #1189 | Full | Close |
| #1194 | Full | Close |
| #951 | Full | Close |
| #1198 | Partial | Retitle |
| #909 | Partial | Add enforcement fields |
| #955 | Partial | Standard schema replaces custom |
| #954 | Partial | Frugal contract |
| #1213 | Partial | Merge into linter |
| #1019/#1020 | Partial | Dispatch routing fix |
| #1013 | Partial | Hash protection at boundary |
| #912 | Partial | Coherence pre-dispatch |
| #920 | Partial | Audit remains independent |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Hand-off contract standard schema defined and enforced | string + semantic |
| SC-2 | Z3 gate transition mandatory before every task() dispatch | behavioral |
| SC-3 | gate_result = FAIL or BLOCKED prevents dispatch | behavioral |
| SC-4 | Missing artifact_hashes prevents dispatch | behavioral |
| SC-5 | verdict_source mismatch prevents dispatch | behavioral |
| SC-6 | Evidence type mismatch detected | behavioral |
| SC-7 | Contract schema linter runs as pre-dispatch gate | string |
| SC-8 | Superseded issues closed | structural |
| SC-9 | All dispatch table rows have auditor_type | string |
| SC-10 | Contract schema lint validates required fields | behavioral |
| SC-11 | artifact_hash prevents evidence deletion | behavioral |

## Non-Goals

- Not changing 14-step pipeline structure
- Not replacing trigger dispatch tables
- Not replacing DISPATCH_GATE protocol
- Not a commit hook
- Not replacing sycophancy audit