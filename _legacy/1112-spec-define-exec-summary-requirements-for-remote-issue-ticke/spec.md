## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem | Spec-creation skill's `write.md` Step 7 defines only a chat output format for spec results. It has no definition of what the remote issue ticket body should contain when the canonical spec lives in a local artifact. This creates inconsistent, incomplete stakeholder-facing issue bodies across projects. |
| Approach | Define a 6-part mandatory exec summary body structure for any remote issue ticket (platform-agnostic: GitHub, GitBucket, Jira, etc.) and update `spec-creation/write.md` and related skills to enforce it. |
| Key Decisions | Platform-agnostic — no hardcoded GitHub/GitBucket tool names; all links are full resolved URLs from session-init; repo-awareness guard required to prevent cross-repo link errors |
| Alternatives | Keep current freeform approach (rejected: produces inconsistent stakeholder-facing docs). Use platform-specific templates (rejected: violates platform-agnostic mandate). |
| Scope | spec-creation write.md task, issue-operations creation task, and any other skill that creates remote issue body content |

## Problem

The `spec-creation/write.md` Step 7 defines only the chat output format for when a spec is created (brief exec summary + URL + byline in chat output). It does NOT define what the remote issue ticket body should contain when the canonical spec lives in a local artifact (`.issues/N/spec.md` on `issues-data` branch). This gap means:

- Stakeholder-facing issue bodies are inconsistent across repos
- AI agents lack a clear directive to read the local spec, not the exec summary
- No spec reference blockquote exists pointing to the local artifact
- Links use platform-specific shortcuts instead of full resolved URLs
- No repo-awareness guard prevents cross-repo link errors
- Step 7 conflates two outputs (remote issue creation and chat output) into a single step
- Step 7 only knows about `github_issue_write` as the persistence mechanism, ignoring the local `.issues/N/spec.md` mirror requirement
- Step 3 defines a 4-column SC table format (ID, Criterion, Verification Method, Remediation) that conflicts with the 12-column format used elsewhere in the skill

## Requirements

### R-1: Remote Issue Body Structure

Every remote issue ticket body created by `issue-operations` MUST include the following sections, in order:

#### 1. Spec Reference Blockquote (mandatory — top of body, before all other content)

```
> Full spec and plan artifacts: {{REMOTE_BROWSER_URL}}/{{OWNER}}/{{REPO}}/tree/{{SPEC_BRANCH}}/{{SPEC_PATH}}
```

Resolution rules:
- `{{REMOTE_BROWSER_URL}}` — resolved from session-init (platform-agnostic)
- `{{OWNER}}` / `{{REPO}}` — resolved from session-init, verified against the target issue's repo context
- `{{SPEC_BRANCH}}` — always `issues-data`
- `{{SPEC_PATH}}` — always `.issues/N/`

Repo-awareness guard: before resolving, confirm `owner`/`repo` matches the target issue's repository. All links MUST be full resolved URLs — no platform-specific shortcuts (`#NNN`, `owner/repo#NNN`).

#### 2. Problem (mandatory)

What problem this solves, why now, business/user impact. BLUF — lead with outcome, not mechanism.

#### 3. Scope (mandatory)

3-5 bullets in-scope. Explicit out-of-scope list. Stakeholder-facing outcomes, not implementation details.

#### 4. Approach (mandatory)

High-level solution in 3-5 sentences. Names the approach, not the implementation.

#### 5. Impact (mandatory)

Top 3 risks with one-line mitigation. Key dependencies. Call to action.

#### 6. AI Agent Instructions (mandatory)

```
## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at {{SPEC_PATH}}.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.
```

### R-2: Constraints

| Constraint | Value |
|------------|-------|
| Length | 150-300 words, 1 page max |
| Structure | BLUF — conclusion/action first, context second, evidence third |
| Tone | Assertive, decision-oriented, jargon-free, third-person |
| Independence | Fully readable without clicking any link |
| Links | All links MUST be full resolved URLs from session-init — no platform-specific shortcuts. Repo-awareness guard required. |
| Exclusions | No implementation details, file paths, algorithms, methodology, unreferenced acronyms |
| Platform | Platform-agnostic — no hardcoded GitHub/GitBucket tool names |

### R-3: Changes to spec-creation/write.md

