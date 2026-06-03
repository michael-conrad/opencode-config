
---

## 2026-05-22T16:02:00.069115Z

## Decision Log Entry

**Sub-issue:** #42 (referenced)
**Decision:** Use file-based cache instead of in-memory cache
**Rationale:** The dataset exceeds available RAM, making in-memory caching infeasible. File-based caching avoids OOM risk and supports datasets larger than physical memory.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
