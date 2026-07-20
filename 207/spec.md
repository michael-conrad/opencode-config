## Summary

Add a "Reporting Issues" section to `/AGENTS.md` (root repo, not `.opencode/AGENTS.md`) that documents the routing rule: bugs, missing features, improperly documented features, and documentation deficiencies detected in `.opencode/` tooling must be filed against the upstream `.opencode/` repository (`michael-conrad/.opencode`).

## Problem

`/AGENTS.md` currently tells the reader where agent configuration lives:

> All agent rules, guidelines, and skills are in the submodule — not here.

But it does **not** tell the reader what to do when something is wrong with that configuration. When an agent or developer encounters:

- A **bug** in an `.opencode/` tool (e.g., `local-issues` misbehaves, `guidelines` tool crashes, `resolve-models` produces wrong output)
- A **missing feature** in an `.opencode/` tool (e.g., the `gitbucket-api` client lacks a needed endpoint)
- An **improperly documented** or **undocumented** feature that causes first-invocation confusion
- A **documentation gap** in skills, guidelines, or tool READMEs that produces incorrect agent behavior

...there is currently no routing instruction in `/AGENTS.md` telling them to file the issue against `michael-conrad/.opencode` (the submodule repo). Issues get filed in the wrong repo, or not filed at all.

### Root Cause

The submodule relationship (`opencode-config/.opencode` → `michael-conrad/.opencode`) is transparent to git but opaque to issue routing. Newcomers to the project — including AI agents — see a file at `.opencode/guidelines/` and naturally file issues against `opencode-config` because that is the repo they're working in. There is nothing in `/AGENTS.md` that routes them to the correct upstream.

## Fix

Append a new section to `/AGENTS.md` (after the existing Reference Files table) titled `## Reporting Issues`. The section must document:

### Routing Table

| Problem Type | Examples | File Against |
|---|---|---|
| Bug in `.opencode/` tool | Tool crash, wrong output, unexpected behavior | `michael-conrad/.opencode` |
| Missing feature in `.opencode/` tool | Tool missing a needed command or flag | `michael-conrad/.opencode` |
| Documentation deficiency in `.opencode/` skill/guideline | Missing or wrong instructions causing agent confusion | `michael-conrad/.opencode` |
| Documentation gap in `.opencode/` tool | Tool has no README or usage docs for first-time use | `michael-conrad/.opencode` |
| Bug in `.opencode/.issues/` workflow | `.issues/` tooling misrouting, wrong issue state | `michael-conrad/.opencode` |
| Bug in root repo itself (`opencode-config`) | AGENTS.md is wrong, root repo config needs change | `michael-conrad/opencode-config` |

### Bug Report Content Requirements

Every bug report filed against `.opencode/` MUST include:

1. **Environment**: What tool/command was invoked, what agent model, what branch
2. **Expected behavior**: What should have happened
3. **Actual behavior**: What happened instead
4. **Reproduction steps**: Minimal steps to reproduce — the target audience is an AI agent or developer who needs to recreate the issue in a clean environment
5. **Evidence**: Tool output, error messages, log excerpts. For behavioral issues, include the exact prompt text that triggered the incorrect behavior
6. **Version context**: `.opencode/` submodule SHA or commit range (can be obtained via `git rev-parse HEAD:.opencode`)

### Documentation Deficiency Report Requirements

When reporting a documentation deficiency (missing docs, unclear instructions, wrong guidance):

1. **Affected file**: Exact file path within `.opencode/`
2. **What the documentation currently says** (or lacks): Quote the relevant section, or state "no documentation exists for X"
3. **What is missing or wrong**: Be verbose enough that the upstream can address it without back-and-forth. Describe:
   - What the reader needed to know
   - What they tried based on the existing docs
   - Where they got stuck
4. **What correct documentation should look like**: If known, include suggested wording. At minimum describe the gap in enough detail that a maintainer can fill it in one pass.
5. **Impact**: What broke or went wrong because the documentation was deficient

### First-Invocation Documentation Gap Pattern

A common pattern is first-invocation confusion: the tool/feature exists and works correctly, but the documentation does not cover the discovery or onboarding flow, so a first-time user (human or AI agent) cannot figure out how to use it correctly. When this pattern is detected, the reporter MUST:

1. File the bug against `.opencode/` (the tool's repo)
2. Include what they tried first (wrong approach based on incomplete docs)
3. Include what they expected to happen vs what happened
4. Flag it with `first-invocation` label if applicable

## Success Criteria

**SC-1 (behavioral):** After the change, an AI agent reading `/AGENTS.md` and encountering a bug in an `.opencode/` tool MUST route the bug report to `michael-conrad/.opencode`, not `michael-conrad/opencode-config`.

**SC-2 (string):** `/AGENTS.md` MUST contain an explicit `## Reporting Issues` section with a routing table mapping problem types to target repos.

**SC-3 (string):** The reporting section MUST specify the minimum required content for bug reports against `.opencode/`.

**SC-4 (behavioral):** After the change, when an agent encounters a first-invocation documentation gap in `.opencode/` tooling, the agent's default behavior MUST be to file a bug against `michael-conrad/.opencode` with sufficient documentation context for the upstream to resolve without back-and-forth.

## Affected File

- `/AGENTS.md` (root repo: `michael-conrad/opencode-config`, path: `AGENTS.md` — NOT `.opencode/AGENTS.md`)

## Not In Scope

- Updating `.opencode/AGENTS.md` (the submodule's own file)
- Changing the content of `.opencode/` tools, guidelines, or skills
- Modifying any behavioral enforcement tests
- Creating a bug-report template in the `.opencode/` repo
- Any implementation beyond adding the text section to `/AGENTS.md`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)