---
issue: 1314
spec: .opencode/.issues/1314/spec.md
plan_structure: separate
authorization_scope: for_pr
halt_at: pr_created
pr_strategy: stacked
generated_at: "20260622015732"
---

# Plan: Playwright CLI as First-Class Browser Automation Entry Point

## Phase 1: Deletion

**Concern:** Remove `ui-design` and `ui-engineer` skill directories and all contents.

**SCs:** SC-1

**Affected Files:**
- `.opencode/skills/ui-design/SKILL.md`
- `.opencode/skills/ui-design/` (entire directory)
- `.opencode/skills/ui-engineer/SKILL.md`
- `.opencode/skills/ui-engineer/` (entire directory)

### Dispatch Table — Phase 1

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|---------------|-----------------|-----|
| sc-coherence-gate | task() | Yes | coherence-auditor | spec SC-1 + phase files | SC-1 |
| pre-red-baseline | task() | Yes | baseline-checker | phase files current state | SC-1 |
| red-phase | task() | Yes | RED-impl | spec SC-1 + baseline | SC-1 |
| red-doublecheck | task() | Yes | RED-verifier | RED artifact + spec | SC-1 |
| post-red-enforcement | task() | Yes | enforcement-checker | RED evidence | SC-1 |
| green-phase | task() | Yes | GREEN-impl | RED gap + spec SC-1 | SC-1 |
| post-green-enforcement | task() | Yes | enforcement-checker | GREEN evidence | SC-1 |
| checkpoint-commit | bash | No | — | git operations | — |
| structural-checks | bash | No | — | ruff, pyright, mdformat | — |
| green-doublecheck | task() | Yes | GREEN-verifier | GREEN artifact + spec | SC-1 |
| green-vbc | task() | Yes | VbC-auditor | GREEN artifact + spec SC-1 | SC-1 |
| adversarial-audit | task() | Yes | dual-auditor | full artifact + spec | SC-1 |
| cross-validate | task() | Yes | cross-validator | audit findings | SC-1 |
| regression-check | bash | No | — | existing tests | — |
| review-prep | task() | Yes | review-prep | full artifact | SC-1 |
| exec-summary | task() | Yes | completion-reporter | all evidence | SC-1 |

## Phase 2: Creation

**Concern:** Create `playwright-cli` skill directory adapted from upstream `viewport-editor` repo.

**SCs:** SC-2

**Affected Files:**
- `.opencode/skills/playwright-cli/SKILL.md` (new)
- `.opencode/skills/playwright-cli/` (new directory)

### Dispatch Table — Phase 2

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|---------------|-----------------|-----|
| sc-coherence-gate | task() | Yes | coherence-auditor | spec SC-2 + upstream reference | SC-2 |
| pre-red-baseline | task() | Yes | baseline-checker | upstream skill files | SC-2 |
| red-phase | task() | Yes | RED-impl | spec SC-2 + upstream + baseline | SC-2 |
| red-doublecheck | task() | Yes | RED-verifier | RED artifact + spec | SC-2 |
| post-red-enforcement | task() | Yes | enforcement-checker | RED evidence | SC-2 |
| green-phase | task() | Yes | GREEN-impl | RED gap + spec SC-2 + upstream | SC-2 |
| post-green-enforcement | task() | Yes | enforcement-checker | GREEN evidence | SC-2 |
| checkpoint-commit | bash | No | — | git operations | — |
| structural-checks | bash | No | — | ruff, pyright, mdformat | — |
| green-doublecheck | task() | Yes | GREEN-verifier | GREEN artifact + spec | SC-2 |
| green-vbc | task() | Yes | VbC-auditor | GREEN artifact + spec SC-2 | SC-2 |
| adversarial-audit | task() | Yes | dual-auditor | full artifact + spec | SC-2 |
| cross-validate | task() | Yes | cross-validator | audit findings | SC-2 |
| regression-check | bash | No | — | existing tests | — |
| review-prep | task() | Yes | review-prep | full artifact | SC-2 |
| exec-summary | task() | Yes | completion-reporter | all evidence | SC-2 |

## Phase 3: Reference Cleanup

**Concern:** Remove all references to deleted skills from guidelines, tests, and registry files.

**SCs:** SC-3

**Affected Files:**
- `.opencode/guidelines/INDEX.md`
- `.opencode/tests/` (all test files referencing ui-design or ui-engineer)
- `.opencode/AGENTS.md`
- Any other files referencing deleted skills

### Dispatch Table — Phase 3

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|---------------|-----------------|-----|
| sc-coherence-gate | task() | Yes | coherence-auditor | spec SC-3 + affected files | SC-3 |
| pre-red-baseline | task() | Yes | baseline-checker | reference files current state | SC-3 |
| red-phase | task() | Yes | RED-impl | spec SC-3 + baseline + reference list | SC-3 |
| red-doublecheck | task() | Yes | RED-verifier | RED artifact + spec | SC-3 |
| post-red-enforcement | task() | Yes | enforcement-checker | RED evidence | SC-3 |
| green-phase | task() | Yes | GREEN-impl | RED gap + spec SC-3 | SC-3 |
| post-green-enforcement | task() | Yes | enforcement-checker | GREEN evidence | SC-3 |
| checkpoint-commit | bash | No | — | git operations | — |
| structural-checks | bash | No | — | ruff, pyright, mdformat | — |
| green-doublecheck | task() | Yes | GREEN-verifier | GREEN artifact + spec | SC-3 |
| green-vbc | task() | Yes | VbC-auditor | GREEN artifact + spec SC-3 | SC-3 |
| adversarial-audit | task() | Yes | dual-auditor | full artifact + spec | SC-3 |
| cross-validate | task() | Yes | cross-validator | audit findings | SC-3 |
| regression-check | bash | No | — | existing tests | — |
| review-prep | task() | Yes | review-prep | full artifact | SC-3 |
| exec-summary | task() | Yes | completion-reporter | all evidence | SC-3 |

