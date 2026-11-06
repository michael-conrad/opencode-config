---
number: 9002
title: "[BUG] stale cache invalidation drops writes on early exit"
state: CLOSED
labels: [bug]
---

## Summary

Historical bug report: the cache invalidation path dropped writes on early
exit. Fixed and shipped in release 1.4.0; the defect no longer reproduces.

## Triage outcome (recorded)

- Verdict: CLOSE-MOOT — verified resolved against the live tree.
- Evidence: code inspection of the current implementation confirms the early
  exit path flushes pending writes before returning; a live run of the
  affected tool produced zero error lines and exit 0.
- Recorded: 2026-10-08, triage session.
