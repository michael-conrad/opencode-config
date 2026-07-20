## Intent and Executive Summary

- **Problem Statement:** Issue ticket directory names in `.issues/` use a slug suffix pattern (`/NNN-slug/`). The slug is never used for human navigation — issue numbers are the canonical key — and the hyphenated suffix adds filesystem noise with no semantic value.
- **Root Cause/Motivation:** The `_slug()` function in `local-issues` appends a kebab-cased title to the issue number when creating new directories (`get_issue_path()`), and `import-remote.md` additionally zero-pads the number (`:03d`). Both patterns create unnecessary path complexity.
- **Approach Chosen:** Drop the slug entirely: `.issues/NNN/`. Remove zero-padding. Maintain backward compatibility so existing `.issues/NNN-slug/` directories remain resolvable by number prefix.
- **Alternatives Considered & Why Discarded:**
  - Keep slug but shorten it: still creates unnecessary coupling between title and path.
  - Rename all existing dirs via migration: risk of data loss, not worth it when prefix matching handles backward compat.
  - Keep zero-padding without slug: padding adds no value when git and filesystem handle arbitrary integers.
- **Key Design Decisions:**
  - `_find_issue_dir()` and `_parse_number()` must continue to resolve BOTH `NNN/` and `NNN-slug/` formats (backward compatibility).
  - `get_issue_path()` stops calling `_slug()` for new directories but `_slug()` function is preserved as an available utility.
  - Model-slug in test helpers (`helpers.sh __model_slug()`) is NOT in scope — separate concern.

## Problem

Issue ticket directory names in `.issues/` use a slug suffix pattern: `/NNN-slug/`. This creates unnecessary filesystem friction — the slug is never used for human navigation (issue numbers are the canonical key) and the hyphenated suffix adds visual noise with no semantic value. The fix is to drop the slug entirely: `.issues/NNN/`.

## Documentation Sources

- `local-issues` tool source: `.opencode/tools/local-issues` — canonical implementation of `_slug()`, `get_issue_path()`, `_find_issue_dir()`, `_parse_number()`
- Local platform SKILL.md: `.opencode/skills/issue-operations/platforms/local/SKILL.md` — architecture examples showing `NNN-slug` pattern
- Issue operations tasks: `.opencode/skills/issue-operations/tasks/` — all task files referencing `NNN-slug` paths
- Test fixtures: `.opencode/tests/test_local_issues.py` — unit test for `NNN-slug` pattern
- Behavioral test helpers: `.opencode/tests/behaviors/helpers.sh` — `__model_slug()` (NOT in scope)

## Cost-Frame Prose

