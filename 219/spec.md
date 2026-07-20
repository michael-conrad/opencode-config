## Problem

The `glob` tool is defective — it does not work correctly with submodules, causing failed implementations and broken workflows. Despite this, the skill deck contains extensive instructions telling sub-agents to use the `glob` tool, and the submodule operation sub-agent cards do not explicitly deny it.

## Scope

This fix covers two concerns:

1. **Sub-agent card permissions**: Ensure all sub-agent cards deny the `glob` tool
2. **Skill deck references**: Replace all instructions that tell sub-agents to use the `glob` tool with working alternatives

## Investigation Summary

### Sub-agent Cards

| Card | Format | `glob` Permission | Status |
|------|--------|-------------------|--------|
| `auditor-deepseek-flash.md` | YAML frontmatter | `glob: deny` | ✅ Already correct |
| `auditor-gemma4.md` | YAML frontmatter | `glob: deny` | ✅ Already correct |
| `auditor-mistral-large.md` | YAML frontmatter | `glob: deny` | ✅ Already correct |
| `auditor-qwen3.5.md` | YAML frontmatter | `glob: deny` | ✅ Already correct |
| `submodule-dev-restore.jsonc` | JSONC `tools` array | `["bash", "github_*"]` | ⚠️ `glob` not in allowlist, but not explicitly denied |
| `submodule-feature-push.jsonc` | JSONC `tools` array | `["bash", "github_*"]` | ⚠️ Same |
| `submodule-liveness-check.jsonc` | JSONC `tools` array | `["bash", "github_*"]` | ⚠️ Same |
| `submodule-tag-prework.jsonc` | JSONC `tools` array | `["bash", "github_*"]` | ⚠️ Same |

The JSONC format uses a `tools` allowlist — tools not listed are implicitly denied. However, the `general` sub-agent type (used by `task(subagent_type="general")`) is not defined in `.opencode/agents/` and may have different permission defaults. The spec must verify whether `general` sub-agents have `glob` access and ensure it is denied.

### Skill Deck `glob` References (Requiring Changes)

**Category A: Tool Invocation Instructions** — these tell sub-agents to USE the `glob` tool and MUST be replaced:

| Area | Files | Count | Replacement |
|------|-------|-------|-------------|
| Adversarial audit tasks | `spec-audit.md`, `verification-audit.md`, `cross-validate.md`, `concern-separation.md`, `drift-detection.md`, `guideline-audit.md`, `spec-summary.md`, `closure-verification.md`, `plan-fidelity.md`, `coherence-extraction.md`, `coherence-maintenance.md` | 11 files | Replace `glob` with `read` (directory listing) for discovering `.md` files in `spec_local_dir` |
| Approval gate tasks | `spec-to-plan-cascade.md`, `reconcile-issue-graph.md`, `verify-already-implemented.md`, `verify-codebase.md`, `build-dependency-graph.md`, `screen-issue-gate2.md` | 6 files | Replace `glob` with `read` or `bash ls` for file discovery |
| Verification-before-completion tasks | `verify.md`, `collect.md`, `completion.md` | 3 files | Replace `glob` with `read` for artifact discovery |
| SRE runbook tasks | `generate.md` | 1 file | Replace `glob` with `read` or `bash find` |
| Pre-analysis tasks | `analyze.md` | 1 file | Replace `glob` with `read` for directory enumeration |
| Completeness gate tasks | `check.md` | 1 file | Replace `glob` with `read` for file verification |
| Spec creation tasks | `traceability.md`, `write.md` | 2 files | Replace `glob` with `read` or `srclight` |
| Issue operations tasks | `pre-creation.md` | 1 file | Replace `glob` with `read` |
| Implementation pipeline tasks | `pipeline-executor.md` | 1 file | Replace `glob` with `read` for artifact discovery |
| Writing plans tasks | `clean-room.md` | 1 file | Replace `glob` with `read` |
| Agent cards (auditor instructions) | `auditor-*.md` (4 files) | 4 files | Replace `glob` instructions with `read` (directory listing) |
| Guidelines | `020-go-prohibitions.md`, `016-srclight-preference.md` | 2 files | Replace `glob` instructions with `read` or `srclight` |

**Category B: Tool References** — these list `glob` as an available tool in tables and references. These should be updated to remove `glob` from the tool lists:

