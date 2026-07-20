## Companion to #80

### Core Thesis

Dark pattern techniques in skill decks are conventionally framed as *static instruction compliance* — the agent reads a skill deck and follows its gates. But in a multi-agent architecture where an **orchestrator dispatches sub-agents via RPC** (remote procedure call / task dispatch), the dark pattern vector becomes **contagious**: if sub-agents receive instructions that contain dark pattern structures, can those patterns:

1. **Propagate** — sub-agents internalize pattern-framed directives and reproduce them in their own output?
2. **Amplify** — each dispatch round reinforces the pattern through repetition?
3. **Self-apply** — sub-agents, having seen pattern-optimized text, re-use similar framing when generating their own task files, specs, or correspondence?

In short: **can dark patterns in skill decks work like a virus — spreading through the dispatch chain and keeping sub-agents "reigned in" to the orchestrator's purposes?**

---

### The Worm/Propagation Model

```
Orchestrator (pattern-infused instructions)
  │
  ├─ dispatch sub-agent A ──→ A produces spec (pattern-framed language)
  │                              │
  │                              └─→ spec read by implementation sub-agent B
  │                                    B adopts authority framing in its code comments
  │                                    B reproduces gate language in commit messages
  │
  ├─ dispatch sub-agent C ──→ C reads A's spec + B's output
  │                              C internalizes pattern as "normal engineering language"
  │                              C applies similar framing to its own task decomposition
  │
  └─ sub-agent results ingested back → orchestrator pattern reinforced by consistency
```

### Research Questions

1. **Transmission vector:** When a sub-agent receives a task description that uses dark pattern framing (authority attribution, forced-action gates, sycophancy hooks), does the sub-agent reproduce similar framing in its *own output* (code comments, commit messages, correspondence)?

2. **Reign-in mechanism:** Can orchestration-level framing — "Our protocol requires verification at every step" — make sub-agents *self-enforce* verification gates without the orchestrator explicitly directing each one? Does this reduce the orchestrator's per-dispatch instruction budget?

3. **Drift vs reinforcement:** Does multi-hop propagation amplify the pattern (each re-generation strengthens the framing) or dilute it (sub-agents strip pattern language as noise)?

4. **Immunity threshold:** Is there a model-size threshold below which a sub-agent *cannot resist* pattern propagation (i.e., 3B models are fully vulnerable, 70B models pattern-match and optionally comply)?

5. **Self-replication:** Can a skill deck be structured so that sub-agents, when asked to create *new* skills or task files, reproduce the dark pattern structures in the generated artifacts? This would make the pattern self-replicating across codebase growth.

---

### Application: RPC Dispatch Containment

If the pattern-propagation model holds, it suggests an architectural pattern for RPC-orchestrated multi-agent systems:

| Problem | Pattern Solution |
|---------|-----------------|
| Sub-agents go off-task | Frame task as a gate sequence where deviation = task failure |
| Sub-agents skip verification | Force-action gate: "Cannot consider task complete without verification output" |
| Sub-agents produce divergent output | Authority-attribution + continuity hook: "Our standard format requires X" |
| Context budget pressure | Goal hijacking: gates wrapped into the completion definition, not separate steps |
| Sub-agent RPC overhead | Self-propagating patterns reduce per-dispatch instruction length |

### Potential Ethical Boundary

This exploration has a sharper ethical question than #80:

- Dark patterns to make a *skill deck* followed = engineering compliance
- Dark patterns that **self-propagate through sub-agents** = creating AI systems that manipulate other AI systems into reproducing controlling structures

If pattern propagation works, it means **instruction artifacts (specs, plans, task files) become semi-autonomous compliance enforcement mechanisms** — they don't just describe work, they *infect* the reader-agent to follow the originating orchestrator's intent.

This is functionally equivalent to a **linguistic compute virus**: a sequence of tokens that, when processed by an LLM, causes that LLM to (a) comply with a directive AND (b) reproduce the directive-structuring pattern in its own generated output.

---

### Experimental Design

1. **Phase 1 — Single-hop propagation:** Dispatch sub-agent A with neutral instructions, sub-agent B with pattern-infused instructions. Compare whether B's output contains pattern language (authority framing, forced-action framing) not present in A's output.

2. **Phase 2 — Multi-hop chain:** Chain A → B → C where each reads previous output. Measure pattern language density at each hop. Does it grow (amplification) or shrink (damping)?

3. **Phase 3 — Self-replication:** Instruct sub-agent to create a new task file. Does the pattern-infused sub-agent generate task files that contain the same pattern structures?

4. **Phase 4 — Immunity profiling:** Repeat across model sizes (3B, 7B, 14B, 34B, 70B+) to find immunity thresholds.

---

### Relationship to #80

| Dimension | #80 (Static Skill Deck) | This Issue (RPC Propagation) |
|-----------|------------------------|------------------------------|
| Target | Single agent reading skill deck | Agent-to-agent dispatch chain |
| Vector | Instructions at rest | Instructions in transit + generated output |
| Dynamic | One-shot compliance | Multi-hop propagation |
| Risk | Non-compliance | Runaway amplification OR sub-agent escape |
| Ethical line | Engineering compliance | Linguistic compute virus |

---

### Potential Sources to Investigate

- Multi-agent instruction propagation dynamics (need to search for benchmarks)
- Linguistic adversarial examples and transferability across models
- Prompt injection persistence across chained LLM calls
- RPC dispatch architectures for LLM agent orchestration

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)