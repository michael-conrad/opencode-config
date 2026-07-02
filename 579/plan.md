# Plan: Upstream bug report filing — standalone `upstream-report` skill

**Spec:** [michael-conrad/.opencode#579](https://github.com/michael-conrad/.opencode/issues/579)
**Authorization scope:** `for_pr` (label: `approved-for-plan`)
**Plan structure:** Combined (single skill directory, multiple task files, one concern boundary)

**Path resolution:** `*/.issues/{N}/plan.md` is repo-relative. For files in `.opencode/skills/`, it resolves to `.opencode/.issues/{N}/plan.md`. For files in the parent repo, it resolves to `.issues/{N}/plan.md`.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
>
> **One step at a time protocol:** Execute exactly one item per phase before advancing. Do not batch items. Do not skip items. Each item is a self-contained unit of work with its own RED→GREEN→doublecheck→commit cycle. The pipeline gates (G1-G16) enforce this sequencing — do not advance past a gate until it returns PASS.
>
> **Self-remediation protocol:** If a pipeline gate returns FAIL, remediate the root cause and re-run the gate. Do not reclassify FAIL as PASS. Do not skip the gate. Do not proceed past FAIL. Only after remediation + re-verification PASS may the next gate proceed. If re-verification also fails, HALT and report the double-failure with both failure artifacts.

## Architecture

**Goal:** Create a standalone `upstream-report` skill at `.opencode/skills/upstream-report/` that codifies proper upstream bug report filing: target resolution, template discovery, content stripping, claim verification, platform filing, and local tracking.

**Tech stack:** Markdown skill/task files, GitHub MCP for template fetching and filing, `gb` CLI for GitBucket filing, `local-issues` tool for local tracking.

**File structure:**
- `.opencode/skills/upstream-report/SKILL.md` — Main skill definition (frontmatter, overview, persona, trigger dispatch table, tasks, invocation)
- `.opencode/skills/upstream-report/tasks/` — 8 task files:
  - `classify.md` — Context classifier gate (internal bug vs upstream report)
  - `resolve-target.md` — Upstream repo resolution with fallback to explicit parameter
  - `discover-template.md` — Template discovery (fetch upstream `.github/ISSUE_TEMPLATE/bug-report.md`)
  - `strip-content.md` — Content stripping (remove RCA, fix suggestions, botsplaining)
  - `verify-claims.md` — Claim verification against live sources
  - `file-report.md` — Filing via correct platform API (GitHub MCP or `gb`)
  - `track-local.md` — Local `.issues/` tracking entry creation
  - `completion.md` — Workflow completion

## Phases

### Global Pre-Phase: Skill scaffold

**Concern:** Create the skill directory structure and SKILL.md with frontmatter, overview, persona, trigger dispatch table, tasks list, invocation section, and authorization model documentation (SC-9).
**Files:** `.opencode/skills/upstream-report/SKILL.md`
**SCs covered:** SC-1, SC-9

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1, SC-9 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-1 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-1 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-1 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-1 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-1 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1, SC-9 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1, SC-9 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": "pre"}` | SC-1 |

**RED condition:** No `.opencode/skills/upstream-report/` directory exists; no SKILL.md file.
**GREEN condition:** `.opencode/skills/upstream-report/SKILL.md` exists with frontmatter, overview, persona, trigger dispatch table, tasks list, invocation section, and authorization model documenting `for_analysis` scope.

**Items:**
- [ ] 1. **RED** — Verify no `.opencode/skills/upstream-report/` directory exists (RED condition: absent)
- [ ] 2. **GREEN** — Create `.opencode/skills/upstream-report/` directory
- [ ] 3. **GREEN** — Create `SKILL.md` with frontmatter (name, description, license, compatibility), overview, persona, trigger dispatch table, tasks list, invocation section
- [ ] 4. **GREEN** — Document authorization model: upstream filing is `for_analysis` scope (reporting action per `010-approval-gate.md`)
- [ ] 5. **DOUBLECHECK** — Verify SKILL.md exists with all required sections; verify RED condition no longer holds
- [ ] 6. **COMMIT** — Commit SKILL.md with message "feat: create upstream-report skill scaffold"

---

### Phase 1: `classify.md` — Context classifier gate

**Concern:** Gate that distinguishes internal bugs (our repos) from upstream reports (external repos). Routes internal bugs to `issue-review --task analyze-and-spec`, upstream reports to the upstream-report workflow.
**Files:** `.opencode/skills/upstream-report/tasks/classify.md`
**SCs covered:** SC-2

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-2 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-2 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-2 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-2 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-2 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-2 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 1}` | SC-2 |

**RED condition:** No `classify.md` task file exists; or existing file does not implement the context classifier gate.
**GREEN condition:** `classify.md` exists with entry criteria, exit criteria, procedure steps for: checking target repo owner against session-init repo information, routing internal bugs to `issue-review --task analyze-and-spec`, routing upstream reports to upstream-report workflow.

**Items:**
- [ ] 7. (**sub-agent**) **RED** — Verify no `classify.md` task file exists (RED condition: absent)
- [ ] 8. (**sub-agent**) **GREEN** — Create `classify.md` with entry criteria (target repo owner/repo known), exit criteria (classification verdict: internal or upstream)
- [ ] 9. (**sub-agent**) **GREEN** — Procedure: compare target repo owner against session-init repo information table; if match → internal (route to analyze-and-spec); if no match → upstream (proceed with upstream-report workflow)
- [ ] 10. (**sub-agent**) **GREEN** — Document the classification logic and routing decision
- [ ] 11. (**inline**) **DOUBLECHECK** — Verify classify.md exists with all required sections; verify RED condition no longer holds
- [ ] 12. (**inline**) **COMMIT** — Commit classify.md with message "feat(upstream-report): add context classifier gate"

---

### Phase 2: `resolve-target.md` — Upstream repo resolution

**Concern:** Determine the upstream repo owner/name for filing. Depends on #601 Fork Detection for fork scenarios; implements fallback to explicit parameter when fork detection unavailable.
**Files:** `.opencode/skills/upstream-report/tasks/resolve-target.md`
**SCs covered:** SC-8

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-8 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-8 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-8 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-8 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-8 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-8 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 2}` | SC-8 |

