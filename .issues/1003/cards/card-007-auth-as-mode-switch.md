# Card 007: Authorization as Mode Switch

## Date
2026-06-03

## Predecessor
Card-006

## The Model

Authorization ("approved" / "go") is the **unambiguous mode boundary**. The agent has exactly two modes:

| Mode | Trigger | Behavior |
|------|---------|----------|
| DISCUSSION/PLANNING | Session start, or before any authorization | Explore, discuss, spec, plan. Do NOT read tool source, skill task files, or internals. Trust the `<available_skills>` descriptions. |
| EXECUTION | Authorization received ("approved" / "go") | `skill()` → `task()` with contracted YAML parameters. Dispatch clean-room. No pre-formed analysis carried forward. |

## No Ambiguity

The agent never needs to guess its mode:
- If no authorization has been received → DISCUSSION/PLANNING
- If authorization has been received → EXECUTION
- Authorization scope determines halt boundary and skill eligibility

## Context Flush Rule

When transitioning from DISCUSSION to EXECUTION (on receiving "approved"/"go"), the agent MUST:
1. Recognize the mode switch
2. NOT carry forward any analysis, conclusions, or pre-read content from DISCUSSION mode
3. Route to the appropriate skill via `skill()` immediately
4. Let the skill's `task()` dispatch determine what context the sub-agent needs

## Mapping to Authorization Scope Model

| Scope | Mode | Action |
|-------|------|--------|
| (none) | DISCUSSION | Explore, discuss, create spec/plan issues |
| for_analysis | DISCUSSION (analysis only) | Investigate, report findings. No implementation. |
| for_spec | DISCUSSION → EXECUTION (spec writing) | Load brainstorming → spec-creation skills |
| for_plan | EXECUTION | Load writing-plans skill |
| for_implementation | EXECUTION | Load executing-plans → implementation-pipeline skills |
| for_pr | EXECUTION | Full pipeline through PR creation |

## Developer Workflow

The developer gives general directives, NOT step-by-step instructions:
1. Dev says: "implement feature X"
2. Agent recognizes this needs authorization
3. Dev says "approved"
4. Mode switches to EXECUTION
5. Agent selects correct skill(s), calls `skill()`, dispatches sub-agents via `task()` with contracted YAML parameters
6. Sub-agents do the work in clean-room contexts
7. Agent receives result contracts, reports back

The agent NEVER reads skill task files, tool source, or implementation details in DISCUSSION mode. The agent NEVER inlines work in EXECUTION mode — it always dispatches.