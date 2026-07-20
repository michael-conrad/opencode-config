## Problem Statement

The current `for_*` authorization scope model (`for_analysis`, `for_spec`, `for_plan`, `for_implementation`, `for_review_prep`, `for_pr`, `for_pr_only`, `for_review_only`, `for_next_phase`, `for_phase_N`) was derived from a defunct implementation workflow. Key problems:

1. `for_review_prep` is the DEFAULT for bare `"approved #N"` — inverted from natural developer intent
2. `for_review_prep` and `for_review_only` occupy the same conceptual space
3. Halt_at values (`review-prep`, `code_review_ready`, `verification_complete`) don't correspond to actual pipeline stage boundaries
4. No scopes for cleanup or release workflows
5. No scopes for pre-work (branch creation, submodule init)
6. Gap-fill cascades (`for_implementation` auto-creates spec+plan+auto-approves) skip real gates
7. PR strategies locked to scope rather than being independent
8. The flat enum can't express "approve through RED only, stop before GREEN"

## Proposed Solution

Replace the flat `for_*` enum with a hierarchical dotted-scope model that mirrors the actual workflow structure. The top-level scope gates the full workflow; sub-stages gate individual phases for intermediate review.

### Scope Domain (48 values)

**Top-level entry points:**
- analysis — investigation, reading, issue creation
- spec — create a spec issue
- plan — create a plan from a spec

**Pre-work (sub-stages under prework):**
- prework — full pre-work through reporting
- prework.DEV_VERIFY — verify/ensure dev branch exists
- prework.SYNC — sync local dev with remote
- prework.BRANCH — create feature branch
- prework.SUBMODULE — init and tag submodules
- prework.VERIFY — verify branch environment
- prework.REPORT — report ready state

**Implementation (22 sub-stages):**
- implementation — full pipeline through summary
- implementation.BASELINE — pre-RED baseline capture
- implementation.COHERENCE — spec/plan checked against codebase
- implementation.RED — RED tests written
- implementation.RED_CHECK — RED-side verification
- implementation.GREEN — implementation written
- implementation.COMMIT — checkpoint commit
- implementation.STRUCTURAL — lint/typecheck/format
- implementation.GREEN_CHECK — GREEN-side verification
- implementation.VBC — verification before completion
- implementation.AUDIT — adversarial audit
- implementation.CROSS — cross-validate audit results
- implementation.REGRESSION — regression test pass
- implementation.SUBMODULE_PUSH — push submodule changes
- implementation.TEMP_CLEAN — clean temp files
- implementation.REBASE — rebase on current dev
- implementation.PUSH_VERIFY — verify branch push
- implementation.WORKTREE_HANDOFF — worktree cleanup
- implementation.URL — generate compare URL
- implementation.PREP_REPORT — report and halt
- implementation.SUMMARY — exec summary + issue comment

**PR creation (4):**
- pr — full PR creation through API call
- pr.GATE — enforcement gate + liveness check
- pr.SQUASH — squash+rebase+push
- pr.CREATE — PR body writing + API call
- pr_only — PR only, assuming branch exists

**Cleanup (8):**
- cleanup — full cleanup through verification
- cleanup.DETECT — detect submodules and build context
- cleanup.VERIFY_MERGE — verify PR merge
- cleanup.CLOSE — close sub-issues
- cleanup.PARENT_CLOSE — close parent plan
- cleanup.BRANCH — delete branches, restore submodules
- cleanup.EVIDENCE — clean behavioral evidence artifacts
- cleanup.VERIFY — post-cleanup dev-tip verification

**Release (9):**
- release — full release through posting
- release.ROUTE — route to submodule/non-submodule path
- release.LOCK — lock submodule SHAs
- release.TAG — tag submodule SHAs with semver
- release.VALIDATE — validate release tags
- release.PROMOTE — create release branch and PR
- release.POST_TAG — post-merge tag master
- release.POST_PUSH — post-merge push tags
- release.POST_RELEASE — create platform release

### Halt Points (48, all distinct)

Each scope maps to exactly one halt_at value. The Z3 model proves all mappings are SAT and distinct.

### Default Behavior Change

Bare `"approved #N"` (no qualifier) → `implementation` scope. This matches natural developer intent — "approved" means "do the work."

### PR Strategy Decoupling

`pr_strategy` is no longer locked to scope. `stacked` is set for pr, pr.*, and pr_only scopes only. All others are `none`.

### Gap-Fill Rules

`analysis`, `plan`, `prework`, `implementation` (and all sub-stages), `pr` → gap-fill creates missing artifacts automatically. The Z3 model proves consistency.

## Files to Change

1. `.opencode/skills/approval-gate/enforcement/scope-parsing.md` — rewrite verb-prefix parsing table with new scopes
2. `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md` — rewrite scope-dispatch routing
3. `.opencode/skills/approval-gate/tasks/verify-authorization/scope-auto-resolve.md` — update default behavior
4. `.opencode/skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md` — update gap-fill tables
5. `.opencode/skills/approval-gate/SKILL.md` — update authorization context template
6. `.opencode/guidelines/010-approval-gate.md` — update scope table
7. `.opencode/guidelines/000-critical-rules.md` — remove obsolete scope references
8. `.opencode/skills/implementation-pipeline/SKILL.md` — update template
9. All skill task files with boilerplate `authorization_scope` and `halt_at` templates (~40+ files)

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)