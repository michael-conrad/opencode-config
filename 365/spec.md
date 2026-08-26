> Full spec and plan artifacts: https://github.com/michael-conrad/opencode-config/tree/issues-data/.issues/N/

**Problem** — The release process currently tags and promotes without verifying that the release tree actually builds and deploys. A broken build discovered after tagging requires a re-release. The release must be verified against a clean, pinned-SHA checkout before promotion.

**Scope** — In scope: a shallow temp-copy checkout of the root repo at the release commit; submodule resolution to the gitlink-pinned SHAs (not latest); a build + shadowJar + test run against that checkout; a drift assertion that resolved submodule SHAs equal pinned SHAs; a PASS/FAIL gate that blocks release promotion on failure. Out of scope: changes to the feature-merge CI pipeline; changes to how feature PRs pin submodule SHAs; any modification to the release-promoter tag/creation logic beyond adding the verification gate.

**Approach** — Add a verification step that performs a shallow clone of the root repo at the release commit, initializes submodules at their gitlink-pinned SHAs (shallow per submodule), asserts resolved SHA == pinned SHA with a hard fail on drift, then runs the build, shadowJar, and test suite. The gate runs once per release and blocks promotion on any failure. The checkout must use `git submodule update --init --depth 1` (honoring pinned SHAs), never `--remote` or `--recursive`.

**Impact** — Top risks: (1) submodule drift producing a green build of the wrong tree — mitigated by the SHA==pinned assertion; (2) shallow checkout missing submodule content — mitigated by explicit submodule init; (3) gate placement redundancy — mitigated by running once per release at the pinned-SHA configuration. Key dependency: the repo's actual build system (Gradle/shadowJar). Call to action: approve the spec to proceed to planning.

🤖 OpenCode (deepseek-v4-flash) created
