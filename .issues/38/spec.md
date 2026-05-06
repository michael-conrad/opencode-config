---
title: "[SPEC] Investigate Read-Only Default Agent Mode"
issue_number: 38
state: open
labels:
  - needs-approval
  - "[SPEC]"
created_at: "2026-05-04T06:25:55Z"
updated_at: "2026-05-04T06:33:17Z"
html_url: "https://github.com/michael-conrad/opencode-config/issues/38"
---

## Summary

Investigate making the default/main orchestrator agent read-only so that it cannot directly modify files. All file modifications would require sub-agent dispatch by design, not just by guideline enforcement.

## Context

Currently, guidelines and skills enforce sub-agent dispatch for file modifications (clean-room dispatch, DISPATCH_GATE checkpoint, etc.), but the system itself does not prevent the main agent from writing files directly. A system-level read-only mode would structurally enforce what guidelines currently attempt to enforce procedurally.

This is distinct from [.opencode#106](https://github.com/michael-conrad/.opencode/issues/106) (Universal Clean-Room Sub-Agent Dispatch) which addresses the same domain through guideline-level enforcement. This investigation should explore whether a read-only default mode is feasible at the system/loader level.

## Success Criteria

1. Feasibility assessment of making the main agent read-only by default in the opencode framework
2. Identification of what tool categories would need read-only enforcement (write, edit, bash with side effects, etc.)
3. Assessment of impact on existing workflows (direct-branch, worktree, pair-mode)
4. Recommendation on implementation approach (plugin-level, tool-level, or configuration-level enforcement)

STATUS: 0.1 (DRAFT — awaiting investigation)

🤖 Co-authored with AI: OpenCode (unknown (version detection failed))
