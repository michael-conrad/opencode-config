# [SPEC] Phase-Checkpoint Git Tags for Multi-Phase Plan Rollback Anchors (parent repo)

**STATUS: 1.1 (REVISED — NEEDS APPROVAL)**

## Summary

Add git-tag-based checkpoint anchors to the Progressive Iterative Implementation workflow. When a multi-phase plan completes a phase group, the orchestrator commits all artifacts and creates a `<github.repo>/checkpoint/<branch-slug>/phase-<N>` tag. On verification failure in a subsequent phase, rollback uses `git reset --hard <tag> + git submodule update + git checkout dev` to restore the last known-good state. Tags are pushed to remote per existing discipline and cleaned up during `git-workflow --task cleanup`.

Submodule implementation: https://github.com/michael-conrad/.opencode/issues/391

## Motivation

`020-go-prohibitions.md` §Progressive Iterative Implementation mandates commit-anchored inter-phase gates with VbC + dual-auditor verification. The current mandate requires checkpoints but does not specify the rollback mechanism. Without explicit rollback anchors, a poisoned phase cannot be cleanly undone. Git tags provide lightweight, non-branch-polluting checkpoints that support rollback without creating per-phase branches.

## Fix Approach (parent repo changes only)

### 1. Tag Naming Convention (documented in AGENTS.md)

Use `<github.repo>/checkpoint/<branch-slug>/phase-<N>` — staying within the existing `<parent-repo>/` namespace per AGENTS.md §Tag Layers.

| Tag Type | Pattern | Example |
|----------|---------|---------|
| Release | `<parent-repo>/v<N.N.N>` | `opencode-config/v0.1.1` |
| Hash permanence | `<parent-repo>/<issue-number>` | `opencode-config/221` |
| Checkpoint | `<github.repo>/checkpoint/<branch-slug>/phase-<N>` | `opencode-config/checkpoint/scope-243/phase-1` |

### 2. Work State File Location — `.issues/workflow/`

Work state files consolidate from `./tmp/` and `.opencode/tmp/` (both .gitignored) to `.issues/workflow/work-<timestamp>.md` (git-tracked by default, no `.gitignore` manipulation needed). Separate from submodule's `.opencode/.issues/`.

### 3. Rollback Procedure (documented in AGENTS.md)

```
git reset --hard <checkpoint-tag>
git submodule update
cd .opencode && git checkout dev
cd ..
```

## Success Criteria

- [ ] SC1: `AGENTS.md` Tag Layers extended with checkpoint tag row
- [ ] SC2: `.issues/workflow/` directory created with README documenting purpose
- [ ] SC3: `.issues/workflow/` committed to feature branch; work state migration documented

## Files Affected

| File | Change |
|------|--------|
| `AGENTS.md` | Add checkpoint tag row to Tag Layers |
| `.issues/workflow/` | New directory for orchestration work state files |

Submodule files: see https://github.com/michael-conrad/.opencode/issues/391

## Revision Notes

- 1.0: Initial spec — 2026-05-04
- 1.1: Revised — stripped `.opencode/` file references (belong to #391); corrected to parent-only scope; added placeholder pattern for tag naming

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