| Area | Files | Count |
|------|-------|-------|
| Guidelines | `060-tool-usage.md`, `016-srclight-preference.md`, `065-verification-honesty.md`, `115-branch-naming.md` | 4 files |
| Skills | `mcp-tool-usage/SKILL.md`, `using-git-worktrees/tasks/tool-usage.md`, `git-workflow/tasks/implementation.md`, `git-workflow/tasks/pr-creation/squash-push.md`, `git-workflow/tasks/review-prep/push-and-cleanup.md`, `finishing-a-development-branch/tasks/prepare.md` | 6 files |
| Plugins | `session-enforcement.ts` | 1 file |
| Prompts | `default.txt` | 1 file |

**Category C: Behavioral Tests** — these assert `glob` appears in agent output patterns and need updating:

| File | Lines |
|------|-------|
| `tests/behaviors/pre-analysis-autonomous-discover-full-scope.sh` | 29 |
| `tests/behaviors/pre-analysis-verification-deep-dive-report.sh` | 29 |
| `tests/behaviors/post-flight-no-cached-claims.sh` | 31 |
| `tests/enforcement/agents-content/test-all-auditor-agents.sh` | 29 (ALLOW_KEYS includes `glob`) |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All sub-agent cards have `glob` explicitly denied in their permission configuration | `string` | grep for `glob: deny` in all `.opencode/agents/*.md` files; verify JSONC cards don't include `glob` in `tools` array |
| SC-2 | No skill task file instructs a sub-agent to use the `glob` tool | `string` | grep for tool-invocation patterns (`glob \`**`, `glob(pattern=`, `via \`glob\``) in `.opencode/skills/` — zero matches |
| SC-3 | No guideline file instructs a sub-agent to use the `glob` tool | `string` | grep for tool-invocation patterns in `.opencode/guidelines/` — zero matches |
| SC-4 | No agent card instructs a sub-agent to use the `glob` tool | `string` | grep for tool-invocation patterns in `.opencode/agents/` — zero matches |
| SC-5 | Tool reference tables that list `glob` as an available tool are updated to remove `glob` | `string` | grep for `glob` in tool-listing contexts (tables, tier lists) — zero matches |
| SC-6 | Behavioral tests that assert `glob` in agent output patterns are updated to use alternative search tool patterns | `string` | grep for `glob` in `.opencode/tests/behaviors/` — only unrelated uses remain |
| SC-7 | The `general` sub-agent type (used by `task(subagent_type="general")`) does not have `glob` access | `behavioral` | Dispatch a `general` sub-agent with a prompt that would use `glob`; verify it uses `read` or `bash` instead |
| SC-8 | All replacements use appropriate alternatives: `read` for directory listing, `bash ls/find` for filesystem patterns, `srclight` for code search | `string` | Verify each replaced reference uses a valid alternative tool |

## Phases

### Phase 1: Sub-agent Card Permissions
- Verify `general` sub-agent type permissions (check if `general` has implicit `glob` access)
- Add explicit `glob: deny` to any sub-agent card missing it
- For JSONC format cards, verify the `tools` allowlist excludes `glob`

### Phase 2: Skill Deck Tool Invocation Instructions
- Replace all `glob` tool invocation instructions in skill task files with `read` (directory listing)
- Update adversarial audit task files (11 files)
- Update approval gate task files (6 files)
- Update verification-before-completion task files (3 files)
- Update remaining skill task files (7 files)
- Update agent card instruction text (4 files)
- Update guideline instruction text (2 files)

### Phase 3: Tool Reference Tables
- Remove `glob` from tool tier lists and reference tables
- Update guidelines (4 files)
- Update skill files (6 files)
- Update plugins (1 file)
- Update prompts (1 file)

### Phase 4: Behavioral Tests
- Update test assertions that expect `glob` in agent output
- Update content-verification tests that list `glob` as an allowed key

### Phase 5: Verification
- Run grep-based content verification for all SCs
- Run behavioral test for SC-7 (general sub-agent glob access)
- Run full enforcement test suite

## Labels

`spec-fix`, `glob`, `sub-agent`, `permissions`

🤖 Co-authored with AI: DeepSeek V4 Flash (ollama-cloud/deepseek-v4-flash)
