# Card 009: Directory Naming Convention Normalization

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** 5 different naming patterns across task files introduced during successive edits

## The Canonical Form

```
{number:03d}-{slug}
```

Where:
- `number` = issue number (integer)
- `N:03d` = zero-padded to minimum 3 digits (001, 042, 123, etc.)
- `slug` = first 5 words of title, kebab-cased, lowercased

Examples:
- `001-test-issue`
- `042-full-spec-redesign-proposal`
- `123-fix-crash-in-parser-logic`

## Current Inconsistencies

| Pattern | File:Line | Problem |
|---------|-----------|---------|
| `<remote_number>-<slug>` | `creation.md:154`, `import-remote.md:16,17` | No `:03d` — risk of `42-slug` for remote numbers < 100 |
| `<number>-<slug>` | `sync-pull-to-local.md:15` | No zero-padding |
| `N-slug` | `body-edit.md:68` | 1-digit notation |
| Bare number (no slug) | Fixtures `932/`, `956/`, `972/` | `_find_issue` won't match |
| No `:03d` | `creation.md:154` (same file, different line) | Contradicts `_issue_dir_name()` |

## Fixes Required

| File | Fix |
|------|-----|
| `creation.md:154` | `<remote_number>-<slug>` → `<remote_number:03d>-<slug>` |
| `creation.md:155` | `<remote_number>-<slug>` → `<remote_number:03d>-<slug>` |
| `import-remote.md:16-17` | `<remote_number>-<slug>` → `<remote_number:03d>-<slug>` (match line 96) |
| `import-remote.md:120` | Same |
| `sync-pull-to-local.md:15` | `<number>-<slug>` → `<NNN>-<slug>` |
| `body-edit.md:68` | `N-slug` → `NNN-slug` |
| Fixtures `932/`, `956/`, `972/` | Add slug: `932-topic-slug/`, etc. |

## Enforcement

- `_issue_dir_name()` in the tool already enforces `{number:03d}-{slug}` — no code change needed
- Task files must document the convention consistently
- A `string` enforcement test SHOULD verify all task files use `:03d` or `NNN` notation