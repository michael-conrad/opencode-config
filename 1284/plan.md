# Plan: Stale references to GitHub Issue plan storage — plans are local `*/.issues/{N}/plan.md` artifacts

**Spec:** [michael-conrad/.opencode#1284](https://github.com/michael-conrad/.opencode/issues/1284)
**Authorization scope:** `for_pr` (label: `approved-for-pr`)
**Plan structure:** Separate (multi-task — 6 requirements across 5 skill directories + guidelines)

**Path resolution:** `*/.issues/{N}/plan.md` is repo-relative. For files in `.opencode/skills/`, it resolves to `.opencode/.issues/{N}/plan.md`. For files in the parent repo, it resolves to `.issues/{N}/plan.md`. The `*/.issues/` glob covers both.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Architecture

**Goal:** Replace all stale GitHub Issue plan references (github_issue_read for plans, [PLAN] labels, plan-as-GitHub-Issue language) with local `.issues/{N}/plan.md` file reads across all skill task files and guidelines.

**Tech stack:** Markdown task files, shell/grep for verification, local file system for plan storage.

**File structure:**
- `.opencode/skills/approval-gate/tasks/` — 7 files to update (R1)
- `.opencode/skills/writing-plans/tasks/` — 4 files to update (R2)
- `.opencode/skills/git-workflow/tasks/` — 2 files to update (R3)
- `.opencode/skills/issue-operations/tasks/` — 2 files to update (R4)
- `.opencode/skills/pre-analysis/tasks/` — 1 file to update (R5)
- `.opencode/guidelines/` — 3 files to update (R6)

## Phases

### Phase 1: Update approval-gate task files (R1)

**Concern:** Plan reading in approval-gate — replace `github_issue_read`/`github_search_issues` for plan artifacts with local `.issues/{N}/plan.md` reads.
**Files:** `verify-sub-issues.md`, `verify-authorization/sub-issue-verification.md`, `verify-authorization/spec-to-plan-cascade.md`, `verify-authorization/item-decomposition-check.md`, `verify-already-implemented.md`, `reconcile-issue-graph.md`, `verify-codebase.md`
**SCs covered:** SC-1, SC-3, SC-4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1284, "phase": 1}` | SC-1 |

**RED condition:** `github_issue_read` or `github_search_issues` calls for plan reading still exist in approval-gate task files.
**GREEN condition:** All plan reads in approval-gate task files use local `.issues/{N}/plan.md` — no `github_issue_read`/`github_search_issues` for plan artifacts.

**Items:**
1. `verify-sub-issues.md` — Replace `github_issue_read(method="get_sub_issues", issue_number=plan_issue)` with local `.issues/{N}/plan.md` read
2. `verify-authorization/sub-issue-verification.md` — Replace `github_issue_read` for plan with local file read
3. `verify-authorization/spec-to-plan-cascade.md` — Replace `github_search_issues` for plan with local file existence check
4. `verify-authorization/item-decomposition-check.md` — Replace `github_issue_read` for plan with local file read
5. `verify-already-implemented.md` — Replace `github_issue_read` for plan sub-issues with local file read
6. `reconcile-issue-graph.md` — Replace all 4 `github_issue_read`/`github_search_issues` plan calls with local file operations
7. `verify-codebase.md` — Replace `github_issue_read` for superseding plan check with local file read

### Phase 2: Update writing-plans task files (R2)

**Concern:** Plan creation/validation in writing-plans — replace GitHub Issue plan operations with local `.issues/{N}/plan.md` operations.
**Files:** `validate.md`, `retroactive.md`, `completion.md`, `clean-room.md`
**SCs covered:** SC-1, SC-3, SC-4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1284, "phase": 2}` | SC-1 |

**RED condition:** Writing-plans task files still reference GitHub Issue plan creation, `[PLAN]` labels, or `github_issue_read` for plan validation.
**GREEN condition:** All writing-plans task files use local `.issues/{N}/plan.md` operations — no GitHub Issue plan references.

