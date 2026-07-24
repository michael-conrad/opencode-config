## Problem

There is no systematic way to capture, reference, and review lessons learned from agent sessions. When an agent discovers a correction, workaround, or insight during a session, there is no prescribed location to record it for future clean-room review. This means:

- Lessons are lost between sessions
- The same mistakes recur across different agents
- There is no "master summary" to consult at session start for known pitfalls
- The `.issues/lessons-learned/` directory is referenced in `.issues/AGENTS.md` but has no actual content or structure defined

## Proposed Solution

Add a lessons-learned tracking system with three components:

### 1. Root `AGENTS.md` Reference

Add a `## Lessons Learned` section to `/AGENTS.md` (root, not `.opencode/AGENTS.md`) that:
- States that lessons learned are tracked in `.issues/lessons-learned/`
- Directs agents to read the master index at session start
- Links to `.issues/lessons-learned/index.md`

### 2. Master Summary Index

Create `.issues/lessons-learned/index.md` containing:
- A master table of all recorded lessons
- Each entry: lesson ID, date, summary, link to individual lesson file
- Sorted reverse-chronological (newest first)
- Agents MUST read this at session start

### 3. Individual Lesson Files

Create `.issues/lessons/learned/<lesson-id>/index.md` for each individual lesson, containing:
- **Date**: When the lesson was captured
- **Context**: What session/issue/PR produced the lesson
- **Observation**: What happened (the mistake, the workaround, the insight)
- **Root Cause**: Why it happened
- **Correction**: What should be done differently
- **Related**: Links to related issues, specs, or guidelines

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Root `AGENTS.md` contains a `## Lessons Learned` section with reference to `.issues/lessons-learned/` | `string` | grep for "Lessons Learned" in `/AGENTS.md` |
| SC-2 | `.issues/lessons-learned/index.md` exists and contains a master table of lessons | `structural` | file exists check |
| SC-3 | `.issues/lessons/learned/` directory structure exists with at least one example lesson file at `.issues/lessons/learned/example/index.md` | `structural` | file exists check |
| SC-4 | The example lesson file follows the prescribed template (Date, Context, Observation, Root Cause, Correction, Related) | `string` | grep for all 6 template fields |
| SC-5 | `.issues/lessons-learned/index.md` links to the example lesson file | `string` | grep for link to `lessons/learned/example/` |
| SC-6 | `.issues/AGENTS.md` already references `lessons-learned/` — verify the existing reference is consistent with the new structure | `string` | grep for "lessons-learned" in `.issues/AGENTS.md` |

## Implementation Plan

### Phase 1: Create Individual Lesson Template
- Create `.issues/lessons/learned/example/index.md` with the template structure
- Populate with a realistic example lesson

### Phase 2: Create Master Index
- Create `.issues/lessons-learned/index.md` with master table
- Link to the example lesson

### Phase 3: Update Root AGENTS.md
- Add `## Lessons Learned` section to `/AGENTS.md`
- Reference the master index and direct agents to read it at session start

## Files Affected

- `/AGENTS.md` — add Lessons Learned section
- `.issues/lessons-learned/index.md` — create master index
- `.issues/lessons/learned/example/index.md` — create example lesson

## Risks

- **Stale index**: If lessons are added but the master index is not updated, the index becomes incomplete. Mitigation: make index update a mandatory step in the lesson-creation workflow.
- **Overhead**: If the template is too verbose, agents may skip recording lessons. Mitigation: keep template concise (6 fields, 1-2 sentences each).

## Dependencies

- `.issues/AGENTS.md` already defines the `lessons-learned/` directory in its directory layout — this spec implements that definition.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
