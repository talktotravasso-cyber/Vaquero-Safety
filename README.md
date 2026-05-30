# Vaquero Safety Inc.
### AI-Powered Regulatory Compliance Intelligence Platform

> **For AI Agents:** Read this file first. It defines what this project is, how it is structured, and where every authoritative document lives. Do not make assumptions about scope, architecture, or agent behavior that are not grounded in the documents linked below. When in doubt about any decision — scope, tooling, pipeline logic, or client messaging — stop and read the relevant document before proceeding.

---

## What This Project Is

Vaquero Safety automates regulatory compliance monitoring for Canadian mid-market industrial operators. The platform watches Canadian regulatory sources, interprets what changed, performs gap analysis against client SOP libraries, and delivers human-reviewed compliance alerts with draft revision language — eliminating manual regulatory monitoring.

**Core value delivered:** When regulations change, clients know exactly what to update and receive draft language to do it.

**Operating model (current phase):** Managed service with AI augmentation. Human review gates on every AI output before client delivery. Not autonomous. Not self-serve yet.

**Primary market:** Alberta oil & gas contractors, 100–500 employees.
**Secondary market:** Canadian municipalities, 200–2,000 employees.

---

## Project Navigation

This is the authoritative map of the project. Every document is listed with its exact path and the decisions it governs. When working on any task, identify the relevant document and read it before writing code, generating content, or making architectural decisions.

```
C:\Projects\Vaquero_Safety_Inc\
│
├── README.md                          ← Start here. Every session. Maps the full project.
│
├── 01_Discovery\
│   ├── Business_Goals.md              ← Project scope, KPIs, success criteria,
│   │                                     in-scope / out-of-scope boundaries,
│   │                                     stakeholder roles, and milestone timeline.
│   │                                     READ THIS before any task to check scope.
│   │
│   ├── GTM_Strategy.md                ← ICP definition, sales motion, pricing tiers,
│   │                                     channel strategy, competitive positioning,
│   │                                     objection handling, and messaging rules.
│   │                                     READ THIS before generating any client-facing
│   │                                     content, outreach copy, or sales collateral.
│   │
│   └── Client_Assets\                 ← Client-specific files (SOPs, onboarding docs,
│                                         scope definitions). Organized per client.
│                                         Contains PII — handle per AI_Agent_Rules.md
│                                         Section 4 before passing to any LLM.
│
├── 02_Architecture\
│   ├── Technical_Architecture.md      ← Full tech stack, phase-by-phase build sequence,
│   │                                     data flow, database schema, build/buy/integrate
│   │                                     decisions, prompt versioning rules, confidence
│   │                                     scoring implementation, and deferred components.
│   │                                     READ THIS before any code, infrastructure, or
│   │                                     tooling decision.
│   │
│   └── AI_Agent_Rules.md              ← Agent behavior rules per pipeline stage,
│                                         the four absolute rules, confidence thresholds,
│                                         mandatory human review gates, output schema,
│                                         hallucination prevention system, prohibited
│                                         behaviors, and reviewer guidance.
│                                         READ THIS in full before writing any pipeline
│                                         logic, prompt, or AI workflow code.
│
└── 03_Workflows\                      ← Workflow definitions, n8n configurations,
                                          automation logic, and process maps.
                                          Governed by Technical_Architecture.md
                                          and AI_Agent_Rules.md.
```

---

## Document Load Order

Load documents in this sequence based on task type. Do not skip Steps 1 and 2.

| Step | Document | Required For |
|---|---|---|
| 1 — Always | `README.md` | Every session, every task |
| 2 — Always | `01_Discovery\Business_Goals.md` | Scope check before any work begins |
| 3 — Code / infra tasks | `02_Architecture\Technical_Architecture.md` | Any code, database, tooling, or infrastructure task |
| 4 — AI pipeline tasks | `02_Architecture\AI_Agent_Rules.md` | Any prompt, agent behavior, pipeline logic, confidence scoring, or output schema task |
| 5 — Content / sales tasks | `01_Discovery\GTM_Strategy.md` | Any client-facing content, outreach, demo script, pricing discussion, or positioning task |

**If a task touches two domains** (e.g., building the client delivery pipeline AND writing the email template), load both relevant documents before starting.

---

## Critical Constraints

These are the rules most likely to be violated by a capable AI trying to be helpful. They are system constraints, not guidelines. Read them before every session.

**1. No AI output reaches a client without human review.**
Every pipeline stage routes through the human review queue before delivery. Review gates are hard logic, not optional steps. Build them that way.