## Phase 4: Gitignore

**Concern:** Add `.tools/` entry to `.gitignore` to prevent tracking project-local tool installations.

**SCs:** SC-4

**Affected Files:**
- `.gitignore`

### Dispatch Table — Phase 4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|---------------|-----------------|-----|
| sc-coherence-gate | task() | Yes | coherence-auditor | spec SC-4 + .gitignore | SC-4 |
| pre-red-baseline | task() | Yes | baseline-checker | .gitignore current state | SC-4 |
| red-phase | task() | Yes | RED-impl | spec SC-4 + baseline | SC-4 |
| red-doublecheck | task() | Yes | RED-verifier | RED artifact + spec | SC-4 |
| post-red-enforcement | task() | Yes | enforcement-checker | RED evidence | SC-4 |
| green-phase | task() | Yes | GREEN-impl | RED gap + spec SC-4 | SC-4 |
| post-green-enforcement | task() | Yes | enforcement-checker | GREEN evidence | SC-4 |
| checkpoint-commit | bash | No | — | git operations | — |
| structural-checks | bash | No | — | ruff, pyright, mdformat | — |
| green-doublecheck | task() | Yes | GREEN-verifier | GREEN artifact + spec | SC-4 |
| green-vbc | task() | Yes | VbC-auditor | GREEN artifact + spec SC-4 | SC-4 |
| adversarial-audit | task() | Yes | dual-auditor | full artifact + spec | SC-4 |
| cross-validate | task() | Yes | cross-validator | audit findings | SC-4 |
| regression-check | bash | No | — | existing tests | — |
| review-prep | task() | Yes | review-prep | full artifact | SC-4 |
| exec-summary | task() | Yes | completion-reporter | all evidence | SC-4 |

## Phase 5: Verification

**Concern:** Confirm zero references to deleted skills, directories absent, new skill exists with correct content.

**SCs:** SC-5

**Affected Files:** None (verification phase — reads all modified files)

### Dispatch Table — Phase 5

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|---------------|-----------------|-----|
| sc-coherence-gate | task() | Yes | coherence-auditor | spec SC-5 + all phase artifacts | SC-5 |
| pre-red-baseline | task() | Yes | baseline-checker | post-phase-1-4 state | SC-5 |
| red-phase | task() | Yes | RED-impl | spec SC-5 + baseline | SC-5 |
| red-doublecheck | task() | Yes | RED-verifier | RED artifact + spec | SC-5 |
| post-red-enforcement | task() | Yes | enforcement-checker | RED evidence | SC-5 |
| green-phase | task() | Yes | GREEN-impl | RED gap + spec SC-5 | SC-5 |
| post-green-enforcement | task() | Yes | enforcement-checker | GREEN evidence | SC-5 |
| checkpoint-commit | bash | No | — | git operations | — |
| structural-checks | bash | No | — | grep, ls verification | — |
| green-doublecheck | task() | Yes | GREEN-verifier | GREEN artifact + spec | SC-5 |
| green-vbc | task() | Yes | VbC-auditor | GREEN artifact + spec SC-5 | SC-5 |
| adversarial-audit | task() | Yes | dual-auditor | full artifact + spec | SC-5 |
| cross-validate | task() | Yes | cross-validator | audit findings | SC-5 |
| regression-check | bash | No | — | existing tests | — |
| review-prep | task() | Yes | review-prep | full artifact | SC-5 |
| exec-summary | task() | Yes | completion-reporter | all evidence | SC-5 |

## Dependency Graph

```
Phase 1 (deletion) ─────┬──→ Phase 2 (creation)
                        ├──→ Phase 3 (reference-cleanup)
Phase 4 (gitignore) ────┤
                        └──→ Phase 5 (verification) ←── all phases
```

- Phase 1 → Phase 2: creation depends on deletion completing (directories must be gone before new skill is created)
- Phase 1 → Phase 3: reference cleanup depends on deletion (references point to deleted files)
- Phase 4: independent (can run in parallel with Phase 1-3)
- Phase 5: depends on all prior phases (final verification)

## Dependency Ordering Contract

See `.opencode/.issues/1314/dependency-ordering-verification/ordering.yaml` for Z3-verified ordering.

## SC-ID Mapping

| SC-ID | Phase | Concern | Evidence Type |
|-------|-------|---------|---------------|
| SC-1 | 1 (deletion) | Delete ui-design and ui-engineer directories | structural |
| SC-2 | 2 (creation) | Create playwright-cli skill from upstream | behavioral |
| SC-3 | 3 (reference-cleanup) | Remove deleted skill references | string |
| SC-4 | 4 (gitignore) | Add .tools/ to .gitignore | structural |
| SC-5 | 5 (verification) | Confirm zero references, directories absent | behavioral |
