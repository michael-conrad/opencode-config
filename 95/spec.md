## [SPEC] Weave behavioral test infrastructure references into verification task files

### Prerequisites

- **opencode-config#94** — Analysis of the root cause (missing-instruction gap in verify.md, start.md, checklist.md)
- **.opencode#627** — Dark Prose Reference Card (all 6 pattern formulas + agency-respecting constraint)
- **.opencode#622** — Confirmshaming weave (routing layer)
- **.opencode#626** — Goal hijacking weave (verify = completion)

## Problem

Verification task files (`verify.md`, `start.md`, `checklist.md`) tell the agent *that* it must run behavioral tests for SC verification, but never *how*. The evidence table at `verify.md:144` shows `opencode-cli run output` — bare CLI, no `with-test-home`, no `behavior_run`, no existing test script reference. Step 5.5c in `start.md` says "confirm it has been run and FAILS" without specifying the invocation mechanism.

A task file that specifies WHAT without specifying the existing infrastructure is a gap that produces waste: the agent reads the verification procedure, encounters "run `opencode-cli run`", and proceeds to recreate the entire test isolation framework from scratch for each SC check — writing ad-hoc scripts, creating isolated temp directories, reimplementing assertion helpers that already exist in `helpers.sh`. Every recreated test infrastructure is an infrastructure that was already built, tested, and verified to work. The `with-test-home` wrapper, `behavior_run()` function, and 40+ existing behavioral test scripts represent infrastructure that was paid for once and should be used every time.

The verification pipeline must carry the infrastructure reference to the agent. A verification instruction without the infrastructure reference is an instruction that produces duplicate, uncoordinated work.

## Solution

Weave behavioral test infrastructure references into 3 task files so that when the agent reaches SC verification, the existing test infrastructure is the obvious, expected mechanism — not an optional optimization the agent must discover independently.

### dark-prose-006 Application (Agency-Respecting Identity Frame)

This spec defines WHAT must change (infrastructure references in three files) and WHY (agents must not recreate test infrastructure). The implementing agent reads `.opencode#627` Section 3 for the prose formula — the specific consequence assertion for each insertion point must match the file's concern domain. The compliance gate (#641) verifies correctness; the spec does not prescribe exact text.

The Purpose section in each modified file must carry identity-framing prose using dark-prose-001 (confirmshaming) — the formula variant appropriate to the file's position in the pipeline:
- `verify.md` (post-implementation): "an agent that runs bare `opencode-cli run` is an agent that bypasses the isolation layer" — consequence-assertion variant (dark-prose-003)
- `start.md` (pre-implementation RED gate): "the RED phase that uses `behavior_run` is the RED phase that verifies real agent behavior" — confirmshaming variant (dark-prose-001)
- `checklist.md` (completion gate): "a re-run with `behavior_run` catches what the first run missed" — identity-frame variant (dark-prose-002)

### dark-prose-002 Application (Goal Hijacking)

The verification task's identity must be reframed from "verify SC evidence" to "run the existing behavioral test and capture its output as evidence." Using the existing test infrastructure IS verification — there is no valid verification that recreates infrastructure. An SC verification that skips the existing behavioral test and runs bare `opencode-cli run` is a verification that has not verified anything meaningful about agent behavior — it has only proven that `opencode-cli run` produces output. The existing behavioral test scripts with their assertion helpers, `with-test-home` isolation, and retry logic are the verified mechanism for behavioral SC verification. An agent that recreates infrastructure is an agent that introduces untested, unvalidated execution paths into a tested verification pipeline.

### Files Changed

#### 1. `skills/verification-before-completion/tasks/verify.md`

**Evidence Types table — Behavioral test run row (line 144):**

Change from bare `opencode-cli run output` to reference the existing test script invocation mechanism. The behavioral test script `bash .opencode/tests/behaviors/<scenario>.sh` is the verified entry point — it wraps `behavior_run()` which wraps `with-test-home` which isolates XDG state. An agent that reads this table must find the infrastructure reference, not a generic command name.

**New subsection after §Verification Rule (after line 168):**

Insert "How to Run Behavioral Tests for SC Verification" with:
- The existing behavioral test scripts in `.opencode/tests/behaviors/` are the verified mechanism — source `helpers.sh`, call `behavior_run()`, use assertion helpers
- The `with-test-home` wrapper is baked into `behavior_run()` — no manual XDG isolation setup needed
- FORBIDDEN: Bare `opencode-cli run`, ad-hoc test recreation, inline test infrastructure from scratch
- REQUIRED: `bash .opencode/tests/behaviors/<scenario>.sh` for behavioral SC verification

**Per-SC Evidence Table format note (after line 247):**

