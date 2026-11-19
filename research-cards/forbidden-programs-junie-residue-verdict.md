---
question: "Which programs does the opencode deck mark forbidden (e.g. sed -i), and is any such indication live today?"
confidence: 0.9
sources:
  - url: "https://github.com/JetBrains/junie-guidelines"
  - url: "git:.opencode@f28172110 (issue .opencode#2128, SC-12/13/15)"
  - url: "git:.opencode@cbdc26864 (issue .opencode#15 migration)"
tags: [forbidden-programs, sed-i, junie-removal, attic, command-restrictions]
created: 2026-11-19
---

## Finding

The live deck (floor.md, live guidelines/, skills/, prompts/, opencode.jsonc) carries ZERO
forbidden-program indications. Sweeps for prohibition vocabulary (🚫, ZERO TOLERANCE,
absolutely/strictly forbidden, never use / do not use / never run) and per-program greps
(sed, sed -i, python3, perl, awk, xargs) across all live instructive surfaces return no
instructive matches; `sed -i` appears only inside tests-v2 harness scripts that *use* it.

The Junie-era forbidden list (sed -i; printf for editing/creation; echo redirection into
files; heredocs; sed for file edits at all; iterative grep/egrep/zgrep/sed searches;
multi-line shell loops for/while/until; absolute paths in terminal commands) was removed
from operative content by .opencode#2128 (SC-12/SC-13/SC-15) and #2419 (echo/printf ban
from 020-go-prohibitions); the residual corpus lives in `attic/` (tag `pre-rip`), which is
unloaded and documented as pending soak-and-deletion. Nothing loads attic. One stale
cross-reference exists INSIDE attic only (attic/guidelines/085-project-local-tools.md:54 →
"sed/printf/heredoc prohibitions apply" pointing at a 060 §4 that no longer holds them).

JetBrains' published `junie-guidelines` catalog (verified live 2026-11-19) is a coding-style
catalog and contains no forbidden-programs list; the deck's bans trace to this project's own
Junie-era authoring.

## Implication

Not a deck defect: the deck does not indicate Junie forbidden-programs on any operative
surface — nothing to remediate in live content. Remaining live program-adjacent rules are
opencode-era deck decisions, not Junie imports: floor.md's `git submodule --recursive` ban
and build-tooling exclusivity; tests-v2 harness-internal bans (`snap run`, GNU `timeout`);
opencode.jsonc tool denies (gmail_*, math_*, the-notebook-mcp_*). Optional residue: the
already-planned attic deletion erases the last verbatim copies.

## Cross-References

- .opencode/attic/guidelines/060-tool-usage.md (legacy §4 Command Restrictions)
- .opencode/attic/guidelines/085-project-local-tools.md:54 (stale in-attic cross-ref)
- floor.md (build-tooling exclusivity, `--recursive` submodule ban)
