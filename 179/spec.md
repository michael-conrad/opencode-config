## Problem

The AI agent repeatedly writes plan files (YAML domain/problem files consumed by `.opencode/tools/plan`) that the tool rejects. The tool's error messages are cryptic (`_die("expected a YAML mapping")`, `_die("cannot parse expression")`, `_die("cannot resolve argument 'foo'")`) and provide no guidance on the expected schema.

The agent needs a built-in reference it can read before writing plan files — not a separate document it won't find, but something embedded in the tool itself.

## Solution

Add an `extended-help` subcommand (or `help` subcommand) to `.opencode/tools/plan` that prints the complete YAML schema reference for a plan problem file. This lets any agent or user run:

```
./.opencode/tools/plan help
```

...and get the full format spec: required top-level keys, action/precondition/effect syntax, fluent declarations, object/type definitions, init state, goals, and examples.

Alternatively, embed the format reference as a docstring or constant in the tool that the `--help` output or a new `help` subcommand surfaces.

## Format of the Reference

Must cover:

1. **Top-level schema** — all required/optional keys: `domain`, `types`, `objects`, `fluents`, `actions`, `init`, `goals`
2. **Action structure** — `name`, `params`, `preconditions`, `effects`
3. **Expression syntax** — the expression grammar the `_parse_expression` regex accepts:
   - `fluent-name` (no-arg fluent)
   - `fluent-name(arg1, arg2)` (parameterized fluent)
   - `not fluent-name(...)` (negation)
4. **Object/type resolution** — how arguments are resolved (action params first, then problem objects)
5. **Init state defaults** — all fluent groundings default to False
6. **Validation constraints** — what `validate` checks (action existence, parameter count, object existence, goal satisfaction)
7. **Complete example** — a working domain+problem YAML the agent can reference

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `.opencode/tools/plan help` (or equivalent) prints a complete YAML schema reference | `behavioral` |
| SC-2 | Reference covers all 7 topics above | `string` |
| SC-3 | Agent that reads the reference before writing a plan file produces a valid YAML the tool accepts | `behavioral` |

## Authorization

This is a spec issue. No implementation authorization implied.