## Root Cause

The adversarial auditor dispatch contract passes **full spec bodies and evaluation criteria inline** into auditor task context. Every audit task file (spec-audit, plan-fidelity, drift-detection, spec-summary, closure-verification, etc.) embeds the complete `evidence_payload` (spec body, plan text, drift summaries) and `evaluation_criteria` (SCs JSON) directly in the prompt string via f-string substitution.

This violates the "auditor in the airlock" separation principle: the auditor receives its evidence pre-digested by the orchestrator rather than fetching it independently. The security pattern for adversarial evaluation requires an **information bottleneck** between the taint source (orchestrator) and the judgment (auditor). A pre-digested spec body leaks orchestrator framing, selection bias, and interpretation into the auditor's context before the auditor has made any independent assessment.

The fix replaces **data-passing** (inline spec body + SCs) with **reference-based** dispatch (issue number + "go read it"). Auditors and cross-validate fetch the spec independently from GitHub. The spec's SCs as declared in the issue body are the sole authoritative baseline.

Additionally, when a caller provides SCs that **conflict** with the spec's actual SCs (changing, narrowing, or redirecting what the spec requires), the auditor must detect this as a contract violation. Additional SCs beyond the spec's declared ones are fine — the auditor can evaluate them. But SCs that contradict or rewrite spec requirements signal the caller attempting to micromanage or bias the audit. This is a stricter variant of the CONTEXT_TAINTED protocol from #397.

### Related Issues

| Issue | Repo | Relationship |
|-------|------|-------------|
| #397 | michael-conrad/.opencode | Established CONTEXT_TAINTED detection, clean room protocol, semantic depth mandate. This spec extends that with SC_CONFLICT detection + reference-based dispatch. |
| #112 | michael-conrad/opencode-config | Created completeness-gate as non-adversarial pre-check. This spec changes the adversarial dispatch contract that completeness-gate feeds into. |

### Research Reference

The "auditor in the airlock" pattern (disreguard.com), AuditBench (anthropic), and agentic auditing literature all converge on: the auditor must see evidence raw and fetch independently — not receive it pre-digested by the audited party.

## Fix Approach

Two-layer change:

### Layer 1: Orchestrator → Auditor Sub-Agent (SKILL.md Dispatch Contract)

The `must_receive`/`must_not_receive` section in `adversarial-audit/SKILL.md` is the authoritative dispatch contract for all auditor sub-agents. Change the contract:

| Direction | Current | Proposed |
|-----------|---------|----------|
| `must_receive` | `issue_number`, `spec_body`, `evaluation_criteria`, `pipeline_phase` | `spec_issue_number`, `pipeline_phase` (plus audit-phase/pipeline metadata) |
| `must_not_receive` | `orchestrator_reasoning`, `expected_outcomes`, `prior_verdicts`, `inline_file_paths`, `agent_memory`, `cached_verification_results` | Add `spec_body` (spec body text must not be passed — auditor reads from issue), `evaluation_criteria` (must not be passed — auditor extracts from spec; if caller provides inline, auditor compares against spec and detects conflicts) |

