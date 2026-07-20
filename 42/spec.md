## Root Cause

The `session-enforcement.ts` plugin injects seven content blocks into the LLM system prompt and user messages that duplicate information opencode-cli already provides natively. This creates maintenance burden, context window waste, and inconsistency risk — when one copy is updated but the other is not, the agent receives contradictory instructions.

Opencode-cli natively provides:
1. **Skill list** — the `<available_skills>` block built from SKILL.md frontmatter, injected by the CLI framework itself
2. **Guideline content** — full guideline files loaded via the `instructions` list in `opencode.jsonc`
3. **Agent identity** — `AgentName` and `ModelId` fields in the system prompt (filled by opencode-cli at runtime)

The plugin re-injects all three of these, plus content that duplicates guideline text already loaded via instructions.

The user's requirement is clear: "NO INJECTION SKILLS OR OTHER INFORMATION PROVIDED BY THE AI AGENT SOFTWARE FROM ADD-ON PLUGINS." The plugin should only inject **runtime-enforcement guards and dynamic state** that opencode-cli cannot know at system-prompt construction time.

The `env-loader.ts` plugin is clean — it only uses the `shell.env` hook to set bash environment variables. No LLM prompt injection. No changes needed.

### Class of Defect

**Context window waste and inconsistency risk.** Duplicate injection means:
- Same data appears 2-3 times in the system prompt, wasting context tokens
- When guidelines are updated, the plugin's hardcoded copies may differ from the loaded guideline files, creating contradictory instructions
- The agent must reconcile "which copy is authoritative?" — a question that should never arise

## Fix Approach

### Change 1: Remove `buildEnforcementContent()` from plugin injection

**File:** `.opencode/plugins/session-enforcement.ts`

Remove the `<EXTREMELY_IMPORTANT>` block injection (lines 959-1029, and the call at line 1355-1361). This block contains:

- Skill priority ordering — duplicates `opencode.jsonc` instruction loading order and `060-tool-usage.md` §8
- Red-flags table — duplicates `020-go-prohibitions.md` §1 "NEVER DO" list
- Default operating mode (discussion mode) — duplicates `010-approval-gate.md` §Tier 0 "Authorization required"
- **Available Skills list** — FULLY DUPLICATES opencode-cli's native `<available_skills>` block
- "How to Invoke Skills" instruction — duplicates opencode-cli's native skill tool description

Remove the entire `buildEnforcementContent()` function (lines 959-1029) and its call in the `messages.transform` hook (lines 1355-1361).

**Do NOT remove `loadSkillDescriptions()`.** It produces two return values: `{ skills, errors }`. While the `skills` array (used by `buildEnforcementContent`) is no longer needed, the `errors` array feeds `buildFrontmatterWarning()` which is kept (item 19 in "What to KEEP"). Refactor `loadSkillDescriptions()` to only return `{ errors }` by removing the `skills` array population and the `skills` return field. Rename to `validateSkillFrontmatter()` to reflect the narrowed purpose.

### Change 2: Remove `buildTrainingStalenessBlock()` from plugin injection

**File:** `.opencode/plugins/session-enforcement.ts`

Remove the `<TRAINING_STALENESS_CRITICAL>` block (lines 654-693, and the call at line 1279). This content is already covered by:

- `065-verification-honesty.md` (loaded via `opencode.jsonc` instructions)
- `075-docs-verification.md` (loaded via `opencode.jsonc` instructions)

The guideline text is the authoritative copy. The plugin block is a stale copy that can diverge.

### Change 3: Remove `buildReferencesVerificationBlock()` from plugin injection

**File:** `.opencode/plugins/session-enforcement.ts`

Remove the `<REFERENCES_VERIFICATION_MANDATE>` block (lines 696-742, and the call at line 1282). Same duplication as Change 2 — this content is fully covered by `065-verification-honesty.md` and `075-docs-verification.md` already loaded via instructions.

