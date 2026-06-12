## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem | The Platform Routing Mandate ("ALL `github_*`/`gitbucket-api` issue calls MUST route through `issue-operations` dispatcher") lives in `060-tool-usage.md`, which has `trigger_on: tool, path rule, temp file, command restriction, file operation`. When an agent makes `github_*` API calls, the file-operations trigger never fires, so the mandate is never loaded into context. The same rule already exists in `000-critical-rules.md` as a Tier 1 rule (`critical-rules-platform-routing-bypass`). The duplication creates confusion about which is authoritative. |
| Approach | Delete the Platform Routing Mandate section and its symbolic rules (`tool-usage-010`, `tool-usage-011`) from `060-tool-usage.md`. The rule is already fully defined in `000-critical-rules.md`. |
| Key Decisions | Content of the rules stays unchanged — only their location changes. |
| Alternatives | Keep the duplication (rejected: causes loading failures). Move to a new guideline file (rejected: unnecessary file, 000 already has the rule). |
| Scope | `060-tool-usage.md` only |

## Problem

Two problems with the current state:

1. **Wrong trigger zone**: `060-tool-usage.md` triggers on "file operation". Running `github_issue_write` is an API call, not a file operation. The guideline never loads.

2. **Duplicate rule**: The exact same prohibition already exists in `000-critical-rules.md` as two complete entries:
   - Prose: `[critical-rules-platform-routing-bypass]` (Tier 1)
   - Prose: `[critical-rules-platform-api-deliberation]` (Tier 2)
   - Symbolic rule: `critical-rules-platform-routing-bypass` (Tier 1, line 1964)
   - Symbolic rule: `critical-rules-platform-api-deliberation` (Tier 2, line 1979)

Having the same rule in two files means one can be updated without the other, creating drift.

## Requirements

### R-1: Remove from 060-tool-usage.md

Delete the Platform Routing Mandate prose section and `tool-usage-010`/`tool-usage-011` symbolic rules from `060-tool-usage.md`.

### R-2: Verify 000-critical-rules.md completeness

Confirm `critical-rules-platform-routing-bypass` (Tier 1) and `critical-rules-platform-api-deliberation` (Tier 2) exist in `000-critical-rules.md` with complete prose and symbolic rule definitions.

## Out of Scope

- Changes to the content of the platform routing rules
- Changes to `session-enforcement.ts`
- New behavioral tests

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | No Platform Routing Mandate section remains in `060-tool-usage.md` | `string` |
| SC-2 | No `tool-usage-010`/`tool-usage-011` symbolic rules remain in `060-tool-usage.md` | `string` |
| SC-3 | `critical-rules-platform-routing-bypass` exists in `000-critical-rules.md` as Tier 1 | `string` |
| SC-4 | `critical-rules-platform-api-deliberation` exists in `000-critical-rules.md` as Tier 2 | `string` |

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan are at this local path. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)