## Problem
The `.opencode/tools/` directory contains 22+ dedicated agent tools (guidelines access, Python utilities, markdown helpers, gitbucket API, session-init, etc.) but agents have no systematic awareness of these tools. They default to raw bash (grep, cat, find, sed) instead of using the dedicated tools. Sub-agents in clean-room context have zero tool awareness — they don't know the toolset exists.

The `help` tool already exists to list all tools with descriptions, but agents must know to call it.

## Solution
Add a `## Agent Tools` section to `.opencode/prompts/default.txt` — the instruction file loaded by all agent types (orchestrator + sub-agents). Two lines:

```
## Agent Tools
Run `./.opencode/tools/help` to list all available agent tools with descriptions.
Dedicated tools exist for common operations — use them instead of raw bash (grep, cat, find, sed) that bypass integrated verification.
```

No orchestrator propagation logic needed — default.txt feeds into all agent contexts automatically.

## Success Criteria — RED/GREEN TDD Pairings

### SC-1: default.txt contains the Agent Tools section
- **Evidence type**: `string`
- **Verification**: `grep -q "## Agent Tools" .opencode/prompts/default.txt`
- **RED test**: Assert file does NOT contain the section (current state)
- **GREEN test**: Assert file contains the section (after change)
- **Enforcement test**: Content-verification assertion, append to existing enforcement suite

### SC-2: Sub-agent sees the tool reference in task() prompt
- **Evidence type**: `behavioral`
- **Verification**: `opencode-cli run` with a prompt that triggers sub-agent dispatch, inspect stderr for tool reference injection
- **RED test**: `.opencode/tests/behaviors/tool-injection-red.sh` — sends prompt, expects NO reference present, assertion fails → proves the test catches absence
- **GREEN test**: Same file after change — assertion passes → proves injection works
- **Assertion method**: `assert_stderr_pattern_present_all_models "Agent Tools"` or clean-room `assert_semantic` to verify sub-agent received the tool context

### SC-3: Prose uses agency-respecting formulation (not tool-control)
- **Evidence type**: `semantic`
- **Verification**: AI inspector reads the added section against dark-prose-006 (agency-respecting) and dist-shift-002 (negative reinforcement anti-pattern) criteria
- **RED test**: N/A — prose is the artifact being evaluated, not a behavioral toggle
- **GREEN test**: Single-pass semantic audit, documented in spec
- **Note**: Prose already validated against 250 and 255 reference cards during brainstorming; this SC is a verification gate not a separate TDD cycle

## Per-Item TDD Cycle

| Phase | SC-1 | SC-2 |
|-------|------|------|
| RED | Write content-verification assertion (fails: section missing) | Write behavioral test `tool-injection-red.sh` (fails: no reference injected) |
| GREEN | Add section to default.txt (assertion passes) | default.txt already updated by SC-1 GREEN; behavioral test re-run (passes now) |
| REFACTOR | Verify no stale references | Verify no cross-repo sync needed |
| COMMIT | default.txt + both tests committed together | default.txt + both tests committed together |

## Affected Files
- `.opencode/prompts/default.txt` — add 3 lines (header + 2 instruction lines) after the `# Tool usage` section's last bullet
- `.opencode/tests/behaviors/tool-injection-red.sh` — behavioral enforcement test for SC-2 (new file)

## Implementation Notes
- No existing text is removed or modified — only an append
- No new tools created — consumes existing `help` tool
- No configuration changes — default.txt already loads for all agent types
- Dark prose analysis (per 250 and 255 reference cards) confirms the prose avoids tool-control anti-patterns: positive attractor (run help, use tools) with the raw-bash alternative named as the inferior path, not as a prohibition
- SC-2 behavioral test uses `with-test-home` wrapper per standard practice

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)