# SPEC: session-init — Local Issue Artifacts Format and Section Reorganization

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The session-init tool at `.opencode/tools/session-init` emits a `## Local Issue Artifacts` section with structured YAML-like fields (`path`, `issues`, `setup`). This format has three problems:

1. **Verbose and redundant**: Each entry takes 2-3 lines for information that could fit on one line. The `path` field duplicates information already present in the `## Repo Information` block — agents can cross-reference by path prefix.
2. **Worktree nature not explicit**: The section name "Artifacts" doesn't convey that `.issues/` directories are git worktrees (orphan branch worktrees). Agents need to know they should use `git -C` commands, not direct file operations.
3. **Section ordering suboptimal**: `## CLI Auth Status` (most actionable — can the agent push?) appears after `## Repo Information`, and `## Local Issue Artifacts` appears last. The most actionable sections should come first.

## Root Cause Analysis

The `collect_issue_artifact_paths()` function (lines 650-681) was designed to emit structured data for programmatic parsing. However, the primary consumer is an AI agent reading stdout as system context — structured YAML fields add verbosity without benefit. The `path` field was included for self-description but is derivable from the `## Repo Information` block's `path` entries.

The section ordering in `main()` (lines 705-784) evolved organically without considering agent workflow priority: CLI auth status (can I push?) is the first question an agent should answer, followed by local issue folders (where do I write?), followed by repo routing (which API do I call?).

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Keep current format, just rename section | Doesn't solve verbosity or redundancy problems |
| Remove section entirely | Agents need to know which `.issues/` directories exist and how to access them |
| Use JSON format | More verbose than current YAML-like format; harder for agents to parse in context |
| Add `git -C` as an additional field alongside existing fields | Compounds verbosity instead of reducing it |

## Scope

### In Scope

- Rename `## Local Issue Artifacts` to `## Local Issue Folders`
- Change output format from structured YAML-like fields to inline `git -C` commands
- Reorder sections in `main()`: `## CLI Auth Status` first, `## Local Issue Folders` second, `## Repo Information` third
- Remove the `path` field from each entry (derivable from `## Repo Information`)
- Update the `collect_issue_artifact_paths()` function signature and return type
- Update the emission code in `main()` (lines 770-777)
- Update the module docstring (line 17) to reflect the new section name

### Out of Scope

- Changing the `## Repo Information` section format
- Changing the `## CLI Auth Status` section format
- Adding or removing any other sections
- Changing the `## Agent Tools` section
- Modifying any other tool or file outside `.opencode/tools/session-init`

## Affected File

- `.opencode/tools/session-init`

### Specific Code Locations

| Location | Lines | Change |
|----------|-------|--------|
| Module docstring | 17 | Update "Local Issue Artifacts" → "Local Issue Folders" |
| `collect_issue_artifact_paths()` | 650-681 | Change return format from dict with `path`/`issues`/`setup` keys to inline `git -C` command strings |
| `main()` emission code | 770-777 | Update section header and output format |
| `main()` section ordering | 749-777 | Reorder: CLI Auth Status first, Local Issue Folders second, Repo Information third |

## Proposed Output Format

Current:
```
## Local Issue Artifacts
- path: .
  issues: .issues/
- path: .opencode
  issues: .opencode/.issues/
```

Proposed:
```
## Local Issue Folders
- .issues/: git -C .issues/
- .opencode/.issues/: git -C .opencode/.issues/
```

When a `.issues/` directory is missing (needs setup), include a setup comment:
```
## Local Issue Folders
- .issues/: git -C .issues/
- .opencode/.issues/: git -C .opencode/.issues/  # setup: create worktree from orphaned branch issues-data in repo .opencode
```

## Proposed Section Order

Current order in `main()`:
1. `## Repo Information` (line 749)
2. `## CLI Auth Status` (line 762)
3. `project_root` (line 768)
4. `## Local Issue Artifacts` (line 770)
5. `## Agent Tools` (line 781)

