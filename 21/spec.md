STATUS: 0.1 — Investigatory: exploring scope, no implementation commitment

---

## Problem Statement

The current identity detection pipeline in `session-init` and `session_context_identity.py` resolves `github.owner` and `github.repo` from the git remote URL of the local clone. This works correctly for the origin repository itself, but fails to account for two scenarios:

1. **Forked root repo:** When the cloned repo is a fork of another repo on GitHub or GitBucket, the agent routes issues to the fork's repo (the clone's origin) rather than the upstream/parent repo. This may or may not be desired — it depends on the developer's workflow.

2. **Submodule from a fork:** When a submodule tracks a fork, the sub-folder repo mapping resolves to the fork's repo rather than the upstream. If the developer intends to contribute upstream, issue creation targets the wrong repo.

Currently, neither GitHub MCP nor the session-init pipeline has any fork detection logic. The existing submodule routing (`issue-operations` SKILL.md §Submodule Routing for Issue Operations, `approval-gate` SKILL.md §Submodule Detection & Routing) resolves `owner/repo` from `.gitmodules` remote URLs but never checks whether those URLs point to a fork.

## Scope of Investigation

This is an **investigatory spec** — no implementation commitment. The goal is to explore:

1. **Detection mechanisms per platform:**
   - **GitHub:** `gh repo view --json isFork,parent` or `GET /repos/{owner}/{repo}` returns `fork: boolean` and a `parent` object with `full_name` and `html_url`
   - **GitBucket:** `GET /api/v3/repos/{owner}/{repo}` returns `fork: boolean` (and, in practice, a `parent` field when forked — confirmed in the OpenAPI spec at `gitbucket-api/reference/openapi-v4.42.1.json` line 128-130)

2. **Where detection should live:**
   - Option A: In `session-init` — detect fork at startup, emit an additional `github.fork: true/false` and `github.parent_owner` / `github.parent_repo` to the LLM system prompt
   - Option B: In `session_context_identity.py` — detect fork in the identity section, emit fork-aware routing guidance
   - Option C: In the individual issue-operations and approval-gate sub-agents — query fork status lazily when about to create an issue

3. **Undesired behavior scenarios (critical to enumerate):**
   - **Scenario A — Intentional fork workflow:** Developer forked a repo, made changes in their fork, and wants to track issues in their fork (not upstream). Fork detection would redirect to upstream, which is wrong.
   - **Scenario B — Fork with no upstream access:** Developer has no push access to upstream. Fork detection routes issues to upstream repo where the developer cannot create issues — API calls will 403.
   - **Scenario C — Submodule tracking a fork:** The parent repo intentionally pins a submodule to a fork (e.g., for a customized or patched dependency). Fork detection would redirect submodule issue operations to upstream, losing the fork context.
   - **Scenario D — Fork as "canonical" source:** In some org workflows, the fork is the primary development repo and upstream is read-only. Fork detection would undermine this.
   - **Scenario E — Multiple remotes:** Developer has both `origin` (their fork) and `upstream` (the parent). Which one wins? The current pipeline only reads `origin`.
   - **Scenario F — GitBucket fork resolution failure:** The GitBucket API's `parent` field may not be populated in all versions or configurations. Silent resolution failures would break issue routing.

4. **Interaction with existing routing:**
   - `identity_source` values (`root`, `submodule`, `none`) — how does fork status interact?
   - `Sub-folder Repo Mappings` — should mapped submodule repos also be fork-checked?
   - PR creation workflow — does fork status affect PR targeting?

## Questions for Investigation

1. Should fork detection be **mandatory** (agent always checks) or **opt-in** (agent checks only when a `.opencode-fork-probe` marker file exists, analogous to the Tier 3 credential probe)?

2. When a fork is detected, should the agent **default to the parent** (route issues upstream) or **default to the fork** (route issues to the clone's origin) and provide the parent as an alternative?

3. Should there be a `.opencode` configuration directive (in `opencode.jsonc` or a similar config) that explicitly sets the preferred repo for issue operations, overriding fork detection?

4. How does the fork detection interact with `github.identity_source`? Specifically, when `identity_source == "submodule"` and the submodule's remote points to a fork, should the agent route to the fork or the upstream?

5. What is the failure mode for GitBucket instances where the fork/parent API is unreliable or absent? Should we gracefully degrade (no fork detection) or fail loudly?

## Acceptance Criteria (Draft — to be finalized after investigation)

- [ ] Fork detection capability exists (API probe or CLI command) for both GitHub and GitBucket
- [ ] Fork status is available to session context (at minimum, detectable by agent)
- [ ] Undesired behavior scenarios A–F are documented with recommended resolutions
- [ ] Decision made on mandatory vs opt-in fork detection
- [ ] Decision made on default routing behavior (parent vs fork)
- [ ] Interaction with `identity_source` and submodule routing is specified
- [ ] Failure modes for unavailable/absent fork detection are defined

## Cross-References

- `session-init` (`tools/session-init` lines 764–802) — identity resolution (root, submodule, none)
- `session_context_identity.py` (`scripts/session_context_identity.py` lines 378–404) — submodule remote detection and identity section building
- `issue-operations` SKILL.md §Submodule Routing for Issue Operations — current submodule-aware issue routing
- `approval-gate` SKILL.md §Submodule Detection & Routing — current submodule detection and routing rules
- `gitbucket-api/reference/openapi-v4.42.1.json` line 128–130 — GitBucket API `fork` field definition
- `000-critical-rules.md` §Wrong API Routing for Submodule/Sub-folder Repos — current critical rule on wrong API routing
- `060-tool-usage.md` §9 Identity Source Semantics — current identity source routing table

---

STATUS: 0.1 — Investigatory: exploring scope, no implementation commitment

🤖 Co-authored with AI: OpenCode (unknown)