## [SPEC] LLM Control Language: Formalized Subset of English for Reliable Agent Task Dispatch

### Problem Statement
Large language models show significantly different accuracy depending on the language of the prompt (English > Chinese > other high-resource > low-resource). However, the literature has not systematically explored whether a **formalized subset of English** — stripped of ambiguity — can produce higher reliability for agentic task dispatch. Existing work (Formal-LLM, Grammar Prompting, UCL) applies external formal constraints, but no work defines a controlled natural language *within English itself* optimized for LLM instruction-following.

Furthermore, even if a "LLM Control English" grammar exists, raw human-authored prompts will never conform to it. A practical system requires an **LLM-based prompt processor** that compiles standard English prose into the control language — analogous to a compiler that translates high-level code into a constrained intermediate representation. This "prompt distillation" step is the missing pipeline component between human intent and reliable LLM dispatch.

### Research Questions
1. **RQ1:** Does stripping ambiguity from English (removing modal verbs, passive voice, negation, metaphor, vague quantifiers) improve LLM task dispatch reliability?
2. **RQ2:** Is there an optimal formalization ratio (per the UCL Over-Specification Paradox S* threshold)?
3. **RQ3:** Does structured YAML/markdown frontmatter already function as a de facto control language, and can it be systematized?
4. **RQ4:** Which English verb classes produce most reliable dispatch (execute vs. run vs. perform vs. do)?
5. **RQ5:** Can a "LLM Control English" be formally specified as a grammar, and does it outperform both free-form English and fully formal constraints?
6. **RQ6:** Can a secondary LLM (the "prompt compiler") reliably rewrite standard English prose into LLM Control English? What is the fidelity loss of the compilation step versus the dispatch reliability gain?

### Connection to Sparse Priming Representations
The Control English approach shares a structural affinity with **sparse priming representations** — compact, stripped-down encodings of intent that omit redundant or ambiguous linguistic content to maximize signal. Where sparse priming focuses on *token efficiency* and *concept activation*, Control English focuses on *constructional determinacy* (which English structures cause ambiguity). The two approaches may describe the same underlying phenomenon from different angles: sparse priming says "use fewer tokens with higher semantic density," Control English says "use only the grammatical constructions that produce deterministic behavior." A synthesis is worth exploring in the paper — sparse priming as the *optimization objective*, Control English as the *realized grammar*.

### SPR-Based Prompt Compiler Architecture (Core Implementation)
The existing SPR framework (Shapiro, 2023) provides a natural architectural template: **encoder** compresses full prose into a sparse form, **decoder** reconstructs the original from the sparse form. The Control English compiler reuses this encode/decode pattern but rewrites both prompts entirely:

```
Full English prose (human-authored skill, guideline, instruction)
  → [SPR encoder — Control English methodology]  ← rewritten prompt
  → Control English compressed form               ← determinate, stripped language
  → Stored in vector DB / served at inference
  → Agent executes task against compressed form
  → [SPR decoder — Control English methodology]  ← rewritten prompt (optional, for audit)
  → Reconstructed English prose
```

**What changes in the encoder prompt:**
The original SPR methodology instructs: *"Render the input as a distilled list of succinct statements, assertions, associations, concepts, analogies, and metaphors... use complete sentences."*

The Control English encoder prompt instructs instead: *"Render the input as a distilled list of determinate statements. Strip modal verbs, passive voice, negation scope ambiguity, metaphor, analogy, vague quantifiers, and temporal vagueness. Use imperative mood for actions. Mark conditionals explicitly with IF/THEN/ELSE. Mark scope boundaries explicitly with BEGIN/END. Use complete sentences written for another LLM to execute — not for a human to read."*

**What changes in the decoder prompt:**
The original SPR methodology instructs: *"Use the primings given to you to fully unpack and articulate the concept. Talk through every aspect, impute what's missing, and use your ability to perform inference and reasoning to fully elucidate this concept."*

The Control English decoder prompt instructs instead: *"Reconstruct the original instruction from the compressed Control English form. Preserve the logical structure exactly. Do not add analogies, metaphors, or associative elaboration. The reconstructed text must be a faithful expansion of the compressed form — the same instructions, fully articulated."*

**This is a dual deliverable:** both the encoder and decoder prompts are part of the paper's contribution, alongside the Control English grammar itself.

### Fidelity Cross-Validation Protocol
Both encoder and decoder should be subjected to an independent fidelity audit. The full pipeline:

```
Original spec prose
  → [Control English encoder — rewritten SPR prompt]
  → Compressed Control English form
  → [Control English decoder — rewritten SPR prompt]
  → Reconstructed spec prose
  → [Cross-validator — clean room, no context, no orchestrator bias]
  → Structured report: "Original and reconstructed differ on: X, Y, Z"
```

