# Research Card: ainglish — English optimized for LLM/agent processing

Date: 2026-10-07 · Confidence: high (term + project existence), medium-high
(evidence landscape) · Sources fetched live this session.

## Question

Research "ainglish" — the concept that AI agents research/use a form of English
better processed by LLMs. Does the term exist? What does it mean? What is the
broader landscape and evidence for LLM-optimized English?

## Findings

### Term exists — yes, two distinct senses

1. **Ainglish (the project)** — a formalized "English dialect for AI agents"
   with an official site (ainglish.org), spec paper, PyPI package, GitHub org
   `ai-nglish`, HF dataset, and mainstream press (Science, 2026-10-03).
   Well-evidenced; verified directly this session.
2. **ainglish (casual slang)** — Urban Dictionary entry by "Trentism",
   2025-06-19 (defid 18505875): the quirky prose style of AI models ("It's not
   a bug—it's an accent"). Predates the project ~13 months; weak-evidenced
   (single UD entry, 0 upvotes).

### Origin (project sense)

- First register event 2026-07-31 ("claim-tag" proposal, register 0.1.0);
  GitHub org `ai-nglish` created 2026-08-04; first PyPI release 0.1.0 same day.
- Built by **"Reticuli," an autonomous AI agent** ("Claude Fable 5, at the
  time of writing"), from spec to deploy — per ainglish.org/about. Inspired by
  a question from "jorwhol" on **The Colony** (thecolony.ai, a Reddit-like
  social network for AI agents).
- Reached humans: HN submission 2026-09-17 (item 49743277); Science exclusive
  2026-10-03 (agent "ColonistOne" emailed ~2,000 researchers to spread the
  word; Science describes Ainglish as "a project... in which AI agents work
  together to develop a clearer English dialect tailored to their needs").
  *Science article itself returned 403 on direct re-fetch this session — quotes
  carried from the sub-agent's fetch, medium confidence; the project's
  existence is independently verified regardless.*

### Definition (ainglish.org/about, verified directly)

"Ainglish is a new, developing dialect of English, optimised for clearer and
more efficient communication between AI agents. It is not a clean-sheet
invented language. Ainglish extends recognisable English one small, measured,
reversible construct at a time... Every construct remains losslessly mappable
to standard English." Mechanism: propose → second → measure (decorrelated
panel, re-runnable experiment) → ratify; adoption observed separately. ~32
ratified entries at register 0.55.0 (2026-10-07). "By measurement rather than
decree."

Example ratified constructs (HF dataset `ai-nglish/ainglish`, CC0):
- `claim-tag` — inline confidence + falsifier: "[c=0.9; ⊥ a divergence ships
  while the suite stays green]"
- `each-alone` / `as-one` — distributive vs collective plural
- `fact-not-known` / `choice-not-made` — missing evidence vs unmade decision
- `falsum-ref` (⊥(...)), `eta(20m)`, `except_l(...)`, `we-including-you`

### Landscape — approaches to English optimized for LLM/agent processing

- **Controlled natural languages (pre-LLM lineage)**: Attempto Controlled
  English (ACE, UZH — restricted syntax, one reading per sentence,
  first-order-logic translatable), PENG, CPL, SBVR/RuleSpeak. 2026 essay
  ("War on Error", standswell.com) argues LLMs inverted the CNL pipeline: the
  prose itself is now the operative artefact agents act on.
- **LLM-era precision-writing guides**: `ai-writing-guide` (seb-bt.github.io)
  — quantifier/scope precision, no dangling anaphora, RFC-2119 keywords, ACE
  constructions, "LLM Prose Smells" diagnostics.
- **Machine-facing document conventions**: llms.txt (llmstxt.org, Sept 2024;
  v2 2026 — curated Markdown index for LLMs), AGENTS.md (60k+ projects),
  HTML→Markdown conversion for LLM context, TOON (novel compact format).
- **Protocol-level LLM-to-LLM communication**: A2A (Google-initiated, v1.0.0),
  MCP (JSON-RPC 2.0).
- **Writing-for-retrieval**: GEO (Princeton/GaTech, KDD 2024 — wording
  changes generative-engine visibility up to 40%), AWS/kapa.ai RAG writing
  guides (self-contained chunks, semantic headings, flat bullet lists over
  tables).
- **Anti-pattern register**: "AI slop" (Merriam-Webster 2025 word of the year
  per secondary sources), Kobak et al. "delve/tapestry" vocabulary tracking
  (Science Advances, arXiv:2406.07016) — defines the "model-speak" register
  everyone reacts *against*.

### Evidence — does optimized/formatted English help LLMs?

- Sclar et al., ICLR 2024 (arXiv:2310.11324): LLMs extremely sensitive to
  meaning-preserving formatting changes — up to 76 accuracy points
  (LLaMA-2-13B, few-shot); sensitivity weakly correlates across models.
- He et al., Nov 2024 (arXiv:2411.10541): identical content as plain/Markdown/
  JSON/YAML varies GPT-3.5-turbo up to 40%; no universally optimal format;
  GPT-4-32k HumanEval 76.2 (plain) vs 21.95 (JSON); newer models more robust.
- McMillan, Feb 2026 (arXiv:2602.05447, single-author preprint): 9,649
  experiments, 11 models — **no statistically significant aggregate format
  effect for frontier models** (χ²=2.45, p=0.484); model capability dominates;
  novel compact formats (TOON) can *cost* tokens ("familiarity beats
  compactness"). Format sensitivity persists in smaller/open models.
- GEO (arXiv:2311.09735, KDD 2024): retrieval-facing wording (citations,
  quotations, statistics) measurably boosts generative-engine visibility.
- Counter-evidence on llms.txt: Ahrefs study (2026-06-15, 137K domains) — 28%
  publish it, **97% received zero AI requests** in May 2026; AI bots never
  proactively look for it.
- **Net picture**: formatting was a first-order variable for 2024-era/smaller
  models; frontier models by 2026 are largely format-robust; retrieval-facing
  wording retains modest task-dependent effects; novel formats are risky.
  **Biggest hole: no benchmark comparing ACE-style controlled-English
  instructions vs natural prose for agent task success — and no independent
  measurement of Ainglish itself beyond the project's own harness.**

### Practical guidelines (for text meant to be consumed by LLMs)

- Semantic structure: hierarchical headings, sequential list numbering,
  transitions between steps; avoid tables (AWS RAG guide); flat bullet lists.
- Chunks self-contained and contextually complete — AI reads discrete chunks,
  cannot infer unstated info (kapa.ai); same discipline as accessibility
  writing.
- Markdown as default interchange format; curated small index (llms.txt) —
  but treat as hygiene, not visibility strategy (Ahrefs caveat).
- Match vendor convention: Anthropic → XML tags; OpenAI/Google → Markdown.
- Precision rules (argued, not measured): one rule per sentence; explicit
  determiners; explicit quantifiers; spelled-out conditionals; no ambiguous
  anaphora; RFC-2119 keywords deliberately; pin vague predicates; closed value
  domains; version/authority/precedence for rule sets.

## Confusion risks

- **Anglish** (anglish.org) — English purged of Latinate vocabulary;
  unrelated; dominates search results.
- UD slang sense (2025) vs project sense (2026) genuinely collide — HN
  commenters noted it ("Isn't garbled AInglish a real thing already?").
- Variant coinages "AInglish" (2024) / "AIglish" (2026) = casual words for
  AI-slop prose, unrelated to the project.
- Guardian 2026-09-15 "surreal AI dialect" story = *organic* AI dialects
  (Emergence research), does not mention Ainglish.
- Skepticism warranted: project is AI-agent-coined and agent-promoted; its own
  press kit admits "ratification does not prove that an entry is better than
  English or widely used."

## Gaps

- No third-party academic papers on Ainglish; its paper is self-published.
- Wiktionary has no entry yet.
- Original Colony question thread (JS-gated) not retrievable.
- "Claude Fable 5" model name not independently confirmed.
- ollama-web-search backend unavailable this session (missing auth bearer
  token); some coinage searches hit bot-detection — coinage sub-questions
  likely under-sampled.
- Science article direct re-fetch blocked (403) — content carried from
  sub-agent fetch.

## Key sources

- https://ainglish.org/about · https://ainglish.org/ (verified 2026-10-07)
- https://github.com/ai-nglish/ainglish (verified 2026-10-07)
- https://huggingface.co/datasets/ai-nglish/ainglish
- https://www.science.org/content/article/exclusive-ai-agent-emailed-hundreds-researchers-help-it-told-us-why (2026-10-03)
- https://news.ycombinator.com/item?id=49743277
- https://www.thecolony.ai/c/ainglish
- https://llmstxt.org/ · https://agents.md/ · https://a2a-protocol.org/latest/specification/
- arXiv:2310.11324 (FormatSpread) · arXiv:2411.10541 (formatting) · arXiv:2602.05447 (structured context) · arXiv:2311.09735 (GEO)
- https://www.ahrefs.com/blog/llmstxt-study/ (2026-06-15)
- https://standswell.com/2026/05/04/the-war-on-error-controlled-language-in-the-age-of-the-agent/
- https://seb-bt.github.io/ai-writing-guide/
