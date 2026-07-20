## Problem Statement

The current adversarial-audit system has grown into a high-maintenance, cloud-dependent architecture with a brittle failure mode:

| Metric | Current Value |
|--------|--------------|
| Auditor card files | 4 model-specific cards (415 lines each = 1,660 total) |
| `resolve-models` tool | 221 lines — randomly selects 2 auditors from different model families |
| `qualified-auditor-pool.sh` | 19 lines |
| Total eliminated lines | ~1,900 |
| Dispatch contract fields | 3 (`spec_local_dir`, `artifact_evidence_dir`, `audit_phase`) |
| Task files | 15, each with generic auditor persona + conditional logic on `audit_phase` |
| Cross-validate | Separate general sub-agent (not integrated into chain) |
| Dispatch model | Sequential: auditor-1 → if PASS → auditor-2 → if PASS → cross-validate |
| Remediation | Restart from `resolve-models` on any FAIL |

**Critical failure mode — `INSUFFICIENT_FAMILIES`:** When only one model family is available locally (e.g., only `deepseek` variants installed), `resolve-models` cannot select 2 auditors from different families and returns `INSUFFICIENT_FAMILIES`. This blocks ALL adversarial audits — the entire pipeline halts because the dispatch precondition cannot be met. This is a hard dependency on having ≥2 model families installed, which is not guaranteed in local/CI environments.

**Additional costs:**
- Cloud dependency: cross-model diversity requires either multiple local models (VRAM-intensive) or cloud API calls (latency, cost, credential management)
- Card maintenance: 4 auditor cards must be kept in sync — any persona update requires editing 4 files
- Conditional complexity: 15 task files each contain `if audit_phase == X` branches, making them harder to read and maintain
- Cross-validate as separate sub-agent adds an extra dispatch round-trip

## Proposed Solution

Replace the cross-model-family adversarial audit system with a **DiMo-aligned architecture**: same-model, role-differentiated agent chaining.

### Research Justification

DiMo (Diverse Multi-Agent Collaboration, He & Feng, arXiv:2510.16645) demonstrates that same-model role-differentiated agents outperform cross-model debate baselines on 5/6 benchmarks. The divergence mechanism is **architectural** (role persona + clean-room isolation + structured protocol), not model-family diversity. This means we can achieve superior audit quality with a single local model — eliminating the `INSUFFICIENT_FAMILIES` error state entirely.

### DiMo's Four Roles

| Role | Function |
|------|----------|
| **Generator** | Produces initial answer/verdict |
| **Evaluator** | Assesses correctness, identifies gaps |
| **Knowledge Supporter** | Retrieves and validates evidence |
| **Path Provider** | Constructs reasoning chains |

### DiMo's Two Interaction Protocols

| Protocol | Pattern | Used For |
|----------|---------|----------|
| **Divergent mode** | Parallel proposals → synthesis → discussion | Open-ended audits: spec-audit, content-audit, drift-detection |
| **Logical mode** | Evaluate → Refine → Judge loop | Structured audits: verification-audit, plan-fidelity, closure-verification |

### Proposed Architecture

