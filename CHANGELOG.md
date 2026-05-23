# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Content gate for local issues** (#691): local `.issues/` directory platform for issue tracking when `github.platform` is `local` or unset
- **Stacked PR organization** (#826): enforce single-branch stacked PR strategy; prohibit N-branches-for-N-issues pattern
- **Gate 2 removal** (#808): remove pre-commit Gate 2 (question-as-authorization detection) from session-enforcement.ts
- **Frontmatter triggers** (#810): add YAML frontmatter trigger support to guidelines and skill files for enforcement discovery
- **Test integrity mandate** (#831): add behavioral test integrity rules prohibiting assertion removal/weakening and functional test substitution

### Fixed

- **assert_semantic stdout+stderr concatenation** (#835): fix assert_semantic to concatenate both stdout and stderr for clean-room behavioral inspection
- **SC behavioral evidence rewrite** (#835): replace regex-on-prose assertions with assert_semantic in check-prs-routes-to-cleanup and submodule-cleanup-no-depsync-pr scenarios
- **Evidence type test Rule 5 compliance** (#836): convert SC-7 from 3x assert_required_pattern_present (string evidence on prose) to assert_semantic (behavioral evidence) as primary assertion, with assert_required_pattern_present as secondary corroboration only
- **Squash-push remediation**: submodule pointer update for squash-push workflow fixes

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)