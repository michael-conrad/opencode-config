# Lessons Learned — 2026-06-26

## Spec Artifact URL Resolution

**Problem:** The spec folder URL in the remote issue body pointed to the wrong repository's `issues-data` branch, producing a 404 for readers.

**Root cause:** When a spec belongs to a submodule repo (`.opencode`), the `local-issues sync` tool pushes artifacts to the root repo's `issues-data` branch by default. The URL in the issue body must point to the submodule repo's `issues-data` branch, not the root repo's.

**Fix:** Copy artifacts to the submodule's `.issues/` worktree and re-run `local-issues sync` from the submodule root. The submodule repo (`.opencode`) is public; the root repo (`opencode-config`) is private — using the wrong repo's URL breaks access for external readers.

**Lesson:** Always verify the target repo for artifact URLs matches the issue's repository, not the parent repository. The `## Repo Information` section in session-init provides per-repo values — use the entry whose `path` matches the issue's repo.

## Spec Body Format — Exec Summary vs Full Spec

**Problem:** The remote issue body contained the full spec content (problem, root cause, affected files, SC table, edge cases, etc.) instead of the condensed exec-summary format required by the spec-creation write task (Step 7r).

**Root cause:** The spec was created by a prior agent session that wrote the full spec body directly to the remote issue. The write task's Step 7r mandates a 6-part exec summary (Problem, Scope, Approach, Impact, AI Agent Instructions) — not the full spec.

**Fix:** Replaced the remote issue body with the exec-summary format. The full spec lives in `.issues/{N}/spec.md` on the `issues-data` branch.

**Lesson:** The remote issue body is a stakeholder-facing exec summary, not the spec. The authoritative spec is always the local `.issues/{N}/spec.md` file. Never dump the full spec to the remote issue body.

## Plan Validation — Dispatch Indicator Mismatch

**Problem:** The plan validation step flagged 5 checkpoint commit steps marked `(**inline**)` that contained sub-agent dispatch language (`Dispatch git-workflow --task commit-prep`).

**Root cause:** The plan writer used `(**inline**)` as a default dispatch indicator for checkpoint commit steps without verifying the indicator matched the actual dispatch mode.

**Fix:** Changed the dispatch indicators from `(**inline**)` to `(**sub-agent**)` for all checkpoint commit steps.

**Lesson:** Every plan step's dispatch indicator must match the actual dispatch mode. Checkpoint commits that dispatch `git-workflow` are sub-agent dispatches, not inline operations. Validate dispatch indicators during plan self-review.

## Spec Artifact Completeness — Pipeline Readiness Gate

**Problem:** The plan creation pipeline blocked at the readiness step because `sc-pipeline-readiness.yaml` did not exist in `.issues/{N}/`.

**Root cause:** The spec was created by a prior agent session that did not run the pipeline-readiness-gate task from spec-creation. The readiness gate file is a required artifact for plan creation.

**Fix:** Created `sc-pipeline-readiness.yaml` with all 5 PR checks (atomicity, dependency ordering, single concern, phase dependency, three-tier structure) passing.

**Lesson:** The pipeline-readiness gate is mandatory before plan creation. If a spec was created without running this gate, the file must be created manually before the plan pipeline can proceed. The gate validates SC atomicity, dependency ordering, single concern, phase DAG acyclicity, and three-tier phase structure.
