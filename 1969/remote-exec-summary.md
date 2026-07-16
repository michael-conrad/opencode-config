> **Full spec and artifacts: [`.issues/1969/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1969/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1969/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The spec-creation task procedure (`spec-creation-validation/tasks/create.md`) defines a mandatory sequence of steps for creating any spec. Despite this, agents routinely bypass the procedure — skipping steps, inlining work, or treating "simple" or "small" specs as exempt. The most recent example: a spec for gating the per-turn git config watchdog was created by calling `github_issue_write` directly with a raw body, bypassing the entire spec-creation pipeline.

## Goals

- Add a procedure-compliance attestation step to `create.md`
- Add an orchestrator post-dispatch compliance gate to `spec-creation/SKILL.md`
- Add a critical violation entry to `000-critical-rules.md` for spec-creation procedure bypass

## Non-Goals

- Not changing the spec-creation pipeline architecture — only adding enforcement gates
- Not modifying any other skill or guideline files beyond the three affected files

## Scope

- Add procedure compliance attestation step to `spec-creation-validation/tasks/create.md`
- Add orchestrator post-dispatch compliance gate to `spec-creation/SKILL.md`
- Add critical-rules-spec-procedure-bypass entry to `000-critical-rules.md`

## Approach

Three-component enforcement: (1) sub-agent self-certification at end of create.md procedure, (2) orchestrator compliance gate in spec-creation SKILL.md, (3) critical violation entry in 000-critical-rules.md with behavioral enforcement tests.

## Impact

- Risk: Behavioral tests (SC-4, SC-5, SC-6) require `opencode run` infrastructure — if unavailable, SCs are FAIL
- Key dependency: Issue #1969 is the tracking issue for this spec
- Call to action: Review and approve the spec on this issue