**RED condition:** No `resolve-target.md` task file exists; or existing file does not implement fallback resolution.
**GREEN condition:** `resolve-target.md` exists with: primary path using #601 Fork Detection when available, fallback path accepting explicit `target_owner`/`target_repo` parameters, dependency declaration on #601.

**Items:**
- [ ] 13. (**sub-agent**) **RED** — Verify no `resolve-target.md` task file exists (RED condition: absent)
- [ ] 14. (**sub-agent**) **GREEN** — Create `resolve-target.md` with entry criteria (target repo identifier or explicit owner/repo), exit criteria (resolved upstream owner/repo)
- [ ] 15. (**sub-agent**) **GREEN** — Procedure: attempt fork detection via #601; if unavailable, use explicit parameter fallback
- [ ] 16. (**sub-agent**) **GREEN** — Document dependency on #601 and the fallback behavior
- [ ] 17. (**inline**) **DOUBLECHECK** — Verify resolve-target.md exists with all required sections; verify RED condition no longer holds
- [ ] 18. (**inline**) **COMMIT** — Commit resolve-target.md with message "feat(upstream-report): add upstream repo resolution with #601 fallback"

---

### Phase 3: `discover-template.md` — Template discovery

**Concern:** Fetch the upstream repo's `.github/ISSUE_TEMPLATE/bug-report.md` and respect its structure when filing.
**Files:** `.opencode/skills/upstream-report/tasks/discover-template.md`
**SCs covered:** SC-3

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-3 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-3 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-3 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-3 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-3 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-3 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 3}` | SC-3 |

**RED condition:** No `discover-template.md` task file exists; or existing file does not implement template fetching.
**GREEN condition:** `discover-template.md` exists with: procedure to fetch upstream `.github/ISSUE_TEMPLATE/bug-report.md` via `github_get_file_contents`, parse template structure, and respect its sections when composing the report body.

**Items:**
- [ ] 19. (**sub-agent**) **RED** — Verify no `discover-template.md` task file exists (RED condition: absent)
- [ ] 20. (**sub-agent**) **GREEN** — Create `discover-template.md` with entry criteria (resolved upstream owner/repo), exit criteria (template structure parsed and available for report composition)
- [ ] 21. (**sub-agent**) **GREEN** — Procedure: call `github_get_file_contents` for `.github/ISSUE_TEMPLATE/bug-report.md`; if not found, try `ISSUE_TEMPLATE.md`; if neither exists, proceed with standard format
- [ ] 22. (**sub-agent**) **GREEN** — Parse template sections and make them available for report composition
- [ ] 23. (**inline**) **DOUBLECHECK** — Verify discover-template.md exists with all required sections; verify RED condition no longer holds
- [ ] 24. (**inline**) **COMMIT** — Commit discover-template.md with message "feat(upstream-report): add template discovery for upstream bug-report.md"

---

### Phase 4: `strip-content.md` — Content stripping

**Concern:** Remove RCA, fix suggestions, botsplaining, and internal implementation details from the report body before filing.
**Files:** `.opencode/skills/upstream-report/tasks/strip-content.md`
**SCs covered:** SC-4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-4 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-4 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-4 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-4 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-4 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-4 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 4}` | SC-4 |

