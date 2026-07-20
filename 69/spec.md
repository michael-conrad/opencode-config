## Objective

Replace opencode core's mode-switch `<system-reminder>` blocks (injected as synthetic text parts) with anchored versions that reference existing mandatory skills, guidelines, and approval gates — without restating them.

## Motivation

The core-injected `build-switch.txt` reads as an unconditional green light:

```
<system-reminder>
Your operational mode has changed from plan to build.
You are no longer in read-only mode.
You are permitted to make file changes, run shell commands, and utilize your arsenal of tools as needed.
</system-reminder>
```

The AI agent interprets "permitted to make file changes" as implementation authorization — bypassing every approval gate, mandatory skill, and guideline the agent carries. The fix is a lightweight anchor that does not restate the rulebook but references it.

## Success Criteria

- [ ] SC-1: `session-enforcement.ts` detects the exact `build-switch.txt` content ("Your operational mode has changed from plan to build...") in any synthetic `type: "text"` part within a user message.
- [ ] SC-2: On detection, the original text is replaced **in-place** with the anchored version below.
- [ ] SC-3: Same detection + replacement logic applies for the plan-mode switch ("build to plan").
- [ ] SC-4: Replacement is idempotent — if the anchored version is already present, no change is made.
- [ ] SC-5: Only synthetic parts are targeted (`synthetic: true`). User-written text is never touched.
- [ ] SC-6: Existing `messages.transform` behavior (secret redaction, git config watchdog, inline work detector, evidence gate) is not affected.
- [ ] SC-7: Behavioral enforcement test in `.opencode/tests/behaviors/` verifies the replacement occurs when the build-switch text is injected (RED state before change).

## Replacement Text

### Build mode (plan → build)

```
<system-reminder>
Your operational mode has changed from plan to build.
You are no longer in read-only mode.
Mandatory skills, guidelines, and approval gates remain in full effect.
FAIL = FAIL — justifiable violations do not exist. Correctness and
completeness always trump context cost or efficiency concerns.
</system-reminder>
```

### Plan mode (build → plan)

```
<system-reminder>
Your operational mode has changed from build to plan.
You are now in read-only mode.
Mandatory skills, guidelines, and approval gates remain in full effect.
FAIL = FAIL — justifiable violations do not exist. Correctness and
completeness always trump context cost or efficiency concerns.
</system-reminder>
```

## Implementation Approach

### Detection

In the existing `messages.transform` handler, scan synthetic text parts in user messages for:

- Build switch: exact match on `"Your operational mode has changed from plan to build."`
- Plan switch: exact match on `"Your operational mode has changed from build to plan."`

Use `.includes()` or `.startsWith()` on `part.text` — the exact text is stable since it comes from a hardcoded core file (`build-switch.txt`).

### Replacement

Replace `part.text` entirely with the anchored version. This is the same in-place mutation pattern already used for secret redaction at line 1053 of `session-enforcement.ts`:

```typescript
if (part.type === "text" && part.text && part.synthetic) {
  const replaced = replaceModeSwitchText(part.text);
  if (replaced !== part.text) {
    part.text = replaced;
  }
}
```

### Guard

Only target `synthetic: true` parts. User-authored text is never substituted.

### Idempotency

Check whether the anchored text is already present before replacing. If `part.text` already contains the new version, skip.

## Affected File

- `.opencode/plugins/session-enforcement.ts` — `messages.transform` handler (new detection + replacement logic near the existing per-turn behaviors)

## Risk and Edge Cases

- **Sub-agent sessions**: The existing `isSubAgent` guard gates first-turn injections, but mode-switch blocks are injected per-turn by core. The detection/replacement must run unconditionally (not gated by `shouldInjectFirstTurn`).
- **Multiple synthetic parts**: A user message may contain multiple synthetic parts. Only the one matching the mode-switch text is replaced.
- **Plan-mode injection is already first-turn-only**: Core's `insertReminders` injects the plan-mode `<system-reminder>` as synthetic in the first user message only. The replacement must handle this case correctly.

## Verification Method

After implementation, run:
```
bash .opencode/tests/with-test-home opencode-cli run 'test: verify mode switch anchor injection'
```

And the behavioral enforcement test:
```
bash .opencode/tests/test-enforcement.sh --scenario mode-switch-anchor
```

## Semantic Intent

- Three trailing lines are an **anchor**, not a re-statement of the rulebook. They tell the agent "the rules you already carry still apply" and "FAIL=FAIL is non-negotiable."
- FAIL = FAIL specifically closes the "functionally equivalent" / "it works for this use case" / "good enough" rationalization pathways.
- The original first two lines ("changed from X to Y", "no longer read-only" / "now read-only") are preserved because they communicate the mode switch factually.