Cost is measured in defect-discovery-latency (DDL), not model roundtrips. Behavioral evidence catches path-creation defects at gate 1 (pre-commit, minutes of execution). String evidence (grep) lets slug-path defects slip through if the tool has a fallback path — those surface at CI or review at 100x the cost. Structural evidence (file exists) lets the defect ship to production and compound via rework: diagnose, fix, re-CI, redeploy, each cycle costing 1000x more than the skipped behavioral test. The death spiral starts when structural evidence replaces behavioral testing. SC-1, SC-2, SC-9, SC-11 are behavioral because they verify runtime path behavior — a grep would pass on a file with correct text but miss a tool that silently creates slug-named dirs anyway.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues` tool creates `.issues/NNN/` directories (no slug suffix, no zero-padding) | `behavioral` | `opencode-cli run`: create issue, inspect `.issues/` directory — name is `NNN` not `NNN-slug` |
| SC-2 | `local-issues` tool resolves existing `.issues/NNN/` directories correctly | `behavioral` | `opencode-cli run`: create issue N, then find issue by number N, verify correct path returned |
| SC-3 | `_parse_number()` in `local-issues` extracts integer from bare `NNN` directory name | `behavioral` | `.opencode/tests/test_local_issues.py` test for `_parse_number()` on bare `NNN` directory |
| SC-4 | All skill task files reference `.issues/NNN/` not `.issues/NNN-slug/` | `string` | grep for `NNN-slug` across `.opencode/skills/` returns zero matches |
| SC-5 | All guideline files reference `.issues/NNN/` not `.issues/NNN-slug/` | `string` | grep for `NNN-slug` across `.opencode/guidelines/` returns zero matches |
| SC-6 | `import-remote.md` no longer uses zero-padding (`:03d`) or slug in directory names | `string` | grep for `:03d` or `NNN-slug` in `import-remote.md` returns zero |
| SC-7 | Existing local-issue behavioral tests pass after directory naming change | `behavioral` | Run a local-issue create+resolve sequence via `opencode-cli run`: create issue, find issue, verify directories are bare `NNN` |
| SC-8 | Content-verification enforcement tests pass (when guideline/skill changes exist) | `behavioral` | `bash .opencode/tests/test-enforcement.sh --changed` passes |
| SC-9 | `_find_issue_dir()` in `local-issues` successfully resolves BOTH `.issues/NNN/` AND `.issues/NNN-slug/` formats | `behavioral` | Create one dir as `NNN-slug/` and one as `NNN/` manually; verify `local-issues` resolves both by number |
| SC-10 | All behavioral test fixtures use `NNN/` format instead of `NNN-slug/` (excluding `__model_slug` in helpers.sh) | `string` | grep for `NNN-slug` across `.opencode/tests/` returns zero matches (excluding helpers.sh `__model_slug`) |
| SC-11 | `get_issue_path()` creates `.issues/NNN/` directories without slug suffix when no existing dir found | `behavioral` | `opencode-cli run`: create issue with title, verify directory is bare `NNN` not `NNN-slug` |

## Pipeline Gate Table

| Gate | Requirement | PASS Condition | FAIL Condition | Remediation |
|------|------------|---------------|----------------|-------------|
| SC-1 behavioral | Dir is `NNN` not `NNN-slug` | `ls .issues/NNN/` succeeds | Dir created with slug suffix | Fix `get_issue_path()` to skip `_slug()` call |
| SC-2 behavioral | Resolve `NNN/` by number | Correct path returned | Path not found | Fix `_find_issue_dir()` prefix matching |
| SC-3 behavioral | Parse bare `NNN` | Integer returned | ValueError or wrong int | Fix `_parse_number()` |
| SC-9 behavioral | Both formats resolvable | Both found by number | One format fails | Fix `_find_issue_dir()` matching logic |
| SC-11 behavioral | No slug on create | Dir is bare `NNN` | Dir is `NNN-slug` | Fix `get_issue_path()` |
| SC-4/5/6/10 string | Zero grep matches | grep returns empty | grep returns hits | Edit remaining reference files |
| SC-7/8 behavioral | Tests pass | Exit code 0 | Exit code non-zero | Fix test fixtures or implementation |

## SC Enforcement Gate

**All 11 SCs must PASS.** Any SC FAIL blocks implementation and requires remediation before re-audit. String-type SCs (SC-4, SC-5, SC-6, SC-10) block when grep returns any match — a single remaining `NNN-slug` reference is a hard FAIL. Behavioral SCs (SC-1, SC-2, SC-3, SC-7, SC-8, SC-9, SC-11) block when the verification command exits non-zero.

## Non-Goals

- NOT changing `__model_slug()` in `helpers.sh` — model identifier slug is a separate concern
- NOT changing `./tmp/{issue-N}/artifacts/` template placeholders — those never had slugs
- NOT renaming existing `.issues/NNN-slug/` directories — backward compatibility maintained via `_find_issue_dir()` prefix matching (SC-9)
- NOT changing `{issue-N}` placeholder variables — these are bare number references, not slug paths

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Existing `.issues/NNN-slug/` dirs become unreadable | Medium | High | SC-9: `_find_issue_dir()` maintains backward compat; `_parse_number()` splits on `-` for integer prefix |
| Behavioral tests fail due to path format change | Medium | Medium | SC-10: Update fixtures in same pass; SC-7: re-run all behavioral tests |
| Missed references in skill/guideline files | Low | Medium | SC-4/SC-5: Global grep for `-slug` before any edit; verify zero post-edit |
| `_parse_number()` breaks on non-standard names | Low | Medium | Existing `try/except ValueError` guards non-numeric prefixes; SC-3 covers bare `NNN` case |