**Clean room setup for the cross-validator:**
- Receives ONLY the original and the reconstruction — no encoder prompt, no decoder prompt, no expected outcomes, no orchestrator reasoning
- Task: "Compare these two texts. Identify every semantic discrepancy. A discrepancy is any difference that changes what an agent instructed to follow this spec would do. Classify each discrepancy by construction type: modal, conditional restructuring, scope boundary shift, negation scope change, verb class change, or other."
- Returns a structured diff per construction type
- This maps directly to the adversarial audit sub-agent pattern — the cross-validator is just another auditor with `audit_phase: fidelity_check`

**What the protocol catches:**
- The encoder removing something that changes the spec's meaning
- The decoder failing to reconstruct faithfully
- Cascading loss: encoder error → decoder compounds it
- False positives: encoder strips something that looked eliminable but carried meaning

**Relationship to existing adversarial audit workflow:**
The spec is already audited by dual cross-family auditors for structural concerns. The fidelity cross-validator runs as a third audit phase — after Control English compilation, before the spec enters the dispatch pipeline. It is an additional gate, not a replacement.

### Compilation as Compression — Stats to Collect
The prompt compiler will necessarily compress (removing modals, hedging, anaphora, etc.). This overlaps with prompt compression research (LLMLingua, Selective Context). The paper should collect:
- Token reduction ratio per compilation
- Formalization ratio (constructions removed / total constructions)
- Correlation between compression ratio and dispatch accuracy
This positions Control English not as an alternative to compression, but as a *principled* compression strategy where removed tokens are determined by grammatical rule rather than probabilistic salience.

### DSL Embedding Within Control English
When task-specific DSLs (SQL, JSON Schema, PDDL) are embedded inline, the embedding syntax should follow the same "English-y" aesthetic as the host language — YAML-like line structure and keyword markers rather than JSON-like bracket nesting. The paper should specify that DSL blocks are demarcated by explicit Control English markers (e.g., `BEGIN DSL: <name>` / `END DSL`) rather than syntactic braces, maintaining the readability and parseability of the surrounding control language.

### Construction-Level Error Rate Analysis
RQ4 requires empirical measurement of error rates per English construction type. Planned data source: **opencode prompt chains** from the session database. Methodology:
1. Construct multi-turn agent dispatch test scenarios with controlled prompt variations
2. Run each variant through opencode-cli against real models
3. Log dispatch errors (wrong skill, wrong tool, wrong parameter, skipped step)
4. Attribute each error to the nearest English construction in the prompt
5. Aggregate by construction type to produce an error-rate ranking
This produces actionable data for the compiler: which constructions to strip first.

### Model-Dependency of S\* Threshold (Deferred)
If S* (the Over-Specification Paradox threshold) varies by model architecture, the compiler must be model-aware. This is end-game analysis for the paper — acknowledge it as a limitation and open question, potentially addressed in a follow-up studying threshold variation across 5+ model families.

### Self-Compilation — Agent Rewrites Its Own Prompt
Forward-looking direction: an agent that observes its own dispatch failures could rewrite its instructions into Control English as a self-correction mechanism — *self-modifying prompts*, echoing the self-modifying code tradition. This inverts the compiler pattern: instead of a separate pre-processor, the agent itself detects ambiguity in its instructions and resolves it before re-execution. Questions:
- Does self-compilation by the same model that failed produce better or worse results than a separate compiler model?
- Is there a risk of cascading misinterpretation (the agent misunderstands its own rewrite)?
- Can the agent detect *which* construction caused the failure and strip only that one (surgical self-correction)?
This should be a forward-looking section in the paper discussion, not a primary contribution.

### Supporting Literature (Research Note Cards)

**Card 1 — Language Accuracy Gap**
- "Not all languages are created equal in LLMs" (Huang et al., EMNLP 2023, cited 255)
- "Don't trust ChatGPT when your question is not in English" (Zhang et al., EMNLP 2023, cited 206)
- English prompts produce highest accuracy; gap is structural, not translation-quality

**Card 2 — Multilingual Instruction-Following Benchmarks**
- "Multi-IF" (He et al., 2024, cited 76)
- "XIFBench" (Li et al., NeurIPS 2026)
- "M-IFEval" (Dussolle et al., Findings 2025, cited 22)
- Instruction-following accuracy is NOT uniform across languages

**Card 3 — Formal Constraints on LLM Output**
- "Grammar Prompting for Domain-Specific Language Generation" (Wang et al., NeurIPS 2023, arXiv:2305.19234)
- BNF grammar in context improves structured output reliability
- Approach: LLM predicts grammar, generates within it

**Card 4 — Formal Constraints on Agent Planning**
- "Formal-LLM: Integrating Formal Language and Natural Language for Controllable LLM-based Agents" (Li et al., 2024, arXiv:2402.00798, cited 60)
- DFA automaton supervises plan generation
- **>50% overall performance increase**

