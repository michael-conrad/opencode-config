> Full spec and plan artifacts: https://github.com/michael-conrad/opencode-config/tree/issues-data/.issues/N/

**Problem** — The release process currently tags and promotes without verifying that the release tree actually builds and deploys. A broken build discovered after tagging requires a re-release. The release must be verified against a clean, pinned-SHA checkout before promotion.

**Scope** — In scope: a shallow temp-copy checkout of the root repo at the release commit; submodule resolution to the gitlink-pinned SHAs (not latest); a build + test run against that checkout using the repository's declared canonical build and test commands; a drift assertion that resolved submodule SHAs equal pinned SHAs; a PASS/FAIL gate that blocks release promotion on failure. Out of scope: changes to the feature-merge CI pipeline; changes to how feature PRs pin submodule SHAs; any modification to the release-promoter tag/creation logic beyond adding the verification gate; any hardcoding of a specific build system (Gradle, Maven, uv, npm, etc.).

**Approach** — Add a verification step that performs a shallow clone of the root repo at the release commit, initializes submodules at their gitlink-pinned SHAs (shallow per submodule), asserts resolved SHA == pinned SHA with a hard fail on drift, then discovers and executes the repository's declared canonical build and test commands from the repo's AGENTS.md (or equivalent build manifest) and asserts zero failures. The gate runs once per release and blocks promotion on any failure. The checkout must use `git submodule update --init --depth 1` (honoring pinned SHAs), never `--remote` or `--recursive`. The build/test step is build-system-agnostic: it reads the canonical build and test commands from the repository's declared build manifest rather than assuming a specific toolchain, so the gate is implementable and testable for any build system the agent's repo uses.

**Impact** — Top risks: (1) submodule drift producing a green build of the wrong tree — mitigated by the SHA==pinned assertion; (2) shallow checkout missing submodule content — mitigated by explicit submodule init; (3) gate placement redundancy — mitigated by running once per release at the pinned-SHA configuration; (4) build manifest missing or ambiguous — mitigated by a hard fail when the canonical build/test commands cannot be discovered. Key dependency: the repository's declared build manifest (AGENTS.md or equivalent) must name the canonical build and test commands. Call to action: approve the spec to proceed to planning.

## Affected Files

| File | Change |
|------|--------|
| `release-promoter` skill (tag/operating-protocol) | Add the verification gate step that runs before tag creation |
| Repository build manifest (`AGENTS.md` or equivalent) | Source of the canonical build and test commands the gate executes (read-only dependency, not modified) |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The gate performs a shallow temp-copy checkout of the root repo at the release commit | `behavioral` | `opencode run` with stderr assertion that the gate issues a shallow checkout at the release commit |
| SC-2 | The gate resolves submodules to their gitlink-pinned SHAs (not latest) using `git submodule update --init --depth 1`, never `--remote` or `--recursive` | `behavioral` | `opencode run` with stderr assertion of the submodule init command and absence of `--remote`/`--recursive` |
| SC-3 | The gate asserts resolved submodule SHA == pinned SHA and hard-fails on drift | `behavioral` | `opencode run` with stderr assertion that a SHA mismatch produces a hard fail |
| SC-4 | The gate discovers the repository's canonical build and test commands from the repo's AGENTS.md (or equivalent build manifest) rather than assuming a specific build system | `behavioral` | `opencode run` with stderr assertion that the gate reads the declared build manifest to obtain build/test commands |
| SC-5 | The gate executes the discovered build and test commands and asserts zero failures; a non-zero exit is FAIL and blocks promotion | `behavioral` | `opencode run` with stderr assertion that a non-zero build/test exit blocks promotion |
| SC-6 | The gate runs once per release and blocks release promotion on any failure | `behavioral` | `opencode run` with stderr assertion that the gate is invoked once per release and a failure halts promotion |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-26 | Reworded the build step to be build-system-agnostic: replaced the hardcoded Gradle/shadowJar build with a generic mechanism that discovers and executes the repository's declared canonical build and test commands from AGENTS.md (or equivalent build manifest), asserting zero failures (non-zero exit = FAIL, blocks promotion). Updated the Scope, Approach, Impact, Affected Files, and Success Criteria to reflect the generic build mechanism. | Revision request: the current spec hardcodes a Gradle/shadowJar build that does not exist in this repository; the gate must be implementable and testable for any build system the agent's repo uses. | Developer revision request |

🤖 OpenCode (deepseek-v4-flash) created
