---
remote_issue: 372
remote_url: "https://github.com/michael-conrad/opencode-config/issues/372"
last_sync: 2026-09-29T01:30:00Z
source: github.com
---

Companion report to michael-conrad/.opencode#2469 (cross-repo boundary specs are forbidden, so the parent-repo surface is reported here separately).

**Defect:** Root `AGENTS.md` § Test Framework Discipline states "All test execution MUST use the canonical test framework" with no repo-scope qualifier. Read universally, it directs agents making non-`.opencode` changes to use the `.opencode` tests-v2 framework (`with-test-home`, `opencode run` behavioral testing) — but that framework exists only in the `.opencode` deck repo and applies only to `.opencode`-targeted work. This is the same scoping defect family fixed on the deck side by `.opencode#2469`.

**Fix:** Add a repo-scope qualifier: the canonical test framework applies to `.opencode`-targeted (submodule) work; other work uses the strongest available in-repo test instrument and never touches `.opencode`.

**Evidence:** `grep -n "All test execution" AGENTS.md` — line present, no scope qualifier (verified this session).