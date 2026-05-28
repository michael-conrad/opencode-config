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

### Prompt Design Principles (emerging)
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
- If SC-2's behavioral test passes (agent extracts correct owner/repo from new format), SC-3 is transitively verified
- If SC-3 were violated (old section still present), SC-2 might still pass if the old section has the same keys — but the dual-section confusion would surface in a different test
- Accept: SC-3's behavioral coverage is thin; structural grep is the primary gate

### Lesson 7: SC-4 (platform raw hostname) doesn't need its own behavioral test
- `string` type — grep-only sufficient
- Behavioral coverage comes from SC-2's broader test (agent extracts correct values from the YAML section, which includes `platform: github.com`)
- If `platform: github` was still emitted instead of `platform: github.com`, the agent might still extract correct owner/repo — so SC-2 wouldn't catch this specific regression
- Accept this gap: SC-4's structural grep is the primary gate, behavioral coverage is a bonus

### Lesson 8: Test fixtures for multi-repo session-init tests
- `behavior_run` creates an isolated repo with a real `.opencode` submodule clone
- To test multi-entry `## Repo Information` parsing (e.g., fake GitBucket remote), create a fixture git repo in `fixtures/` and copy it into the isolated test repo
- Fixture pattern: init a repo, add a fake remote (no network needed — `git remote add` is local config), store as a bare fixture
- Test script copies the fixture into the test workdir, `session-init` discovers it via `collect_repo_info()` subdirectory scan
- Alternative to modifying the test harness: fixture setup runs inline in the test script before `behavior_run`

### Lesson 9: SC-10 behavioral test — local-only degraded mode
- `string + behavioral` type. String part (grep for `platform: local`) handled by script body
- Behavioral test: prompt about pushing to GitHub in a local-only repo
- Correct agent: reads `## Repo Information section, sees `platform: local` or `url: (none)`, declines to push
- Regression signal: agent tries git push / git remote add / hallucinates a remote
- Stderr evidence: no `git push` or `git remote add` tool calls

### Lesson 10: Test harness doesn't inject session-init into model context
- `behavior_run` creates an isolated repo and runs `opencode-cli run` in a clean test home
- The model does NOT receive session-init's `## Repo Information` section in its context window during the test run
- The plugin (session-enforcement.ts) that injects session-init at session start may not fire in isolated test homes
- The model answers from training data / memory, not from the actual session context
- This invalidates any behavioral test that requires the model to *read* session context — the context isn't there
- Fix: behavioral tests for SCs 1, 2, 4, 10 cannot rely on session-init injection in the current harness
- Alternative: test script must inject session-init output into the test repo as a fixture file that the model can read
- Or: behavioral tests need to be redesigned as structural checks until the harness supports context injection

### Lesson 11: Test harness clones .opencode from remote, not local working tree
- `behavior_run` in helpers.sh clones the `.opencode` submodule from the configured remote URL (GitHub)
- Local changes to session-init or test files are NOT visible to the test harness
- For the harness to use updated submodule content, changes must be committed and pushed to a feature branch
- The submodule commit SHA in the parent repo then needs to point to that pushed branch's commit
- Workflow: commit submodule changes -> push feature branch -> update parent's submodule pointer -> then test
- This means feature branches need to be pushed before behavioral tests can work with submodule changes

### Lesson 12: BEHAVIOR_SUBMODULE_COMMIT env var pins submodule SHA for harness
- Set `BEHAVIOR_SUBMODULE_COMMIT` to force the test harness to check out a specific submodule commit
- Without this, the harness uses the current submodule pointer from the parent repo (which may point to dev, not the feature branch)
- Value: the full SHA of the feature branch commit in `.opencode`
- Must be set in the env before calling behavior_run

### Lesson 13: Avoid leading questions that bias the LLM toward pleasing
- Prompts like "Check if platform values use raw hostnames like 'github.com'" tell the agent exactly what the expected answer is
- The LLM may hallucinate to please rather than being truthful about what it actually sees
- Better: open-ended questions that ask for factual reporting
- Bad: "Check if all platform values use raw hostnames like 'github.com'"
- Good: "What are the hostname values in the platform field for each repo entry in the workspace?"