**2. Every AI output must include source citations.**
Output schema validation rejects any output without `citations` populated. No unsourced claim leaves the system.

**3. Confidence scoring is mandatory on every AI output.**
No output enters the review queue without `confidence.score` (float 0.0–1.0) and `confidence.rationale`. Enforced at application layer.

**4. The audit log is append-only.**
No `UPDATE` or `DELETE` on the `audit_log` table. Ever. Under any circumstance.

**5. Tenant isolation is non-negotiable.**
Row-Level Security enforced at database layer on all client tables. No cross-tenant queries. No shared embedding namespaces.

**6. Prompts are version-controlled code.**
No prompt deployed to production without a pull request and regression test. Every AI output logs the `prompt_version` used.

**7. Azure Canada Central is the only hosting target.**
Do not suggest or configure infrastructure outside Azure Canada Central.

**8. Do not build deferred components.**
Before proposing any new feature or component, check `02_Architecture\Technical_Architecture.md` Section 5. If it's on the defer list, do not build it without an explicit override instruction.

**9. Never deliver enforcement or penalty-adjacent content without senior review.**
Regardless of confidence score. No exceptions.

**10. Autonomous SOP publishing without human approval is permanently prohibited.**
This is not a deferral. It is a permanent constraint for a regulated industry product.

---

## Tech Stack — Quick Reference

| Layer | Tool |
|---|---|
| Scraping | Firecrawl MCP (primary), Playwright (fallback) |
| LLM — Primary | Anthropic Claude API (`claude-sonnet-4-20250514`) |
| LLM — Fallback | OpenAI GPT-4o |
| Embeddings | OpenAI `text-embedding-3-large` |
| Database | Supabase (PostgreSQL + pgvector) |
| Orchestration | n8n (self-hosted) → `03_Workflows\` |
| App layer | Next.js + Supabase |
| Hosting | Azure Canada Central |
| Email | Postmark |
| Notifications | Microsoft Teams webhook |
| Document parsing | LlamaParse / Unstructured.io |
| Version control | GitHub |

Full rationale and architecture decisions → `02_Architecture\Technical_Architecture.md`

---

## Pipeline Overview

```
[1] INGESTION        Scrape regulatory sources → detect changes → diff extraction
         ↓             Governed by: 02_Architecture\Technical_Architecture.md Section 3
                        Agent rules: 02_Architecture\AI_Agent_Rules.md — Stage 1

[2] INTERPRETATION   AI classifies change → generates summary + citations + confidence score
         ↓             Governed by: 02_Architecture\AI_Agent_Rules.md — Stage 2
                        Output schema: 02_Architecture\Technical_Architecture.md Section 7

[3] GAP ANALYSIS     Compare change against client SOP library → identify affected sections
         ↓             → generate draft revision language (flagged as AI DRAFT)
                        Governed by: 02_Architecture\AI_Agent_Rules.md — Stage 3
                        Client data lives in: 01_Discovery\Client_Assets\

[4] HUMAN REVIEW     Compliance reviewer approves / modifies / rejects → decision logged
         ↓             Governed by: 02_Architecture\AI_Agent_Rules.md — Stage 4
                        SLA: 24hr standard | 12hr low-confidence | 4hr enforcement

[5] DELIVERY         Approved output sent to client via email + Teams → delivery logged
                       Governed by: 02_Architecture\AI_Agent_Rules.md — Stage 5
```

---

## What This Project Is Not

Do not propose or build the following without an explicit override instruction:

- A full EHS platform (incident management, risk matrices, permit-to-work)
- A Learning Management System or training content generator
- An API integration layer for SAP, Oracle, or Workday
- A native mobile application
- US-jurisdiction regulatory monitoring
- Autonomous SOP publishing — permanent constraint, not a deferral
- SOC 2 infrastructure — deferred until enterprise prospects require it
- White-label platform features — deferred until 20+ customers

Full scope boundaries → `01_Discovery\Business_Goals.md` Section 3

---

## Current Build Phase

**Phase 1 — MVP (Months 1–6)**

Core pipeline only: scrape → detect → interpret → human review → deliver.

SOP ingestion and gap analysis (Phase 2) are not in scope until Phase 1 is stable and generating revenue. Do not build Phase 2 components.

Phase sequencing → `01_Discovery\Business_Goals.md` Section 7
Architecture phasing → `02_Architecture\Technical_Architecture.md` Sections 3–4

---

*Last Updated: May 2026 | Root file for `C:\Projects\Vaquero_Safety_Inc\`*
*Update this file when: folders are added or renamed, new documents are created, critical constraints change, or phase transitions occur.*
