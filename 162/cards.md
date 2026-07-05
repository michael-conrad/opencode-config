---
number: 162
title: "Card Catalogue — Same-Model Adversarial Auditor Divergence"
status: DRAFT
---

# Card Catalogue — Issue #162

## Research Cards

| Card | Status | Confidence | Source |
|------|--------|------------|--------|
| DiMo (He & Feng, arXiv:2510.16645) | COMPLETE | 0.9 | Paper reading + web fetch |
| PETITE (Tutor-Student same-model) | COMPLETE | 0.8 | Research notes |
| Calboreanu (Same-family blind spot) | COMPLETE | 0.7 | Research notes |
| Self-Correction (EIR/ECR model) | COMPLETE | 0.8 | Research notes |
| Self-Redraft (Exploration-exploitation) | COMPLETE | 0.7 | Research notes |
| MAD (Multi-Agent Debate, Degeneration-of-Thought) | COMPLETE | 0.8 | Research notes |
| RepoAudit (Guo et al., arXiv:2501.18160, ICML 2025) | COMPLETE | 0.85 | Paper reading via arxiv.org |
| MAD Limitations (Wu et al., arXiv:2511.07784) | COMPLETE | 0.8 | Paper reading via arxiv.org |
| MAD Scaling Critique (ICLR Blogpost 2025) | COMPLETE | 0.8 | Blog post reading |
| LLMs-as-Judges Survey (Li et al., arXiv:2412.05579) | COMPLETE | 0.7 | Abstract + survey scope |
| MAD Judge Stability (Hu et al., arXiv:2510.12697) | COMPLETE | 0.7 | Paper reading via arxiv.org |

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-07-04 | DiMo as primary reference | Same-model outperforms cross-model on 5/6 benchmarks; architectural divergence mechanism maps to existing clean-room task() isolation |
| 2026-07-04 | Cross-reference `.opencode#1672` | Implementation spec in submodule covers concrete changes; this spec provides theoretical foundation |

## Status

- [ ] Paper outline finalized
- [ ] Section 1-3 drafted
- [ ] Section 4 (DiMo reference) drafted
- [ ] Section 5 (Role-Differentiated Agent Chaining) drafted
- [ ] Section 6 (Empirical Evaluation) drafted
- [ ] Sections 7-9 drafted
- [ ] Full draft complete
- [ ] Peer review pipeline initiated
