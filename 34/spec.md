# Spec: Frontmatter Conformance Remediation for All Skills

**STATUS: 1.0 (DRAFT — NEEDS APPROVAL)**

## Root Cause

A frontmatter audit of all 46 SKILL.md files across 42 skills revealed systemic non-conformance to the required format. The canonical frontmatter block is:

```yaml
---
name: skill-name
description: Use when [triggering conditions]. Triggers on: [keywords].
type: discipline-enforcing
license: MIT
---
```

The audit found:

### `type` field non-conformance (24 files)
Skills use non-standard type values instead of `discipline-enforcing`:
- `technique` (15): brainstorming, changelog-generator, executing-plans, finishing-a-development-branch, fragment-manager, issue-operations, pr-creation-workflow, receiving-code-review, requesting-code-review, spec-creation, sync-guidelines, ui-design, ui-engineer, writing-plans, local
- `reference` (2): gitbucket-api, github-mcp, mcp-tool-usage
- `orchestrator` (1): issue-review
- `pattern` (1): programming-principles
- `research` (1): research
- `routing` (1): multimodal-dispatch
- `verification` (1): verification

### `license` field non-conformance (5 files)
Uses `Apache-2.0` instead of `MIT`:
- multimodal-dispatch, research, skill-creator, verification, verification-enforcement

### `description` field non-conformance (3 files)
Description does not start with "Use when":
- gitbucket-api, github-mcp, local (platform sub-skills)

## Fix Approach

The fix is mechanical — no behavioral change, no semantic change:

1. **`type` field**: Set all to `discipline-enforcing`
2. **`license` field**: Set all to `MIT`
3. **`description` field**: Prepemd "Use when" prefix to the 3 platform sub-skill descriptions

## Scope Classification

This is purely structural/metadata — zero behavioral impact. These changes are analogous to `ruff --fix` on code: mechanical corrections that bring non-conforming artifacts into compliance with the format specification.

## Success Criteria

1. All 46 SKILL.md files have `type: discipline-enforcing`
2. All 46 SKILL.md files have `license: MIT`
3. All 46 SKILL.md files have `description` starting with "Use when"
4. `bash .opencode/tests/behaviors/run-all.sh` passes all existing tests
5. `bash .opencode/tests/test-enforcement.sh` passes all content-verification tests

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)