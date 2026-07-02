# Spec: Local-First Skill Fixes for spec-creation → writing-plans Pipeline

## Status: DRAFT

## Problem

Skills in the spec-creation → writing-plans → adversarial-audit pipeline treat the GitHub Issues API as the primary content store. They:

1. Create remote Issues without pre-checks for duplicates/superseding/cross-concerns
2. Push full spec/plan content into remote Issue bodies
3. Read spec content back from GitHub API instead of local `.issues/{N}/spec.md`
4. Gate completion on remote Issue existence instead of local file existence
5. Post plan phases as remote Issue tasks instead of keeping them local

This causes issue ticket churn (1000+ entries in `.issues/`), circular dependencies on remote Issue existence, and conflicts with the `issue-operations` local-first architecture already established in `body-edit.md` and `sync-pull-to-local.md`.

## Architecture

The `issue-operations` skill already has the correct model:

- `body-edit.md:10`: "Body editing IS remote synchronization... No valid remote state exists without a verified local source"
- `body-edit.md:249`: "Mirror protocol: remote.md is the sync source"
- `creation.md:273-297`: Creates remote Issue with blockquote pointing to `issues-data` branch, not full content

The fix extends this local-first pattern to `spec-creation`, `writing-plans`, and `adversarial-audit`.

## Storage Model

| Layer | Location | Contents |
|---|---|---|
| Primary (canonical) | `.issues/{N}/spec.md` | Full spec with STATUS markers |
| Primary (canonical) | `.issues/{N}/plan.md` | Full plan with phases |
| Primary (canonical) | `.issues/{N}/plan-{NN}-*.md` | Individual phase files |
| Sync layer | `.issues/{N}/remote.md` | Blockquote + URLs only |
| Branch sync | `issues-data` branch | Git commit/push/pull of `.issues/{N}/` |
| Remote Issue | GitHub/GitBucket body | Blockquote + title + exec summary, NOT full content |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | `spec-creation/tasks/write.md` performs pre-checks (search for duplicates, superseding, superseded, cross-concerns) before creating any remote Issue | `string` | grep for search/pre-check steps before `issue-operations --task creation` |
| SC-2 | `spec-creation/tasks/write.md` builds spec in local `.issues/{N}/spec.md` first, syncs second, updates remote third | `string` | grep for local-first ordering in write.md |
| SC-3 | `spec-creation/tasks/completion.md` gates on local `.issues/{N}/spec.md` existence, not remote Issue existence | `string` | grep for local file check replacing remote Issue check |
| SC-4 | `spec-creation/tasks/completion.md` does NOT push full spec content to remote Issue body | `string` | grep for absence of `issue-operations --task update-issue` with full body content |
| SC-5 | `writing-plans/tasks/create.md` reads spec from local `.issues/{N}/spec.md`, not GitHub API | `string` | grep for absence of `github_issue_read` for spec content |
| SC-6 | `writing-plans/tasks/update.md` reads revised spec from local `.issues/{N}/spec.md`, not GitHub API | `string` | grep for local file read replacing `github_issue_read` |
| SC-7 | `adversarial-audit/tasks/spec-audit.md` reads spec from local `.issues/{N}/spec.md` | `string` | grep for local file read replacing `github_issue_read` |
| SC-8 | `adversarial-audit/tasks/plan-fidelity.md` reads spec from local `.issues/{N}/spec.md` | `string` | grep for local file read replacing `github_issue_read` |
| SC-9 | `writing-plans/tasks/completion.md` uses local plan path as primary action URL | `string` | grep for local path in URL field |
| SC-10 | Pre-check searches remote for existing Issue with matching title/content before creation | `behavioral` | `opencode-cli run` → verify agent searches before creating |

## Affected Files

| File | Change |
|---|---|
| `spec-creation/tasks/write.md` | Add pre-check step before Step 0.8; reorder to local-first |
| `spec-creation/tasks/completion.md` | Gate on local files; remove full-body push |
| `writing-plans/tasks/create.md` | Replace `github_issue_read` with local file reads |
| `writing-plans/tasks/update.md` | Replace `github_issue_read` with local file reads |
| `writing-plans/tasks/completion.md` | Local path as primary URL |
| `adversarial-audit/tasks/spec-audit.md` | Replace `github_issue_read` with local file reads |
| `adversarial-audit/tasks/plan-fidelity.md` | Replace `github_issue_read` with local file reads |

## Pipeline Flows

### spec-creation flow (revised)

```
1. brainstorming → .issues/{N}/spec.md (local)
2. Pre-check: search remote for duplicates/superseding
3. local-issues sync (commit+push to issues-data branch)
4. issue-operations --task creation (remote Issue with blockquote only)
5. issue-operations --task update-issue (body = blockquote + title + exec summary)
```

### writing-plans flow (revised)

```
1. Read spec from .issues/{N}/spec.md (local)
2. Build plan in .issues/{N}/plan.md (local)
3. local-issues sync (commit+push to issues-data branch)
4. Remote Issue URL reported but not required for completion
```

### adversarial-audit flow (revised)

```
1. Read spec from .issues/{N}/spec.md (local)
2. Audit against local content
3. Report findings to chat
```

## Non-Goals

- Renaming existing `.issues/` entries (future cleanup, not part of this spec)
- Changing `local-issues` CLI tool (already correct)
- Changing `issue-operations` core skill (already correct)

## References

- `issue-operations/tasks/body-edit.md` — correct architecture reference
- `issue-operations/tasks/sync-pull-to-local.md` — correct sync pattern
- `issue-operations/tasks/creation.md` — correct remote Issue creation pattern
- `130-authority-source.md` — superseding issue check mandate
- `spec-creation/tasks/write.md:28` — Step 0.8 (current, needs fix)
- `writing-plans/tasks/update.md:29` — reads spec from GitHub API (current, needs fix)
