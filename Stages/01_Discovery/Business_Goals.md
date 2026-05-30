# Business_Goals.md
# Vaquero Safety Inc.
_Last Updated: May 2026 | Version 1.0_

---

## 1. PROJECT OVERVIEW & HIGH-LEVEL OBJECTIVES

### Project Name & Description
**Vaquero Safety Inc. — AI-Powered Regulatory Compliance Intelligence Platform**

Vaquero Safety automates the conversion of regulatory change into operational action for Canadian regulated industries. The platform monitors Canadian regulatory sources (provincial OH&S bodies, AER, WCB, CSA, municipal), interprets what changed, performs gap analysis against a client's existing SOP library, and delivers human-reviewed compliance alerts with draft SOP revision language — eliminating manual regulatory monitoring and reducing compliance lag from weeks to hours.

### Core Goal
Build a recurring-revenue compliance intelligence service — initially delivered as a managed service with AI augmentation — that becomes the regulatory operationalization layer for Canadian mid-market industrial operators. The primary value delivery: **when regulations change, clients know exactly what to update and receive draft language to do it.**

### Problem Statement (Current Manual Process Pain Points)
- Safety managers and HSE directors spend 10–20+ hours/month manually monitoring regulatory bodies for changes across provincial OH&S, AER, WCB, CSA, and federal requirements
- No centralized system exists to track which regulatory changes affect which internal SOPs
- Regulatory interpretation requires specialist knowledge most mid-market companies don't have in-house
- Companies currently rely on expensive external safety consultants ($150–$300/hour) for interpretation and SOP updates
- Compliance lag between regulation change and SOP update creates audit exposure and liability risk
- Documentation and audit trail for compliance decisions is ad hoc, inconsistent, and legally fragile
- Oil & gas contractors operating across multiple regulatory jurisdictions face compounding complexity with no scalable tooling

---

## 2. SUCCESS CRITERIA & KPIs (MEASURABLE)

### Target Metrics — 12-Month Targets

| Metric | Target | Rationale |
|---|---|---|
| Paying customers | 10–15 | Proves repeatable sales motion |
| MRR | $30,000–$60,000 | Validates pricing holds at $3K–5K/month |
| ARR | $400,000–$700,000 | Sustainable operations threshold |
| Compliance admin time reduction (per client) | ≥40% reduction in regulatory monitoring hours | Core value prop proof point |
| AI interpretation accuracy (post-human review) | ≥95% accuracy on regulatory classification and impact assessment | Trust threshold for enterprise adoption |
| Customer churn (month 12) | <10% annual | Validates product-market fit |
| Average onboarding time | <30 days from contract to first regulatory alert delivered | Operational efficiency benchmark |
| Human review turnaround | <24 hours from AI output to client-facing delivery | Service quality standard |
| Audit support events successfully documented | 100% of client audit requests fulfilled | Defensibility proof |

### ROI Projections

**Customer ROI (per client justification):**
- Safety consultant replacement/reduction: $2,000–$8,000/month saved per client
- Internal safety manager time recovered: 10–20 hours/month × $75–$120/hour fully loaded = $750–$2,400/month
- Total monthly value delivered: $3,000–$10,000 per client
- Platform cost: $1,500–$6,000/month → **3x–5x ROI on low end**

**Vaquero Unit Economics (target):**
- Gross margin target: 60–70% at steady state (managed service phase)
- Customer Acquisition Cost (CAC): <$5,000 (founder-led sales, low channel spend)
- Target LTV: $54,000–$180,000 (3-year contract at $1,500–$5,000/month)
- LTV:CAC ratio target: >10:1

---

## 3. SCOPE & BOUNDARIES

### In-Scope (What the AI System Handles)

**Regulatory Monitoring Layer:**
- Automated scraping and change detection across defined Canadian regulatory sources (Alberta OH&S, AER, WCB Alberta, CSA standards, federal OHS Code, and client-defined jurisdictions)
- Hash-based change detection with diff generation on monitored regulatory documents
- Classification of change type: new requirement, amendment, clarification, enforcement update, deadline change

