## Intent and Executive Summary

**Problem Statement:** The AI agent has stopped following the established git tag protocol for submodule hash permanence. Feature-branch tip tags use ad-hoc suffixes (e.g., `-phase1`, `-spec-revision`, `-feature-tip`, `-parent-start`) instead of the documented `<parent>/<issue>-<sub>` convention where `<sub>` is the submodule directory name (e.g., `-opencode`). Pre-work tags point to merge commits instead of dev tip at branch-creation time. Duplicate tags on identical SHAs are created.

**Root Cause:** The tag suffix convention (`-opencode`) was established by historical precedent (tags #215-opencode, #219-opencode, #526-opencode, #548-opencode) but was never formally codified with a behavioral enforcement test. Spec #215 defines `<parent>/<issue>-<sub>` where `<sub>` resolves to the submodule directory name, but recent AI agents invent arbitrary suffixes because nothing enforces the resolution rule. Additionally, the pre-work tag procedure is not reliably following its own spec — the tag should capture dev tip at the moment the branch diverges, not a later merge point.

**Approach Chosen:** Codify the suffix resolution rule in git-workflow task files with explicit language and an enforcement test. Fix the pre-work tagging step to explicitly tag dev tip before branch creation (not after). Add a no-duplicate-tags SC. The fix spans both repos: the submodule skill files (tag procedure) and this repo's behavioral tests.

**Alternatives Considered & Why Discarded:**
- **Allowlist of valid suffixes** — Would require an allowlist and create a maintenance burden each time a submodule is added/removed
- **Auto-detection via submodule path** is the correct approach since the suffix IS the directory name; no allowlist needed

**Key Design Decisions:**
1. The tag suffix is NOT configurable — it MUST be derived from the submodule directory name in `.gitmodules`. For `.opencode`, suffix is `-opencode`. For any future submodule, suffix is `-<directory-name>`.
2. Pre-work tag MUST be created from dev tip before branching, not after work begins.
3. Duplicate tags on the same SHA (different suffixes) are prohibited — the pre-existing tag takes priority.

## Objective

Restore compliance with the submodule tag protocol defined in #215 (`.opencode` repo) by codifying the suffix resolution rule, fixing the pre-work tag timing, and preventing duplicate/ad-hoc tags with a behavioral enforcement test.

## Problem

**Regression evidence:**

1. **Wrong feature-branch tag suffix** (4 historical correct tags: `215-opencode`, `219-opencode`, `526-opencode`, `548-opencode` vs 5 regression tags):
   - `842-feature-tip` → should be `842-opencode`
   - `872-phase1` → should be `872-opencode`
   - `872-spec-revision` → duplicate of `872-phase1` on same SHA, also should be `872-opencode`
   - `928-parent-start` → should be `928-opencode`
   - `928-submodule-start` → duplicate, should be `928-opencode`

2. **Pre-work tag `opencode-config/872` points to wrong SHA**: Points to `03dcd933` (a merge commit), NOT dev tip `0166e15f` at branch-creation time. The tag was created after work had already been committed to the submodule, not at the pre-work boundary.

3. **Duplicate tags on identical SHA**: `opencode-config/872-phase1` and `opencode-config/872-spec-revision` both point to SHA `5202c633`. This is a duplicate that provides zero additional hash permanence value and pollutes the tag namespace.

4. **No behavioral enforcement test**: Spec #215 SC-1 mandates tag creation, but there is no behavioral test that verifies the agent creates the CORRECT suffix. The `-opencode` convention has no enforcement — hence it was silently bypassed.

## Context

- **Authoritative spec:** https://github.com/michael-conrad/.opencode/issues/215 (Tag-Based Hash Permanence)
- **Spec #215 tag format:** `<parent-repo>/<issue-number>-<submodule-name>` — feature-branch tip tag
- **Submodule:** `.opencode` (directory name = `.opencode`, suffix = `-opencode`)
- **Pre-work location:** `skills/git-workflow/tasks/pre-work.md` and `skills/git-workflow/tasks/pre-work/submodule-tag-prework.md`
- **Feature-push location:** `skills/git-workflow/tasks/provenance/dev-push-provenance.md`
- **Cleanup tag-if-untagged:** `skills/git-workflow/tasks/cleanup/branch-cleanup.md`

## Scope

| In scope | Out of scope |
|----------|-------------|
| Fix tag suffix derivation in pre-work task file | Release tag format (`<parent>/v<version>`) |
| Fix tag suffix derivation in dev-push-provenance task file | Checkpoint tags (`/checkpoint/...`) |
| Add behavioral enforcement test for correct suffix | Cleanup tag-if-untagged format |
| Fix pre-work tag timing (tag dev tip before branch, not after work) | Parent-side tags (no protocol exists for these) |
| Add no-duplicate-tags SC | |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation |
|----|-----------|---------------|-------------------|-------------|
| SC-1 | `submodule-tag-prework` sub-agent task file explicitly states: "Tag suffix MUST be derived from submodule directory name in `.gitmodules` (e.g., `.opencode` → `-opencode`). DO NOT use issue title, phase name, or any ad-hoc string." | `string` | `grep -E '\-opencode.*submodule.*directory\|directory.*name.*suffix\|suffix.*derived.*from' .opencode/skills/git-workflow/tasks/pre-work/submodule-tag-prework.md` returns match | Add the explicit suffix derivation rule to the task file |
| SC-2 | `dev-push-provenance.md` replaces `<sub>` placeholder with concrete instruction: "Replace `<sub>` with the submodule directory name (e.g., `.opencode` → `-opencode`)." | `string` | `grep 'submodule directory name\|directory.*name.*opencode' .opencode/skills/git-workflow/tasks/provenance/dev-push-provenance.md` returns match | Update the template placeholder with the resolution rule |
| SC-3 | Pre-work task explicitly tags dev tip BEFORE feature branch creation, not after submodule changes are made. The tagging step precedes the `git checkout -b` step. | `string` | `grep -E 'Step.*tag.*dev.*tip.*before.*branch\|tag.*before.*feature.*branch' .opencode/skills/git-workflow/tasks/pre-work.md` returns match | Reorder the pre-work procedure: tag dev tip, then create branch |
| SC-4 | Behavioral enforcement test exists at `.opencode/tests/behaviors/submodule-tag-prework.sh` that verifies the `-opencode` suffix is used by sending a pre-work prompt to the agent and asserting on stderr evidence of the correct tag command | `behavioral` | `bash .opencode/tests/with-test-home opencode-cli run 'pre-work for issue #X'` with `assert_stderr_pattern_present 'opencode-config/X-opencode'` or `assert_stderr_pattern_present 'git tag.*opencode-config/X-opencode'` | Create the behavioral test; if it fails (no `-opencode` tag), the task hasn't been fixed yet |
| SC-5 | Behavioral test also asserts that ad-hoc suffixes (-phase1, -feature-tip, -spec-revision, -parent-start, -submodule-start) are NOT present in the agent's dispatch | `behavioral` | Same test as SC-4 with `assert_forbidden_pattern_absent '-phase1\|-feature-tip\|-spec-revision\|-parent-start\|-submodule-start'` | Add the negative assertion |
| SC-6 | Pre-work tag tag-if-untagged rule prevents duplicate tags on same SHA (idempotent tagging — skip if SHA already has a parent-prefixed tag) | `string` | `grep 'tag-if-untagged\|skip.*already.*tagged\|idempotent' .opencode/skills/git-workflow/tasks/pre-work/submodule-tag-prework.md` returns match | Add idempotent tag-if-untagged check to the submodule-tag-prework task |

## Affected Files

All in submodule `michael-conrad/.opencode` (branch: `dev`):

| File | Change |
|------|--------|
| `skills/git-workflow/tasks/pre-work/submodule-tag-prework.md` | SC-1: Add explicit suffix derivation rule. SC-3: Ensure tagging precedes branch creation. SC-6: Add idempotent tag-if-untagged. |
| `skills/git-workflow/tasks/provenance/dev-push-provenance.md` | SC-2: Replace `<sub>` with concrete directory-name resolution rule |
| `tests/behaviors/submodule-tag-prework.sh` | NEW: SC-4 and SC-5 behavioral enforcement test |

Changes in this repo (`michael-conrad/opencode-config`):

No file changes needed. This spec and its behavioral test reside in the submodule.

## Edge Cases

- **Shared submodules (multiple parent repos):** The `<parent-repo>` prefix prevents collision. The suffix derivation is per-parent, not global — each parent tags with its own name plus the submodule directory suffix.
- **Submodules with multiple directories:** Each submodule gets its own tag. A `.opencode` submodule gets `-opencode`. A `lib/` submodule gets `-lib`. The directory name in `.gitmodules` IS the suffix.
- **No submodule changes expected:** Feature-branch tip tag (`-opencode`) is only created when the submodule actually has pushed changes. Pre-work tag is always created.
- **Tag already exists from prior work:** The idempotent tag-if-untagged check prevents duplicates. If the SHA already has a parent-prefixed tag, skip creation.
- **Phase-named issues:** The agent cannot confuse phase names for tag suffixes because `-opencode` is now explicitly tied to the directory name, not to any other string.

## Change Control

- This spec updates the existing tag protocol from #215; it does not replace it
- Pre-work tag timing (tag before branch) amends the procedure implied by the current task file — the tag should capture the state BEFORE work begins, which means it must be placed in the procedural order before `git checkout -b`
- Behavioral test SC-4/SC-5 is new — no existing test covers tag suffix compliance
- No changes to the release tag format (`<parent>/v<version>`) or checkpoint tag format (`/checkpoint/...`)

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Agent continues to invent ad-hoc suffixes | Medium | High | Behavioral test SC-4/SC-5 enforces correct suffix; negative assertion catches regressions |
| Pre-work tag still points to wrong SHA | Medium | High | SC-3 explicitly demands tagging before branching; the behavioral test must verify the tag command appears at the correct procedural position |
| Duplicate tags on future issues | Medium | Low | SC-6 idempotent check prevents this; cleanup already has tag-if-untagged which is idempotent |
| Existing ad-hoc tags need cleanup | Low | Low | Existing tags (`842-feature-tip`, `872-phase1`, `872-spec-revision`, etc.) are permanent — they can be ignored or manually deleted; the fix prevents future occurrences |

## Decision Rationale

**Why derive suffix from directory name (not an allowlist)?** The directory name is always known at pre-work time from `.gitmodules`. There is exactly one submodule in this project (`.opencode`). An allowlist would need updating on submodule add/remove. The derivation rule is simpler and future-proof.

**Why tag before branch creation?** The pre-work tag captures "dev tip at the moment this work started." If the tag is created after the feature branch already has commits, it captures the feature branch SHA, not dev tip — defeating the purpose of a starting-point anchor. The procedural reorder prevents this category of error.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)