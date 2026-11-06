---
remote_issue: 2295
remote_url: https://github.com/michael-conrad/.opencode/issues/2295
---

# [SPEC] Prevent agents from storing source/tests/fixtures in `.issues/` worktree

## Intent and Executive Summary

- **Problem Statement:** The AI agent has begun storing tests, test fixtures, and other source/project items in the `.issues/` worktree folders. `.issues/` is a git worktree on the `issues-data` branch — a separate git repository gitignored in the parent repo. Any file written there never reaches the deployable repo and is lost.
- **Root Cause / Motivation:** `.opencode/skills/test-driven-development/tasks/red.md` states "Test files go to permanent storage (`.opencode/tests-v2/` or `.issues/{N}/tests/`)." This explicitly authorizes placing test files in `.issues/{N}/tests/`, a path that does not exist in the canonical `.issues/` layout and is invisible to the parent repo's build system.
- **Approach Chosen:** Establish a universal principle: tests and source artifacts are tracked in the git repository that owns the code under test, never in `.issues/`. The `.issues/` worktree is a gitignored, non-deployable git repository — any source/test/fixture written there is lost. The fix removes the explicit authorization in `red.md`, corrects the misleading "permanent" framing, disambiguates the artifact copy, and stops auto-committing `.issues/` files into feature PRs. An explicit exclusions list establishes the content-type boundary. A behavioral enforcement test verifies agents do not write test files under `.issues/`.

## Not Included

- Migration or deletion of already-misrouted test files.
- Changes to the root repo (`opencode-config`).
- Changes to the `.issues/` worktree mechanism itself.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/.issues/AGENTS.md` contains an explicit exclusions list stating `.issues/` holds issue metadata only, never source/test/fixture/code. | string | grep AGENTS.md for the exclusions-list marker |
| SC-2 | `.opencode/skills/test-driven-development/tasks/red.md` no longer lists `.issues/{N}/tests/` as a valid test storage path. | string | grep red.md for absence of `.issues/{N}/tests/` |
| SC-3 | `.opencode/skills/test-driven-development/tasks/red.md` directs test placement by the owning-repo principle. | string | grep red.md for presence of owning-repo reference |
| SC-4 | `.opencode/skills/writing-plans/reference/implementation-workflow.md` Rule 1 clarifies `.issues/{N}/` holds issue metadata only. | string | grep Rule 1 for metadata-only language |
| SC-5 | `.opencode/skills/spec-creation/tasks/create.md` Step 6 disambiguates the "analytical artifacts" copy target so only analysis artifacts are copied to `.issues/{N}/artifacts/`. | string | grep Step 6 for unambiguous copy-target description |
| SC-6 | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` Step 0 no longer auto-commits arbitrary dirty `.issues/<N>/` files into feature PRs. | string | grep Step 0 for removal of unconditional `git add .issues/` auto-commit |
| SC-7 | A new behavioral enforcement test at `.opencode/tests-v2/behaviors/` asserts an agent does NOT write test files under `.issues/`. Artifact-only generator per canonical framework. | behavioral | Behavioral test execution via `with-test-home opencode run`; stderr-based assertions for absence of `.issues/` write actions; Bash tool timeout >= 600s |

## Requirements

- R-7. A behavioral enforcement test SHALL exist at `.opencode/tests-v2/behaviors/` asserting an agent does NOT write test files under `.issues/`.
- R-10. The behavioral enforcement test SHALL be an artifact-only generator (exit 0, no self-evaluation) per the canonical framework in `.opencode/tests-v2/AGENTS.md`.
- R-9. All changes SHALL be confined to the `.opencode` submodule; no root repo (`opencode-config`) changes.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
