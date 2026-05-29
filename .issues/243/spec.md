---
id: 243
title: "[SPEC] Add Piskala (2026) Unix-to-Agentic-AI Reference"
type: spec
status: draft
created: 2026-05-03
target: docs/unix-philosophy-skilldeck/unix-philosophy-skilldeck.tex
---

# [SPEC] Add Piskala (2026) Unix-to-Agentic-AI Reference

**STATUS: 1.1 (IMPLEMENTED)**

## Summary

Add the arXiv paper 2601.11672 ("From Everything-is-a-File to Files-Are-All-You-Need: How Unix Philosophy Informs the Design of Agentic AI Systems" by Deepak Babu Piskala, January 2026) as a citation to the LaTeX document `docs/unix-philosophy-skilldeck/unix-philosophy-skilldeck.tex` and the research survey.

## Motivation

The paper argues that Unix's "everything is a file" abstraction has a contemporary analogue in agentic AI — where file- and code-centric interaction models enable maintainable, auditable, and operationally robust agent systems. This directly supports the paper's core thesis that Unix philosophy informs agent skill deck architecture. No other reference in the current bibliography traces the Unix-to-agentic-AI design lineage explicitly.

## Fix Approach

### 1. LaTeX Bibliography Entry

Add a `\bibitem{piskala2026unix}` entry to `\begin{thebibliography}{99}` (lines 1265–1402 in `unix-philosophy-skilldeck.tex`), positioned alphabetically after `neuroclaw2026` (line 1332) and before `smallorchestrator2026` (line 1334):

```latex
\bibitem{piskala2026unix}
Deepak Babu Piskala.
``From Everything-is-a-File to Files-Are-All-You-Need: How Unix Philosophy
Informs the Design of Agentic AI Systems.''
arXiv:2601.11672, January 2026.
```

### 2. Research Survey Entry

Add a row to the Academic Papers table in `docs/unix-philosophy-skilldeck/references/research-survey.md` (line 22, after Small Orchestrator row):

```
| Unix to Agentic AI | Piskala | Jan 2026 | arXiv:2601.11672 | File- and code-centric interaction models → maintainable, auditable agent systems |
```

### 3. Optional Body Citations

Add `\cite{piskala2026unix}` at relevant points where the paper's thesis is discussed:

- **Line ~204** — after "These principles were devised for operating-system processes communicating through pipes. Remarkably, they map onto the emerging field of AI agent architecture with surprising fidelity." → append `\cite{piskala2026unix}` to the sentence.
- **Line ~782** — after "The Unix philosophy's insight about composing small programs through pipes maps directly to sub-agent decomposition." → append `\cite{piskala2026unix}`.
- **Lines ~1125–1129** — conclusion section, after "The Unix philosophy of 'do one thing well' is precisely the design framework that the deck *aspires* to implement." → append `\cite{piskala2026unix}`.

## Success Criteria

- [x] SC1: `\bibitem{piskala2026unix}` entry present in the LaTeX bibliography between `neuroclaw2026` and `smallorchestrator2026`
- [x] SC2: Piskala (2026) row present in research-survey.md Academic Papers table after Small Orchestrator row
- [x] SC3: At least three `\cite{piskala2026unix}` references placed in the tex body at Introduction (line 204), Pipeline Model (line 782), and Conclusion (line 1125)
- [x] SC4: `xelatex` compiles without undefined-citation warnings for the new key (3-pass resolve)

## Files Affected

| File | Change |
|------|--------|
| `docs/unix-philosophy-skilldeck/unix-philosophy-skilldeck.tex` | Add bibitem + citations |
| `docs/unix-philosophy-skilldeck/references/research-survey.md` | Add Piskala table row (file- and code-centric) |

## Revision Notes

- 1.0: Initial spec — 2026-05-03
- 1.1: Implemented — 2026-05-03 (branch spec/243-piskala-reference; xelatex compile verified 3-pass; SC1-SC4 all PASS)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