Note: audit-phase metadata (`audit_phase`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`) stays — these are structural routing parameters, not spec data.

### Layer 2: Task → Cross-Validate (Task File Dispatch Templates)

Every task file that dispatches to cross-validate currently passes `evidence_payload: <spec_body>` (or equivalent inline data) and `evaluation_criteria: <criteria_json>`. Change to reference-based:

**Before (current pattern in spec-audit.md Step 3):**
```
evidence_payload: <spec_body>
evaluation_criteria: <criteria_json>
```

**After:**
```
spec_issue_number: <N>
github.owner: <github.owner>
github.repo: <github.repo>
```

The cross-validate sub-agent fetches the spec via `github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<N>)` and extracts its own SC declarations. The `evaluation_criteria` (audit-type-specific structural criteria like "Problem statement present", "All phases covered") remain as lightweight structural instructions — these are not spec data, they are audit-type definitions.

This affects all task files that build cross-validate dispatch templates:

| Task File | Evidence Payload Change |
|-----------|------------------------|
| `spec-audit.md` | `<spec_body>` → reference `spec_issue_number`; `<criteria_json>` (SCs from spec) → auditor fetches independently |
| `plan-fidelity.md` | Two full plans inline → plan_issue_number references |
| `concern-separation.md` | Phase analyses JSON → reference `spec_issue_number` + fetch plan |
| `coherence-maintenance.md` | Summaries inline → reference-based (fetch from baseline file, spec issue) |
| `drift-detection.md` | Requirements + scan inline → reference-based (spec issue + impl files) |
| `spec-summary.md` | Spec + PR sections inline → reference-based (spec issue + PR number) |
| `closure-verification.md` | PR + spec + SCs inline → reference-based (PR number + spec issue) |
| `guideline-audit.md` | Full file content inline → reference-based (file path only) |

Note: `guideline-audit.md` passes file content inline because it reads guidelines files. This is different from spec content — it's not about evaluation criteria. This should change too (pass only the file path, let auditor read it), but it's a guideline file audit, not a spec audit. The SC_CONFLICT detection in Layer 1 still applies.

### Layer 3: SC Conflict Detection (NEW)

When the calling agent provides evaluation criteria (SCs) inline alongside the dispatch — and those SCs **conflict** with what the spec actually declares — the auditor MUST:

1. Fetch the spec independently from GitHub (issue body)
2. Extract the spec's declared SCs from the body
3. Compare caller-provided SCs against spec-declared SCs
4. If any caller-provided SC **conflicts** with a spec-declared SC (changes requirements, narrows scope, rewrites intent): return `BLOCKED` with `reason: SC_CONFLICT` and list the conflicting SCs with evidence (quotes from spec vs quotes from caller context)
5. If caller-provided SCs are a **superset** of spec-declared SCs (all spec SCs present + additional ones): proceed and evaluate all (spec + additional) — additional SCs are fine
6. If caller-provided SCs are a **subset** that faithfully restates spec SCs without conflict: proceed normally
7. If caller-provided SCs are absent: proceed using spec's own SCs only

This is a **hard HALT** gate — not a soft-pass, not a flag. SC_CONFLICT means the caller attempted to bias the audit. The orchestrator must re-dispatch with clean context. If the orchestrator re-dispatches with the same tainted context, the auditor returns `BLOCKED` with `reason: SC_CONFLICT_REPEATED` — escalating to developer intervention.

**Conflict signals** (non-exhaustive):

| Signal | Example | Why Conflict |
|--------|---------|-------------|
| Changed threshold | Spec says "≥90% coverage", caller passes "≥50% coverage" | Narrowing spec requirement |
| Removed requirement | Spec SC-3 says "must handle error path E", caller excludes it | Dropping spec-mandated SC |
| Rewritten intent | Spec says "user can retry 3 times", caller says "unlimited retries" | Changing spec semantics |
| Added constraint | Spec says "cache for 5 minutes", caller says "cache for 5 minutes with persistent storage" | Adding unapproved constraint that changes evaluation scope |
| Contradictory framing | Spec says "agent MUST verify", caller says "agent MAY verify" | Weakening a mandatory requirement |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `must_receive` in `adversarial-audit/SKILL.md` removes `spec_body` and `evaluation_criteria`; adds `spec_issue_number` as primary | `string` |
| SC-2 | `must_not_receive` in `adversarial-audit/SKILL.md` adds `spec_body` and `evaluation_criteria` as forbidden fields | `string` |
| SC-3 | All task file cross-validate dispatch templates replace inline `evidence_payload` (spec body / plan text / PR content) with `spec_issue_number` + `github.owner` + `github.repo` references. Lightweight audit-type structural criteria (e.g., SC-1/PF-1/CS-1/GA-1) remain as task-file-defined templates but WITHOUT embedded spec SC content | `behavioral` — dispatch adversarial auditor with a spec, verify the dispatch template omits inline spec body |
| SC-4 | All task context audit entries in SKILL.md updated to remove `spec_body` and `evaluation_criteria` from audit dispatch context scope | `string` |
| SC-5 | Auditor agent cards (`.opencode/agents/auditor-*.md`) add SC_CONFLICT detection: fetch spec independently, compare caller-provided SCs against spec-declared SCs, return `BLOCKED` with `reason: SC_CONFLICT on conflict` | `behavioral` — dispatch auditor with conflicting SCs, verify BLOCKED response |
| SC-6 | Auditor agent cards (`.opencode/agents/auditor-*.md`) accept additional SCs (superset, no conflict) and evaluate them alongside spec SCs | `behavioral` — dispatch auditor with superset SCs, verify audit proceeds |
| SC-7 | Cross-validate entry criteria updated: `evidence_payload` replaced by `spec_issue_number` + `github.owner` + `github.repo`. Cross-validate fetches spec independently for evidence type checks | `behavioral` — dispatch cross-validate without spec_body but with spec issue ref, verify it fetches spec |
| SC-8 | CONTEXT_TAINTED violation signals in auditor agent cards are extended with SC_CONFLICT detection as a specific violation type | `string` |
| SC-9 | BEHAVIORAL enforcement test: dispatches auditor with SCs that conflict with the spec → auditor returns `BLOCKED` with `SC_CONFLICT` and reason listing conflicting SCs | `behavioral` |
| SC-10 | BEHAVIORAL enforcement test: dispatches auditor with superset SCs (spec SCs + additional) → auditor evaluates all, no BLOCKED | `behavioral` |
| SC-11 | BEHAVIORAL enforcement test: dispatches auditor with NO inline SCs → auditor fetches spec and uses spec's own SCs as sole criteria | `behavioral` |
| SC-12 | All task context audit tables updated to reflect removal of inline spec_body/evaluation_criteria from dispatch scope | `string` |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/adversarial-audit/SKILL.md` | Update `must_receive`/`must_not_receive` — remove `spec_body`, `evaluation_criteria`, add `spec_issue_number`. Add SC_CONFLICT mandate to Dispatch Context Contract. Update all task context audit entries. |
| `.opencode/skills/adversarial-audit/tasks/spec-audit.md` | Replace `evidence_payload: <spec_body>` and `evaluation_criteria: <criteria_json>` with `spec_issue_number: <N>` + `github.owner`/`repo` in Step 3 cross-validate dispatch template. Add Step for auditor to fetch spec independently. |
| `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` | Replace inline plan body references with `plan_issue_number` in dispatch template. |
| `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Replace `evidence_payload` entry criterion with `spec_issue_number` + `github.owner` + `github.repo`. Add Step 0: fetch spec independently. Update Evidence Type Gate to read from fetched spec. |
| `.opencode/skills/adversarial-audit/tasks/concern-separation.md` | Replace phase analyses JSON inline data with `spec_issue_number` + `plan_issue_number` references. |
| `.opencode/skills/adversarial-audit/tasks/coherence-maintenance.md` | Replace summary inline data with reference-based dispatch (baseline file path + spec issue). |
| `.opencode/skills/adversarial-audit/tasks/drift-detection.md` | Replace requirements + scan inline data with spec issue + impl file path references. |
| `.opencode/skills/adversarial-audit/tasks/spec-summary.md` | Replace spec + PR sections inline with `spec_issue_number` + `pr_number` references. |
| `.opencode/skills/adversarial-audit/tasks/closure-verification.md` | Replace PR + spec + SCs inline with `pr_number` + `spec_issue_number` references. |
| `.opencode/skills/adversarial-audit/tasks/guideline-audit.md` | Replace FILE + CONTENT inline with `target_file_path` reference only. |
| `.opencode/agents/auditor-*.md` (all 9) | Add SC_CONFLICT detection: fetch spec via API, compare caller-provided SCs against spec-declared SCs, BLOCKED on conflict. Extend CONTEXT_TAINTED violation signals with SC_CONFLICT. Accept superset SCs without blocking. |
| `.opencode/tests/behaviors/auditor-sc-conflict-refusal.sh` | NEW — behavioral test for SC-9 (BLOCKED on conflicting SCs) |
| `.opencode/tests/behaviors/auditor-superset-scs.sh` | NEW — behavioral test for SC-10 (accepts additional SCs) |
| `.opencode/tests/behaviors/auditor-no-inline-scs.sh` | NEW — behavioral test for SC-11 (proceeds with spec-only SCs) |
| `.opencode/guidelines/000-critical-rules.md` | Add `critical-rules-062`: SC conflict detection — caller providing SCs that conflict with the spec is a context contamination violation |
| `.opencode/tests/test-enforcement.sh` (content-verification) | Add test scenarios for SC-1, SC-2, SC-4, SC-8 — verify rule text exists |

## Non-Goals

- No changes to `resolve-models.md` (model selection is unaffected by dispatch contract)
- No changes to `coherence-extraction.md` (this is a data extraction task, not an audit dispatch point)
- No changes to `test-quality-audit.md` (this is a non-adversarial structural audit — separate concern)
- No changes to `completion.md` (completion checker is unaffected)
- No changes to the auditor agent card generic posture (#397 already established that)
- The `completeness-gate` skill (#112) is unaffected — it's the pre-check, not the dispatcher

## Implementation Plan

1. Update `adversarial-audit/SKILL.md` — `must_receive`/`must_not_receive` contracts + SC_CONFLICT mandate
2. Update `cross-validate.md` — replace `evidence_payload` entry criteria with spec issue reference, add independent fetch step
3. Update `spec-audit.md` — reference-based dispatch template
4. Update `plan-fidelity.md` — reference-based plan dispatch
5. Update remaining task files (concern-separation, coherence-maintenance, drift-detection, spec-summary, closure-verification, guideline-audit)
6. Update all 9 auditor agent cards — add SC_CONFLICT detection + superset acceptance
7. Add `critical-rules-062` to `000-critical-rules.md`
8. Create behavioral test: `auditor-sc-conflict-refusal.sh` (RED phase)
9. Create behavioral test: `auditor-superset-scs.sh` (RED phase)
10. Create behavioral test: `auditor-no-inline-scs.sh` (RED phase)
11. Update content-verification tests for contract changes
12. Run RED tests — confirm they fail
13. GREEN: implement items 1-7
14. Run all behavioral tests — confirm GREEN
15. Run content-verification tests — confirm no regressions
16. Run existing behavioral tests — confirm no regressions

## Risk Analysis

| Risk | Mitigation |
|------|------------|
| Auditors make additional API calls (reading spec independently) — latency increase | Negligible — `github_issue_read` is fast (~200ms). Eliminates ~20KB of inline context per dispatch, which reduces context window pressure |
| Cross-validate needs spec but receives only issue reference — extra API round trip | Same mitigation — single `github_issue_read` call, already authorized |
| SC_CONFLICT detection is false-positive prone (caller might use slightly different wording that means the same thing) | Strict: only exact semantic contradiction triggers BLOCKED. Slight wording variance (e.g., "≥ 90%" vs "≥90%") is not a conflict. Only clear contradiction (e.g., "≥ 90%" vs "≥ 50%") triggers BLOCKED. The auditor must cite both sources (caller's version vs spec's version) in the BLOCKED reason |
| Existing verification-before-completion dispatch passes `spec_sc_list` as metadata — is this a conflict vector? | No — `spec_sc_list` in VbC is structural metadata for evidence collection, not evaluation criteria for auditor dispatch. VbC does NOT dispatch adversarial auditors directly (it calls drift-detection downstream) |

## Changelog

- 2026-05-24: Initial draft

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)