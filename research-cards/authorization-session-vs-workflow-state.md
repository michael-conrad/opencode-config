---
title: "Session Authorization vs Workflow State — Authorization Workflow Design Defects"
tags: [authorization, session-state, workflow-state, confused-deputy, self-authorization, approval-gate, record-then-verify]
confidence: 0.85
sources:
  - url: https://www.mindstudio.ai/blog/workflow-state-vs-session-state-ai-agents
    title: "What Is Workflow State vs Session State in AI Agents?"
    authors: "MindStudio"
    year: 2026
    finding: "Session state is conversational context within a single interaction. Workflow state tracks task progress independent of any particular conversation. Conflating them causes context window pollution, broken task continuity across sessions, and impossible debugging. Workflow state must live in a persistent store (database, state machine), not in the message thread."
  - url: https://safeguard.sh/resources/blog/ai-agent-tool-confused-deputy-problem-2026
    title: "AI Agent Confused Deputy Problem 2026"
    authors: "Shadab Khan, safeguard.sh"
    year: 2026
    finding: "The confused deputy in AI agents means the agent holds authority on behalf of a user and can be tricked into using it for a different purpose. The canonical fix: dual-channel architecture where the agent has a 'plan' channel (freely reason) and an 'act' channel (requires explicit approval). The authorization layer below the agent must refuse to execute unauthorized actions regardless of how eloquently the agent requested them."
  - url: https://www.stackai.com/insights/human-in-the-loop-ai-agents-how-to-design-approval-workflows-for-safe-and-scalable-automation
    title: "Human-in-the-Loop AI Agents: How to Design Approval Workflows"
    authors: "StackAI"
    year: 2026
    finding: "Key design principle: separate intent from execution. 'Propose' means storing a structured action payload in a durable store. 'Commit' means executing the tool call with strict checks. The state machine model: drafted → pending → approved → executing → completed. Approval must happen before side effects, not after. The approval channel must be one the agent cannot forge from its own context."
  - url: https://workos.com/blog/ai-agent-access-control-best-practices
    title: "Best Practices for AI Agent Access Control"
    authors: "Maria Paktiti, WorkOS"
    year: 2026
    finding: "Separate user authority from agent authority. The agent's effective authority should never exceed the intersection of what the agent and the user are each permitted to do. Defend against confused deputy attacks: the approval step must be out of band with respect to the agent's context. Require out-of-band human approval for high-impact and irreversible actions."
  - url: https://tianpan.co/blog/2026-04-20-rbac-ai-agents-authorization
    title: "RBAC Is Not Enough for AI Agents: A Practical Authorization Model"
    authors: "Tian Pan"
    year: 2026
    finding: "Treat the agent as its own identity with per-task credential issuance. The confused deputy is the default architecture for AI agents, not an edge case. The fix: scope access to what the current task requires, make that access expire when the task ends. Authorization decisions must be context-aware (ABAC), not static role-based."
  - url: https://tianpan.co/blog/2026-04-18-agent-identity-delegated-authorization-oauth-agentic-actions
    title: "Agent Identity and Delegated Authorization: OAuth Patterns for Agentic Actions"
    authors: "Tian Pan"
    year: 2026
    finding: "Dual-identity tokens (sub = user, act = agent) are the foundation of attribution. Per-operation scoping rather than per-agent scoping. Short-lived credentials (5-15 min) by default. Just-in-time provisioning: credential injected only when needed, expires immediately after."
  - url: https://www.urxion.com/resources/ai-agent-engineering/approval-workflows-for-agents
    title: "Approval Workflows for AI Agents"
    authors: "Sean Brennan, URXION"
    year: 2026
    finding: "Represent proposed actions as structured intents. Validate identity, scope, arguments, and risk before review. Show reviewers the expected effect and alternatives. Reauthorize if the plan or state changes. Log approvals, rejections, waivers, and escalations. Evidence-first agent loop: route → ground → validate → review."
  - url: https://cheatsheetseries.owasp.org/cheatsheets/AI_Agent_Security_Cheat_Sheet.html
    title: "AI Agent Security Cheat Sheet"
    authors: "OWASP"
    year: 2026
    finding: "Agents must not be able to self-authorize. Authorization must come from a source external to the agent's context. Tool abuse and privilege escalation are critical risks. The agent's authority must be explicitly delegated, never implicitly assumed."
summary: "The authorization workflow in approval-gate-scope has a fundamental design defect: it conflates session state (chat authorization) with workflow state (recorded issue state). The workflow checks for authorization in the issue tracking system as a precondition, but the authorization was just given in the chat session — it hasn't been recorded yet. This creates a circular dependency: the spec can't be approved without authorization, but the workflow requires the spec to be approved. Industry research converges on a record-then-verify pattern: (1) accept session authorization as authoritative, (2) record it into persistent workflow state, (3) verify the recording was successful. The agent must NOT be the one verifying its own authorization by checking records it hasn't yet written — this is a confused deputy variant."
applies_to:
  - approval-gate-scope
  - verify-authorization
  - gap-fill-cascade
  - spec-to-plan-cascade
