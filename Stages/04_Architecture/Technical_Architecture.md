# Technical_Architecture.md
# Vaquero Safety Inc.
_Last Updated: May 2026 | Version 1.0_

---

## 1. ARCHITECTURE PHILOSOPHY

Three non-negotiable principles that govern every technical decision:

1. **Traceability over automation** — Every AI output must be traceable to a source document. No untraceable interpretation reaches a client. Ever.
2. **Modular over monolithic** — Build each layer independently. Regulatory sources change structure. LLM providers change pricing. Client integrations vary. Tightly coupled systems break when any one piece changes.
3. **Boring infrastructure, not cutting-edge** — Use proven tools. The product is regulatory intelligence, not the tech stack. Do not introduce infrastructure complexity that you can't maintain with a 2-person team.

---

## 2. BUILD vs. BUY vs. INTEGRATE

| Component | Decision | Rationale |
|---|---|---|
| LLM reasoning | **Buy** (Anthropic API + OpenAI fallback) | Commodity. Not your moat. |
| Regulatory ingestion pipeline | **Build** | This IS your moat. Proprietary data collection. |
| SOP gap analysis engine | **Build** | Core IP. |
| Change detection / diff engine | **Build** (simple) | Hash comparison + diff. Do not over-engineer. |
| Document management | **Integrate** (SharePoint / Google Drive) | Do not rebuild. |
| Training / LMS | **Integrate** (TalentLMS or client's existing system) | Do not compete with LMS vendors. |
| Workflow / approvals | **Build lightweight** then integrate (Teams) | Keep simple early. |
| Audit logging | **Build** | Non-negotiable. This is your compliance credential. |
| Email / notifications | **Buy** (Postmark) | Deliverability reliability. |
| Workflow orchestration | **Buy** (n8n self-hosted) | Avoids vendor lock-in. Sufficient for MVP. |

---

## 3. PHASE 1 ARCHITECTURE — MVP (Months 1–6)

### Data Flow

```
Regulatory Sources (Alberta OHS, AER, WCB, CSA, Federal)
        │
        ▼
[Ingestion Layer]
Firecrawl MCP (primary) → clean markdown output
Playwright (fallback for dynamic/JS-heavy pages)
        │
        ▼
[Change Detection Layer]
Hash comparison against previous scrape snapshot
Diff engine → extracts changed sections only
        │
        ▼
[AI Interpretation Layer]
Claude API (claude-sonnet-4 primary)
  → Regulatory change classification
  → Plain-language impact summary
  → Confidence score + source citation
  → Affected industry/operation tags
GPT-4o (fallback for high-volume / lower-stakes classification)
        │
        ▼
[Storage Layer]
Supabase (PostgreSQL) — structured data
pgvector — semantic embeddings for regulatory corpus
Append-only audit log table — immutable record
        │
        ▼
[Human Review Queue]
Internal review workflow (email-based initially)
Reviewer approves / rejects / modifies AI output
Review decision + rationale logged with timestamp + reviewer ID
        │
        ▼
[Client Delivery Layer]
Email (Postmark) — regulatory digest
Microsoft Teams webhook — alert notification
Monthly compliance summary PDF
```

### Phase 1 Tech Stack

| Layer | Tool | Notes |
|---|---|---|
| Scraping | Firecrawl MCP | Primary. Clean markdown output, handles JS rendering |
| Scraping (fallback) | Playwright | For complex/dynamic regulatory pages |
| Change detection | Custom (hash + diff) | Simple and reliable. Do not over-engineer |
| LLM (primary) | Anthropic Claude API (`claude-sonnet-4-20250514`) | Reasoning-heavy tasks |
| LLM (fallback) | OpenAI GPT-4o | Cost optimization, high-volume classification |
| Embeddings | OpenAI `text-embedding-3-large` | High-quality semantic search |
| Database | Supabase (PostgreSQL + pgvector) | Storage, semantic search, audit log |
| Workflow orchestration | n8n (self-hosted) | Automation routing, retry logic |
| Application layer | Next.js + Supabase | Fast to build, easy to maintain |
| Hosting | **Azure Canada Central** | Data residency — mandatory for regulated industry clients |
| Email | Postmark | Transactional email deliverability |
| Notifications | Microsoft Teams webhook | Client alert delivery |
| Document parsing | LlamaParse or Unstructured.io | PDF/Word SOP ingestion |
| Version control | GitHub | Code + prompt versioning |

---

## 4. PHASE 2 ADDITIONS (Months 7–12)

Add only after Phase 1 is stable and generating revenue.

```
[SOP Ingestion Layer — NEW]
Client SOP library upload (PDF, Word)
LlamaParse / Unstructured.io parsing
Chunking + embedding → pgvector storage
SOP metadata registry (document ID, version, last updated, owner)

[Gap Analysis Engine — NEW]
Claude API with regulatory change + client SOP context
Section-level matching → identifies specific SOP clauses affected
Draft revision language generation
Mandatory "AI DRAFT — REQUIRES REVIEW" flag on all outputs

[Approval Workflow — NEW]
Email-based approval routing (lightweight)
Approval status tracked in Supabase
Approved SOP version written back to SharePoint via Microsoft Graph API

[SharePoint / Teams Integration — NEW]
Microsoft Graph API
Pull client SOP documents on schedule
Push approved SOP updates back to client SharePoint
Trigger Teams notifications on approval required
```

---

## 5. WHAT TO DEFER (DO NOT BUILD YET)

These will be suggested by AI tools, developers, and advisors. Resist all of them until the listed conditions are met.

| Component | Defer Until |
|---|---|
| Dedicated vector database (Pinecone, Weaviate) | pgvector fails at actual scale (it won't in year one) |
| LangChain / LlamaIndex orchestration | You understand your retrieval patterns well enough to need it |
| Custom fine-tuned models | 12+ months of labeled interpretation data exists |
| Full API integration layer (SAP, Oracle, Workday) | Enterprise contract that explicitly requires it |
| Native mobile app | Post product-market fit, customer-driven request |
| SOC 2 certification | Enterprise prospects requiring it in procurement |
| Multi-region hosting | Canadian data residency is sufficient until US expansion |
| Real-time collaborative SOP editing | Post-Phase 2 with proven demand |
| Autonomous SOP publishing (no human approval) | **Never in regulated industries. This is a permanent constraint.** |

---

## 6. DATA ARCHITECTURE

### Database Schema — Core Tables (Supabase)

```sql
-- Tenant isolation: every table includes tenant_id
-- All timestamps in UTC

regulatory_sources          -- monitored regulatory bodies and URLs
regulatory_snapshots        -- raw scrape content + hash per source per cycle
regulatory_changes          -- detected diffs between snapshots
regulatory_interpretations  -- AI-generated analysis of each change
  └── confidence_score      -- float 0.0–1.0
  └── source_citations      -- JSONB array of cited source sections
  └── reviewer_id           -- NULL until reviewed
  └── review_status         -- pending | approved | rejected | modified
  └── review_notes          -- reviewer rationale

client_profiles             -- client account + regulatory scope definition
client_sop_library          -- ingested SOP document registry
  └── document_id
  └── version_number        -- increments on every change
  └── content_hash          -- immutable reference to content snapshot
  └── embedding_id          -- pgvector reference
sop_gap_analyses            -- AI-generated gap analysis per regulatory change
sop_draft_revisions         -- AI-generated revision language (always flagged as draft)

audit_log                   -- APPEND ONLY. Never update, never delete.
  └── event_type
  └── actor_id              -- system or human reviewer ID
  └── entity_type           -- what was acted on
  └── entity_id
  └── payload               -- JSONB full snapshot of state at time of event
  └── created_at            -- immutable timestamp

client_deliveries           -- record of every alert/report sent to clients
```

### Tenant Isolation Rules
- Every table with client data includes `tenant_id` column
- Row-Level Security (RLS) enforced in Supabase on all client tables
- No cross-tenant queries permitted in application layer
- Separate pgvector namespaces per client for SOP embeddings
- Production database: zero direct access from MCP or development tools

---

## 7. AI OUTPUT SCHEMA — MANDATORY STRUCTURE

Every AI output must conform to this schema before entering the human review queue. Outputs that do not include all fields are rejected at the application layer.

```json
{
  "output_id": "uuid",
  "output_type": "regulatory_interpretation | gap_analysis | sop_draft",
  "source_document": {
    "regulatory_body": "string",
    "document_title": "string",
    "document_url": "string",
    "section_reference": "string",
    "snapshot_id": "uuid"
  },
  "content": {
    "summary": "string",
    "detail": "string",
    "draft_revision_language": "string | null"
  },
  "classification": {
    "impact_level": "HIGH | MEDIUM | LOW",
    "change_type": "new_requirement | amendment | clarification | enforcement | deadline",
    "affected_industries": ["oil_gas | construction | municipalities | ..."]
  },
  "confidence": {
    "score": 0.0,
    "rationale": "string",
    "review_flag": "standard | elevated | mandatory"
  },
  "citations": [
    {
      "source": "string",
      "section": "string",
      "verbatim_excerpt": "string"
    }
  ],
  "ai_draft_flag": true,
  "generated_at": "ISO8601 timestamp",
  "model_used": "string",
  "prompt_version": "string"
}
```

**Enforcement:** Application layer validates schema completeness before routing to review queue. Missing `confidence.score`, missing `citations`, or missing `prompt_version` triggers automatic rejection and ops alert.

---

## 8. PROMPT VERSIONING — NON-NEGOTIABLE

Prompts are code. Treat them as code.

### Rules
- Every prompt stored in `/prompts` directory in Git repository
- Prompt files named with semantic versioning: `regulatory_interpretation_v1.2.0.txt`
- No prompt deployed to production without a pull request and review
- Every AI output in the database logs the `prompt_version` used to generate it
- Prompt changes that affect confidence scoring or citation behavior require regression testing against a labeled test set before deployment
- Rollback path: any prompt version can be re-deployed in under 5 minutes

### Prompt Registry Table (Supabase)
```sql
prompts
  └── prompt_id
  └── prompt_type        -- interpretation | gap_analysis | classification | draft_revision
  └── version            -- semver string
  └── content            -- full prompt text
  └── deployed_at
  └── deprecated_at      -- NULL if active
  └── test_results       -- JSONB (accuracy metrics from regression test)
```

---

## 9. CONFIDENCE SCORING IMPLEMENTATION

Confidence scoring is not optional. It is the trust architecture.

### Scoring Factors (Claude evaluates each)
1. **Source text completeness** — was the full regulatory section available, or only a partial excerpt?
2. **Regulatory language clarity** — is the requirement explicit or interpretive?
3. **Precedent availability** — are there prior interpretations of this type of change in the corpus?
4. **Scope match** — how directly does this change apply to the client's defined operational scope?
5. **Conflicting signals** — does this change conflict with any other current requirement?

### Routing by Score
| Score | Label | Action |
|---|---|---|
| ≥0.85 | HIGH | Route to standard review queue (24hr SLA) |
| 0.70–0.84 | MEDIUM | Route with low-confidence flag and uncertainty explanation |
| <0.70 | LOW | Block output — escalate to senior reviewer immediately |
| Any score | CRITICAL | If output touches enforcement, fines, or stop-work — mandatory senior review |

---

## 10. AUDIT LOG — ARCHITECTURE RULES

The audit log is your compliance credential and legal defense. These rules are permanent.

- **Append-only:** No UPDATE or DELETE operations permitted on `audit_log` table
- **Immutable timestamps:** Set by database server, not application layer
- **Full state snapshots:** Each log entry stores the complete state of the entity at time of event — not just the delta
- **Actor identity:** Every entry requires either a human `reviewer_id` or a system identifier — no anonymous entries
- **Coverage:** The following events must always be logged:
  - Regulatory change detected
  - AI interpretation generated (including prompt version and model)
  - Human review decision (approve / reject / modify) with rationale
  - Client delivery (what was sent, to whom, at what time)
  - SOP version change
  - Client approval of SOP update
  - Any system error that caused a processing delay >4 hours

---

## 11. INFRASTRUCTURE & SECURITY

### Hosting
- **Primary:** Azure Canada Central (mandatory — data residency for Canadian regulated clients)
- **No multi-region until US expansion is scoped**

### Security Rules
- All API keys and credentials in environment variables — never in code or version control
- PII detected in client SOP documents stripped or anonymized before LLM processing
- Row-Level Security (RLS) enabled on all Supabase client tables from day one
- Supabase MCP scoped to dev/staging project reference only — **never connect production database via MCP**
- All external API calls logged (provider, latency, cost) for audit and budget monitoring
- No client data used for model training without explicit written consent in contract

### Backup & Recovery
- Supabase automated daily backups enabled from day one
- Audit log table backed up to separate Azure Blob Storage (append-only mirror)
- Recovery Time Objective (RTO): <4 hours for full service restoration
- Recovery Point Objective (RPO): <24 hours (daily backup cycle)

---

## 12. TECHNICAL DEBT — RISKS TO AVOID

These are the patterns most likely to create expensive problems at scale. Flag them in code review.

| Risk | Prevention |
|---|---|
| Monolithic architecture | Build each pipeline layer as an independent module from day one |
| Prompt engineering without versioning | See Section 8. Every prompt is versioned before it touches production |
| No evaluation framework for AI outputs | Maintain a labeled test set of 50+ regulatory changes with expected outputs. Run regression on every prompt change. |
| Shared infrastructure across clients | RLS enforced from day one. Never reuse embeddings or context across tenants. |
| Hardcoded regulatory source URLs | All source URLs in database, not code. Updating a source should not require a deployment. |
| LangChain in production | Use direct API calls with custom orchestration. LangChain is fine for prototyping, fragile in production. |
| Single LLM provider dependency | Claude (primary) + GPT-4o (fallback) from day one. Provider outages happen. |
| Silent scrape failures | Every scrape job must report success/failure to ops monitoring. No silent failures allowed. |

---

_This document governs all technical decisions made by Claude Code for this project. When a proposed implementation conflicts with these principles, flag the conflict and resolve before proceeding. Update this document when architecture decisions evolve based on real operational learnings._
