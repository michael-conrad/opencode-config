---
remote_issue: 2311
remote_url: https://github.com/michael-conrad/.opencode/issues/2311
labels: [spec]
approved: true
---

> **Full spec and artifacts: [`.opencode/.issues/2311/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2311)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2311/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

**Problem Statement:** The `writing-plans` skill has a contract mismatch between two task files that blocks plan creation for any issue requiring retroactive artifact backfill.

**Root Cause / Motivation:** `backfill.md` step 4 instructs `interface-compatibility.yaml` to contain only "interface boundaries between affected modules" and never instructs the sub-agent to include a `dependency_contract` section. `research.md` step 9 requires extracting a `dependency_contract` section from `interface-compatibility.yaml`; if absent, it returns BLOCKED with `DEPENDENCY_CONTRACT_NOT_FOUND`. The producer task produces an artifact the consumer task cannot consume.

**Approach Chosen:** Make `backfill.md` and `research.md` agree on the `interface-compatibility.yaml` schema by either (1) having `backfill.md` step 4 instruct the sub-agent to include a `dependency_contract` section, or (2) updating `research.md` step 9 to derive the dependency contract from the existing artifact keys. Apply one path consistently.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `backfill.md` step 4 for `interface-compatibility.yaml` instructs the sub-agent to include a `dependency_contract` section (or the research task is updated to derive the contract from the existing artifact keys without requiring a section that is never produced) | behavioral | opencode run → session.yaml |
| SC-2 | The producer and consumer task files agree on the `interface-compatibility.yaml` schema | structural | grep both task files |
| SC-3 | A plan can be created for an issue requiring retroactive backfill without hitting `DEPENDENCY_CONTRACT_NOT_FOUND` | behavioral | opencode run → session.yaml |

> **Enforcement gate:** All success criteria must pass before this spec is considered complete. Partial implementation is not permitted.

## Files Affected

- `.opencode/skills/writing-plans/tasks/backfill.md`
- `.opencode/skills/writing-plans/tasks/research.md`

## Requirements

- REQ-1: `backfill.md` step 4 for `interface-compatibility.yaml` instructs the sub-agent to include a `dependency_contract` section, OR `research.md` step 9 derives the contract from existing artifact keys
- REQ-2: Producer and consumer task files agree on the `interface-compatibility.yaml` schema

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