Proposed order:
1. `## CLI Auth Status` (first — most actionable)
2. `## Local Issue Folders` (second — where to write)
3. `## Repo Information` (third — API routing)
4. `project_root` (unchanged position relative to sections)
5. `## Agent Tools` (unchanged)

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Section header renamed from `## Local Issue Artifacts` to `## Local Issue Folders` | `grep -q "## Local Issue Folders" .opencode/tools/session-init` | Update the print statement in `main()` | pre-commit | `.issues/282/` | Section name change | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | Output format changed from structured YAML fields to inline `git -C` commands | Run `uv run .opencode/tools/session-init` and verify output matches `- .issues/: git -C .issues/` pattern | Update `collect_issue_artifact_paths()` return format and `main()` emission code | pre-commit | `.issues/282/` | Output format change | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `path` field removed from each entry | Run `uv run .opencode/tools/session-init` and verify no line starts with `  path:` | Remove `path` key from `collect_issue_artifact_paths()` return dicts | pre-commit | `.issues/282/` | Redundancy removal | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | Section ordering: CLI Auth Status first, Local Issue Folders second, Repo Information third | Run `uv run .opencode/tools/session-init` and verify section order via grep of `## ` headers | Reorder print blocks in `main()` | pre-commit | `.issues/282/` | Section reordering | Phase 2 | pre-commit | standalone | — | — | — | Phase 2 |
| SC-5 | Module docstring updated to reflect new section name | `grep -q "Local Issue Folders" .opencode/tools/session-init` (line 17) | Update docstring text | pre-commit | `.issues/282/` | Documentation accuracy | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-6 | Missing `.issues/` directories include setup comment in inline format | Run `uv run .opencode/tools/session-init` in a context where `.opencode/.issues/` is missing and verify `# setup:` comment appears | Update `collect_issue_artifact_paths()` to emit setup comments | pre-commit | `.issues/282/` | Edge case coverage | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-7 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | Behavioral test via `opencode-cli run` with stderr assertion for SC-lobotomy prohibition | Reject any PR that weakens SC evidence types | post-implementation | `.issues/282/` | Anti-lobotomization | Phase 2 | post-implementation | standalone | — | — | — | Phase 2 |
| SC-8 | Before any implementation, write unit or integration tests that verify the changed behavior; confirm RED state (test fails before change) | Verify test file exists in `.opencode/tests/` with assertion that fails before change | Create test file with RED assertion before any source changes | pre-commit | `.issues/282/` | TDD mandate | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |

## Edge Cases

1. **No `.issues/` directories exist**: The function should still emit entries with setup comments for each repo path.
2. **Submodule repos with `.issues/` worktrees**: The `.issues` path entries (`.issues`, `.opencode/.issues`) are already skipped by the function — verify this behavior is preserved.
3. **Downstream consumers parsing current format**: Search the codebase for any tool or script that parses the `## Local Issue Artifacts` section. If found, update those consumers in a separate change.

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Downstream consumers parse current structured format | Low | Medium | Search codebase for consumers before changing format |
| Setup comment format breaks agent parsing | Low | Low | Use standard `#` comment prefix — agents understand comments |
| Section reordering confuses agents expecting old order | Medium | Low | Agents read sections by header, not position — reordering is safe |

## Interdependency

No interdependencies identified. This is a standalone spec.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read` on `.opencode/tools/session-init` | Verify function locations, line numbers, current output format |
| Direct source search | `grep -r "Local Issue Artifacts" .opencode/` | Check for downstream consumers of the section name |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Inline `git -C` commands over structured YAML | Makes worktree nature explicit; agents can copy-paste | MUST | SC-2 |
| DEC-2 | Remove `path` field | Derivable from `## Repo Information` block | MUST | SC-3 |
| DEC-3 | CLI Auth Status first in section order | Most actionable info for agent | MUST | SC-4 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |

After this spec is approved, invoke `writing-plans` to create `.issues/282/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