**RED condition:** No `strip-content.md` task file exists; or existing file does not implement content stripping rules.
**GREEN condition:** `strip-content.md` exists with: rules for removing RCA sections, fix suggestions, botsplaining (excessive explanation of stack traces), and internal implementation details; procedure to apply stripping before filing.

**Items:**
- [ ] 25. (**sub-agent**) **RED** — Verify no `strip-content.md` task file exists (RED condition: absent)
- [ ] 26. (**sub-agent**) **GREEN** — Create `strip-content.md` with entry criteria (draft report body), exit criteria (stripped report body with only: What happened, How to reproduce, Environment)
- [ ] 27. (**sub-agent**) **GREEN** — Define stripping rules: remove root cause analysis, remove suggested fixes, remove botsplaining (explanations of what stack traces mean), remove internal implementation details
- [ ] 28. (**sub-agent**) **GREEN** — Procedure: apply rules sequentially, verify stripped content meets the 3-section constraint
- [ ] 29. (**inline**) **DOUBLECHECK** — Verify strip-content.md exists with all required sections; verify RED condition no longer holds
- [ ] 30. (**inline**) **COMMIT** — Commit strip-content.md with message "feat(upstream-report): add content stripping rules"

---

### Phase 5: `verify-claims.md` — Claim verification

**Concern:** Verify all reproduction claims against live sources before filing. Reuses patterns from `verification` and `verification-enforcement` skills.
**Files:** `.opencode/skills/upstream-report/tasks/verify-claims.md`
**SCs covered:** SC-5

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-5 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-5 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-5 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-5 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-5 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-5 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 5}` | SC-5 |

**RED condition:** No `verify-claims.md` task file exists; or existing file does not implement claim verification.
**GREEN condition:** `verify-claims.md` exists with: procedure to verify each reproduction claim against live sources (code state, logs, configuration), reference to `verification` and `verification-enforcement` skill patterns.

**Items:**
- [ ] 31. (**sub-agent**) **RED** — Verify no `verify-claims.md` task file exists (RED condition: absent)
- [ ] 32. (**sub-agent**) **GREEN** — Create `verify-claims.md` with entry criteria (draft report body with claims), exit criteria (all claims verified PASS or removed)
- [ ] 33. (**sub-agent**) **GREEN** — Procedure: extract claims from report body, verify each against live sources, remove unverifiable claims
- [ ] 34. (**sub-agent**) **GREEN** — Reference reusable patterns from `verification` and `verification-enforcement` skills
- [ ] 35. (**inline**) **DOUBLECHECK** — Verify verify-claims.md exists with all required sections; verify RED condition no longer holds
- [ ] 36. (**inline**) **COMMIT** — Commit verify-claims.md with message "feat(upstream-report): add claim verification workflow"

---

### Phase 6: `file-report.md` — Filing via platform API

**Concern:** File the report via the correct platform API (GitHub MCP for github.com, `gb` for GitBucket). Reuses `issue-operations` platform routing.
**Files:** `.opencode/skills/upstream-report/tasks/file-report.md`
**SCs covered:** SC-6

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-6 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-6 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-6 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-6 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-6 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-6 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 6}` | SC-6 |

