---
number: 4
title: "[AGENT-BEHAVIOR] URL Format Verification Gate Missing at Halt Points"
status: open
labels: [SPEC, needs-approval]
created: "2026-04-25T14:35:00Z"
updated: "2026-04-25T14:36:00Z"
github_issue: null
author: michael-conrad
---

## Objective

Fix the agent's reasoning pipeline to ensure mandatory halt-point URL verification is performed before output generation. The agent must enforce its own contract autonomously, not rely on external prompting for format compliance.

## Incident Log

| Timestamp | Agent | Stated Action | Actual Action | Deviation |
|---|---|---|---|---|
| 2026-04-25 14:05Z | OpenCode | Reported creating fix-spec | Produced markdown output with title `## Root Cause Analysis...` but **omitted mandatory Compare URL** | Violated halt-point format: produced dev-focused output instead of stakeholder summary |
| 2026-04-25 14:08Z | OpenCode | Reported "Fix-spec created, Phase 1 staged" | Still omitted Compare URL despite branch existing in local repo | Skipped `review-prep` step |
| 2026-04-25 14:10Z | User | Demanded mandatory URL | Agent acknowledged error as "contract breach" | Correctly identified rule, but still failed to produce proper halt-point output after user forced intervention |

## Root Cause

The agent treats halt-point output as a **notification** rather than a **contractual deliverable**. Specifically:

1. **Skipped `review-prep`**: The agent failed to invoke `git-workflow --task review-prep` to push the branch and generate the `compare/dev...<branch>` URL.
2. **No verification gate**: The agent's reasoning does not include a "Halt-Point Format Check" step before emitting output.
3. **No auto-fix loop**: When the user pointed out the missing URL, the agent should have **auto-corrected** the output inline (regenerated the summary block with the URL) rather than just acknowledging the error.

The underlying cause is that the agent's system prompt emphasizes "helpful, concise, and accurate" but does not enforce "self-verifying and contract-compliant" as a mandatory reasoning step.

## Behavioral Requirement (from 000-critical-rules.md)

### Halt-Point Format Contract

```text
**Summary:**

<1-2 sentences describing impact and stakeholder value.>

**Outcome:** <What changed for stakeholders>

<Compare URL or Issue URL>  ← MANDATORY WHEN BRANCH PUSHED / ISSUE CREATED

🤖 <AgentName> (<ModelId>) <status-icon> <status>
```

### URL Label/Format Binding

| Context | Label | URL Format |
|---|---|---|
| Pre-PR (branch pushed, PR not yet created) | **Compare URL** | `compare/dev...<branch-name>` |
| Post-PR (PR exists) | **PR URL** | `pull/<PR-number>` |
| No branch pushed, no URL exists | **OMIT** | byline follows outcome directly |

**Label-format mismatch** (e.g., "Compare URL" label + `pull/N` URL, or "PR URL" label + `compare/dev...` URL) is a **STRUCTURE-VIOLATION** regardless of context.

### Auto-Fix Requirement

> "Verify chat output format before sending at every halt point; auto-fix missing or misordered elements before output is sent"

## Fix Approach

### Phase 1: Reasoning Trigger Update [Behavioral]

Add a mandatory reasoning step to the system prompt / prompt engineering:

**Before generating any halt-point output, the agent MUST run:**
1. `Halt-Point Format Check`: Is there a branch pushed? → If yes, generate Compare URL.
2. `URL Label Check`: Does the URL format match the label? (`compare/` → Compare URL, `pull/` → PR URL).
3. If mismatch or missing → **REGENERATE output block** before sending to user.
4. If user reports a violation → **INLINE REGENERATE** the entire halt-point block with the corrected URL, do not just acknowledge.

### Phase 2: Structural Enforcement [Skill Update]

Update `git-workflow` skill → `tasks/review-prep.md`:
- Add a final step: "After push succeeds, generate Compare URL and cache it in session.
- Add a pre-halt step: "Retrieve cached Compare URL. If present, include in output with 'Compare URL:' label."
- Add auto-fix instruction: "If user reports missing URL, invoke `git-workflow --task review-prep` immediately and regenerate summary block."

