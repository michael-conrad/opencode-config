## Objective

Update the viewport-editor MCP tool from v0.2.0 → v0.3.2 in `opencode.jsonc` and incorporate the relevant agent guidance from its v0.3.2 AGENTS.md into `.opencode/AGENTS.md`.

## Background

viewport-editor v0.3.2 was released today (2026-06-12). The release adds:
- Agent-facing composite tools: `read_file`, `write_file`, `edit_text`, `find_text`
- Stress test framework and tool selection test framework
- Various fixes and infrastructure improvements

The v0.3.2 AGENTS.md includes a Timeout Mandate (Tier 1) and Model Set section that should be reflected in the parent repo's AGENTS.md so agents routing to the viewport-editor tool have correct timeout guidance.

## Scope

Single-task: both changes are part of one update workflow.

## Files Affected

| File | Change |
|------|--------|
| `.opencode/opencode.jsonc` | Update `@v0.2.0` → `@v0.3.2` in the viewport-editor MCP command |
| `.opencode/AGENTS.md` | Incorporate Timeout Mandate + Model Set sections from viewport-editor's AGENTS.md |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | opencode.jsonc viewport-editor MCP command references `@v0.3.2` | `string` | grep `@v0.3.2` in opencode.jsonc |
| SC-2 | .opencode/AGENTS.md contains Timeout Mandate section with the model-specific timeout table | `string` | grep for "Timeout Mandate" and at least 3 model entries |
| SC-3 | .opencode/AGENTS.md contains Model Set section listing the 6 models with priorities | `string` | grep for "Model Set" and at least 4 model entries |

## Implementation Notes

- The viewport-editor AGENTS.md Timeout Mandate has a Tier 1 label — the incorporated section should preserve this tier designation in `.opencode/AGENTS.md`
- The timeout table should be adapted to the parent repo's existing AGENTS.md style (same formatting conventions)
- The LaTeX Papers section of viewport-editor's AGENTS.md is repo-specific and should NOT be incorporated
- Provider `chunkTimeout` guidance from viewport-editor's AGENTS.md should be noted: the current opencode.jsonc has `chunkTimeout: 120000` — viewport-editor recommends at least 300000ms for slow local models. This may warrant a separate config update.

## Out of Scope

- Updating `chunkTimeout` in opencode.jsonc (separate concern)
- Adding viewport-editor as a submodule (not needed — it's an MCP tool installed via uvx)
- The LaTeX Papers section from viewport-editor's AGENTS.md (repo-specific content)

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*