**RED condition:** No `file-report.md` task file exists; or existing file does not implement platform-aware filing.
**GREEN condition:** `file-report.md` exists with: procedure to determine target platform (GitHub vs GitBucket), file via `github_issue_write` or `gb` CLI, extract `html_url` from response.

**Items:**
- [ ] 37. (**sub-agent**) **RED** — Verify no `file-report.md` task file exists (RED condition: absent)
- [ ] 38. (**sub-agent**) **GREEN** — Create `file-report.md` with entry criteria (stripped and verified report body, resolved target owner/repo), exit criteria (report filed, `html_url` extracted)
- [ ] 39. (**sub-agent**) **GREEN** — Procedure: determine platform from target repo URL; file via GitHub MCP (`github_issue_write`) or `gb` CLI; extract `html_url` from API response
- [ ] 40. (**sub-agent**) **GREEN** — Reference `issue-operations` platform routing patterns
- [ ] 41. (**inline**) **DOUBLECHECK** — Verify file-report.md exists with all required sections; verify RED condition no longer holds
- [ ] 42. (**inline**) **COMMIT** — Commit file-report.md with message "feat(upstream-report): add platform-aware filing"

---

### Phase 7: `track-local.md` — Local tracking

**Concern:** Create a local `.issues/` tracking entry mirroring the filed report for audit trail. Adapts `issue-operations import-remote` pattern.
**Files:** `.opencode/skills/upstream-report/tasks/track-local.md`
**SCs covered:** SC-7

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-7 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 7}` | SC-7 |

**RED condition:** No `track-local.md` task file exists; or existing file does not implement local tracking.
**GREEN condition:** `track-local.md` exists with: procedure to create `.issues/{N}/` entry with upstream issue URL, report body, and metadata; reference to `issue-operations import-remote` pattern.

**Items:**
- [ ] 43. (**sub-agent**) **RED** — Verify no `track-local.md` task file exists (RED condition: absent)
- [ ] 44. (**sub-agent**) **GREEN** — Create `track-local.md` with entry criteria (filed report URL, report body), exit criteria (local `.issues/` entry created)
- [ ] 45. (**sub-agent**) **GREEN** — Procedure: use `local-issues create` to create tracking entry; store upstream URL, report body, and metadata
- [ ] 46. (**sub-agent**) **GREEN** — Reference `issue-operations import-remote` pattern for adaptation
- [ ] 47. (**inline**) **DOUBLECHECK** — Verify track-local.md exists with all required sections; verify RED condition no longer holds
- [ ] 48. (**inline**) **COMMIT** — Commit track-local.md with message "feat(upstream-report): add local tracking"

---

### Phase 8: `completion.md` — Workflow completion

**Concern:** Standard completion task for the upstream-report workflow — push, URL generation, lifecycle event append, executive summary.
**Files:** `.opencode/skills/upstream-report/tasks/completion.md`
**SCs covered:** (structural — standard completion pattern)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 8}` | — |

