# SPEC: Paper Edits — Unix Philosophy Skill Deck Architecture Analysis

## Problem

The companion paper ("Do One Thing Well: Unix Philosophy for AI Agent Skill Deck Architecture") at `docs/paper/paper.tex` was created during initial investigation. It requires:

1. Rename the folder/file slug from generic "paper" to a descriptive name
2. Integrate Gap 7 (preloaded sub-agent context / orchestrator pollution) discovered during May 1, 2026 investigation
3. Cross-reference spec #274 (Universal Pre-Analysis Gate) filed in michael-conrad/.opencode
4. Update the priority table to include Gap 7 at P0
5. Any additional edits driven by further investigation or spec implementation

## Fix Approach

- Rename `docs/paper/` → `docs/unix-philosophy-skilldeck/` and `paper.tex` → `unix-philosophy-skilldeck.tex`
- Update paper content to reflect live-state findings (Gap 7, spec #274 cross-reference, priority table)
- Track all edits through this issue as formal change control

## Affected Files

- `docs/paper/paper.tex` → `docs/unix-philosophy-skilldeck/unix-philosophy-skilldeck.tex`
- `docs/paper/paper.pdf`, `docs/paper/paper.aux`, `docs/paper/paper.log`, `docs/paper/paper.out`, `docs/paper/paper.toc` → renamed accordingly

## Success Criteria

| ID | Criterion |
|----|-----------|
| SC-1 | Folder renamed from `docs/paper/` to `docs/unix-philosophy-skilldeck/` |
| SC-2 | LaTeX file renamed from `paper.tex` to `unix-philosophy-skilldeck.tex` |
| SC-3 | Gap 7 section integrated into §5.2 |
| SC-4 | Spec #274 cross-referenced in Gap 7 and priority table |
| SC-5 | Priority table updated with Gap 7 at P0 |

## Revision Notes

- **v1.0** — Initial creation

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)