1. Add new section "Remote Issue Body Format" (before or in Step 7) defining the 6-part structure
2. Keep Step 7 chat output format as-is (that's the agent's chat message, not the issue body)
3. Add the AI Agent Instructions section requirement
4. Add the spec reference blockquote requirement
5. Add full URL requirement with repo-awareness guard
6. Add tone/length/exclusions constraints table
7. Clarify that the Intent and Executive Summary 5-field table (Step 5) goes in the local spec, NOT the remote issue body
8. Resolve SC table format discrepancy: Ensure the 4-column SC table format in Step 3 (ID, Criterion, Verification Method, Remediation) is consistent with the 12-column format used elsewhere in the skill. The SC table format MUST be the same across all sections.
9. Add remote exec summary persistence: Step 7 MUST include a step to save the remote issue body (exec summary) to `.issues/N/remote-exec-summary.md` as a local mirror companion. Both persistence paths must be defined: remote issue via `github_issue_write` and local mirror via `.issues/N/remote-exec-summary.md`. The full authoritative spec remains at `.issues/N/spec.md` (created during spec authoring, not during Step 7).

### R-4: Changes to other skills

- `issue-operations` creation task: MUST implement the exec summary body structure when creating issues
- Any other skill that creates remote issue body content: same requirement

### R-5: Minimize redesign surface

Do NOT change the spec-creation pipeline flow, sub-agent routing, or task decomposition structure. This is a content-format change to the issue body only.

## Out of Scope

- Changes to the local spec format (`.issues/N/spec.md`)
- Changes to the brainstorming skill
- Changes to the spec-audit or adversarial-audit skills
- Changes to sub-agent routing or pipeline flow

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Pipeline Step Binding | Phase Binding |
|----|-----------|---------------|---------------------|----------------------|---------------|
| SC-1 | write.md includes a "Remote Issue Body Format" section with the 6-part structure | `string` | grep for "Remote Issue Body Format" heading in write.md | green-phase | 1 |
| SC-2 | write.md includes the AI Agent Instructions section requirement | `string` | grep for "AI Agent Instructions" in write.md | green-phase | 1 |
| SC-3 | write.md includes the spec reference blockquote requirement with repo-awareness guard | `string` | grep for "Repo-awareness guard" and "blockquote" in write.md | green-phase | 1 |
| SC-4 | write.md includes the full URL requirement (no shortcuts) | `string` | grep for "full resolved URL" and "no platform-specific shortcuts" in write.md | green-phase | 1 |
| SC-5 | write.md includes the tone/length/exclusions constraints table | `string` | grep for "Constraints table" or "| Constraint | Value |" in write.md | green-phase | 1 |
| SC-6 | write.md clarifies that the 5-field preamble belongs in local spec only | `string` | grep for "Intent and Executive Summary 5-field table" in write.md | green-phase | 1 |
| SC-7 | issue-operations creation task produces exec summary bodies with the 6-part structure | `behavioral` | `opencode-cli run` with spec-creation prompt, verify stderr shows issue body with all 6 sections | green-phase | 1 |
| SC-8 | issue body contains a full resolved URL (not shortcut) to the local spec artifact | `behavioral` | `opencode-cli run` with spec-creation prompt, verify stderr shows full GitHub URL (not `#NNN`) | green-phase | 1 |
| SC-9 | issue body contains the AI Agent Instructions section | `behavioral` | `opencode-cli run` with spec-creation prompt, verify stderr shows "## AI Agent Instructions" section | green-phase | 1 |
| SC-10 | No hardcoded GitHub/GitBucket platform-specific tool names in exec summary formatting | `string` | grep for "github_issue_write" or "gitbucket-api" in write.md Step 7r section — MUST NOT appear | green-phase | 1 |
| SC-11 | Existing behavioral tests for spec-creation and issue-operations still pass | `behavioral` | `bash .opencode/tests/test-enforcement.sh --tag spec-creation` and `--tag issue-operations` — all PASS | regression-check | 1 |
| SC-12 | Step 3 SC table format is consistent with the 12-column format used elsewhere in write.md | `structural` | Verify write.md Step 3 uses same 12-column format as the SC table in Step 3 section — grep for column count match | green-phase | 1 |
| SC-13 | Step 7 saves remote issue body mirror to `.issues/N/remote-exec-summary.md` as a companion to remote issue creation | `structural` | grep for "remote-exec-summary.md" in write.md Step 7 | green-phase | 1 |

## Cost Model

| Evidence Type | Cost (DDL) | What It Verifies |
|---------------|-----------|------------------|
| `behavioral` | Cheapest | Exercises actual path — PASS is ground truth |
| `semantic` | ↓ | Intent via analytical judgment |
| `string` | ↓ | Pattern presence via grep |
| `structural` | Most expensive | File/ref existence via ls |



🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
