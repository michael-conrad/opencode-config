---
title: "Spec: Playwright CLI as First-Class Browser Automation Entry Point"
status: approved-for-implementation
phase: plan
labels: spec, browser-automation
author: michael-conrad
created_at: 2026-06-20T17:17:11Z
updated_at: 2026-06-21T14:00:00Z
---

# Spec: Playwright CLI as First-Class Browser Automation Entry Point

> **Full spec and artifacts:** [`.issues/1314/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1314/) — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1314/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

The repo has two browser automation skills (`ui-design`, `ui-engineer`) built around custom Python Playwright scripts. These scripts are unmaintained, tightly coupled to a Python-only workflow, and diverge from the upstream toolchain. `ui-engineer` references `ui-design` scripts via relative paths and has no standalone purpose after `ui-design` is deleted.

## Root Cause / Motivation

The original browser automation skills were built when `@playwright/cli` did not exist as a first-class npm package. The custom Python wrapper added complexity without providing value over the upstream CLI's native capabilities (session management, headless execution, config). Maintaining two parallel implementations (Python wrapper + upstream CLI) creates technical debt and confusion about which tool to use.

## Approach Chosen

Replace the Python Playwright workflow with `@playwright/cli` from `microsoft/playwright-cli`. Delete both existing skills entirely. Create a new `playwright-cli` skill by adapting the upstream's own skill cards — adding YAML frontmatter, dispatch tables, and provenance attribution while preserving the original content structure. Install `@playwright/cli` lazily via `npx` into `.tools/` on first use.

## Alternatives Considered & Why Discarded

| Alternative | Why Discarded |
|-------------|---------------|
| Keep existing Python scripts + update them | Still requires Python dependency; does not align with upstream toolchain; adds maintenance burden for no functional benefit over the native CLI |
| Fork `microsoft/playwright-cli` and customize it | Creates a separate codebase to maintain; diverges from upstream; unnecessary when the upstream skill cards already cover our needs with minor adaptation |
| Use a different browser automation library (e.g., Cypress, Playwright test framework) | Changes scope beyond what is needed; the existing skills target Playwright APIs specifically |

## Key Design Decisions

- **Package is `@playwright/cli` from `microsoft/playwright-cli`** — NOT `@anthropics/playwright-cli`. Verified by searching GitHub for the package.
- **Both `ui-design` and `ui-engineer` deleted** — `ui-engineer` references deleted `ui-design` scripts via relative paths; no standalone purpose after purge.
- **Lazy install only** — Agent detects need, installs to `.tools/`, then invokes. No eager install on session start or skill load.
- **Browser cache isolated under `.tools/*/.cache`** — `rm -rf .tools/` removes everything.
- **Upstream adaptation, not copy-paste** — Skill cards adapted to `.opencode/` format with provenance attribution (Apache-2.0).

## Scope

### In scope

1. Delete `ui-design` and `ui-engineer` skills entirely
2. Create `playwright-cli` skill adapted from upstream skill cards
3. Remove all references to deleted skills from guidelines, tests, registry
4. Add `.tools/` to `.gitignore` for lazy install target

### Out of scope

- Modifying upstream `microsoft/playwright-cli` repository
- Changing parent project's Playwright usage
- Creating browser automation workflows (deferred to implementation)

## Success Criteria

| SC ID | Criterion | Evidence Type | Verification Command |
|-------|-----------|---------------|---------------------|
| SC-1 | Both `ui-design` and `ui-engineer` skill directories are deleted; all references removed from guidelines, README, test-enforcement.sh, and skill registry | behavioral + structural + string | `test -d skills/ui-design && echo exists || echo absent` → must output exactly `absent`; same for `skills/ui-engineer/`. `grep -r "ui-design\|ui-engineer" .opencode/guidelines/000-critical-rules.md .opencode/README.md tests/test-enforcement.sh 2>/dev/null; echo $?` → must output exactly `1` (no matches) |
| SC-2 | New `playwright-cli` skill exists with valid YAML frontmatter, dispatch tables, and provenance attribution from upstream cards | behavioral | `grep -c "name:\|description:\|Triggers on:\|provenance:" skills/playwright-cli/SKILL.md` → must output exactly `4`; `test -d skills/playwright-cli/references/ && echo exists || echo absent` → must output exactly `exists`; semantic inspector validates SKILL.md structure matches `.opencode/` skill format |
| SC-3 | All references to deleted skills removed from `000-critical-rules.md`, `README.md`, `tests/test-enforcement.sh`, and `skill-registry-v2-skills.json` | string (grep) | `grep -r "ui-design\|ui-engineer" .opencode/guidelines/000-critical-rules.md .opencode/README.md tests/test-enforcement.sh .opencode/skills/.git 2>/dev/null; echo $?` → must output exactly `1` (no matches) |
| SC-4 | `.tools/` entry added to `.gitignore`; lazy install target works via `npx @playwright/cli` | behavioral (elevated from structural) | `grep -c "^\.tools/" .gitignore` → must output exactly `1`; `cat .gitignore \| head -n -1 > /tmp/gitignore-check && diff .gitignore /tmp/gitignore-check; echo $?` → must output exactly `0` (no trailing blank lines added) |
| SC-5 | Zero residual Python Playwright references, zero deleted-skill references, both directories absent, new skill exists with correct content | behavioral + structural + string | `grep -r "from playwright" --include="*.py" .opencode/ 2>/dev/null; echo $?` → must output exactly `1`; `test -d skills/ui-design && echo exists \|\| echo absent` → must output exactly `absent`; `test -f skills/playwright-cli/SKILL.md && grep -c "name:" skills/playwright-cli/SKILL.md` → must output at least `1` |

## Edge Cases and Risks

1. **Upstream skill cards are monolithic** — Single SKILL.md + 10 reference files. Adaptation requires adding YAML frontmatter and dispatch tables without breaking content. Mitigation: preserve original structure, add metadata layer.
2. **Lazy install may fail on constrained environments** — `@playwright/cli` download requires internet access. Mitigation: graceful fallback with clear error message.
3. **Enforcement tests reference deleted skills** — `tests/test-enforcement.sh` has `ui-engineer-red-gate` scenario. Mitigation: remove scenario in Step 3.

## Dependencies

- `@playwright/cli` npm package availability (public, no access issues)
- Upstream `microsoft/playwright-cli` repository stability

## Affected Files

| File | Action | Phase |
|------|--------|-------|
| `skills/ui-design/SKILL.md` | Delete directory | 1 |
| `skills/ui-engineer/SKILL.md` | Delete directory | 1 |
| `.opencode/skills/playwright-cli/` (new) | Create with SKILL.md + references/ | 2 |
| `.opencode/guidelines/000-critical-rules.md` | Remove trigger entries for ui-design, ui-engineer | 3 |
| `.opencode/README.md` | Remove rows from skill table | 3 |
| `tests/test-enforcement.sh` | Remove `ui-engineer-red-gate` scenario | 3 |
| `.opencode/skills/.git/skill-registry-v2-skills.json` | Add playwright-cli entry; remove ui-design, ui-engineer entries | 3 |
| `.gitignore` | Append `.tools/` entry | 4 |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at [`.issues/1314/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1314/).
After creation, `local-issues sync 1314` MUST be run and the result committed to create the local `.issues/1314/` entry.
The implementation plan will be created in `.issues/1314/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.