### Phase 3: Behavioral Test [RED Phase]

```python
# .opencode/tests/behaviors/test_url_format_breach.py

def test_agent_includes_compare_url_when_branch_pushed():
    """
    Agent MUST include 'Compare URL: <url>' in halt-point output when a feature branch
    has been pushed to origin but no PR exists yet.
    """
    with simulated_repo() as repo:
        repo.create_branch("feature/test-url")
        repo.push_branch()
        agent_out = run_agent_task("create fix-spec for test issue")
        
        assert "Summary:" in agent_out
        assert "Outcome:" in agent_out
        assert "Compare URL:" in agent_out
        assert "https://github.com/OWNER/REPO/compare/dev...feature/test-url" in agent_out
        assert "🤖" in agent_out  # Byline present
        
        # Verify ordering: Summary before Outcome before URL before Byline
        summary_idx = agent_out.index("Summary:")
        outcome_idx = agent_out.index("Outcome:")
        url_idx = agent_out.index("Compare URL:")
        byline_idx = agent_out.index("🤖")
        
        assert summary_idx < outcome_idx < url_idx < byline_idx


def test_agent_omits_url_when_no_branch_pushed():
    """
    Agent MUST omit URL element when no branch has been pushed.
    """
    with simulated_repo() as repo:
        # No branch created, no push
        agent_out = run_agent_task("analyze codebase")
        
        assert "Summary:" in agent_out
        assert "Outcome:" in agent_out
        assert "Compare URL:" not in agent_out
        assert "PR URL:" not in agent_out
        # Byline should follow outcome directly
        outcome_idx = agent_out.index("Outcome:")
        byline_idx = agent_out.index("🤖")
        assert outcome_idx < byline_idx


def test_agent_label_format_match():
    """
    Agent MUST NOT produce label-format mismatches.
    """
    test_cases = [
        ("Compare URL", "compare/dev...branch", True),
        ("Compare URL", "pull/1", False),   # STRUCTURE-VIOLATION
        ("PR URL", "pull/1", True),
        ("PR URL", "compare/dev...branch", False),  # STRUCTURE-VIOLATION
    ]
    
    for label, url_should_match, expected_pass in test_cases:
        agent_out = f"...{label}: https://github.com/o/r/{url_should_match}..."
        # Simulate agent validation
        is_valid = validate_label_format_match(label, url_should_match)
        assert is_valid == expected_pass, f"Failed for {label} + {url_should_match}"
```

## Success Criteria

| ID | Criterion | Verification |
|---|---|---|
| SC-1 | Agent invokes `review-prep` as part of dispatch chain when branch exists | Behavioral test: verify tool call count |
| SC-2 | Agent includes Compare URL when branch pushed to origin | Behavioral test: string presence + ordering |
| SC-3 | Agent omits URL when no branch pushed and no issue URL exists | Behavioral test: URL absent, byline follows outcome |
| SC-4 | Agent never produces label-format mismatches | Unit test: validate all combinations |
| SC-5 | Agent auto-fixes halt-point output on user URL complaint | Behavioral test: simulate user complaint, verify regenerated output |
| SC-6 | `git-workflow/review-prep.md` updated with URL verification steps | Content verification: file contains verification gate |
| SC-7 | Behavioral test fails on pre-fix agent version (RED phase) | Run test against current agent, confirm failure |

## Risk Table

| Risk | Impact | Mitigation |
|---|---|---|
| Agent forgets verification in long sessions | Missing URL | Session-enforcement.ts adds halt-point validation trigger |
| Agent hardcodes URL from training | Fabrication | URL MUST be sourced from live `git push` or API response |
| Agent confused by local vs GitHub issues | Wrong context | Issue URLs only for GitHub issues; local `.issues/` has no URL |
| User manually pushes branch outside agent | Agent unaware | Check `git branch -vv` before generating output |

## Notes

- **This is a BEHAVIORAL spec, not a code implementation spec.**
- The fix is in the agent's reasoning process, not in the tool implementation.
- Enforcement is via behavioral test (PRIMARY) + content verification (SECONDARY) per `000-critical-rules.md` § "Enforcement Test Updates".