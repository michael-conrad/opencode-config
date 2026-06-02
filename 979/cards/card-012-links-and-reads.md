# Card 012: links.yaml + YAML Read Output Format

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Replacing fragile `#` reference parsing in comments with machine-readable YAML; standardizing output to YAML for LLM consumption

## links.yaml

At `.issues/R/links.yaml`, created at issue creation time. Tracks all issue interdependencies:

```yaml
parent: null          # parent issue number
children: []          # sub-issues
related: []           # related but not hierarchical
duplicate_of: null    # or remote number
superseded_by: null   # or remote number
blocked_by: []        # blocking dependencies
```

Created empty at issue creation. Updated by `local-issues link` commands. Replaces fragile `#456` grep-from-comments convention for sub-issue detection.

## Read Output Format — YAML

All read commands output YAML for direct LLM consumption without special parsing.

### local-issues read N

```yaml
number: 979
title: "..."
status: open
labels: [SPEC, needs-approval]
phase: spec-design
created: "ISO-timestamp"
updated: "ISO-timestamp"
github_issue: 979
remote_url: "https://..."
body: |
  Full spec body text...
```

### local-issues read-comments N

```yaml
- author: "AgentName"
  timestamp: "ISO-timestamp"
  body: "Comment text..."
- author: "Developer"
  timestamp: "ISO-timestamp"
  body: "More text..."
```

### local-issues read-labels N

```yaml
labels: [SPEC, needs-approval]
```

### local-issues read-sub-issues N

```yaml
parent: null
children: []
related: []
blocked_by: []
duplicate_of: null
superseded_by: null
```

### local-issues read N --all (bundle)

```yaml
issue:
  number: 979
  title: "..."
  status: open
  labels: [SPEC, needs-approval]
  phase: spec-design
  body: "..."

comments:
  - author: "..."
    timestamp: "..."
    body: "..."

links:
  parent: null
  children: []
  related: []
  blocked_by: []
```

## Skill Card Dispatch — read-issue

```
read.md (local platform dispatcher)

  type: full      → local-issues read N
  type: comments  → local-issues read-comments N
  type: labels    → local-issues read-labels N
  type: links     → local-issues read-sub-issues N
  type: all       → local-issues read N --all
```

Individual reads available for targeted queries. `--all` bundle for one-dispatch full context.

## References

- Replaces: existing read-comments/read-labels/read-sub-issues CLI commands (currently missing)
- Used by: update.md (reads current state before mutation), promote.md (reads spec for exec summary extraction)