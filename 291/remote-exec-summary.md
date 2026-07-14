> **Full spec and artifacts: [`.issues/291/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/291)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/291/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The opencode guidelines use ~164 cross-references of the form `See `FILENAME.md` §SECTION` or `See `SKILLNAME` skill`. These are written as prose citations. The agent treats them as decorative closing sentences rather than as load directives. The agent reads the summary sentence before "see" and treats it as the complete rule, never loading the referenced content where the actual rule lives.

The band-aid spec (#288) adds a text mandate to default.txt and .opencode/AGENTS.md telling the agent that cross-references are load directives. This spec addresses the root cause: the cross-references themselves are written in a form the agent interprets as citations.

## Goals

- Rewrite all ~164 guideline cross-references from citation form to load-directive form
- Add behavioral enforcement tests to verify agent loads referenced content
- Add linting rules to detect citation-style cross-references
- Document the correct load-directive format
- Prevent regression

## Non-Goals

- Modifying the band-aid mandate in default.txt or AGENTS.md (that's #288)
- Changing cross-references in non-guideline files (code, scripts, etc.)

## Scope

- All ~164 guideline cross-references rewritten from `See `FILE.md` §SECTION` to `The rule is incomplete without `FILE.md` §SECTION — load it now.`
- Behavioral enforcement test verifying agent loads referenced content
- Behavioral enforcement test verifying agent does not treat load-directives as decorative prose
- Linting rule detecting citation-style cross-references
- Linting rule integrated into markdown lint pipeline
- Guideline documenting the correct load-directive format
- SKILL.md cross-reference sections updated

## Approach

Rewrite every citation-style cross-reference to the load-directive form: `The rule is incomplete without `FILE.md` §SECTION — load it now.` This uses an imperative verb ("load"), signals incompleteness, and preserves the existing identifier format. Add behavioral tests, linting, and documentation to prevent regression.

## Impact

- Risk: Large-scale text change may introduce typos. Mitigation: automated linting + behavioral tests.
- Risk: Behavioral tests may be slow. Mitigation: scope-limited execution.
- Dependency: Blocked by #288 (band-aid spec must be implemented first).

## Research Card

`.issues/research-cards/cross-reference-lobotomization.md` (not yet created — to be created during implementation)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)