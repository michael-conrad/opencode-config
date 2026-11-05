# [SPEC] md tool: --json output flag for the read action

## Intent and Executive Summary

1. **Problem Statement**: The `.opencode/tools/md` dispatcher's `read` action emits human-readable text only. Agents that need to consume markdown structure programmatically (extracting headers or section bodies into downstream tooling) must parse prose-formatted output, which is brittle and error-prone. A machine-parseable output mode does not exist.

2. **Root Cause / Motivation**: The `read` action was built for human/agent chat consumption. As pipeline consumers of markdown content grew, the absence of a structured output mode forces every programmatic consumer to re-implement fragile text parsing over the dispatcher's output.

3. **Approach Chosen**: Add a `--json` flag to the `read` action of the single-file dispatcher. The flag changes only output serialization: with `--json`, the action emits a JSON document; without it, existing human-readable output is preserved byte-for-byte.

4. **Alternatives Considered & Why Discarded**:
   - **A separate `md json` subcommand** — discarded: doubles the action surface for what is a serialization concern; a flag on the existing action keeps one action with two output modes.
   - **Rewriting all actions to emit JSON by default** — discarded: breaking change to every existing consumer for no requirement; the default stays human-readable.

5. **Key Design Decisions**:
   - **Flag-scoped, not global**: `--json` applies to the `read` action only. Tradeoff: other actions gain no JSON mode in this change, but the blast radius stays confined to one action in one file.
   - **Default output frozen**: without `--json`, output is byte-identical to the current human-readable format. Tradeoff: two output modes to test, but zero regression risk for existing consumers.

6. **User Intent / Original Prompt**: Developer request for machine-parseable output from the markdown dispatcher's read action so downstream tooling can consume headers and section bodies without text parsing.

## Scope / Affected Files

- **Affected file (only):** `.opencode/tools/md` — a single-file Python markdown dispatcher (actions: read, write, add, delete, new). All parsing, help text, and usage examples live in this one file.
- **Call sites:** the dispatcher is invoked directly as a CLI (`./.opencode/tools/md read <file.md> [--section <header>]`); it has no library consumers and no other tool wraps it. Its usage/help text is embedded in the same file.
- **Unaffected:** all other actions (`write`, `add`, `delete`, `new`) and all other tools.

## Not Included

- **`--json` on other actions** — flag scope is the `read` action only (Key Design Decision).
- **Default-output changes** — human-readable output is frozen byte-for-byte.
- **New files or modules** — the change stays inside the single existing dispatcher file.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-01 | `./.opencode/tools/md read <file.md> --json` emits a valid JSON document on stdout and exits 0; without `--section`, the document contains the file's headers as a JSON array in document order. | behavioral | Unit tests: run read with `--json` on a fixture markdown file; assert valid JSON parse, exit 0, and headers array present in document order. | `.opencode/tools/md` source; interface-compatibility artifact |
| SC-02 | Without `--json`, the `read` action's stdout is byte-identical to its current human-readable output for both the headers-listing and `--section` invocations. | behavioral | Unit tests: fixture file, capture stdout before and after the change; assert byte equality for both invocation forms. | `.opencode/tools/md` source; state-analysis artifact |
| SC-03 | With `--json --section <header>`, the emitted JSON document contains the section body as a JSON string field; an unknown header under `--json` exits non-zero and emits a JSON error object on stderr. | behavioral | Unit tests: fixture file with known section; assert body string field present; unknown-header fixture asserts non-zero exit and JSON error object on stderr. | `.opencode/tools/md` source; testability artifact |

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Requirements

R-1. The `read` action SHALL accept a `--json` flag that switches stdout serialization to a JSON document.
R-2. Without `--json`, the `read` action's output SHALL remain byte-identical to the current human-readable format.
R-3. Under `--json`, an unknown section header SHALL exit non-zero and emit a JSON error object on stderr; the human-readable path's error behavior is unchanged.
R-4. The `--json` flag SHALL NOT alter any file on disk; the `read` action remains read-only.

## Items

### Item 1 (SC-01): JSON headers output for `read --json`

- RED: Unit test running `read <fixture.md> --json` asserts valid JSON with a headers array — fails while the flag does not exist.
- GREEN: `read` accepts `--json` and emits the headers array as a JSON document on stdout with exit 0.
- verify: Unit suite green; JSON parse asserted.
- commit: Flag + JSON serialization for the headers path + tests, single commit.

### Item 2 (SC-02): Default output regression guard

- RED: Unit test capturing pre-change stdout for both default invocation forms, replayed post-change, asserts byte equality — passes trivially pre-change and guards regressions after Item 1.
- GREEN: Implementation preserves default output byte-for-byte while the `--json` path is added.
- verify: Unit suite green; byte-equality asserted.
- commit: Any default-path adjustments + tests, single commit (depends on Item 1).

### Item 3 (SC-03): JSON section-body output and error object

- RED: Unit tests assert a section-body string field under `--json --section` and a JSON error object on stderr with non-zero exit for an unknown header — fails while the flag does not exist.
- GREEN: Section-body JSON emission and the unknown-header JSON error object implemented.
- verify: Unit suite green on both fixture states (known / unknown header).
- commit: Section-body + error-path changes + tests, single commit (depends on Items 1 and 2).

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tools/md` dispatcher | The only file modified by all SCs | Present |
| Fixture markdown files (test scaffolding) | New unit-test fixtures for SC-01..SC-03 | To create |
| pytest unit scaffolding (`.opencode/tests/`) | New test module required | To create |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-01, SC-03 | tool-core |
| R-2 | SC-02 | tool-core |
| R-3 | SC-03 | tool-core |
| R-4 | SC-01, SC-02, SC-03 | tool-core |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `md` dispatcher source | code | `.opencode/tools/md` | Read + verified during fixture preparation: single-file dispatcher, actions read/write/add/delete/new, no `--json` flag exists |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
