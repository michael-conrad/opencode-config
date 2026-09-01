# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Implementation Pipeline TDT Updates** (#361): Phase 1 TDT updates, state machine, inline Z3 check after AUDIT
- **Git Workflow Regression & Timestamp Tools** (#358): git-workflow regression fixes, timestamp tools, step counts, testing lessons learned documentation
- **Skill Card Architecture Docs** (#333): cross-reference new `.opencode/reference/` documentation files in AGENTS.md
- **Behavioral Test Remediation** (#327): 4 new behavioral test files, fixed completion.md, stripped DiMo cross-references, cost model documentation
- **Test Framework Discipline** (#306): timeout command prohibition, with-test-home mandate, standalone binary setup pattern, prohibited bypass patterns
- **Phase 10 Behavioral Tests** (#286): behavioral test scripts and AGENTS.md references for version-manager and release-promoter skills
- **Trigger Dispatch Tables** (#199): submodule-sync task, sub-agent task file discovery directive
- **Filesystem-as-Pipe Paper** (#159): LaTeX paper on context rot, ritual enforcement, Piskala extension (11 pages)
- **Verification Gate Restructure** (#142): git-workflow restructure, verification-gate pipeline, anti-evasion rules, BEHAVIOR_MODEL default, orphaned process fix, assert_semantic removal
- **Content Gate & Local Issues** (#133): local `.issues/` directory platform, stacked PR organization, evidence type taxonomy, Gate 2 removal, frontmatter triggers, test integrity mandate
- **Skill Routing Dissonance** (#104): stderr-based behavioral test mandate, auditor routing fixes
- **Piskala Reference** (#36): add Piskala (2026) Unix-to-agentic-AI arXiv reference as sibling citation
- **Unix Philosophy Skilldeck Paper** (#26): unix philosophy skilldeck paper with Gap 7-8 analysis and model benchmarking
- **Question-Response Routing Gate** (#13): question-response gate to prevent interrogative premise collapse, submodule routing gate in issue-operations
- **Tag-Based Submodule Permanence** (#8): replace submodule release PRs with tag-based hash permanence, idempotent tag-if-untagged rule
- **Skill Card Mandatory Tasks** (#7): mandatory tasks checklist sections in 8 priority SKILL.md files
- **Multi-Feature Implementation** (#3): SCP universal rule, for_pr scope continuation, pre-push branch topology hook, workflow restore, mermaid diagrams in 44 skill cards
- **Runtime Enforcement Gates** (#19): runtime enforcement gates, Gate 4 disable fix, config rollback to 1860c0d tree

### Changed

- **Default Test Model Update** (#2425): bump parent root AGENTS.md default test model reference to `ollama/qwen3.8:27b-256k-gguf4` and update `.opencode` submodule pointer to the merged submodule PR
- **Gitignore Enhancement** (#336): comprehensive `.gitignore` for mixed Python/LaTeX/Node.js project with standard ignores
- **Specs-Not-Tracking-Docs** (#329): update AGENTS.md and submodule pointer — specs and plans are NOT tracking documents
- **Read-Link Cross-Reference** (#294): replace `See` with `Read [Text](path)` cross-reference pattern in AGENTS.md
- **Submodule Pointer Updates** (#251, #249, #247): trunk-based transition, submodule pointer sync to main
- **Trim Parent AGENTS.md** (#88): remove skilldeck-subverting content, trim AGENTS.md from 98 to 3 lines
- **Track Local Work** (#47): track local `.issues/`, auditor docs, behavioral tests, submodule pointer updates
- **Submodule Pointer Docs** (#11): pointer handling documentation for #224 #225
- **Submodule Post-Merge Update** (#2): update submodule pointer after PR #216 merge
- **Submodule Sync** (#67): update submodule to latest dev (PR #490, #491)

### Fixed

- **Test & Docs Fix** (#337): flat writing-plans architecture, test/docs fixes, submodule pointer workflow documentation
- **Submodule Pointer Fixes** (#178): PR body format fix (remove instructional language), memory tool removal
- **Stale .issues/ Untrack** (#175): untrack stale `.issues/` directory from parent repo index (orphan-branch worktree)
- **Root Detection** (#15): unify project root detection across all scripts
- **Gitmodules Restore** (#5): restore `.gitmodules` with correct submodule URL
- **Skilldeck-Subverting Content** (#87): remove skilldeck-subverting content from parent AGENTS.md
- **.issues/ Gitignore Enforcement** (#276): agents ignore `.gitignore` and corrupt git state — enforcement documentation
- **Squash-Push Remediation**: submodule pointer update for squash-push workflow fixes
- **assert_semantic stdout+stderr concatenation** (#835): fix assert_semantic to concatenate both stdout and stderr for clean-room behavioral inspection
- **SC behavioral evidence rewrite** (#835): replace regex-on-prose assertions with assert_semantic in check-prs-routes-to-cleanup and submodule-cleanup-no-depsync-pr scenarios
- **Evidence type test Rule 5 compliance** (#836): convert SC-7 from 3x assert_required_pattern_present (string evidence on prose) to assert_semantic (behavioral evidence) as primary assertion, with assert_required_pattern_present as secondary corroboration only

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)