### Change 4: Remove `buildGuidelineIndexBlock()` from plugin injection

**File:** `.opencode/plugins/session-enforcement.ts`

Remove the `<GUIDELINE_INDEX>` block (lines 758-772, and the call at lines 1288-1291). The `opencode.jsonc` `instructions` list already loads the full content of every guideline file. An index of content that is already loaded in full is pure redundancy — progressive disclosure is unnecessary when the full guideline is already present.

The `INDEX.md` file itself should be KEPT — it serves as a routing reference for sub-agents who load guidelines on demand. Only the plugin injection of it into the system prompt should be removed.

### Change 5: Remove `runSessionContextIdentity()` prose section from system.transform

**File:** `.opencode/plugins/session-enforcement.ts`

Remove the `runSessionContextIdentity()` call and its `output.system.push(identityOutput)` at lines 1300-1302. The `session-init` script (injected at line 1263) already provides all the same data in key:value format:

- `github.owner`, `github.repo`, `github.platform`, `github.identity_source` (from session-init)
- `GITHUB_CREDENTIALS=present/missing/stale` (from session-init via credential probing)
- `Remote:` display (from session-init)
- `gitbucket.*` values (from session-init)
- Submodule routing (from session-init's `.gitmodules` scanning)

The identity script reformats the same data into prose paragraphs, adding no new information. Two copies of the same data (session-init key:value format + identity script prose format) is one copy too many.

Remove `runSessionContextIdentity()`, `cachedIdentityOutput`, and `identityCacheTimestamp` (lines 450-506). The `<IDENTITY_ECHO>` directive remains but must now parse identity values from session-init output instead of the removed identity script output (see Change 7 for details).

**Do NOT remove `detectAgentBinary()`.** The session-init script intentionally emits **empty** `AgentName:` and `ModelId:` lines (lines 791-792) — it only provides key scaffolding, not actual values. The `detectAgentBinary()` function (lines 1038-1059) is the ONLY source of actual agent binary detection, which opencode-cli does NOT provide natively from session-init. The `AgentName`/`ModelId` system.push at lines 1306-1311 must be KEPT as a non-duplicate runtime detection.

**Do NOT remove `extractValue()`.** It is needed by the `<IDENTITY_ECHO>` directive and the `<IDENTITY_VALIDATION_FAILURE>` block to parse identity values from session-init output. Currently `extractValue()` parses from `cachedIdentityOutput` (the removed identity script cache). Repoint it to parse from `cachedOutput` (the session-init cache, line 305) instead. The session-init output uses the same `key=value` format with the same key names (`github.platform`, `github.owner`, `github.repo`, `github.identity_source`), so the parsing logic works unchanged — only the source variable changes.

### Change 6: Remove `<LOCAL_MODE>` blocks from messages.transform

**File:** `.opencode/plugins/session-enforcement.ts`

Remove the `<LOCAL_MODE>` blocks at lines 1410-1419 (local-only mode) and lines 1420-1428 (submodule mode). Session-init already emits `github.identity_source: none` / `github.identity_source: submodule` in key:value format. The `060-tool-usage.md` §9 "Identity Source Semantics" table (loaded via `opencode.jsonc` instructions) maps these values to the same behavioral directives that the prose warnings contain:

- "No remote exists" → `060-tool-usage.md` §9: "Full local-only mode — no remote exists anywhere"
- "Do NOT add remotes" → `060-tool-usage.md` §9: "Do NOT add remotes"
- "Do NOT push from parent" → `060-tool-usage.md` §9: "git push from the parent repo is FORBIDDEN"

The `<IDENTITY_VALIDATION_FAILURE>` block (lines 1429-1476) should be KEPT — this is runtime enforcement, not duplication.

### Change 7: Repoint `<IDENTITY_ECHO>` directive to session-init output

**File:** `.opencode/plugins/session-enforcement.ts`

After Change 5 removes `runSessionContextIdentity()`, the `<IDENTITY_ECHO>` directive construction (lines 1365-1399) currently reads `knownPlatform`, `knownOwner`, `knownRepo`, `knownIdentitySource` from `cachedIdentityOutput` via `extractValue()`. Update all four to parse from `cachedOutput` (the session-init cache) instead:

```
const knownPlatform = extractValue(cachedOutput, "github.platform");
const knownOwner = extractValue(cachedOutput, "github.owner");
const knownRepo = extractValue(cachedOutput, "github.repo");
const knownIdentitySource = extractValue(cachedOutput, "github.identity_source");
```

This works because session-init emits the same keys in the same `key=value` format. The `extractValue()` regex pattern (`key=\\s*(\\S+)`) matches both formats identically.

**Session-init failure handling:** When `runSessionInit()` fails, `cachedOutput` is set to `""` (empty string), and `extractValue()` returns `null` for all keys. This is the same behavior as the current identity script failure path — `knownPlatform`/`knownOwner`/`knownRepo` are null, which triggers the `<IDENTITY_VALIDATION_FAILURE>` block at lines 1429-1476 that injects a FATAL halt message. No new failure mode is introduced.

**Agent identity in echo:** The `<IDENTITY_ECHO>` directive line `🤖 ${agentName || "<AgentName>"} (${modelId || "<ModelId>"})` currently receives `agentBinary.name` and `agentBinary.version` from `detectAgentBinary()`. Since `detectAgentBinary()` is kept (per Change 5), this continues to work unchanged.

### What to KEEP (runtime enforcement guards and non-duplicate injections)

The following plugin injections are NOT duplicates and must remain:

1. `session-init` output — dynamic git state (branch, remote, srclight, dev branch)
2. `<IDENTITY_ECHO>` directive — runtime validation gate (repointed to session-init per Change 7)
3. `<IDENTITY_VALIDATION_FAILURE>` — validates agent's identity echo matches
4. `<SESSION_TRIGGERS>` — per-turn git state triggers (protected branch, stash, etc.)
5. `<PLUGIN_DIAGNOSTICS>` — startup diagnostic warnings
6. `<GIT_CONFIG_MUTATION>` — per-turn config change detection
7. `<NO_VERIFY_BLOCKED>` — per-turn `--no-verify` detection
8. `<INLINE_WORK_DETECTED>` — per-turn orchestrator work detection
9. `<EVIDENCE_GATE_BLOCK>` — per-turn issue closure gate
10. `<ISSUE_PIPELINE_TRIGGER>` — bare `#N` issue references
11. `<FRONTMATTER_VALIDATION_WARNING>` — unique diagnostic (fed by `validateSkillFrontmatter()`)
12. Secret redaction — per-turn output sanitization
13. Protected branch edit guard — per-turn detection
14. `buildWorktreeBlock()` — dynamic worktree state
15. `buildMetadataBlock()` — project metadata
16. `<LANGUAGE_PREFERENCE>` — not duplicated by any guideline file or opencode-cli native injection; this is a project-specific preference with no equivalent in the currently loaded instructions
17. Git hook installation (`ensureHooksInstalled`)
18. Git config baseline capture (for mutation watchdog)
19. `detectAgentBinary()` — the ONLY source of actual AgentName/ModelId values; session-init emits empty placeholders
20. `extractValue()` — needed by `<IDENTITY_ECHO>` and `<IDENTITY_VALIDATION_FAILURE>` to parse identity from session-init output

### What is REMOVED (duplicate injections)

| Change | Injection Block | Line Range | Duplicate Of |
|--------|----------------|------------|-------------|
| 1 | `<EXTREMELY_IMPORTANT>` (skill enforcement) | 959-1029, 1355-1361 | opencode-cli native `<available_skills>` + guidelines `060-tool-usage.md` §8, `020-go-prohibitions.md` §1, `010-approval-gate.md` §Tier 0 |
| 2 | `<TRAINING_STALENESS_CRITICAL>` | 654-693, 1279 | Guidelines `065-verification-honesty.md`, `075-docs-verification.md` |
| 3 | `<REFERENCES_VERIFICATION_MANDATE>` | 696-742, 1282 | Guidelines `065-verification-honesty.md`, `075-docs-verification.md` |
| 4 | `<GUIDELINE_INDEX>` | 758-772, 1288-1291 | `opencode.jsonc` instructions list (already loads full guideline content) |
| 5 | `runSessionContextIdentity()` prose | 450-506, 1300-1302 | session-init key:value output (same data, different format) |
| 6 | `<LOCAL_MODE>` blocks | 1410-1428 | session-init `github.identity_source` + `060-tool-usage.md` §9 |

## Success Criteria

1. `<EXTREMELY_IMPORTANT>` block is removed from plugin injection — opencode-cli's native `<available_skills>` block is the sole source of skill discovery
2. `<TRAINING_STALENESS_CRITICAL>` block is removed — `065-verification-honesty.md` and `075-docs-verification.md` (loaded via `opencode.jsonc` instructions) are the sole sources
3. `<REFERENCES_VERIFICATION_MANDATE>` block is removed — same guideline files are the sole sources
4. `<GUIDELINE_INDEX>` block is removed from plugin injection — `INDEX.md` file is kept for sub-agent routing but not injected into system prompt
5. `runSessionContextIdentity()` prose section is removed from system.transform — session-init key:value format is the sole source of identity data; `<IDENTITY_ECHO>` directive remains as enforcement gate, repointed to parse from session-init cache
6. `<LOCAL_MODE>` blocks are removed from messages.transform — `github.identity_source` key from session-init plus `060-tool-usage.md` §9 provide the same behavioral directives
7. `loadSkillDescriptions()` is refactored to `validateSkillFrontmatter()` returning only `{ errors }` — frontmatter validation warnings still appear when skills have broken frontmatter
8. `detectAgentBinary()` is kept — it remains the only source of actual AgentName/ModelId values
9. `extractValue()` is kept and repointed to parse from `cachedOutput` (session-init cache) instead of `cachedIdentityOutput` — `<IDENTITY_ECHO>` and `<IDENTITY_VALIDATION_FAILURE>` continue to function
10. All runtime enforcement guards (listed in "What to KEEP" above) remain functional
11. `env-loader.ts` is unchanged — it uses `shell.env` hook only, no LLM content injection
12. `<FRONTMATTER_VALIDATION_WARNING>` still appears when skills have broken frontmatter after `loadSkillDescriptions()` is refactored — verified by `validateSkillFrontmatter()` producing `FrontmatterError[]` output
13. `<IDENTITY_ECHO>` directive still validates correctly after repointing — verified by `extractValue(cachedOutput, ...)` returning same values as before from session-init output
14. Session-init failure path still triggers `<IDENTITY_VALIDATION_FAILURE>` — when `cachedOutput` is empty string, `extractValue()` returns null for all keys, which triggers the FATAL halt message
15. Behavioral test: agent presented with a task requiring skill invocation discovers skills from the native `<available_skills>` block only, not from a duplicate plugin block
16. Behavioral test: agent presented with a verification task follows `065-verification-honesty.md` content from the instructions-loaded guideline, not from a plugin-injected block
17. Content verification: `session-enforcement.ts` no longer contains `buildEnforcementContent`, `buildTrainingStalenessBlock`, `buildReferencesVerificationBlock`, `buildGuidelineIndexBlock`, `runSessionContextIdentity`, `cachedIdentityOutput`, or `identityCacheTimestamp`
18. Content verification: `session-enforcement.ts` still contains `validateSkillFrontmatter` (renamed from `loadSkillDescriptions`), `detectAgentBinary`, `extractValue`, `buildFrontmatterWarning`, `buildIdentityEchoDirective`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5)