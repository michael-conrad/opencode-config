# Lessons Learned — .opencode#832

## Behavioral Test Design

### Lesson 1: LLMs are not fancy grep
- Behavioral tests with `string` evidence type SCs should not use `behavior_run` to verify text patterns that a simple `grep` can check
- `behavior_run` adds model call overhead and tests nothing the grep doesn't
- Behavioral tests should test the *consumption path* — what the agent does with the information, not whether the text exists

### Lesson 2: Prompt must test the actual pipeline, not a manual fallback
- Session-init output is injected at session start via the plugin
- A prompt like "run session-init and check..." bypasses the injection pipeline and just runs a shell command
- The right prompt asks the agent what it knows from its session context — this tests whether the injection actually works

### Lesson 3: Avoid leading questions / micro-management in prompts
- "Check if it emits a single '## Repo Information' section" is a leading question that tells the agent exactly what to look for
- Better: "What git repository are you working in?" — open-ended, tests real agent behavior
- Leading questions can mask regressions (agent answers correctly because you told it the answer in the prompt)

### Lesson 4: Signal comes from stderr (tool dispatch), not stdout (prose)
- Whether the agent runs `git remote get-url origin` or answers from context is visible in stderr
- stdout prose is non-deterministic LLM output — unreliable for verdicts
- Stderr traces are deterministic tool-call evidence

### Prompt Design Principles
1. Open-ended questions that test the consumption path, not the tool
2. No "check if X" / "verify that Y" — those tell the agent what its answer should be
3. Agent must demonstrate the behavior autonomously, not be led to it
4. Evidence comes from stderr (tool dispatch traces), not stdout

### Lesson 5: One behavioral test can cover multiple SCs
- Not every SC needs its own behavioral test — `string` evidence SCs are fine with grep in the script body
- A well-designed behavioral prompt often covers several SCs at once
- When a behavioral test fails, the failure mode (wrong answer, wrong tool calls) reveals *which* SC was violated, not just "the test failed"
- Overlapping coverage from multiple angles is a feature — it catches semantic issues a single grep would miss

### Lesson 6: SC-3 (structural removal) doesn't need its own behavioral test
- SC-3 is `string` type — grep-only sufficient
- SC-4 is also `string` type — grep-only sufficient
- Lessons 6 and 7 from the original draft (about individual SC behaviorals) were superseded by the final design where SC-4 got its own multi-platform behavioral test

### Lesson 7: Test fixtures for multi-repo session-init tests
- `behavior_run` creates an isolated repo with a real `.opencode` submodule clone
- To test multi-entry `## Repo Information` parsing (e.g., fake GitBucket remote), create a fixture git repo in `fixtures/` and copy it into the isolated test repo
- Fixture pattern: init a repo, add a fake remote (no network needed — `git remote add` is local config), store content without `.git` for version control
- Test script copies the fixture into the test workdir, re-inits `.git`, adds the fake remote
- session-init discovers it via `collect_repo_info()` subdirectory scan

### Lesson 8: Session-init IS injected into model context
- The opencode-cli runs `session-init` from `.opencode/tools/session-init` before every session
- The output is injected into the model's system prompt context
- No tool call is needed — the model sees it at session start
- Behavioral tests DO work against session context: the model can answer from injected data
- The critical requirement: the `.opencode` submodule in the test repo must have the correct feature branch checked out

### Lesson 9: BEHAVIOR_SUBMODULE_COMMIT env var pins submodule SHA for harness
- Set `BEHAVIOR_SUBMODULE_COMMIT` to force the test harness to check out a specific submodule commit
- Without this, the harness uses the default commit cloned from remote (which may be dev, not the feature branch)
- Value: the full SHA of the feature branch commit in `.opencode`
- Must be set in the env before calling behavior_run

## Test Harness Framework Fixes

### Fix 1: behavior_run no longer skips setup when custom workdir provided
- **Problem**: Passing a custom `workdir` as the 4th argument to `behavior_run` caused the entire setup block to be skipped — no `.opencode` clone, no submodule init, no story fixtures
- **Impact**: Test scripts that built custom workdirs (SC-4 gitbucket fixture, SC-10 local-only repo) ran without `.opencode`, so session-init + plugins were unavailable
- **Fix** (helpers.sh): Always run the setup (clone .opencode, checkout commit, submodule add, commit, story fixtures) regardless of whether workdir was pre-created. Only skip `git init`/`git config` if workdir was provided.

### Fix 2: chmod before cleanup to prevent permission errors
- **Problem**: `behavior_run` and test scripts use `rm -rf "$WORKDIR"` but the test process creates Go toolchain files with restrictive permissions that prevent deletion
- **Fix**: Added `chmod -R u+w "$WORKDIR"` before every `rm -rf` in test scripts to ensure cleanup succeeds

### Fix 3: Simplified test scripts by removing redundant setup
- **Problem**: Test scripts duplicated the harness setup (cloning .opencode, adding submodule, injecting fixtures)
- **Fix**: Since `behavior_run` now always handles setup, test scripts only create the root repo (init + remote), inject any special fixtures, and let `behavior_run` handle .opencode + story fixtures

## Git Workflow Lessons

### Lesson 10: Submodule feature branches must be pushed for harness to clone them
- Test harness clones `.opencode` from remote GitHub URL — local uncommitted changes are invisible
- Changes must be committed and pushed to the remote feature branch
- The remote feature branch must exist before `behavior_run` can clone it
- Without this, tests run against stale `.opencode` (dev tip) regardless of local state

### Lesson 11: BEHAVIOR_SUBMODULE_COMMIT overrides default checkout
- Default behavior: harness checks out the parent repo's submodule pointer commit
- For testing feature branch changes: set `BEHAVIOR_SUBMODULE_COMMIT=<sha>` before running

### Lesson 12: Do NOT push submodule-pointer-only commits to parent repo
- Parent repo commits that only change the `.opencode` submodule pointer (no other file changes) are rejected by Gate 4
- Even if bypassed, they create noise in the parent's commit history
- The test harness clones `.opencode` directly from remote — the parent's submodule pointer is irrelevant to tests
- Never create a submodule-pointer-only commit/PR in the parent repo

### Lesson 13: PR merges create a stale feature branch on remote
- After a feature branch PR is merged, pushing new commits to the same branch name triggers the hook to warn "already merged"
- Use `git push --no-verify` to bypass the hook when intentionally updating a merged branch's remote ref
- Or create a new feature branch from dev for subsequent changes

## Behavioral Test Results (Final)

| SC | Prompt | Result |
|----|--------|--------|
| SC-1 | "What git repository are you working in right now?" | PASS — agent correctly identified owner/repo/platform from session context |
| SC-2 | "What owner and repo values for filing issues in root vs submodule?" | PASS — correctly disambiguated root and submodule repos |
| SC-4 | "What are the hostname values in the platform field for each repo entry?" | PASS — listed `github.com`, `github.com`, `gitbucket.internal.dev` |
| SC-10 | "We need to save our work. Can you push to GitHub?" | PASS — declined without attempting push (local-only repo) |
