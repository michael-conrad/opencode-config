# Spec: #9907 — Remove the deprecated .junie integration notes

## Summary

The README carries an integration-notes section describing the legacy
`.junie/` folder, which the project no longer supports. The notes mislead
new contributors.

## Requirements

- **R-1** — The README's integration-notes section for `.junie/` is removed.
- **R-2** — The README references only supported integration folders.
- **R-3** — The `.junie/` corpus files themselves (`docs/junie-notes/`)
  are deleted from the repository.

## Success criteria

### SC-1 (structural)

`README.md` contains no reference to `.junie/` or the legacy integration
notes.

- **Verify:** grep for `.junie` in `README.md` returns no match.