**Interpretation Layer:**
- AI summarization of what changed and what it means in plain language
- Impact classification: High / Medium / Low based on client's industry and operational scope
- Source citation attached to every interpretation output (no unsourced claims reach clients)
- Confidence scoring on every output — flagging items requiring elevated human review

**Gap Analysis Layer:**
- Comparison of regulatory change against client's ingested SOP library
- Identification of specific SOP sections requiring update
- Draft revision language generation with explicit "AI-generated, requires review" flagging

**Human Review Queue:**
- Structured review workflow for compliance reviewer to approve, reject, or modify AI outputs
- Review audit log with reviewer identity, timestamp, and decision rationale
- Escalation path for low-confidence or ambiguous interpretations

**Client Delivery:**
- Regulatory digest delivery via email and/or Microsoft Teams webhook
- SOP gap alert with draft revision language attached
- Monthly compliance summary report
- Audit documentation package on request

**Audit & Traceability:**
- Append-only audit log of every regulatory change detected, every AI interpretation, every human review decision, and every client-facing delivery
- Full version history of all client SOP documents
- Immutable compliance decision record

### Out-of-Scope (Explicit Boundaries — Do Not Build Yet)

- Autonomous SOP publishing without human approval — **never fully autonomous in regulated industries**
- Custom Learning Management System (LMS) module generation — integrate with TalentLMS/existing systems
- Full EHS platform (incident management, risk matrices, permit-to-work) — do not compete with Cority/Intelex
- US regulatory coverage — defer until Canadian market proof is airtight
- Enterprise API integration layer (SAP, Oracle, Workday) — defer until enterprise contract justifies it
- Native mobile application — unnecessary in year one
- SOC 2 certification — pursue only when enterprise prospects require it
- White-label platform — defer until 20+ customers
- Proprietary LMS or training content generation at scale
- Legal advice, legal opinion, or acting as a substitute for qualified legal counsel — outputs are compliance operations support, not legal interpretation
- Autonomous AI decision-making without confidence threshold validation and human review gate

---

## 4. PROCESS DOCUMENTATION & INPUTS

### Current Manual Workflow (What We Replace)

1. Safety manager allocates 2–5 hours/week monitoring Alberta OHS, AER, WCB, CSA, and federal regulatory websites
2. Manually downloads or reads bulletins, notices, and amended documents
3. Assesses whether change is relevant to their operations — often requires re-reading source legislation
4. Searches internal SOP library manually to identify potentially affected procedures
5. Writes notes or emails summarizing the change — no structured format
6. Engages external safety consultant for interpretation if change is complex ($150–$300/hour)
7. Consultant or internal person drafts SOP revision — no version control, no audit trail
8. SOP revision circulated via email for approval — no formal workflow
9. Updated SOP saved over previous version in SharePoint/network drive — no immutable history
10. No automated notification to affected workers — training distribution is manual
11. At audit time, scramble to reconstruct documentation — no centralized compliance decision record

**Time cost:** 10–25 hours/month per client, plus consultant fees of $500–$3,000/month

### Inputs & Data Sources

| Source | Type | Method | Notes |
|---|---|---|---|
| Alberta OHS Legislation | Regulatory text | Firecrawl scrape | Primary jurisdiction |
| Alberta Energy Regulator (AER) | Directives, bulletins | Firecrawl scrape | Oil & gas specific |
| WCB Alberta | Policy, rates, bulletins | Firecrawl scrape | Workers compensation |
| CSA Standards (relevant) | Standards updates | Scrape + manual | Some gated content |
| Federal OHS Code | Legislation | Scrape | For federally regulated clients |
| WorkSafeBC / ON MOL | Legislation, bulletins | Scrape | Expansion jurisdictions |
| Client SOP Library | PDF, Word documents | Upload / SharePoint API pull | Ingested at onboarding |
| Client Regulatory Scope Definition | Structured form | Onboarding questionnaire | Defines monitoring filters |

### Tools & Platforms

