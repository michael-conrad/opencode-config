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
├── .opencode/        ← git submodule (michael-conrad/.opencode, dev branch)
├── AGENTS.md         ← Repo-purpose context for AI agents
├── README.md         ← This file
├── LICENSE           ← MIT
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

The submodule must track the `dev` branch — never detached HEAD or `main`.

## Submodule Discipline

- **Edit inside `.opencode/`**: All changes to guidelines, skills, etc. happen inside the submodule directory
- **Push from `.opencode/`**: Commit and push from inside `.opencode/` to the `michael-conrad/.opencode` remote
- **Update parent pointer**: After pushing submodule changes, update the parent repo's submodule SHA:
  ```bash
  git add .opencode
  git commit -m "chore: update .opencode submodule pointer"
  ```

## License

MIT