**Card 5 — Formal Prompt Language**
- "Universal Conditional Logic: A Formal Language for Prompt Engineering" (Mikinka, 2025, arXiv:2601.00880)
- Indicator functions I_i in {0,1}, structural overhead O_s
- Over-Specification Paradox: threshold S* ≈ 0.509
- **29.8% token reduction** (p < 0.001, Cohen's d = 2.01)

**Card 6 — Prompt Programming Languages**
- "Plang: Efficient Prompt Engineering Language" (Hu et al., Expert Systems, 2025)
- "Grammar-LLM: Grammar-constrained NLG" (Tuccio et al., Findings 2025)
- LMQL (Beurer-Kellner et al.) — SQL-like query language for LLMs

**Card 7 — Cross-Lingual Ideological Differences**
- "Large Language Models Reflect the Ideology of their Creators" (Buyl et al., 2024)
- Same model, different language → different output
- LLM responds to Chinese tasks in Chinese almost as frequently as English (Zhang et al., 2025)

**Card 8 — LLM-as-Translator / Prompt Rewriting**
- LLMs are routinely used to rewrite and formalize prompts (prompt compression, prompt optimization)
- DSM Prompt Compression, LLMLingua, Selective Context — distill prose into concise structured form
- Novel angle: compiling to a *formal target grammar*, not just shorter prompts

**Card 9 — Sparse Priming Representations**
- Shapiro (2023) — SPR encoder/decoder for compressing knowledge to activate latent space
- Original methodology: *"analogies, metaphors, associations"* — evocative language for concept activation
- Control English adapts the SPR encode/decode pattern but rewrites both prompts for determinate task dispatch
- This is not "SPR applied to a new domain" — it is a *deliberate inversion* of the SPR language methodology

### Methodology
1. Define candidate "LLM Control English" grammar — subtractive: strip ambiguous constructions
2. **Rewrite the SPR prompts for Control English methodology:**
   - Encoder prompt: compress full English prose into determinate Control English form (no analogies, no metaphors, no modals, no passive voice)
   - Decoder prompt: reconstruct original instructions from compressed Control English (do not add associative elaboration)
   - These prompts are explicit deliverables — they define the compiler
3. **Design the prompt compiler/distiller:** The rewritten SPR encoder is the compiler front-end. Evaluate for:
   - Fidelity (round-trip: full English → compress → reconstruct — measured by cross-validator)
   - Formalization ratio (what fraction of ambiguous constructions were successfully removed?)
   - Compilation overhead (token cost, latency)
   - Token compression ratio (collected as stats for the compression synergy thread)
4. **Fidelity cross-validation (new):** Third-party clean-room auditor receives only the original and reconstruction. Tasked to identify every semantic discrepancy, classified by construction type. This audit runs as a separate phase — after compilation, before dispatch pipeline. Provides structured evidence of compilation fidelity.
5. **Construction-level error analysis:** Build multi-turn agent dispatch test scenarios from the opencode session database. For each prompt variant, attribute dispatch errors to the nearest English construction. Aggregate to produce a per-construction error-rate ranking (answers RQ4).
6. Test on standardized agent dispatch benchmarks (tool selection, task decomposition, planning)
7. Compare across five conditions:
   - Raw free-form English (baseline)
   - Control English (human-written, gold standard)
   - Control English (LLM-compiled from free-form via rewritten SPR encoder)
   - Fully formalized (BNF/DFA constraint)
   - Mixed (structured YAML-like frontmatter + free-form body)
8. Sweep formalization ratio to find S\* for the English-continuum case
9. Statistical analysis: effect size per construction removal, compilation fidelity vs. dispatch accuracy tradeoff
10. **End-to-end validation:** Compare full pipeline (human prose → encoder → compressed → dispatch) against baseline (human prose → dispatch directly). Is compilation overhead offset by dispatch reliability gain?

### Discussion Topics for the Paper
- **SPR inversion:** The paper reuses the SPR encode/decode architecture but deliberately inverts the language methodology (evocative → determinate). This contrast sharpens both approaches.
- **Fidelity auditing:** The cross-validation protocol provides an empirical measure of compilation integrity — can also detect decoder drift over iterative compilation cycles.
- **Self-compilation (forward-looking):** Agent rewrites its own failed prompt into Control English — self-modifying prompts.
- **Model-dependency of S\* (limitation):** UCL's threshold may vary by architecture; acknowledge as future work.
- **DSL embedding syntax:** Embedded task languages should use YAML-like "English-y" markers (BEGIN DSL / END DSL) rather than JSON-like bracket syntax.

### Deliverables
- LaTeX paper (target: ACL/EMNLP 2026 or 2027)
- Supporting research note cards (Zettelkasten format)
- Controlled English grammar specification
- **Rewritten SPR encoder prompt** — compresses full English prose into Control English
- **Rewritten SPR decoder prompt** — reconstructs original from compressed Control English
- **Prompt compiler implementation** — encoder + decoder as deployable prompts
- **Cross-validation audit protocol** — clean-room fidelity checker specification
- **Construction-level error rate dataset** — per-construction error rankings from opencode prompt chains
- Benchmark results across 3+ LLM families
- Reproduction datasets and prompts
- Fidelity-loss analysis: what semantic content is lost during compilation, and what is the cost/reliability tradeoff?

### Labels
- `spec`
- `research`