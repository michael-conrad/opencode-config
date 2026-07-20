> **Full spec and plan artifacts: `opencode-config/.issues/{ISSUE_NUMBER}/`**

## Problem

When a spec writer creates success criteria in `write.md`, the Evidence Type Classification Gate (§3) already instructs correct classification at authorship time. However, there is **no post-creation step** that systematically re-examines ALL SCs for missed runtime-behavioral misclassification, applies automatic uplift, provides structured remediation, and re-checks before the spec is considered complete.

The pipeline-readiness gate validates SC atomicity, dependency ordering, single concern, and phase DAG — but does **not** check evidence type correctness against the BEH-EV substrate classification ("does this change affect runtime behavior?").

This means: an SC misclassified as `structural` for a runtime-behavioral change will pass the pipeline-readiness gate, pass self-review, and only be caught downstream at VbC time — the exact death-spiral pattern the BEH-EV classification gate was designed to prevent.

## Scope

**In scope:**
- Add a post-SC uplift check step to `write.md`, positioned between self-review (Step 6) and the evidence artifact verification (Step 6.5)
- The check MUST: re-examine each SC's evidence type against the substrate BEH-EV question, auto-uplift misclassified SCs to `behavioral`, provide remediation guidance, and re-check after remediation
- Update `completion.md` to verify this step ran
- Update `write.md` Operating Protocol and/or procedure to reflect the new step

**Out of scope:**
- Changes to the pipeline-readiness gate itself (PR-3 single concern already validates verification domain — that's a separate check)
- Changes to VbC pre-flight classification (already covers downstream uplift)
- Changes to guidance in `000-critical-rules.md` or `080-code-standards.md` (the BEH-EV rules are correct; the gap is procedural enforcement at spec-creation time)

## Approach

Add a new substep under `write.md` Step 6 (Self-Review), positioned **before Step 6.5 (Evidence Artifact Verification)** — since the uplift check IS an evidence type verification that should feed into the artifact verification step.

The step:

1. **SC evidence type re-check**: For each SC in the spec body, evaluate the substrate question: "Does this change affect runtime behavior?" 
2. **Uplift misclassified SCs**: If runtime-behavioral YES but evidence type is NOT behavioral → auto-uplift to `behavioral`. Log the uplift action as a finding.
3. **Downgrade flag (conditional)**: If runtime-behavioral NO but evidence type IS behavioral → flag for review. The writer may have intended a behavioral test for structural reasons, but this mismatch warrants human review.
4. **Remediation guidance**: For each uplifted SC, provide guidance on what changes (if any) the verification method needs:
   - `structural` → `behavioral`: Must add a real test execution command (e.g., `opencode-cli run`, `pytest`, `bash test.sh`)
   - `string` → `behavioral`: Must replace grep assertion with test execution + semantic inspection
5. **Re-check**: After remediation, re-run the classification check. Confirm no remaining misclassifications.
6. **Evidence artifact**: Write findings to `.issues/{N}/post-sc-uplift-check.yaml`

## Impact

| Risk | Mitigation |
|------|------------|
| False positives (uplifting SCs that legitimately don't need behavioral tests) | The downgrade-flag path catches → flagged-for-review, no auto-change |
| Adding too many behavioral SCs increases verification burden | Intentional — per BEH-EV rule, behavioral is the only valid evidence for runtime-behavioral changes. The cost is bounded and intentional. |
| Existing specs not retroactively checked | Out of scope — this fix applies to spec creation time only |

## Key Decisions

- **Position**: After Step 6 (self-review), before Step 6.5 (artifact verification). Rationale: uplift check IS an evidence type verification, and Step 6.5 consolidates all evidence artifact checks.
- **Auto-uplift**: Only for `structural`/`string` → `behavioral` when runtime-behavioral. Downgrade (`behavioral` → `structural`) is always conditional/flag-for-review — never auto.
- **Single step, not separate task**: The check is simple enough to be a substep within Step 6, avoiding an extra task file. If it grows, split into `post-sc-uplift-check.md` later.

## Cards (dependency order)

1. **Add post-SC uplift check substep in write.md** — New step between Step 6 and Step 6.5: SC evidence type re-check, auto-uplift, remediation guidance, re-check, evidence artifact for each SC
2. **Update completion.md** — Verify post-SC uplift check step ran before spec completion
3. **Update write.md Operating Protocol checklist** — Add the new step to the procedure checklist

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/{N}/`.
After creation, `local-issues sync {N}` MUST be run and the result committed to create the local `.issues/{N}/` entry.
The implementation plan will be created in `.issues/{N}/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)