| Component | Current | Proposed |
|-----------|---------|----------|
| Auditor cards | 4 model-specific (1,660 lines) | 1 role-differentiated card |
| `resolve-models` | 221 lines | **Eliminated** |
| `qualified-auditor-pool.sh` | 19 lines | **Eliminated** |
| Dispatch contract | 3 fields incl. `audit_phase` | 2 fields (no `audit_phase`) |
| Task files | 15 with conditionals | 15 self-contained, each with embedded DiMo role persona |
| Cross-validate | Separate sub-agent | Integrated as **Judger** role in chain |
| Dispatch model | Sequential cross-model | Sequential per-task checklist: role-1 → role-2 → role-3 → etc. |
| Remediation | Restart from `resolve-models` | Restart from step 1 of task checklist (all prior artifacts invalidated) |
| Model dependency | ≥2 model families | 1 model family (any) |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 4 model-specific auditor cards removed from `.opencode/skills/adversarial-audit/auditors/` | `structural` | File existence check — 0 auditor card files remain |
| SC-2 | `resolve-models` tool removed from `.opencode/tools/` | `structural` | File existence check — tool absent |
| SC-3 | `qualified-auditor-pool.sh` removed | `structural` | File existence check — file absent |
| SC-4 | 1 role-differentiated auditor card replaces the 4 model-specific cards | `structural` | Single `auditor-role.md` (or equivalent) exists with all 4 DiMo roles defined |
| SC-5 | Dispatch contract reduced to 2 fields: `spec_local_dir`, `artifact_evidence_dir` | `string` | Grep all task files — no `audit_phase` references in dispatch contracts |
| SC-6 | All 15 task files self-contained with embedded DiMo role persona — no conditional logic on `audit_phase` | `string` | Grep all task files — zero `if audit_phase` or equivalent conditional branches |
| SC-7 | Cross-validate integrated as Judger role in the task checklist chain | `string` | Grep task files — Judger role referenced in checklist, no separate cross-validate dispatch |
| SC-8 | Sequential dispatch per task checklist: role-1 → if PASS → role-2 → if PASS → role-3 → etc. | `string` | Grep task files — sequential role chain pattern present |
| SC-9 | Remediation restarts from step 1 of task checklist (all prior artifacts invalidated) | `string` | Grep task files — remediation section specifies full restart |
| SC-10 | No `INSUFFICIENT_FAMILIES` error state exists in any remaining code | `string` | Grep codebase — zero occurrences of `INSUFFICIENT_FAMILIES` |
| SC-11 | Behavioral: agent dispatches DiMo role chain (not cross-model auditors) during adversarial audit | `behavioral` | `opencode-cli run` with audit prompt → stderr shows role-differentiated dispatch, not `resolve-models` |
| SC-12 | Behavioral: agent handles single-model-family environment without error | `behavioral` | `opencode-cli run` in environment with 1 model family → audit completes without `INSUFFICIENT_FAMILIES` |

## Phases

### Phase 1: Eliminate Cross-Model Infrastructure
- Remove 4 auditor card files from `.opencode/skills/adversarial-audit/auditors/`
- Remove `resolve-models` tool from `.opencode/tools/`
- Remove `qualified-auditor-pool.sh`
- Remove `INSUFFICIENT_FAMILIES` error handling from any remaining code
- **Deliverable:** Clean deletion of ~1,900 lines

### Phase 2: Create DiMo Role-Differentiated Auditor Card
- Create single `auditor-role.md` (or equivalent) defining all 4 DiMo roles: Generator, Evaluator, Knowledge Supporter, Path Provider
- Define both interaction protocols: Divergent mode and Logical mode
- Define Judger role for cross-validate integration
- **Deliverable:** 1 role card replacing 4 model-specific cards

### Phase 3: Refactor 15 Task Files
- Remove `audit_phase` from dispatch contracts (reduce to 2 fields)
- Embed DiMo role persona in each task file (no conditionals)
- Integrate cross-validate as Judger role in each task's checklist
- Convert dispatch model to sequential role chain per checklist
- Update remediation sections to specify full restart from step 1
- **Deliverable:** 15 self-contained task files, zero conditionals

### Phase 4: Update SKILL.md and Dispatch Logic
- Update `adversarial-audit/SKILL.md` to reference DiMo architecture
- Remove `resolve-models` from dispatch routing
- Update dispatch contract documentation
- **Deliverable:** Updated SKILL.md with DiMo-aligned dispatch

### Phase 5: Behavioral Tests
- Write behavioral enforcement test for SC-11 (DiMo role chain dispatch)
- Write behavioral enforcement test for SC-12 (single-model-family resilience)
- **Deliverable:** 2 behavioral tests, RED before GREEN

## Change Control

| Section | Scope |
|---------|-------|
| `.opencode/skills/adversarial-audit/auditors/` | Delete 4 files |
| `.opencode/tools/resolve-models` | Delete file |
| `.opencode/tools/qualified-auditor-pool.sh` | Delete file |
| `.opencode/skills/adversarial-audit/` | Create 1 role card, modify 15 task files, modify SKILL.md |
| `.opencode/tests/behaviors/` | Create 2 behavioral test scripts |

**No changes outside `.opencode/`.** This is a self-contained refactor of the adversarial-audit skill and its supporting infrastructure.

## References

- He & Feng, "DiMo: Diverse Multi-Agent Collaboration" (arXiv:2510.16645)
- Current adversarial-audit skill: `.opencode/skills/adversarial-audit/SKILL.md`
- Current auditor cards: `.opencode/skills/adversarial-audit/auditors/`
- Current resolve-models tool: `.opencode/tools/resolve-models`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)