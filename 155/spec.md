## Summary

Remove the "texted" MCP plugin entry from `.opencode/opencode.jsonc` (lines 130-134). The texted MCP tool (`texted_edit_file`, `texted_texted_doc`, `texted_texted_eval`) is available through the opencode built-in tool suite and does not need a separate MCP plugin entry. The `run-texted-mcp` script at `.opencode/tools/run-texted-mcp` is also unused and can be removed.

## Problem

The "texted" MCP plugin at lines 130-134 of `.opencode/opencode.jsonc` provides MCP tools (`texted_edit_file`, `texted_texted_doc`, `texted_texted_eval`) that duplicate functionality already available through opencode's built-in tool suite. The `run-texted-mcp` script at `.opencode/tools/run-texted-mcp` is not referenced anywhere else in the configuration.

This is dead config — removing it:
- Reduces MCP plugin startup overhead
- Eliminates unused code paths
- Simplifies the MCP plugin configuration

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | The `"texted"` block (lines 130-134) is removed from `mcp` section of `.opencode/opencode.jsonc` | `string` |

## Affected Files

- `.opencode/opencode.jsonc` — remove lines 130-134 (the "texted" MCP plugin block)

🤖 Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)