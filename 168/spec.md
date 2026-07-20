<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# SPEC: `.opencode/tools/plan` — unified-planning PEP 723 Tool

**Co-authored with AI: OpenCode (deepseek-v4-flash)**

## 1. Purpose & Problem Statement

The `solve` tool validates workflow correctness using Z3 (SAT/SMT constraints). However, agentic workflows need more than constraint validation — they need **action sequence generation**: given a starting state and a goal, what ordered sequence of actions achieves it?

`plan` fills this gap by bringing AI planning to the agent toolchain. It uses the [unified-planning](https://github.com/aiplan4eu/unified-planning) library (v1.3.0, Apache 2.0, Python ≥3.8) as the solver backend, supporting multiple planning engines (Fast-Downward, Tamer, etc.) through a unified API.

Integration with `solve`: `solve` validates *invariants* (constraints that must hold across a plan), while `plan` generates the *action sequence* itself. Composed: plan generates the sequence → solve confirms invariants hold across it.

## 2. Proposed YAML Problem Schema

```yaml
# examples/gripper.yaml
domain: "gripper"
objects:
  - name: room_a
    type: location
  - name: room_b
    type: location
  - name: ball
    type: object
  - name: left
    type: gripper
  - name: right
    type: gripper
fluents:
  - name: at
    type: bool
    params: [{name: x, type: object}, {name: y, type: location}]
  - name: free
    type: bool
    params: [{name: g, type: gripper}]
  - name: carry
    type: bool
    params: [{name: g, type: gripper}, {name: x, type: object}]
actions:
  - name: move
    params: [{name: from, type: location}, {name: to, type: location}]
    preconditions:
      - "at(robot, from)"
    effects:
      - "at(robot, to)"
      - "not at(robot, from)"
  - name: pick
    params: [{name: g, type: gripper}, {name: x, type: object}, {name: l, type: location}]
    preconditions:
      - "free(g)"
      - "at(x, l)"
      - "at(robot, l)"
    effects:
      - "carry(g, x)"
      - "not free(g)"
      - "not at(x, l)"
  - name: drop
    params: [{name: g, type: gripper}, {name: x, type: object}, {name: l, type: location}]
    preconditions:
      - "carry(g, x)"
      - "at(robot, l)"
    effects:
      - "free(g)"
      - "at(x, l)"
      - "not carry(g, x)"
init:
  - "at(ball, room_a)"
  - "at(robot, room_a)"
  - "free(left)"
  - "free(right)"
goals:
  - "at(ball, room_b)"
```

### Schema Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `domain` | string | no | Domain label for the problem |
| `objects` | list | yes | Typed object declarations |
| `fluents` | list | yes | Predicate definitions with typed params (all `bool` type; extensions support `int`/`real`) |
| `actions` | list | yes | Action schemas with params, preconditions (list of ground fluent strings), effects (list of fluent strings, may be negated with `not fluent(...)`) |
| `init` | list | yes | Ground fluent atoms true in initial state |
| `goals` | list | yes | Ground fluent atoms to achieve |

## 3. Action Surface

| Action | Purpose | CLI Invocation |
|--------|---------|----------------|
| `plan` | Load YAML → run planner → print ordered action sequence | `plan plan --problem problem.yaml [--engine engine] [--max-plans N]` |
| `validate` | Verify a plan achieves goals | `plan validate --problem problem.yaml --plan plan.yaml` |
| `ground` | Ground the problem (remove params → concrete actions) | `plan ground --problem problem.yaml [-o output.yaml]` |
| `pddl` | Convert problem to/from PDDL | `plan pddl --export --problem problem.yaml [-o domain.pddl problem.pddl]` or `plan pddl --import --domain domain.pddl --problem problem.pddl [-o problem.yaml]` |
| `discover` | List available planners | `plan discover` |
| `state` | State file management (mirrors `solve` state — init/update/status) | `plan state init/update/status <path>` |

### Plan Output Format (YAML)

```yaml
problem: gripper
engine: fast-downward
quality_metric: quality
plan:
  - action: pick
    params: {g: left, x: ball, l: room_a}
    order: 1
  - action: move
    params: {from: room_a, to: room_b}
    order: 2
  - action: drop
    params: {g: left, x: ball, l: room_b}
    order: 3
metrics:
  actions: 3
  ground_actions: 3
  search_time_ms: 12.4
```

## 4. Integration with Existing `solve` Tool

### Shared State Management

The `plan state` subcommand mirrors `solve state` exactly in CLI interface (`init`/`update`/`status`) and can optionally share the same state file. This enables a compose workflow:

```bash
# Phase 1: Plan generation
plan plan --problem gripper.yaml -o plan.yaml

# Phase 2: Invariant validation via solve
solve check --state-path state.yaml --contract-path contract.yaml
```

### Compose Strategy

| Tool | Role | Output |
|------|------|--------|
| `plan` | Generate action sequence | YAML plan file |
| `solve` | Validate invariants across state | SAT/UNSAT verdict |
| `plan validate` | Verify plan achieves goals | PASS/FAIL |

A typical agent workflow: `plan plan → solve check → plan validate → execute actions with solve check at each step`.

### networkx Integration

The generated plan is loaded into a `networkx.DiGraph` for dependency analysis: each action is a node, and effect-to-precondition chains create edges. The tool reports critical path length, parallelizability, and bottleneck actions.

## 5. File Structure

Single PEP 723 script at `.opencode/tools/plan`:

```
.opencode/tools/plan          ← executable PEP 723 script
```

Dependencies (in PEP 723 header):
```python
# dependencies = ["unified-planning>=1.3.0", "pyyaml>=6.0", "networkx>=3.0"]
```

## 6. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `plan plan --problem <yaml>` runs a planner and prints an ordered action sequence achieving the goals | `behavioral` | Execute on gripper problem → verify output is valid YAML with ordered action list |
| SC-2 | `plan validate --problem <yaml> --plan <yaml>` verifies a plan achieves goals | `behavioral` | Valid plan → PASS; invalid plan (missing goal) → FAIL with exit code 1 |
| SC-3 | `plan ground --problem <yaml>` produces a fully grounded (no parameters) action set | `behavioral` | Grounded output has no param fields, all actions concrete |
| SC-4 | `plan pddl --export` converts to PDDL domain+problem files | `behavioral` | Output files parseable by unified-planning's PDDL reader |
| SC-5 | `plan pddl --import` imports PDDL back to YAML problem | `behavioral` | Roundtrip YAML→PDDL→YAML produces equivalent problem |
| SC-6 | `plan discover` lists available engine backends | `behavioral` | Output contains engine names (e.g., "fast-downward") |
| SC-7 | `plan state init/update/status` mirrors `solve` state CLI and optionally shares state file | `structural` | Same subcommand structure, shared `state.yaml` path |
| SC-8 | Generated plan loads into `networkx.DiGraph` with correct dependency edges | `structural` | `wc -c` on script, `up` check on pip install; action->precondition edges match plan order |

## 7. AI Byline and Provenance

All source files carry:
```python
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
```

```python
"""
plan — AI planning via unified-planning (PEP 723 script).

Actions: plan, validate, ground, pddl, discover, state

Co-authored with AI: OpenCode (deepseek-v4-flash)
"""
```

## 8. Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `unified-planning` | ≥1.3.0 | AI planning backend, multiple engine backends |
| `pyyaml` | ≥6.0 | YAML I/O for problem & plan files |
| `networkx` | ≥3.0 | Plan dependency graph analysis (critical path, parallelizability) |
| Python | ≥3.8 | unified-planning minimum requirement |