# opencode-config

Parent repository for developing and testing the `.opencode` submodule in a realistic folder structure.

## What This Repo Is

A **test harness and integration surface** for the [`.opencode`](https://github.com/michael-conrad/.opencode) submodule. It provides:

- The directory layout that `opencode` CLI expects at runtime
- The `opencode.jsonc` configuration pointing to `.opencode/` paths
- A place to run behavioral and enforcement tests against a properly-structured project

## What This Repo Is Not

- It is NOT the source of truth for guidelines, skills, tools, plugins, or hooks — those live in the `.opencode/` submodule
- It does NOT contain application source code or application tests
- It does NOT contain duplicate copies of `.opencode/` content at the top level

## Structure

```
opencode-config/
├── .opencode/        ← git submodule (michael-conrad/.opencode, tracked branch: main)
├── .github/          ← Issue templates
├── .gitmodules       ← Submodule registration (branch = main)
├── AGENTS.md         ← Repo-purpose context for AI agents
├── CHANGELOG.md      ← Keep a Changelog release notes
├── README.md         ← This file
├── LICENSE           ← MIT
├── docs/             ← Auditor-model qualification research artifacts
├── skills/           ← Historical top-level skill-task content (tracked)
└── .gitignore
```

All guidelines, skills, tools, plugins, hooks, scripts, and tests live inside `.opencode/`. See [`.opencode/README.md`](.opencode/README.md) for details.

## Getting Started

```bash
git clone git@github.com:michael-conrad/opencode-config.git
cd opencode-config
git submodule init
git submodule update
```

## Using `.opencode` as a Submodule in Your Own Repo

```bash
git submodule add git@github.com:michael-conrad/.opencode.git .opencode
```

The submodule tracks the `main` branch — the single trunk; never operate on
a detached HEAD.

## Submodule Discipline

- **Edit inside `.opencode/`**: All changes to the deck (guidelines, skills, tools, etc.) happen inside the submodule directory and are authored upstream in `michael-conrad/.opencode` through its own PR process
- **Push from `.opencode/`**: Commit and push from inside `.opencode/` to the `michael-conrad/.opencode` remote
- **Update parent pointer — rides with real changes**: The parent's submodule pointer update lands in the same commit as the real parent-repo change it accompanies (a CHANGELOG entry, an AGENTS.md update, a release) — never as a pointer-only commit. Record the parent-repo change and the delivered submodule PR; each recorded pointer SHA carries its hash-permanence tag (`opencode-config/<issue>-.opencode`) in the submodule repository.

## License

MIT