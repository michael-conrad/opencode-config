## Problem

When executing a plan, the agent reports progress in chat but there is no standardized format. The user cannot quickly see what step is done, what is being worked on, and what comes next. The plan file itself has no instruction telling the executing agent how to format progress output.

## Solution

Add a new required section to the Plan Format Requirements in `writing-plans/tasks/write.md` — a Step Status instruction block that tells the executing agent the exact chat output format to use when reporting progress.

### Required Section (inserted between current item 4 and item 5)

```
5. **Step Status instruction** — Verbatim blockquote:
   ```
   > **Step Status:**
   > When executing this plan, report progress in chat using:
   > 
   > ✅ Step N-1 — <step description>
   > 🔄 Step N — <step description>
   > ⏳ Step N+1 — <step description>
   > 
   > ✅ = completed. 🔄 = in progress. ⏳ = pending.
   > 
   > Omit the ✅ line when no step is yet completed.
   > Omit the ⏳ line when the current step is the last step.
   ```
```

### Effect on plan document

Every plan file will contain this instruction block. The executing agent reads it and formats chat output accordingly. The user sees at a glance: what's done, what's active, what's next.

### Edge cases

| Scenario | Output |
|----------|--------|
| Start of execution (no prior step) | `🔄 Step 1 — ...` / `⏳ Step 2 — ...` |
| Middle of execution | `✅ Step 2 — ...` / `🔄 Step 3 — ...` / `⏳ Step 4 — ...` |
| Last step (no future step) | `✅ Step 21 — ...` / `🔄 Step 22 — ...` |

### Scope of change

- **File modified:** `writing-plans/tasks/write.md` — Plan Format Requirements section
- **No changes to:** `executing-plans`, `implementation-pipeline`, or any other skill
- **No changes to:** any guideline or enforcement test

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Plan Format Requirements includes Step Status instruction as required section 5 | `string` | grep for `Step Status instruction` in `write.md` |
| SC-2 | Instruction block contains verbatim format with ✅, 🔄, ⏳ markers | `string` | grep for `✅`, `🔄`, `⏳` in the instruction block |
| SC-3 | Instruction block includes edge case rules (omit ✅ when none, omit ⏳ when last) | `string` | grep for `Omit the ✅ line` and `Omit the ⏳ line` in `write.md` |
| SC-4 | Validation rules updated to include Step Status instruction presence | `string` | grep for Step Status in validation rules section |
| SC-5 | Existing sections renumbered correctly (current 5-9 → 6-10) | `string` | Verify section numbering in Required Sections list |

## Files

- `.opencode/skills/writing-plans/tasks/write.md` — Plan Format Requirements (lines 52-167)

## Dependencies

None. Standalone format change to the plan writer task.

## Risks

None identified. This is a documentation-only change to the plan format specification. No runtime behavior changes.

## Change Control

- 2026-06-29: Initial spec