**RED condition:** No `completion.md` task file exists.
**GREEN condition:** `completion.md` exists with: push, URL generation, lifecycle event append, executive summary reporting per `completion-core` skill pattern.

**Items:**
- [ ] 49. (**sub-agent**) **RED** — Verify no `completion.md` task file exists (RED condition: absent)
- [ ] 50. (**sub-agent**) **GREEN** — Create `completion.md` with standard completion workflow: push, URL generation, lifecycle event append, executive summary
- [ ] 51. (**inline**) **DOUBLECHECK** — Verify completion.md exists with all required sections; verify RED condition no longer holds
- [ ] 52. (**inline**) **COMMIT** — Commit completion.md with message "feat(upstream-report): add completion task"

---

### Phase 9: Behavioral enforcement tests

**Concern:** Create behavioral enforcement test scripts for SC-2 through SC-7.
**Files:** `.opencode/tests/behaviors/579-*.sh`
**SCs covered:** SC-2 through SC-7 (behavioral)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G4: z3-check-red | inline | N/A | N/A | — | SC-2..SC-7 |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | SC-2..SC-7 |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G8: z3-check-post-red | inline | N/A | N/A | — | SC-2..SC-7 |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G10: z3-check-green | inline | N/A | N/A | — | SC-2..SC-7 |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G12: z3-check-post-green | inline | N/A | N/A | — | SC-2..SC-7 |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G14: checkpoint-commit | inline | N/A | N/A | — | SC-2..SC-7 |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 9}` | SC-2..SC-7 |

**RED condition:** Behavioral tests for SC-2 through SC-7 do not exist or do not fail (RED not verified).
**GREEN condition:** All behavioral tests exist, pass RED phase (fail before implementation), and pass GREEN phase (pass after implementation).

**Items:**
- [ ] 53. (**sub-agent**) **RED** — Verify no behavioral test files exist for SC-2 through SC-7 (RED condition: absent)
- [ ] 54. (**sub-agent**) **GREEN** — Create `579-sc2-context-classifier.sh` — behavioral test for SC-2 (context classifier gate)
- [ ] 55. (**sub-agent**) **GREEN** — Create `579-sc3-template-discovery.sh` — behavioral test for SC-3 (template discovery)
- [ ] 56. (**sub-agent**) **GREEN** — Create `579-sc4-content-stripping.sh` — behavioral test for SC-4 (content stripping)
- [ ] 57. (**sub-agent**) **GREEN** — Create `579-sc5-claim-verification.sh` — behavioral test for SC-5 (claim verification)
- [ ] 58. (**sub-agent**) **GREEN** — Create `579-sc6-platform-filing.sh` — behavioral test for SC-6 (platform API filing)
- [ ] 59. (**sub-agent**) **GREEN** — Create `579-sc7-local-tracking.sh` — behavioral test for SC-7 (local tracking)
- [ ] 60. (**inline**) **DOUBLECHECK** — Verify all behavioral tests exist and pass RED phase (fail before implementation)
- [ ] 61. (**inline**) **COMMIT** — Commit all behavioral tests with message "test(upstream-report): add behavioral enforcement tests for SC-2 through SC-7"

---

### Phase 10: Finishing and delivery

**Concern:** Finishing checklist, PR creation, post-merge cleanup.
**Files:** (structural — no new files)
**SCs covered:** (structural — standard delivery)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G4: z3-check-red | inline | N/A | N/A | — | — |
| G5: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G6: z3-check-red-doublecheck | inline | N/A | N/A | — | — |
| G7: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G8: z3-check-post-red | inline | N/A | N/A | — | — |
| G9: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G10: z3-check-green | inline | N/A | N/A | — | — |
| G11: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G12: z3-check-post-green | inline | N/A | N/A | — | — |
| G13: checkpoint-tag-create | sub-task | yes (blind) | general | `{"task": "execute checkpoint-tag-create from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G14: checkpoint-commit | inline | N/A | N/A | — | — |
| G15: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G16: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G17: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G18: resolve-models | sub-task | yes (blind) | general | `{"task": "execute resolve-models from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G19: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G20: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G21: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G22: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |
| G23: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 579, "phase": 10}` | — |

**RED condition:** Uncommitted changes exist or git status is dirty.
**GREEN condition:** All changes committed, lint/typecheck passes, PR created with `html_url` extracted from API response.

**Items:**
- [ ] 62. (**inline**) **FINISHING** — Run finishing checklist (git status clean, lint/typecheck)
- [ ] 63. (**inline**) **PR** — PR creation via `github_create_pull_request`, extract `html_url` from response

## Self-Review Evidence

| Check | Status | Evidence |
|-------|--------|----------|
| All SCs covered by phases | ✅ PASS | SC-1→Pre, SC-2→1+Post, SC-3→3+Post, SC-4→4+Post, SC-5→5+Post, SC-6→6+Post, SC-7→7+Post, SC-8→2, SC-9→Pre |
| Phase ordering correct per dependency contract | ✅ PASS | Z3 SAT verified: all_phases_done reachable, 10-step plan found |
| No missing phases | ✅ PASS | 10 phases (Pre, 1-8, Post) cover all 8 task files + SKILL.md + behavioral tests |
| All required task files listed | ✅ PASS | 8 task files (classify, resolve-target, discover-template, strip-content, verify-claims, file-report, track-local, completion) + SKILL.md |
| Dependency contract verified | ✅ PASS | Z3 SOLVED_SATISFICING — all preconditions and invariants satisfied |
| Clean-room plan reconciled | ✅ PASS | Existing plan covers all 8 clean-room phases with additional detail (gate tables, SC matrix, dependency contract) |

## SC Coverage

| SC ID | Criterion | Evidence Type | Phases |
|-------|----------|---------------|--------|
| SC-1 | Skill exists at `.opencode/skills/upstream-report/` with SKILL.md and task files | structural | Pre |
| SC-2 | Context classifier gate routes internal bugs to analyze-and-spec, upstream to upstream-report | behavioral | 1, Post |
| SC-3 | Template discovery fetches and respects upstream `.github/ISSUE_TEMPLATE/bug-report.md` | behavioral | 3, Post |
| SC-4 | Content stripping removes RCA, fix suggestions, botsplaining | behavioral | 4, Post |
| SC-5 | Claim verification against live sources before filing | behavioral | 5, Post |
| SC-6 | Filing via correct platform API (GitHub MCP or `gb`) | behavioral | 6, Post |
| SC-7 | Local `.issues/` tracking entry mirroring filed report | behavioral | 7, Post |
| SC-8 | Dependency on #601 (Fork Detection) declared | structural | 2 |
| SC-9 | Authorization model documented: `for_analysis` scope | structural | Pre |

## Dependency Contract

```
Phase dependencies:
  Pre (scaffold) → independent (no deps)
  Phase 1 (classify) → independent (no deps)
  Phase 2 (resolve-target) → independent (no deps)
  Phase 3 (discover-template) → depends on Phase 2 (need resolved target)
  Phase 4 (strip-content) → independent (no deps)
  Phase 5 (verify-claims) → independent (no deps)
  Phase 6 (file-report) → depends on Phase 3 (template), Phase 4 (stripped content), Phase 5 (verified claims)
  Phase 7 (track-local) → depends on Phase 6 (filed report URL)
  Phase 8 (completion) → depends on all prior phases
  Post (behavioral tests) → depends on all prior phases

SC dependencies:
  SC-3 → depends on SC-8 (template discovery needs resolved target)
  SC-6 → depends on SC-3, SC-4, SC-5 (filing needs template + stripped content + verified claims)
  SC-7 → depends on SC-6 (local tracking needs filed report URL)
```

## Post-All-Phases Sweep

- [ ] POST-MERGE CLEANUP — delete merged branches, close issues, sync dev

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
