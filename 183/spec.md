## Problem

When `local-issues` encounters a bare number on a mutation command (`update`, `close`, `delete`, `promote`) or a non-existent repo qualifier, it prints a terse error message with no indication of what valid qualifiers exist:

```
Error: Use qualified form {repo}#{N} for mutations.
Error: repo 'foo' not found.
```

The user (human or AI agent) is left guessing what repo names are available. The tool already has `_discover_repos()` which enumerates all child repos — the error sites just don't use it.

## Design

Add a `_print_available_repos()` helper that prints the current repo + all discovered child repos with their qualifier name (what goes before `#N`) and filesystem path. Call it at each error site before `sys.exit(1)`.

### Helper function

```python
def _print_available_repos() -> None:
    """Print current repo and all discovered child repos with qualifiers and paths."""
    current = Path(os.getcwd()).resolve()
    current_name = _resolve_repo_name()
    repos = _discover_repos()
    max_name_len = max(len(current_name), *[len(r.name) for r in repos])
    print("Available qualifiers (use name#N format):", file=sys.stderr)
    print(f"  {current_name:<{max_name_len}}     {current}", file=sys.stderr)
    for child in repos:
        print(f"  {child.name:<{max_name_len}}     {child}", file=sys.stderr)
```

### Error sites to wire into

| Site | Function | Line | Current Error | Add `_print_available_repos()` |
|------|----------|------|---------------|--------------------------------|
| Bare number mutation | `_require_qualified()` | 667 | `Error: Use qualified form {repo}#{N} for mutations.` | After error, before `sys.exit(1)` |
| Repo not found (via ensure) | `_ensure_repo()` | 692 | `Error: repo '{repo_name}' not found.` | After error, before `sys.exit(1)` |
| Repo not found (via resolve) | `_resolve_qualified()` | 715 | `error: repo '{repo_name_val}' not found` | After error, before `sys.exit(1)` |

The `cmd_create` collision site (line 616) already names the valid qualifier inline (`Use qualified form {child.name}#{N}.`) — it does not need the full listing for that path specifically, but adding it for consistency would be acceptable.

### Example output

```
Error: Use qualified form {repo}#{N} for mutations.
Available qualifiers (use name#N format):
  opencode-config     /home/user/git/opencode-config
  .opencode           /home/user/git/opencode-config/.opencode
```

### No change to exit codes

All three sites already exit with code 1. No exit code changes.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/tools/local-issues` | Add `_print_available_repos()` helper; wire into `_require_qualified()`, `_ensure_repo()`, `_resolve_qualified()` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues update` with bare number prints error + repo listing to stderr | `string` | `local-issues update --number 1 --status closed 2>&1` → output contains both error message and "Available qualifiers" section |
| SC-2 | `local-issues update` with non-existent repo qualifier prints error + repo listing to stderr | `string` | `local-issues update --number nonexistent#1 --status closed 2>&1` → output contains repo not found + "Available qualifiers" section |
| SC-3 | `local-issues close` (same for delete, promote) with bare number prints repo listing | `string` | Same pattern as SC-1 for each mutation command |
| SC-4 | `local-issues close` with non-existent qualifier prints repo listing | `string` | Same pattern as SC-2 for each mutation command |
| SC-5 | `local-issues read` with non-existent qualifier prints repo listing | `string` | `local-issues read --number nonexistent#1 2>&1` → "Available qualifiers" section and exit code 1 |
| SC-6 | Exit code is 1 in all error cases (unchanged) | `behavioral` | `local-issues update --number 1 --status closed; echo $?` → exit code 1 |

## Implementation Notes

- `_discover_repos()` is already called in other code paths — no new dependency
- Column alignment uses `max(len(r.name) for r in repos)` for tidy formatting
- Output goes to stderr (`file=sys.stderr`) — consistent with existing error messages
- The `_print_available_repos()` helper can be called from any error site that needs to show available repos

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)