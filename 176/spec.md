## Intent

Add a "Reference Files" table to `AGENTS.md` (opencode-config parent repo) linking to the canonical agent documentation files in the `.opencode/` submodule. This helps agents and developers quickly locate the correct AGENTS.md without reading the wrong one.

## Background

When working in the opencode-config repo, agents and humans need to know which AGENTS.md to consult. The parent repo's AGENTS.md should serve as a directory — pointing to the submodule's canonical AGENTS.md, the `.issues/` workspace guide, and the local `.issues/` guide for the parent repo.

## Change

Add a section at the bottom of `/AGENTS.md` with a Reference Files table:

| File | Purpose |
|------|---------|
| `.opencode/AGENTS.md` | Canonical agent rules: build/lint/test commands, workflow, boundaries, pair mode, submodule discipline |
| `.opencode/.issues/AGENTS.md` | `.issues/` workspace guide: tool, workflow, directory layout, GitHub URL convention |
| `.issues/AGENTS.md` | Local `.issues/` workspace guide for the parent repo (mirrors `.opencode/.issues/AGENTS.md` pattern) |

## Status

DRAFT