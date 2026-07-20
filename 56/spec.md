## Summary

Remove the identity validation section in `session-enforcement.ts` and its supporting functions (`extractValue`, `buildIdentityEchoDirective`). The entire mechanism is a circular self-check that does nothing useful and always fires a false-positive `### Identity Validation Failure` due to a delimiter mismatch.

## Problem

The identity validation pipeline works as follows:

1. `session-init` stdout is injected into the system prompt by `system.transform` (line 781) — this is the delivery mechanism that works correctly
2. `messages.transform` re-parses the same text using `extractValue()` with `=` as the key-value delimiter (line 634)
3. `session-init` outputs `key: value` with colon-space delimiter (lines 787–790), so `extractValue()` **never matches** — `knownPlatform`, `knownOwner`, `knownRepo` are always `null`
4. The null check on line 898 fires on every session start, injecting `### Identity Validation Failure` into the first user message
5. The agent echoes the correct identity values from the system prompt, but the validation block already declared failure

The mechanism is circular — it re-parses text it just injected to validate the agent's echo of that same text. There is no independent source of truth being checked. The parser is broken, so the validation never passes, and the failure block pollutes every session start.

## Root Cause

Wrong regex delimiter in `extractValue()` (line 634):
```
`${escapedKey}=\\s*(\\S+)`  ← expects `key=value`
```
Session-init outputs (lines 787–790):
```
github.owner: michael-conrad   ← actual format is `key: value`
```

Fixing the delimiter would not solve the circularity — the validation would still be a self-referential check that adds no value beyond what the system prompt injection already provides.

## Fix Approach

Delete the following from `session-enforcement.ts`:

1. **`extractValue()` function** — line 631–636 (dead code, only used by identity validation)
2. **`buildIdentityEchoDirective()` function** — lines 638–643 (dead code, only used by identity validation)
3. **Identity validation deletions in `shouldInjectFirstTurn`** — NOT lines 838–943 as a contiguous block. Delete only:
   - `extractValue()` calls for `knownPlatform`, `knownOwner`, `knownRepo`, `knownIdentitySource` (lines 841–844)
   - `identityBlock` construction via `buildIdentityEchoDirective()` (lines 846–851)
   - `echoParts` assembly modifications (line 875: remove `if (identityBlock) { echoParts.push(identityBlock); }`)
   - Null-value identity check + failure block injection (lines 898–911)
   - Echo-match identity check + failure block injection (lines 912–943)

   **PRESERVE** (lines within the same range that must NOT be touched):
   - `runSessionContextTriggers()` call (line 840)
   - Trigger block handling and NESTED_OPENCODE_FATAL extraction (lines 854–888)
   - Plugin diagnostics block (lines 891–895)
   - The remaining `echoParts` logic for trigger content: `if (triggerBlock) { echoParts.push(triggerBlock); }` and `firstUser.parts.unshift(...)` (lines 876–882)
   - The opening `if (shouldInjectFirstTurn) {` and closing `}` (lines 838, 945)

**⚠️ Line number shift warning:** Deleting the `extractValue` and `buildIdentityEchoDirective` functions (lines 631–643) will shift all subsequent line numbers downward by ~15 lines. Target deletions by function/section name, not raw line numbers. The line numbers above reflect the pre-edit baseline.

## The Trigger Section Must Be Preserved

The `runSessionContextTriggers()` call (line 840), trigger block construction (lines 854–881), and `nested_opencode_fatal` extraction + injection (lines 884–888) are currently inside the `shouldInjectFirstTurn` block alongside identity validation. These triggers serve a legitimate function and must be preserved.

**`echoParts` modification detail — exact code changes:**

Before deletion (current, lines ~873–882):
```typescript
const echoParts: string[] = [];
if (identityBlock) {
  echoParts.push(identityBlock);    // ← DELETE this push
}
if (triggerBlock) {
  echoParts.push(triggerBlock);     // ← PRESERVE this push
}
if (echoParts.length > 0 && firstUser.parts?.length) {
  firstUser.parts.unshift({ type: "text", text: echoParts.join("\n\n") });
}
```

After deletion:
```typescript
if (triggerBlock && firstUser.parts?.length) {
  firstUser.parts.unshift({ type: "text", text: triggerBlock });
}
```

**Before (simplified):**
```
if (shouldInjectFirstTurn) {
  const triggersOutput = await runSessionContextTriggers(projectDir);
  // extractValue calls — DELETE
  // buildIdentityEchoDirective — DELETE
  // trigger block handling — PRESERVE
  // echoParts assembly — DELETE identityBlock push, PRESERVE triggerBlock push + unshift
  // NESTED_OPENCODE_FATAL injection — PRESERVE
  // plugin diagnostics injection — PRESERVE
  // identity null check — DELETE
  // identity echo-match check — DELETE
}
```

**After (simplified):**
```
if (shouldInjectFirstTurn) {
  const triggersOutput = await runSessionContextTriggers(projectDir);
  // trigger block handling (same as before)
  // prepend triggers to first user (same as before, minus identityBlock)
  // NESTED_OPENCODE_FATAL injection (same as before)
  // plugin diagnostics injection (same as before)
  // identity validation — REMOVED entirely
}
```

## Affected Files

- `.opencode/plugins/session-enforcement.ts` — Remove ~90 lines of identity validation code (lines 631–636, 638–643, and the identity validation deletions within `shouldInjectFirstTurn` as described above)

## Single Concern

This spec addresses exactly one concern: removing the broken identity validation from session-enforcement.ts. The trigger injection, plugin diagnostics, and all other enforcement logic are preserved unchanged.

## Success Criteria

| SC# | Criterion | Verification Method |
|-----|-----------|---------------------|
| SC-1 | `extractValue` function removed from `session-enforcement.ts` | `grep -c "extractValue"` returns 0 |
| SC-2 | `buildIdentityEchoDirective` function removed from `session-enforcement.ts` | `grep -c "buildIdentityEchoDirective"` returns 0 |
| SC-3 | No `### Identity Validation Failure` block in plugin output | Search for "Identity Validation Failure" in source returns only comments/references, not injection code |
| SC-4 | `runSessionContextTriggers` call preserved in `shouldInjectFirstTurn` | Call to `runSessionContextTriggers` present after removal |
| SC-5 | Plugin diagnostics block still injected in `shouldInjectFirstTurn` | `buildDiagnosticBlock` call present after removal |
| SC-6 | Nested opencode fatal extraction still injected | `NESTED_OPENCODE_FATAL` extraction logic present after removal |
| SC-7 | Plugin still compiles and loads without TypeScript errors | `npx tsc --noEmit` or equivalent check |

## PR Merge Boundaries

None. This is standalone — no other PR must merge first.

## Revision Notes

- **v1.0** — Initial creation
- **v2.0** — Fixed misleading line-range reference (838–943) that included preserved trigger/diagnostics code. Replaced with explicit structural deletion targets and added line-number-shift warning. Added exact `echoParts` code before/after for the identityBlock removal. Reduced line estimate from ~105 to ~90. Revised per adversarial audit findings.

Co-authored with AI: OpenCode (deepseek-v4-flash)