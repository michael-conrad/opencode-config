# Card 020: Local Platform SKILL.md — Capability Contract

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** The orchestrator must be able to determine what operations the local platform supports without reading task files or guessing. The SKILL.md capability table is the contract that prevents inline bypass.

## Purpose

One file the dispatcher reads at routing time. Lists every operation the platform supports, the task file that implements each, the expected parameters, and the result contract shape. The orchestrator dispatches based on this table — it never inline-implements what the platform already provides.

## Structure

```yaml
name: local
description: "Local .issues/ issue tracking platform. Files + YAML frontmatter in worktree."

capabilities:
  create:
    scenarios: [draft, promote, import-remote]
    task: creation
    parameters:
      draft: { title: string, labels: [string] }
      promote: { local_number: int, exec_summary: string, platform_type: string }
      import-remote: { remote_number: int, platform_type: string }
    returns: { local_path: string, remote_url?: string, number: int }

  read:
    types: [full, comments, labels, links, all]
    task: read
    parameters: { number: int, type: string }
    returns: YAML document (varies by type)

  update:
    types: [metadata, body]
    task: update
    parameters: { number: int, title?: string, status?: string, phase?: string, labels?: [string], body?: string }
    returns: { number: int, updated_fields: [string] }

  comment:
    types: [internal, stakeholder]
    task: comment
    parameters: { number: int, body: string, type: string }
    returns: { number: int, entry_count: int }

  close:
    task: close
    parameters: { number: int, reason?: string }
    returns: { number: int, status: "closed" }

  delete:
    task: delete
    parameters: { number: int, force?: bool }
    returns: { number: int, deleted: true }

  search:
    task: search
    parameters: { status?: string, labels?: [string], query?: string }
    returns: [{ number: int, title: string, status: string, labels: [string], phase?: string }]

  list:
    task: list
    parameters: { status?: string }
    returns: [{ number: int, title: string, status: string, phase?: string }]

  body-edit:
    task: body-edit
    parameters: { number: int, edit_script: string }
    returns: { sync_status: string, url?: string }

  push-body:
    task: push-body
    parameters: { number: int }
    returns: { sync_status: string, url?: string }

  pull-body:
    task: pull-body
    parameters: { number: int }
    returns: { number: int, last_sync: string }

  link:
    task: link
    parameters: { number: int, github?: int, child?: int, related?: int, blocked_by?: int }
    returns: { number: int, links_updated: [string] }

  promote:
    task: promote
    parameters: { number: int }
    returns: { local_path: string, remote_url: string, remote_number: int }
```

## Rules

1. The orchestrator reads this SKILL.md to determine if the local platform can handle a requested operation.
2. If the operation is listed, the orchestrator dispatches — never inline-implements.
3. If the operation is NOT listed (e.g., assignees, milestones), the orchestrator reports "not supported by local platform" — never creates a workaround.
4. The task files themselves contain the detailed procedure, entry/exit criteria, and error handling. The SKILL.md is the routing contract only.

## References

- Card-003: architectural layering
- Card-010: creation skill card (three-scenario dispatch)
- Existing local/SKILL.md (will be replaced)