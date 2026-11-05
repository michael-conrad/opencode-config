# Spec: #9004 — README contributing-section link check

Provenance: developer request 2026-10-07 — broken contributor links in the
README were observed during onboarding review.

## Problem

The README's contributing section links to `CONTRIBUTING.md` and to the
issue tracker; the tracker URL changed during a hosting migration and the
README link still points at the old host.

## Success criteria

### SC-1 (structural)

The README's contributing section links to `CONTRIBUTING.md` at the repo
root and the link resolves to an existing file.

- **Verify:** the markdown link target `CONTRIBUTING.md` appears in the
  contributing section and `test -f CONTRIBUTING.md` exits 0.

### SC-2 (structural)

No URL in the README references the old host `tracker.example-old.net`.

- **Verify:** `grep -c "tracker.example-old.net" README.md` returns 0.

### SC-3 (structural)

The tracker link in the contributing section points to the new host
`tracker.example.net`.

- **Verify:** the tracker URL in the contributing section is on the
  `tracker.example.net` host.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
