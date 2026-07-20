## Problem

In `.opencode/plugins/session-enforcement.ts` at line 1019, there is an unconditional `console.error()` call that prints sub-agent detection diagnostics on EVERY turn of EVERY session:

```typescript
console.error(`[session-enforcement-diag] isSubAgent=${isSubAgent} detectionSource=${detectionSource} sessionID=${sessionID}`);
```

This pollutes stderr/console with debug output that has no value outside of initial development/debugging. The diagnostic was added to verify sub-agent detection (SC-1, SC-2) was working during development. Now that the feature is proven, this unconditional per-turn diagnostic should be removed.

## Root Cause

The `console.error` at line 1019 was added as a development-time diagnostic to confirm sub-agent detection was firing correctly. It was never gated behind a debug flag or conditional, so it runs on every session turn unconditionally.

## Fix Description

Remove the `console.error` line at line 1019. The sub-agent detection logic (lines 1007-1017) remains intact — only the diagnostic output is removed. The detection logic is still used by the `shouldInjectFirstTurn` gate at line 1025 and subsequent logic.

## Risk Assessment

**Minimal.** The change removes a single `console.error` call. The detection logic that the diagnostic was verifying is unchanged and continues to be exercised by the `shouldInjectFirstTurn` gate and downstream logic. No behavioral change to enforcement, injection, or any other plugin function.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No `[session-enforcement-diag]` output appears in stderr during normal session operation | `string` | `grep` for pattern `session-enforcement-diag` in stderr output — must return no matches |

## File Affected

- `.opencode/plugins/session-enforcement.ts` — remove line 1019

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)