"Verification Command Run" column must show the full command — e.g., `bash .opencode/tests/behaviors/my-scenario.sh`, not a generic "ran the test".

#### 2. `skills/executing-plans/tasks/start.md`

**Step 5.5c (line 24):**

Append infrastructure invocation: "For behavioral tests, run `bash .opencode/tests/behaviors/<scenario>.sh` — the `with-test-home` wrapper is baked into `behavior_run()` in `helpers.sh`. Do NOT run bare `opencode-cli run` or recreate the test infrastructure."

#### 3. `skills/finishing-a-development-branch/tasks/checklist.md`

**SC Verification section (after line 38):**

Add: "For behavioral SCs, re-run `bash .opencode/tests/behaviors/<scenario>.sh` and verify PASS — do NOT accept a prior run's output as evidence; agent state may have changed between implementation and completion."

### dark-prose-006 Compliance Check

Every insertion point in the three files must:
- Define WHAT quality standard the output must meet (the existing infrastructure is the standard)
- State WHY it matters (recreated infrastructure is unverified, introduces defects)
- Reference the source where the formula is defined (.opencode#627 Section 3)
- Not prescribe exact text — the implementing agent reads #627 and derives the formulation
- Not use blame-adjacent framing, tool-control, tone-policing, or competing standards

### dark-prose-005 Application (Social Proof / Quality Signal)

40+ existing behavioral test scripts in `.opencode/tests/behaviors/` all use `behavior_run()` → `with-test-home`. The `helpers.sh` assertion library is tested, the `with-test-home` wrapper is documented in README.md, and the AGENTS.md build/lint/test table specifies the invocation pattern. This is established infrastructure with verified correctness. An agent creating a new verification workflow should match this established pattern — deviation means the new code carries higher risk than the code it replaces.

## Success Criteria

| SC-ID | Criterion | Verification |
|-------|-----------|-------------|
| SC-1 | `verify.md` behavioral evidence row references `bash .opencode/tests/behaviors/<scenario>.sh` instead of bare `opencode-cli run` | `grep` line 144 |
| SC-2 | `verify.md` contains subsection instructing agent to use existing behavioral test scripts with `with-test-home`/`behavior_run` baked in | Read subsection (after line 168) |
| SC-3 | `verify.md` subsection includes FORBIDDEN (bare `opencode-cli run`, ad-hoc) and REQUIRED patterns | Read subsection |
| SC-4 | `start.md` Step 5.5c specifies `bash .opencode/tests/behaviors/<scenario>.sh` | Read line 24 |
| SC-5 | `checklist.md` SC Verification section includes re-run behavioral test step after prior line 38 | Read checklist section |
| SC-6 | All insertions contain consequence assertion (dark-prose-003 formula) — WHAT quality standard and WHY it matters | Read each insertion point |
| SC-7 | No blame-adjacent framing in any insertion — no "you chose to skip", no "cutting corners" | `grep` for blame-adjacent patterns across all 3 files |
| SC-8 | No tool-control in any insertion — no line-number instructions, no copy-paste templates | Read each insertion point |
| SC-9 | `checklist.md` step uses identity-frame (dark-prose-001/002) not threat (dark-prose-004) | Read addition |
| SC-10 | Per-SC evidence table format note in `verify.md` requires full command in Verification Command Run column | Read note after line 247 |

## Non-Goals

- Changes to any other file beyond the 3 task files listed
- Creating or modifying behavioral test scripts
- Changes to `with-test-home`, `helpers.sh`, or any test infrastructure file
- Backfilling existing content in these files beyond the specific insertion points
- Enforcement gate implementation (deferred to #641 per .opencode#627)

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| dark-prose-006 misinterpreted as "no constraints" — agent omits prose | Medium | Medium | SC-6 through SC-9 verify consequence assertion, no blame, no tool-control, identity-frame |
| Insertion point drift — file edits change line numbers before implementation | High | Low | Insertions are anchor-identified (after line 168, after line 38, line 144, after line 247) with surrounding context in SC text |
| Agent copies exact text from spec into files (tool-control anti-pattern) | Medium | Medium | SC-6, SC-7, SC-8 verify the result matches #627 pattern formulas, not spec text |

## References

- `.opencode#627` — Dark Prose Reference Card (pattern formulas, agency-respecting constraint, anti-patterns)
- `.opencode#622` — Confirmshaming weave (dark-prose-001 examples in routing layer)
- `.opencode#626` — Goal hijacking weave (dark-prose-002/003 examples)
- `cross-validate.md` §Step 6 — Dark pattern enforcement taxonomy
- `tests/README.md` — `with-test-home` isolation rationale
- `tests/behaviors/helpers.sh` — `behavior_run()` function
- Session trace: https://opncd.ai/share/9DpoeeuF

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
