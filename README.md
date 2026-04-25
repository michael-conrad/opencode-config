# opencode-config

Shared OpenCode configuration — skills, guidelines, plugins, and tools — maintained in a standalone repository to keep agent configuration separate from project codebases.

## Why This Exists

When OpenCode configuration lives inside a project repo as a submodule or nested directory, every config change requires coordinated commits across multiple repositories. Submodule dependencies create multi-level commit chains that make updates slow and error-prone.

This repository avoids that by pulling all OpenCode configuration into one independent space:

- **No submodule dependency chains** — changes here don't require parent-repo commits to take effect
- **No conflicts with project codebases** — each project can reference this config without embedding it
- **Single source of truth** — skills, guidelines, hooks, plugins, and tools evolve here first

## Structure

| Path | Contents |
|------|----------|
| `.opencode/skills/` | Self-contained skill definitions and task files |
| `.opencode/guidelines/` | Core rule documents (zero-tolerance mandates) |
| `.opencode/hooks/` | Git hooks auto-installed at session start |
| `.opencode/plugins/` | TypeScript plugins (session enforcement, env loading) |
| `.opencode/tools/` | Agent utility scripts |
| `.opencode/scripts/` | Session context scripts |
| `.opencode/tests/` | Enforcement tests (content-verification + behavioral) |
| `.opencode/AGENTS.md` | Coding agent guidelines and command reference |

## Usage

Clone this repository alongside your project directories. OpenCode reads configuration from `.opencode/` at the project root — symlink or copy the `.opencode/` directory into any project that should use this shared configuration.

```bash
# Option 1: Symlink (recommended — stays in sync)
ln -s /path/to/opencode-config/.opencode /path/to/your-project/.opencode

# Option 2: Copy (frozen snapshot)
cp -r /path/to/opencode-config/.opencode /path/to/your-project/.opencode
```

Symlinks are preferred because any update to this repository is immediately available in all linked projects without additional steps.