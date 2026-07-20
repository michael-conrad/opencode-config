## Problem

Parent `AGENTS.md` contains behavioral rules, workflow commands, and submodule discipline that duplicate or subvert the submodule skilldeck. The parent AGENTS.md should only explain this repo's purpose — nothing else.

## Proposed Change

Replace the current 100-line `AGENTS.md` with:

```markdown
# AGENTS.md — opencode-config Repository

This repository holds the agent configuration submodule. All agent rules, guidelines, and skills are in the submodule — not here.
```

## Rationale

Every removed section subverts the submodule skilldeck:

| Removed Section | Why Removed |
|---|---|
| Git operations inside `.opencode/` (lines 38-48) | Behavioral — contradicts `critical-rules-052` which mandates task()ing sub-agents |
| Tag-Based Hash Permanence, Tag Layers, tag-if-untagged, sub-agent dispatch, dev parking, release (lines 62-80) | Behavioral workflow — duplicates `git-workflow` skill tasks and `critical-rules-051/052`. Also creates a circular reference: `git-workflow/SKILL.md` line 85 says "See AGENTS.md §Tag Layers" |
| Remote/branch info (lines 58-60) | Discoverable from `.gitmodules` and git — not repo-purpose information |
| Sub-agent dispatch requirement (line 76) | Behavioral — duplicates `critical-rules-052` |
| Boundaries section (lines 182-209) | Behavioral — every rule duplicates `000-critical-rules.md`, `010-approval-gate.md`, `020-go-prohibitions.md`, or `060-tool-usage.md` |
| Worktree Considerations (lines 82-91) | Behavioral — `git-workflow` skill covers submodule init in worktrees |
| API Routing (lines 93-100) | Behavioral — `critical-rules-036` covers API routing; the table duplicates `.gitmodules` |
| Submodule Discipline introduction (lines 36-37) | Header for removed content |

## Separate Fix Required

`git-workflow/SKILL.md` line 85 contains "See AGENTS.md §Tag Layers" — a circular reference to content being removed. This needs a separate issue in `michael-conrad/.opencode` to point the skilldeck's own provenance content instead of the parent AGENTS.md.

## Success Criteria

| ID | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | `AGENTS.md` is ≤5 lines | `wc -l AGENTS.md` returns ≤5 |
| SC-2 | `AGENTS.md` contains zero behavioral rules (no "must", "never", "MUST", "NEVER" as agent mandates) | `grep -iE '\b(must|never|MUST|NEVER)\b' AGENTS.md` returns no results |
| SC-3 | No circular reference from submodule skilldeck to parent AGENTS.md | Separate submodule issue filed for `git-workflow/SKILL.md` line 85 |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)