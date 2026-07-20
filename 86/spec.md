## Problem

The parent repo's `AGENTS.md` contains behavioral rules that duplicate and subvert the submodule skilldeck (`.opencode/guidelines/` and `.opencode/skills/`). The parent AGENTS.md should only help an agent understand the repo's structure and purpose — nothing else.

**Three categories of subversion:**

1. **Lines 38-48**: Git operations inside `.opencode/` — teaches inline `cd .opencode; git checkout` execution that `critical-rules-052` explicitly forbids (submodule git ops must be task()ed to sub-agents).

2. **Lines 62-80**: Tag-Based Hash Permanence rules, sub-agent dispatch requirement, dev parking, and release commands — behavioral workflow mandates that duplicate `git-workflow` skill tasks (`pre-work.md`, `branch-cleanup.md`, `provenance.md`) and `critical-rules-051/052`. Worse, `git-workflow/SKILL.md` line 85 contains a circular reference: "See AGENTS.md §Tag Layers" — the skilldeck points back to the parent for behavioral rules.

3. **Lines 182-209**: The entire "Boundaries (Critical)" section — every rule here duplicates the submodule skilldeck (`000-critical-rules.md`, `010-approval-gate.md`, `020-go-prohibitions.md`, `060-tool-usage.md`).

**Parent AGENTS.md should only contain structural facts about this repo** — purpose, layout, submodule relationship, API routing. All agent behavioral rules live in the submodule skilldeck.

## Affected Files

- `AGENTS.md` (parent repo) — lines 38-48, 62-80, 182-209 removed; lines 93-100 simplified
- `.opencode/skills/git-workflow/SKILL.md` — line 85 circular reference ("See AGENTS.md §Tag Layers") points to content being removed — needs fixing in a separate submodule issue

## Success Criteria

| ID | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | Parent AGENTS.md contains zero behavioral rules (no "must", "never", "always" agent mandates) | `grep -E '\b(must|never|MUST|NEVER)\b' AGENTS.md` returns no results (excluding code blocks and structural facts) |
| SC-2 | Parent AGENTS.md sections are: Repository Purpose, Authority Hierarchy, Submodule Discipline (structural only), Worktree Considerations, API Routing | Content verification |
| SC-3 | No circular reference from submodule skilldeck to parent AGENTS.md | Separate submodule issue filed |
| SC-4 | Tag format table removed from parent AGENTS.md (structural reference data belongs in skilldeck, not repo-purpose doc) | `grep -i "tag" AGENTS.md` returns only the word "tag" in comments or gitignore context, not as a behavioral specification |
| SC-5 | Boundaries section entirely removed | `grep -i "boundaries" AGENTS.md` returns no results |
| SC-6 | Submodule Discipline section contains only structural facts (remote URL, tracked branch, API routing) — no commands, no rules, no mandates | `grep -E '(git checkout|git pull|git submodule|git push|git add)' AGENTS.md` returns no results |
| SC-7 | Line count of parent AGENTS.md is ≤ 50 lines | `wc -l AGENTS.md` |

## Approach

Single concern: remove all behavioral content from parent AGENTS.md, keeping only structural facts.

Remove:
- Lines 38-48 (git operations inside .opencode — behavioral, contradicts critical-rules-052)
- Lines 62-80 (tag permanence rules, sub-agent dispatch, dev parking, release — behavioral workflow)
- Lines 182-209 (Boundaries section — all behavioral rules duplicated in skilldeck)

Keep as-is:
- Lines 1-18 (Repository Purpose)
- Lines 20-34 (Authority Hierarchy)
- Lines 82-91 (Worktree Considerations — structural git facts)
- Lines 93-100 (API Routing — structural mapping, remove the behavioral sentence "switch the API target")

Simplify:
- Lines 36-60: Keep only remote URL, tracked branch, and API routing as structural facts under Submodule Discipline

## Known Issue

`git-workflow/SKILL.md` line 85 contains "See AGENTS.md §Tag Layers" — a circular reference to content being removed. This requires a separate issue in the `michael-conrad/.opencode` repo to move the tag specification into the skilldeck and remove the pointer to the parent AGENTS.md.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)