**STATUS: AWAITING APPROVAL (v1.0)**
**Created:** 2026-05-02
**Labels:** `approved-for-implementation`
**Co-authored with AI: OpenCode (deepseek-v4-pro)**

---

## Root Cause

Sub-agents dispatched via `task(subagent_type="general")` receive all five per-turn injection guards identically to the primary orchestrator. These guards perform context-dependent runtime probes (`git diff`, `git branch --show-current`, `git config --local --list`, `git remote -v`) and inject enforcement blocks that assume the recipient is the primary orchestrator. Sub-agents receiving these blocks pivot from their scoped task to orchestrator behaviors — gating work, creating worktrees, running audit pipelines, or halting for authorization.

The sub-agent session detection infrastructure already exists (`subAgentSessions: Set<string>` at line 317, populated in `system.transform` at lines 1244-1259) and is already used by the inline work detector (line 1584: `if (!isSubAgent && !isPairBranch)`). The fix follows this established pattern.

## Five Ungated Per-Turn Guards

| # | Guard | Lines | Context Probe | Injection Block | Sub-Agent Confusion |
|---|---|---|---|---|---|
| 1 | Protected branch edit | 1675–1693 | `git diff --name-only` + `git branch --show-current` | `<SESSION_TRIGGERS> protected_branch_with_changes` — "guideline violation", use worktree or pair-mode | Pivots to worktree/pair-mode gate instead of completing scoped task |
| 2 | Evidence gate | 1638–1673 | Scans assistant text for `state=closed` | `<EVIDENCE_GATE_BLOCK>` — demands per-SC verification evidence table | Pivots to verification pipeline for its own deliverables |
| 3 | `--no-verify` detection | 1542–1576 | `git remote -v` + scans for `--no-verify` | `<NO_VERIFY_BLOCKED>` — "Tier 1 mandate" if remotes exist | Blocks legitimate sub-agent `--no-verify` usage |
| 4 | Git config mutation | 1508–1540 | `git config --local --list` diff + baseline hash comparison | `<GIT_CONFIG_MUTATION>` — "Tier 1 mandate violation" | Flags sub-agent branch/config changes as violations |
| 5 | Bare issue pipeline | 1478–1491 | Regex `^\s*#(\d+)\s*$` on user message | `<ISSUE_PIPELINE_TRIGGER>` — audit→brainstorm→plan→HALT | Pivots to full issue pipeline when seeing `#N` in dispatch context |

The **protected branch edit guard** (#1) is the most directly harmful — it fires on every assistant turn where the sub-agent makes file changes on dev/main without a worktree (the sub-agent's normal operating mode).

## Proposed Fix

Add `!isSubAgent` to each of the five per-turn guard conditions, matching the existing pattern at line 1584 (`if (!isSubAgent && !isPairBranch)`).

### Guard 1 — Protected branch edit (line 1679)

```
// Before:
if (currentBranch && isProtectedBranch(currentBranch)) {

// After:
if (!isSubAgent && currentBranch && isProtectedBranch(currentBranch)) {
```

### Guard 2 — Evidence gate (line 1641)

```
// Before:
for (const msg of assistantMessages) {

// After:
if (isSubAgent) break;  // or wrap in if (!isSubAgent)
for (const msg of assistantMessages) {
```

### Guard 3 — `--no-verify` detection (line 1561)

```
// Before:
for (const msg of assistantMessages) {

// After:
if (isSubAgent) break;
for (const msg of assistantMessages) {
```

### Guard 4 — Git config mutation (line 1509)

```
// Before:
if (gitConfigBaseline) {

// After:
if (!isSubAgent && gitConfigBaseline) {
```

### Guard 5 — Bare issue pipeline (line 1478)

```
// Before:
const lastUser = userMessages[userMessages.length - 1];

// After:
if (isSubAgent) return;  // skip entire section
const lastUser = userMessages[userMessages.length - 1];
```

## Additional: Sub-Agent Role Awareness (Optional Enhancement)

To prevent future regressions where new guards are added without sub-agent gating, add a role-awareness note to sub-agent system prompts in `system.transform`. This is defensive but not strictly required by the fix — the five explicit gates above are the minimum.

## Files Changed

- `.opencode/plugins/session-enforcement.ts` — five `!isSubAgent` additions (approximately five lines changed)

## Verification

- Existing inline work detector pattern at line 1584 already demonstrates this works
- No changes to `system.transform` needed
- No changes to `env-loader.ts` needed (it only handles `shell.env`, which is fine for sub-agents)
- Secret redaction at lines 1493–1506 is deliberately left gated for all sessions (benign, always useful)

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-05-02 | OpenCode (deepseek-v4-pro) | Initial spec |
