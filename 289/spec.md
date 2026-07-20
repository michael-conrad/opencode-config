## Problem

The opencode guidelines use ~136 cross-references of the form `See \`FILENAME.md\` §SECTION` or `See \`SKILLNAME\` skill`. These are written as prose citations. The agent treats them as decorative closing sentences rather than as load directives. The agent reads the summary sentence before "see" and treats it as the complete rule, never loading the referenced content where the actual rule lives.

The band-aid spec (#288) adds a text mandate to `default.txt` and `.opencode/AGENTS.md` telling the agent that cross-references are load directives. This spec addresses the root cause: the cross-references themselves are written in a form the agent interprets as citations.

## Root Cause

The word "See" is a passive verb. The agent interprets it as a citation, not an instruction. The backtick-wrapped filename is not recognized as a loadable resource. The `§` section reference is not recognized as a navigation target.

The deck already has one explicit load directive pattern that works: `Read \`<skill>/tasks/<task>.md\` first` in SKILL.md DISPATCH_GATE sections. It uses an imperative verb ("Read"), a backtick-wrapped path, and a temporal qualifier ("first"). The agent follows it.

## Fix

Rewrite all ~136 guideline cross-references from citation form to load-directive form, following the deck's own `Read \`<path>\` first` pattern adapted for the guideline context.

**Replacement form:**

```
The rule is incomplete without `065-verification-honesty.md` §Cost Model — load it now.
```

Three parts:
1. "The rule is incomplete without" — signals that the current text is a summary, not the full rule
2. Backtick-wrapped path + `§` section — the existing identifier format, preserved
3. "load it now" — imperative directive with temporal qualifier

"Load" rather than "read" because "read" in the deck already has a specific meaning (sub-agent task file discovery in DISPATCH_GATE sections). "Load" is unambiguous: fetch this content into your context.

Also add behavioral enforcement tests, linting rules, and documentation updates to prevent regression.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All ~136 guideline cross-references are rewritten from citation form (`See \`...\``) to load-directive form (`The rule is incomplete without \`...\` — load it now.`) | `string` | grep for `See \`` in guidelines; verify zero matches |
| SC-2 | A behavioral enforcement test verifies the agent loads referenced content when it encounters a load-directive cross-reference | `behavioral` | `opencode-cli run` with a prompt that triggers a guideline containing a load-directive cross-reference; verify the agent calls `read` on the referenced file |
| SC-3 | A behavioral enforcement test verifies the agent does NOT treat load-directive cross-references as decorative prose | `behavioral` | `opencode-cli run` with a prompt that triggers a guideline containing a load-directive cross-reference; verify the agent's response references content from the loaded file |
| SC-4 | A linting rule detects citation-style cross-references (`See \`...\``) in guideline files and flags them as violations | `behavioral` | Run lint on a test file containing citation-style cross-references; verify it flags them |
| SC-5 | The linting rule is integrated into the markdown lint pipeline (`.opencode/AGENTS.md` build/lint/test commands) | `string` | grep for the lint rule in AGENTS.md or lint config |
| SC-6 | A guideline documents the correct cross-reference load-directive format and its meaning | `string` | grep for cross-reference format documentation in guidelines |
| SC-7 | SKILL.md cross-reference sections (`## Cross-References`) are updated to use load-directive language where they reference guidelines | `string` | grep for `Guidelines:` in SKILL.md files; verify load-directive language |
| SC-8 | No existing behavioral enforcement tests are broken by the guideline rewrites | `behavioral` | Run `bash .opencode/tests/test-enforcement.sh --changed` after all rewrites; verify all pass |

## Affected Files

- `.opencode/guidelines/000-critical-rules.md` — ~30 cross-references
- `.opencode/guidelines/010-approval-gate.md` — ~4 cross-references
- `.opencode/guidelines/020-go-prohibitions.md` — ~15 cross-references
- `.opencode/guidelines/060-tool-usage.md` — ~4 cross-references
- `.opencode/guidelines/065-verification-honesty.md` — ~7 cross-references
- `.opencode/guidelines/067-context-completeness.md` — ~1 cross-reference
- `.opencode/guidelines/075-docs-verification.md` — ~1 cross-reference
- `.opencode/guidelines/080-code-standards.md` — ~5 cross-references
- `.opencode/guidelines/085-project-local-tools.md` — ~1 cross-reference
- `.opencode/guidelines/090-data-integrity.md` — ~1 cross-reference
- `.opencode/guidelines/091-incremental-build.md` — ~1 cross-reference
- `.opencode/guidelines/116-pair-mode.md` — ~1 cross-reference
- `.opencode/guidelines/117-session-trigger-behavior.md` — ~2 cross-references
- `.opencode/guidelines/130-authority-source.md` — ~1 cross-reference
- `.opencode/guidelines/140-planning-spec-creation.md` — ~2 cross-references
- `.opencode/guidelines/141-planning-status-tracking.md` — ~1 cross-reference
- `.opencode/guidelines/143-planning-spec-templates.md` — ~1 cross-reference
- `.opencode/guidelines/016-srclight-preference.md` — ~1 cross-reference
- `.opencode/guidelines/210-scripting.md` — ~2 cross-references
- `.opencode/guidelines/250-dark-prose-reference.md` — ~1 cross-reference
- `.opencode/guidelines/200-errors.md` — ~1 cross-reference
- `.opencode/guidelines/115-branch-naming.md` — ~1 cross-reference
- `.opencode/guidelines/144-planning-spec-examples.md` — ~1 cross-reference
- `.opencode/guidelines/015-pre-spec-inspection.md` — ~1 cross-reference
- `.opencode/tests/behaviors/` — new behavioral enforcement tests
- `.opencode/AGENTS.md` — lint rule integration

## Research Card

`.issues/research-cards/cross-reference-lobotomization.md`

## Dependencies

- Band-aid spec #288 must be implemented first (provides the mandate that this spec's rewrites rely on)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)