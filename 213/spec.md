## Parent

https://github.com/michael-conrad/opencode-config/issues/212 — Audit: Skill Card "Use When" Description Compliance

## Problem

`playwright-cli` is the only skill whose description does not start with "Use when". Current description:

> Automate browser interactions, test web pages and work with Playwright tests using @playwright/cli from microsoft/playwright-cli.

This reads as a README summary, not a dispatch condition. It also lacks mandatory language and uses a different license (`Apache-2.0`) and has `provenance`/`upstream` fields no other skill has.

## Requirements

1. Rewrite description to start with "Use when" and follow the standard dispatch format
2. Add mandatory language signaling dispatch is required
3. Ensure description reflects the Trigger Dispatch Table's conditions (open, navigate, interact, input, capture, eval, network, storage, tabs, tracing, video, test, spec-driven, session, install)
4. Remove narrative-only content
5. Preserve the `Apache-2.0` license, `provenance`, `upstream`, and `upstream_license` fields — these are structural metadata, not dispatch text

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Description starts with "Use when" | `string` |
| SC-2 | Description contains mandatory language (MUST, REQUIRED, always, not optional, mandatory) | `string` |
| SC-3 | Description reflects all trigger conditions from the dispatch table | `semantic` |
| SC-4 | Description contains no narrative-only sentences | `semantic` |
| SC-5 | Non-description fields (license, provenance, upstream) preserved unchanged | `structural` |

## References

- `playwright-cli/SKILL.md`
- Audit spec #212 §D1, §D4, §D5

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)