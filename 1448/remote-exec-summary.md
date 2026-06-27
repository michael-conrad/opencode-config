> **Full spec and artifacts: [`.issues/1448/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1448/)**
>
> **Local artifacts:** `.issues/1448/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exec Summary

The cross-validate step in the implementation pipeline returns `overall_consensus: FAIL` with `next_step: "remediate then re-audit"`, but the orchestrator has no enforcement mechanism that halts on FAIL. During #1442, the orchestrator treated a hard FAIL as a "cross-validate note" and proceeded past the gate. This spec adds a hard gate in `pipeline-executor.md` that checks cross-validate output and blocks the pipeline on FAIL.

### Cards (dependency order)
1. **Cross-validate FAIL gate** — Add a gate step between cross-validate (step 14) and regression-check (step 15) in the pipeline-executor dispatch table that reads the cross-validate result contract, checks `overall_consensus`, and HALTs with blocker report on FAIL
2. **Behavioral enforcement test** — Write a behavioral test that verifies the orchestrator halts on cross-validate FAIL

### Key Decisions
- **Gate as a new pipeline step, not inline logic**: Adding a dedicated step (step 14.5) in the dispatch table ensures the gate is visible in the pipeline state machine, checkpoint-taggable, and subject to the same remediation routing as all other steps.
- **Gate reads YAML artifact from disk**: Consistent with the existing pattern — the orchestrator reads only the YAML frontmatter from the cross-validate artifact, not the full content.

### Risk Callouts
- **Risk: Gate is skipped by orchestrator** — The same orchestrator that bypassed cross-validate FAIL could bypass the gate itself. Mitigation: The gate is a numbered pipeline step with checkpoint tagging, making it visible in the state machine and auditable.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1448/`.
After creation, `local-issues sync 1448` MUST be run and the result committed to create the local `.issues/1448/` entry.
The implementation plan will be created in `.issues/1448/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
