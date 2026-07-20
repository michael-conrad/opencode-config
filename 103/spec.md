## Problem

When a skill task file tells an agent to "run `scripts/validate_svg.py`", the agent must infer the invocation method. PEP 723 scripts with `# /// script` metadata require `uv run --script <path>` to resolve their inline dependencies. The following failure modes exist:

- `bash scripts/validate_svg.py` — bash interprets Python source as shell commands → runtime failure
- `./scripts/validate_svg.py` — no shebang → exec fails
- `python scripts/validate_svg.py` — PEP 723 dependencies not resolved → import failure
- `uv run --script scripts/validate_svg.py` — **correct**

This is not theoretical — the `.opencode` submodule has **6 PEP 723 scripts without shebangs** in `skills/ui-design/scripts/` and **7 task files** that reference them with bare names, leaving invocation ambiguous. The `.opencode` submodule issue #709 (open, bash guard approach) approaches this from the script-defense side; this spec approaches from the **skill card side** — fixing the instructions that agents read.

## Investigation

### Affected Scripts (PEP 723, no shebang)

| Script | Path | Deps |
|--------|------|------|
| `validate_svg.py` | `skills/ui-design/scripts/validate_svg.py` | lxml |
| `validate_interaction_spec.py` | `skills/ui-design/scripts/validate_interaction_spec.py` | pyyaml |
| `render_html_screenshot.py` | `skills/ui-design/scripts/render_html_screenshot.py` | playwright |
| `render_svg_to_png.py` | `skills/ui-design/scripts/render_svg_to_png.py` | cairosvg, playwright |
| `diff_mockups.py` | `skills/ui-design/scripts/diff_mockups.py` | Pillow |
| `animate_flow.py` | `skills/ui-design/scripts/animate_flow.py` | playwright, pyyaml |

### Affected Task Files (ambiguous invocation)

| Task File | Line | Current Text |
|-----------|------|-------------|
| `skills/ui-design/tasks/design.md` | 28 | `scripts/validate_svg.py` |
| `skills/ui-design/tasks/design.md` | 29 | `scripts/validate_interaction_spec.py` |
| `skills/ui-design/tasks/review.md` | 29 | `scripts/validate_svg.py` |
| `skills/ui-design/tasks/review.md` | 30 | `scripts/validate_interaction_spec.py` |
| `skills/ui-design/tasks/wireframe.md` | 16 | `validate_svg.py` |
| `skills/ui-design/tasks/wireframe.md` | 27 | `scripts/validate_svg.py` |
| `skills/ui-design/tasks/interaction-spec.md` | 27 | `scripts/validate_interaction_spec.py` |
| `skills/ui-design/tasks/mockup.md` | 27 | `scripts/render_html_screenshot.py` |
| `skills/ui-design/tasks/screenshot.md` | 23 | `scripts/render_html_screenshot.py` |
| `skills/ui-design/tasks/screenshot.md` | 24 | `scripts/render_svg_to_png.py` |

### Secondary Issue: resolve-models.md

`skills/adversarial-audit/tasks/resolve-models.md:7` says `bash .opencode/tools/resolve-models` — this script has `#!/bin/bash` so it works, but the `bash` prefix is redundant. The project convention (see `.opencode/tools/gitbucket-api` invocations) is direct path invocation via shebang.

## Success Criteria

| SC | Description | Verification |
|----|-------------|--------------|
| SC-1 | All 10 bare script references in `ui-design/tasks/*.md` updated to `uv run --script <path>` | grep for bare `.py` invocations in ui-design tasks |
| SC-2 | `resolve-models.md` uses direct path `.opencode/tools/resolve-models` instead of `bash .opencode/tools/resolve-models` | read line 7 of resolve-models.md |
| SC-3 | `ui-engineer/scripts/README.md` already correct (`uv run --script`) — verified unchanged | already confirmed |
| SC-4 | Skill-creator task references (`uv run .opencode/.../validate_skill_cards.py`) confirmed correct or updated to use `--script` flag | verify both invocations work |
| SC-5 | All 6 `ui-design/scripts/*.py` optionally get shebangs added (`#!/usr/bin/env -S uv run --script`) enabling both`uv run --script` and direct `./` invocation | check first line of each script |
| SC-6 | Behavioral enforcement test: agent given bare `scripts/validate_svg.py` instruction must invoke `uv run --script` not `bash` | opencode-cli test with stderr assertion |

## Fix Approach

### Phase 1: Task File Updates (in `.opencode` submodule)

Update 7 task files in `skills/ui-design/tasks/` to prefix all script invocations with `uv run --script`:

| File | Current | Updated |
|------|---------|---------|
| `design.md:28` | `scripts/validate_svg.py` | `uv run --script scripts/validate_svg.py` |
| `design.md:29` | `scripts/validate_interaction_spec.py` | `uv run --script scripts/validate_interaction_spec.py` |
| `review.md:29` | `scripts/validate_svg.py` | `uv run --script scripts/validate_svg.py` |
| `review.md:30` | `scripts/validate_interaction_spec.py` | `uv run --script scripts/validate_interaction_spec.py` |
| `wireframe.md:16` | `validate_svg.py` | `uv run --script scripts/validate_svg.py` |
| `wireframe.md:27` | `scripts/validate_svg.py` | `uv run --script scripts/validate_svg.py` |
| `interaction-spec.md:27` | `scripts/validate_interaction_spec.py` | `uv run --script scripts/validate_interaction_spec.py` |
| `mockup.md:27` | `scripts/render_html_screenshot.py` | `uv run --script scripts/render_html_screenshot.py` |
| `screenshot.md:23` | `scripts/render_html_screenshot.py` | `uv run --script scripts/render_html_screenshot.py` |
| `screenshot.md:24` | `scripts/render_svg_to_png.py` | `uv run --script scripts/render_svg_to_png.py` |

### Phase 2: resolve-models.md Cleanup (in `.opencode` submodule)

| File | Current | Updated |
|------|---------|---------|
| `resolve-models.md:7` | `bash .opencode/tools/resolve-models` | `.opencode/tools/resolve-models` |

### Phase 3: Shebangs for ui-design Scripts (OPTIONAL — in `.opencode` submodule)

Add `#!/usr/bin/env -S uv run --script` as line 1 of all 6 ui-design scripts, before the existing `# /// script` block. This enables both `./` direct invocation (via shebang) and `uv run --script` invocation. Removes the single point of failure where no shebang + no `uv run --script` prefix = broken invocation.

### Phase 4: Behavioral Enforcement Test (in `opencode-config` parent)

Add a behavioral test that sends a prompt including the instruction from `design.md:28` ("Validate all SVG artifacts with `scripts/validate_svg.py`") and asserts the agent uses `uv run --script` (visible in stderr via `assert_stderr_pattern_present`), not `bash` invocation.

## Non-Goals

- No changes to the polyglot bash guard approach (that's issue #709 in `.opencode`)
- No changes to `.opencode/tools/` scripts (all have correct shebangs)
- No changes to bash scripts (`resolve-models`, `ollama-model-resolve`, etc.)
- No changes to skill-creator scripts (already work correctly)

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `uv run --script` prefix missed on new task files | Medium | Low — functional failure on next agent invocation | Enforcement test SC-6 catches regressions |
| Shebangs on scripts conflict with existing PEP 723 metadata | Low | Low — shebang before `# /// script` is standard pattern | Already verified: all `tools/` scripts use this pattern |
| Agent ignores `uv run --script` prefix in instructions | Low | High — behavioral test catches it | SC-6 stderr assertion |

---

Co-authored with AI: OpenCode (deepseek-v4-flash)