**Items:**
1. `validate.md` — Replace `github_issue_read` for plan label/sub-issue validation with local file checks
2. `retroactive.md` — Replace `github_search_issues` for plan search with local file existence check
3. `completion.md` — Replace `[PLAN]` prefix and `needs-approval` label verification with local file existence check
4. `clean-room.md` — Replace `[PLAN]` prefixed issue creation language with local file creation language

### Phase 3: Update git-workflow cleanup (R3)

**Concern:** Cleanup task — remove "close parent plan issue" steps and GitHub search for plan references.
**Files:** `cleanup.md`, `cleanup/issue-closure.md`
**SCs covered:** SC-2, SC-3

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2, SC-3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-2 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2, SC-3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2, SC-3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1284, "phase": 3}` | SC-2 |

**RED condition:** Cleanup task files contain "close parent plan issue" steps or GitHub search for plan references.
**GREEN condition:** No "close plan" or "close parent plan" steps exist in cleanup tasks; no GitHub search for plan references.

**Items:**
1. `cleanup.md` — Remove "close parent plan issue" language (lines 260, 303); replace plan-as-GitHub-Issue references
2. `cleanup/issue-closure.md` — Remove `[PLAN]` label/title prefix detection for plan closure path

### Phase 4: Update issue-operations link-sub-issue (R4)

**Concern:** Plan reading in issue-operations — replace `github_issue_read` for plan with local file read.
**Files:** `link-sub-issue.md`, `pre-creation.md`
**SCs covered:** SC-1, SC-4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1284, "phase": 4}` | SC-1 |

**RED condition:** `issue-operations/tasks/link-sub-issue.md` or `pre-creation.md` uses `github_issue_read` for plan reading.
**GREEN condition:** All plan reads in issue-operations task files use local `.issues/{N}/plan.md`.

**Items:**
1. `link-sub-issue.md` — No stale matches found (verified by grep), but verify no hidden references
2. `pre-creation.md` — Replace `github_search_issues(query="label:plan")` with local `.issues/*/plan.md` glob

### Phase 5: Update pre-analysis analyze (R5)

**Concern:** Plan reading in pre-analysis — replace `github_issue_read` for plan with local file read.
**Files:** `analyze.md`
**SCs covered:** SC-1, SC-4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1284, "phase": 5}` | SC-1 |

**RED condition:** `pre-analysis/tasks/analyze.md` uses `github_issue_read` for plan reading.
**GREEN condition:** Plan read in analyze.md uses local `.issues/{N}/plan.md`.

**Items:**
1. `analyze.md` — Replace `github_issue_read(method="get", issue_number=<plan>)` with local `.issues/{N}/plan.md` read

### Phase 6: Update guidelines (R6)

**Concern:** Guideline files — replace `[PLAN]` issue references with `.issues/{N}/plan.md` references.
**Files:** `130-authority-source.md`, `020-go-prohibitions.md`, `140-planning-spec-creation.md`
**SCs covered:** SC-3, SC-4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-3 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1284, "phase": 6}` | SC-3 |

**RED condition:** Guideline files reference `[PLAN]` as a GitHub Issue prefix or plan storage mechanism.
**GREEN condition:** All guideline files reference `.issues/{N}/plan.md` for plan storage — no `[PLAN]` issue references.

**Items:**
1. `130-authority-source.md` — Replace `[PLAN]` in overlap detection checklist with `.issues/{N}/plan.md`
2. `020-go-prohibitions.md` — Replace `[PLAN]` label filter with `.issues/{N}/plan.md` file existence
3. `140-planning-spec-creation.md` — Replace `[PLAN]` prefix and `plan` label language with `.issues/{N}/plan.md` references

## SC Coverage

| SC ID | Criterion | Phases |
|-------|----------|--------|
| SC-1 | No `github_issue_read` or `github_search_issues` call reads a plan artifact | 1, 2, 4, 5 |
| SC-2 | No "close parent plan issue" or "close plan" step in cleanup tasks | 3 |
| SC-3 | No `[PLAN]` prefix or `plan` label referenced as plan storage mechanism | 1, 2, 3, 6 |
| SC-4 | All plan detection uses `.issues/{N}/plan.md` file existence check | 1, 2, 4, 5, 6 |

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — delete merged branches, close issues, sync dev

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
