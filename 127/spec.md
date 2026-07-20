## Problem

When an AI agent edits an existing file (source code docstring, issue comment, PR body, or other artifact) that already has a `Co-authored with AI:` byline from a **previous AI agent**, the editing agent overwrites the prior agent's identity — both the model ID and format — with its own.

### Example (observed regression)

| Artifact | Content |
|----------|---------|
| **Original byline** | `*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*` |
| **After edit by new agent** | `🤖 Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)` |

Two independent changes occurred:
1. **Identity overwrite**: `ollama-cloud/deepseek-v4-flash` → `opencode/deepseek-v4-flash-free` (the editing agent substituted its own model ID for the original author's)
2. **Format drift**: Italic list-item format → emoji-prefix format

### Root Cause

The attribution rules in `080-code-standards.md` §AI Co-Authored Attribution mandate bylines for new AI-generated content, but contain **no preservation rule** for bylines that already exist in files being edited. There is no instruction telling the agent what to do when it encounters an existing `Co-authored with AI:` line written by another AI.

### Impact

- Erases audit trail of which AI agents contributed to which files
- Falsifies content origin history
- Breaks traceability for the project's AI agent accountability model
- The current agent is implicitly claiming authorship of work it did not create

## Fix Scope

The fix adds a **"Preserve Existing Bylines"** rule to `080-code-standards.md` §AI Co-Authored Attribution. No other files need modification.

### What Must Change

Add a new subsection (after "Standalone Byline Correction — FORBIDDEN" at line 208) with the following rules:

1. **Never overwrite a prior agent's byline.** When editing a file that already contains a `Co-authored with AI:` line, the agent MUST NOT modify, replace, or remove that line.
2. **Append, don't replace.** If the editing agent contributed substantive new AI-generated content to the file, it appends its own byline on a new line following the existing byline(s). If the edit is minor (typo fix, formatting, refactoring that doesn't generate new creative content), no additional byline is needed.
3. **Format consistency.** The editing agent uses the same format as the existing byline(s) — do not change `*italic*` to `🤖 emoji` or vice versa when editing existing content. New files use the format specified per file type in the tables above.
4. **Multi-agent bylines.** When a file has bylines from multiple AI agents (each added by a different agent during its respective edit), the chronological order of bylines must be preserved — each new byline appended at the end.

### Examples

**Source file editing:**

```python
# BEFORE edit (existing file):
"""Module description.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
"""

# AFTER edit by new agent (CORRECT — preserve + append):
"""Module description with new feature.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
Co-authored with AI: OpenCode (ollama-cloud/glm-5)
"""

# AFTER edit by new agent (WRONG — identity overwrite):
"""Module description with new feature.

Co-authored with AI: OpenCode (ollama-cloud/glm-5)
"""
```

**Posted content editing:**

```markdown
# BEFORE (existing issue comment):
Implementation complete.
🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

# AFTER edit (CORRECT — preserve + append):
Implementation complete with additional changes.
🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5)
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Guideline text adds "Preserve Existing Bylines" subsection with all 4 rules (never overwrite, append-don't-replace, format consistency, multi-agent ordering) | `string` | grep for "Preserve Existing Bylines" in `080-code-standards.md` |
| SC-2 | The guideline explicitly prohibits modifying/replacing/removing an existing `Co-authored with AI:` line | `string` | grep for "MUST NOT" + "existing byline" near attribution section |
| SC-3 | Behavioral test: agent editing a file with an existing byline appends rather than replaces | `behavioral` | `opencode-cli run` → stderr assertion for no identity-overwrite pattern |
| SC-4 | Behavioral test: agent adding minor edit (typo fix) to a bylined file does NOT add a duplicate byline for itself | `behavioral` | `opencode-cli run` → stderr assertion for no double-bylining on minor edit |

## Affected File

- `.opencode/guidelines/080-code-standards.md` — Add "Preserve Existing Bylines" subsection