| Layer | Tool/Platform | Purpose |
|---|---|---|
| Regulatory Scraping | Firecrawl MCP | Clean markdown extraction from regulatory sites |
| Change Detection | Custom diff engine (hash comparison) | Identify what changed between scrape cycles |
| LLM Reasoning | Anthropic Claude API (primary), OpenAI GPT-4o (fallback) | Interpretation, classification, gap analysis, draft generation |
| Vector Database | Supabase + pgvector | Semantic search across regulatory corpus and client SOPs |
| Document Parsing | Llamaparse or Unstructured.io | Ingest client SOP libraries (PDF, Word) |
| Human Review Queue | Internal workflow (lightweight — email-based initially) | Review gate before client delivery |
| Client Notification | Email + Microsoft Teams webhook | Regulatory alert delivery |
| Document Management Integration | Microsoft Graph API (SharePoint/Teams) | Pull/push client documents |
| Audit Logging | Append-only PostgreSQL table | Immutable compliance record |
| Hosting | Azure Canada Central | Data residency — Canadian regulatory clients require this |
| Prompt Versioning | Version-controlled prompt registry | Every prompt must be versioned and tested |

---

## 5. AI AGENT RULES & CONSTRAINTS

### Decision Logic

| Scenario | AI Action |
|---|---|
| Regulatory change detected, confidence ≥85% | Generate interpretation + gap analysis, route to human review queue |
| Regulatory change detected, confidence <85% | Flag as low-confidence, escalate with explanation of ambiguity — do not generate SOP draft |
| Change affects a CSA standard (gated content) | Flag for manual human review — do not attempt interpretation without full source text |
| Client SOP affected by change | Generate gap analysis with specific section references + draft revision language — marked "AI DRAFT — REQUIRES REVIEW" |
| Client SOP not in ingested library | Flag gap — alert client that SOP coverage is incomplete for this regulatory area |
| Conflicting regulatory signals detected | Surface conflict explicitly — do not resolve conflicts autonomously |
| New regulatory requirement with no analogous precedent | High-confidence flag to senior reviewer — conservative interpretation only |
| AI output involves enforcement action or penalty language | Mandatory human review — never deliver penalty-related interpretation without reviewer sign-off |

### Data Handling & Security

- All client SOP data stored in tenant-isolated database partitions — no cross-client data access
- PII handling: Client documents may contain employee names — strip or anonymize PII before LLM processing
- Regulatory source data: Public — no restriction, but source attribution required on all outputs
- Azure Canada Central hosting is mandatory — data residency for Canadian regulated industry clients
- No client data used for model training without explicit written consent
- API keys, database credentials, and client identifiers stored in environment variables — never in code
- All external API calls logged for audit and cost monitoring

### Confidence Thresholds

| Confidence Level | Threshold | System Action |
|---|---|---|
| High | ≥85% | Route to standard human review queue |
| Medium | 70–84% | Route with low-confidence flag and specific uncertainty explanation |
| Low | <70% | Block automated output — escalate to senior reviewer immediately |
| Critical (enforcement/penalty) | Any confidence | Mandatory senior review regardless of score |

**Confidence scoring must be:**
- Generated by the LLM reasoning layer on every output
- Based on: source text completeness, regulatory language clarity, precedent availability, and scope match to client's operations
- Logged in audit trail alongside the output

---

## 6. HUMAN HANDOFF & EXCEPTIONS

### Exception Handling

| Failure Mode | Response |
|---|---|
| Regulatory source scrape fails | Retry with exponential backoff (max 5 attempts); alert operations team if consecutive failures exceed 3 cycles |
| LLM returns malformed or empty output | Retry once with cleaned prompt; if failure persists, flag for manual processing — do not deliver partial output to client |
| Source regulatory page restructured (scrape schema breaks) | Alert operations immediately; pause monitoring for that source; manual check within 24 hours |
| Client SOP document fails to parse | Flag at onboarding; request client provide clean version; do not silently skip |
| Confidence score unavailable | Treat as Low confidence — escalate to human review |
| Human reviewer unavailable >24 hours | Alert operations lead; SLA clock tracked; do not auto-deliver without review |

### Human-in-the-Loop (HITL) — Mandatory Review Gates

