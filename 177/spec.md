## Intent

Remove the `memory` tool from `.opencode/tools/` — it causes AI agents to misbehave, produce incorrect analysis, and hallucinate state. The memory tool creates a latent vector for contamination: agents treat its content as verified state, skip live verification, and produce unreliable output. Remove it entirely.

## Root Cause

The memory tool stores free-form text that agents read at session start. This text enters the agent's context as if it were verified fact. Agents then:

1. Reference memory content instead of running live tool calls (violating `065-verification-honesty.md`)
2. Treat stale memory entries as current state
3. Produce analysis that assumes memory is correct when it may be outdated or incorrect
4. The "writing to memory" workflow also has opaque validation rules (e.g., rejecting anything with future/pending references) that produce confusing errors and waste time

## Evidence

- The `lessons-learned/` directory pattern is the established convention for this repo — memory tool is a separate, unintegrated parallel system
- Memory tool has inconsistent behavior: requires specific section headers, rejects values containing certain regex patterns, silently creates empty files
- Every session the agent must account for memory tool content on top of actual codebase state, creating a second source of "truth" that competes with the authoritative filesystem

## Resolution

- Delete `.opencode/tools/memory` and its implementation files (`impl/memory-read`, `impl/memory-write`, `impl/memory-update`, `impl/memory-clear`)
- The `lessons-learned/` directory in the submodule (`.opencode/lessons-learned/`) already serves this purpose without the contamination risk — lessons are static files the agent reads on demand, not latent context injected at session start

## Status

DRAFT