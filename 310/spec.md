## Problem

The `opencode.jsonc` MCP configuration pins viewport-editor at `v0.3.4`. The project has released `v0.4.0` (Jul 17, 2026) with two significant behavioral changes that affect how agents interact with the editor:

1. **Default autosave changed from `False` to `True`** — viewports now auto-save by default, changing the editing workflow from buffered (stage-review-save) to immediate (auto-flush on every edit).
2. **Auto-reload on external file change when buffer is clean** — `read_file` on a viewport whose underlying file was modified externally now auto-reloads the buffer instead of returning stale content.

The AGENTS.md documentation must be updated to reflect these behavioral changes so agents use the correct workflow.

## Scope

Changes to `opencode.jsonc` (version pin) and `.opencode/AGENTS.md` (editor MCP plugin section). No source code changes — this is a consuming-repo config update.

## Affected Files

| File | What Changes |
|------|-------------|
| `.opencode/opencode.jsonc` | Version pin: `@v0.3.4` → `@v0.4.0` |
| `.opencode/AGENTS.md` | Editor MCP plugin section: update recommended agent behavior for autosave default |

## Changes

### 1. `opencode.jsonc` — Version pin (line 133)

```
// Before
"command": ["uvx", "--from", "git+https://github.com/michael-conrad/viewport-editor@v0.3.4", "viewport-editor"],

// After
"command": ["uvx", "--from", "git+https://github.com/michael-conrad/viewport-editor@v0.4.0", "viewport-editor"],
```

### 2. `.opencode/AGENTS.md` — Editor MCP plugin section

The current recommended agent behavior (lines 370-376) was written for v0.3.4 where autosave defaulted to `False`. With v0.4.0's autosave default of `True`, the recommended behavior changes:

**Current text (lines 370-376):**
```
**Recommended agent behavior:**

- Use `read_file`, `write_file`, `edit_text`, `find_text` for single-call operations
- Use `viewport` + `edit` + `file` for multi-step editing with diff review
- Always call `diff:show` before `file:save` to verify staged changes
- File paths are relative to project root (MCP resolver defaults to `os.getcwd()`)
- Conflict detection: server tracks file mtime+size externally; stale-file soft warning on reads, hard block on `file:save` (use `force: true` override if change is intentional)
```

**Updated text:**
```
**Recommended agent behavior:**

- Use `read_file`, `write_file`, `edit_text`, `find_text` for single-call operations (empirically validated — see viewport-editor#63 V1 results)
- Use `viewport` + `edit` + `file` for multi-step editing with diff review
- Always call `diff:show` before `file:save` to verify staged changes
- File paths are relative to project root (MCP resolver defaults to `os.getcwd()`)
- Session management is automatic (MCP framework handles session IDs)
- Conflict detection: server tracks file mtime+size externally; stale-file soft warning on reads, hard block on `file:save` (use `force: true` override if change is intentional)
```

**Key changes:**
- Removed the autosave-default caveat (no longer needed — autosave is now `True` by default, which is the expected behavior for composite tools)
- Added reference to empirical validation from viewport-editor#63
- Added session management note

### What Does NOT Change

- The `editor` plugin key name (already renamed in v0.3.4)
- Any other MCP server configurations
- Any guideline files, skill files, or other agent configuration
- The `uvx` invocation pattern

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `opencode.jsonc` version pin is `@v0.4.0` | `string` | `grep` for `@v0.3.4` in `opencode.jsonc` returns 0 matches |
| SC-2 | `opencode.jsonc` version pin is `@v0.4.0` | `string` | `grep` for `@v0.4.0` in `opencode.jsonc` returns 1 match |
| SC-3 | AGENTS.md editor section includes empirical validation reference | `string` | `grep` for `viewport-editor#63` in `AGENTS.md` returns 1 match |
| SC-4 | AGENTS.md editor section includes session management note | `string` | `grep` for `session management` in `AGENTS.md` returns 1 match |
| SC-5 | AGENTS.md editor section does NOT contain stale autosave-default caveat | `string` | `grep` for `autosave` in `AGENTS.md` returns 0 matches |
| SC-6 | `uvx` invocation pattern is preserved (no change to `--from` structure) | `string` | `grep` for `uvx.*--from.*viewport-editor` in `opencode.jsonc` returns 1 match |
| SC-7 | Agent correctly uses autosave=True workflow after upgrade | `behavioral` | `opencode run` with edit task → verify agent does NOT call `viewport:autosave` to enable autosave (it's on by default) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Autosave=True changes agent editing behavior unexpectedly | Medium | Medium | AGENTS.md updated with correct recommended behavior; SC-7 behavioral test verifies agent adapts |
| Version pin typo (v0.4.0 vs v0.4) | Low | Low | SC-1/SC-2 grep verification catches exact string |
| AGENTS.md stale reference missed | Low | Low | SC-3/SC-4/SC-5 grep verification covers all changes |
| `uvx` fails to resolve `@v0.4.0` (tag not yet pushed) | Low | High | Verify tag exists on GitHub before merging PR |

## Change Control

| Date | Change |
|------|--------|
| 2026-07-17 | Initial spec |
| 2026-07-17 | Removed VIEWPORT_PROJECT_ROOT env var (will be handled in separate session) |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