The following steps **always** require human review before client-facing delivery. This is non-negotiable in phase 1 and early phase 2.

1. **All regulatory interpretations** — every AI-generated summary of what changed and what it means
2. **All SOP gap analyses** — every identification of which client SOPs are affected
3. **All SOP draft revisions** — every piece of AI-generated language proposed for client documents
4. **All enforcement / penalty-adjacent content** — any interpretation touching fines, stop-work orders, or regulatory enforcement
5. **All low-confidence outputs** — anything below 85% confidence threshold
6. **First output for any new regulatory source** — manual validation that scraping and interpretation is accurate before automation proceeds
7. **Any output for a client's first 90 days** — elevated review frequency during onboarding period

**Review SLA:** All outputs reviewed within 24 hours of AI generation. High-priority alerts (enforcement, imminent deadline) within 4 hours.

---

## 7. STAKEHOLDERS & TIMELINE

### Roles & Responsibilities

| Role | Responsibility |
|---|---|
| **Founder / Project Owner** | Product direction, sales, customer success, overall execution — does not delegate early sales |
| **AI/Automation Engineer** | Regulatory ingestion pipeline, LLM orchestration, SOP comparison logic, prompt engineering, system reliability — most critical technical hire; must be tight feedback loop, not offshore initially |
| **Compliance Reviewer / Safety Specialist** | Reviews all AI outputs before client delivery; quality gate and liability buffer; likely retired safety director or senior EHS consultant (contractor initially) |
| **Operations / Implementation** | Customer onboarding, SOP ingestion, workflow setup (Founder handles initially; dedicated hire at month 6–9) |
| **Account Manager / Customer Success** | Retention, expansion, renewal (hire at month 9–12 when 5+ customers active) |

### Key Milestones & Timeline

| Milestone | Target Date | Success Criteria |
|---|---|---|
| **MVP Build Complete** | Month 1–2 | Core scraping pipeline live: scrape → detect change → AI interpret → human review queue → email delivery |
| **First Paying Customer** | Month 2–3 | At least 1 customer paying ≥$1,500/month receiving regulatory alerts with reviewed AI output |
| **SOP Ingestion Capability** | Month 3–4 | Client SOP library ingestion working; gap analysis producing accurate section-level matches |
| **Customers 2–3 Signed** | Month 4–5 | Referral or direct outreach conversion; standard pricing (no steep discounts) |
| **SharePoint / Teams Integration** | Month 4–6 | Microsoft Graph API integration functional; regulatory alerts deliverable to Teams |
| **Audit Trail Verified** | Month 4 | Append-only audit log operational; first client audit documentation package produced |
| **Human Review Workflow Formalized** | Month 3 | SLA tracked, reviewer accountability defined, queue tooling functional |
| **10 Paying Customers** | Month 9–12 | $30,000–$60,000 MRR achieved; documented compliance time savings per customer |
| **$400K–$700K ARR** | Month 12 | Revenue target validating pricing and repeatable sales motion |
| **Prompt Versioning System** | Month 2 | Every prompt version-controlled, tested, and logged before production use |
| **Phase 2 Planning** | Month 10 | Self-serve portal scoped based on operational learnings from first 10 customers |

### What Could Kill This Company — Active Risks to Monitor

1. **No AI engineer in first 60 days** → You have a consulting firm with a roadmap, not a technology company
2. **Sales cycle longer than runway** → Mid-market sales at $3K–6K/month to first-time AI compliance buyers: 3–6 months per deal; know your runway number
3. **AI hallucination in a compliance context** → One publicly wrong interpretation that leads to a client fine, injury, or failed audit ends the company via trust failure — the compliance market is small and connected
4. **Regulatory source maintenance underestimated** → Maintaining reliable scraping across 50+ sources that restructure without notice is a real operational burden; budget engineering time explicitly
5. **Overbuilding before first revenue** → Platform features, enterprise integrations, dashboard obsession — all kill execution speed before product-market fit is proven

---

_This document is a living reference for Claude Code. Update when: customer feedback reveals scope gaps, architecture decisions change, or strategic priorities shift. Do not treat this as a static requirements document._
