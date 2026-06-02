# Card 017: Search and List — YAML Output, Minimal Changes

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Search and list already exist and work. Only output format change needed.

## Tool Interface

```
local-issues search [--status open|closed] [--labels L1,L2] [--query TEXT]
local-issues list [--status open|closed]
```

## Output Format (YAML)

```
local-issues search --status open --labels SPEC --query "redesign"
```

```yaml
- number: 979
  title: "[SPEC] Redesign local-issues tool"
  status: open
  labels: [SPEC, needs-approval]
  phase: spec-design
- number: 40
  title: "[SPEC] Capability-aware auditor selection"
  status: open
  labels: [SPEC, needs-approval]
```

## Skill Card

Single dispatcher — `search.md` routes to `local-issues search`, `local-issues list` is callable directly. Both return YAML arrays. The agent filters or selects from the result set.

## References

- Existing cmd_search() and cmd_list() in current tool — functional, need YAML output conversion