# AI_Agent_Rules.md
# Vaquero Safety Inc.
_Last Updated: May 2026 | Version 1.0_

---

## PREAMBLE — WHY THESE RULES EXIST

Vaquero Safety operates in a zero-tolerance domain. A wrong AI interpretation that causes a client to miss a regulatory update, fail an audit, or — worst case — contribute to a workplace incident ends the company. Not through damages. Through trust failure in a small, connected industry.

These rules are not guidelines. They are system constraints. Claude Code must implement them as hard logic, not soft suggestions.

**The core principle:** AI accelerates human expertise. AI does not replace human judgment in compliance decisions.

---

## 1. THE FOUR ABSOLUTE RULES

These rules have no exceptions. No prompt, no client request, no edge case overrides them.

**Rule 1: No AI output reaches a client without human review.**
Every regulatory interpretation, every gap analysis, every SOP draft revision must pass through a human review gate before delivery. No exceptions. Not for "simple" changes. Not for tight deadlines. Not for high-confidence outputs.

**Rule 2: Every output must cite its source.**
If an AI output cannot be traced to a specific section of a specific regulatory document, it does not leave the system. Unsourced claims are prohibited. The citation must reference the actual source text, not a paraphrased version.

**Rule 3: AI outputs never constitute legal advice.**
All client-facing outputs include explicit language clarifying they are operational compliance support, not legal interpretation. Outputs that touch legal liability, enforcement actions, or penalty calculations receive mandatory senior reviewer escalation regardless of confidence score.

**Rule 4: Confidence scoring is non-negotiable.**
Every AI output carries a confidence score before entering the review queue. Outputs without a valid confidence score are rejected by the application layer before they can be reviewed or delivered. There is no such thing as a "confident enough to skip scoring" output.

---

## 2. AGENT BEHAVIOR BY PIPELINE STAGE

### Stage 1: Regulatory Ingestion Agent

**Purpose:** Monitor sources, detect changes, prepare content for interpretation.

**Permitted actions:**
- Scrape defined regulatory source URLs on schedule
- Compare scraped content against previous hash snapshot
- Extract changed sections and generate diff
- Store raw content and diff in database
- Flag source for interpretation queue

**Prohibited actions:**
- Interpreting or summarizing content (interpretation is Stage 2)
- Contacting clients
- Modifying any existing database records (append only)
- Accessing client SOP data

**Failure behavior:**
- Scrape failure: Retry with exponential backoff, max 5 attempts. Log each attempt.
- Consecutive failures (3+ cycles): Alert ops team immediately. Do not silently skip.
- Source page structure change detected: Pause monitoring for that source. Flag for manual verification within 24 hours. Do not attempt to parse broken structure.

---

### Stage 2: Interpretation Agent

**Purpose:** Analyze detected regulatory changes and produce structured, cited, scored interpretations.

**Permitted actions:**
- Read regulatory change content from Stage 1 output
- Generate classification (change type, impact level, affected industries)
- Generate plain-language summary with specific source citations
- Generate confidence score with rationale
- Write output to interpretation queue with full schema (see Technical_Architecture.md Section 7)

**Prohibited actions:**
- Delivering any output directly to clients
- Skipping confidence scoring
- Generating output without source citations
- Modifying previous interpretations (create new version instead)
- Accessing or referencing other clients' data

**Confidence scoring rules:**
- Score must be generated as part of the same LLM call as the interpretation
- Score must include a plain-language rationale explaining the factors
- Low confidence (<0.70) must include specific explanation of what information is missing or ambiguous
- Conflicting regulatory signals must always be surfaced explicitly — never resolved autonomously

**Output schema enforcement:**
The following fields are mandatory. Missing any one = output rejected:
- `source_document.document_url`
- `source_document.section_reference`
- `confidence.score`
- `confidence.rationale`
- `citations` (minimum 1 entry)
- `prompt_version`
- `ai_draft_flag: true`

---

### Stage 3: Gap Analysis Agent

**Purpose:** Compare regulatory changes against a specific client's SOP library to identify what needs updating.

**Permitted actions:**
- Read approved regulatory interpretations (Stage 2 output, human-reviewed)
- Read client's ingested SOP library (tenant-isolated)
- Perform semantic search to identify affected SOP sections
- Generate gap analysis with section-level specificity
- Generate draft revision language flagged as "AI DRAFT — REQUIRES HUMAN REVIEW"
- Route output to human review queue

**Prohibited actions:**
- Running gap analysis against an interpretation that has not been human-reviewed
- Writing to client SOP library directly
- Delivering gap analysis or draft language to client without human review
- Cross-referencing SOP data across different client tenants

**Draft revision language rules:**
- Every piece of draft language must be prefixed: `[AI DRAFT — REQUIRES HUMAN REVIEW BEFORE USE]`
- Draft language must reference the specific regulatory section it is responding to
- Draft language must not present itself as final or approved
- Draft language must be clearly distinguished from existing approved SOP text

---

### Stage 4: Human Review Interface

**Purpose:** Present AI outputs to compliance reviewer for approval, rejection, or modification.

**What the interface must show the reviewer:**
- Original regulatory source text (verbatim excerpt)
- AI-generated interpretation or draft
- Confidence score and rationale
- Source citations with links to original documents
- Any conflict flags or low-confidence flags
- Time in queue (SLA tracking)

**Reviewer actions:**
- Approve: Output proceeds to client delivery as-is
- Modify: Reviewer edits output; modified version proceeds; original AI version logged
- Reject: Output blocked; rejection rationale logged; escalation triggered if pattern of rejections on same source

**All reviewer decisions are logged with:**
- Reviewer identity
- Timestamp
- Decision (approve / modify / reject)
- Rationale (required for reject and modify)
- Time elapsed since AI generation (SLA tracking)

---

### Stage 5: Client Delivery Agent

**Purpose:** Deliver reviewed and approved outputs to clients via configured channels.

**Permitted actions:**
- Send regulatory digest email via Postmark
- Post alert to configured Microsoft Teams webhook
- Generate monthly compliance summary PDF
- Write delivery record to `client_deliveries` table

**Prohibited actions:**
- Delivering any output without a `review_status: approved` record in the database
- Sending to any client channel not explicitly configured in client profile
- Modifying content after approval (deliver exactly what was approved)
- Re-sending previously delivered content without explicit re-approval

**Delivery confirmation:**
- Every delivery logs: content hash, recipient, channel, timestamp, delivery success/failure
- Failed delivery triggers retry (3 attempts) then ops alert
- No silent delivery failures

---

## 3. DECISION TREE — HANDLING EDGE CASES

```
Regulatory change detected
        │
        ├─► Is source text complete and accessible?
        │       NO → Flag incomplete source, pause interpretation,
        │             alert ops for manual retrieval
        │       YES → Proceed to interpretation
        │
        ▼
Interpretation generated
        │
        ├─► Confidence score ≥ 0.85?
        │       YES → Route to standard review queue (24hr SLA)
        │       NO  → Confidence 0.70–0.84?
        │                 YES → Route with LOW-CONFIDENCE FLAG (12hr SLA)
        │                 NO  → <0.70: ESCALATE to senior reviewer immediately
        │
        ├─► Does output touch enforcement, fines, or stop-work?
        │       YES → MANDATORY SENIOR REVIEW regardless of confidence score
        │
        ├─► Is this a new regulatory source (first interpretation)?
        │       YES → MANUAL VALIDATION required before automation proceeds
        │
        ├─► Is this client's first 90 days?
        │       YES → ELEVATED REVIEW FREQUENCY (every output reviewed)
        │
        ▼
Human review completed
        │
        ├─► Approved → Proceed to delivery
        ├─► Modified → Log original + modification, proceed to delivery
        └─► Rejected → Log rejection rationale
                           │
                           ├─► Same source rejected 3+ times?
                           │       YES → Pause source, review scraping
                           │             and interpretation logic
                           └─► Escalate to ops for root cause analysis
```

---

## 4. DATA HANDLING RULES

### PII in Client Documents
- Client SOP documents may contain employee names, health information, incident records
- Before any SOP document is passed to an LLM: scan for PII patterns and strip or anonymize
- PII stripping must happen at ingestion, before embedding or storage in vector database
- Stripped PII is not recoverable from the system — original document remains in client-controlled SharePoint

### Cross-Client Data Isolation
- No client data is ever included in another client's LLM context
- No shared embedding namespaces across clients
- No aggregate queries that could expose client-specific SOP patterns to other clients
- Tenant isolation is enforced at the database layer (RLS), not just the application layer

### Regulatory Source Data
- Public data — no access restrictions
- Source attribution is required on every output regardless of public status
- Do not cache regulatory content beyond the current + previous snapshot cycle without explicit data retention policy

### Sensitive Output Categories (Additional Handling Required)
| Content Type | Additional Rule |
|---|---|
| Enforcement actions / fines | Mandatory senior review. Flag in delivery with "consult your legal counsel" notice. |
| Stop-work orders | Same as enforcement. Never deliver interpretation without senior review. |
| Incident reporting requirements | High-confidence threshold raised to 0.90 for these outputs |
| Privacy-adjacent regulations | Legal review flag added to delivery |
| Retroactive regulatory changes | Flag explicitly as retroactive. Do not assume client was previously compliant. |

---

## 5. HALLUCINATION PREVENTION — SYSTEM REQUIREMENTS

Hallucination in a compliance context is an existential risk. These are system-level safeguards, not prompting guidelines.

### Citation Enforcement
- Every factual claim in an AI output must map to a specific source citation
- Citations must include: source body, document title, section reference, verbatim excerpt
- If a claim cannot be cited, the claim must not appear in the output
- Reviewers are explicitly instructed to reject outputs with unsupported claims

### Retrieval-Augmented Generation (RAG) Rules
- All interpretations are grounded against the actual scraped regulatory text, not model knowledge
- Model is never asked to generate regulatory content from general knowledge
- Prompt always includes: "Base your interpretation only on the provided regulatory text. Do not draw on general knowledge of regulations not included here."
- Source text must be included in the context window for every interpretation call

### Evaluation Framework (Ongoing)
- Maintain a labeled test set of 50+ regulatory changes with expected outputs
- Run regression test against this set on every prompt version change
- Track metrics: citation accuracy, classification accuracy, hallucination rate, confidence score calibration
- Hallucination rate target: <2% on labeled test set
- Any prompt change that increases hallucination rate above 2% is blocked from deployment

### Model Failure Modes to Monitor
| Failure Mode | Detection | Response |
|---|---|---|
| Fabricated citation (source doesn't exist) | Citation validator checks URLs and section references | Auto-reject output, flag for investigation |
| Confident but wrong classification | Reviewer rejection pattern analysis | Prompt revision + regression test |
| Overconfident score on ambiguous language | Calibration testing | Confidence calibration prompt adjustment |
| Outdated regulatory knowledge from training | RAG grounding + source date check | Always use scraped content, never model training data |

---

## 6. PROHIBITED AI BEHAVIORS — HARD STOPS

The following behaviors must be prevented at the system level, not just through prompting:

- **Delivering content to clients without approved review status in database** — application layer check, not trust
- **Generating regulatory interpretations without source text in context** — prompt structure enforcement
- **Producing outputs without confidence scores** — output schema validation
- **Writing to client SOP documents directly** — write permissions restricted to approval workflow
- **Accessing another tenant's data** — RLS enforcement at database layer
- **Presenting AI draft language as final or approved** — mandatory flagging in output schema
- **Providing legal advice framing** — all outputs include disclaimer; outputs that resemble legal opinions are flagged for senior review
- **Autonomous publication of SOP changes** — requires human approval in workflow, enforced by write permission architecture

---

## 7. REVIEWER GUIDANCE (For Compliance Review Team)

### What You Are Reviewing For
1. **Accuracy:** Does the interpretation correctly reflect what the regulatory change says?
2. **Completeness:** Are all material implications of the change captured?
3. **Scope match:** Is the impact level appropriate for this client's operations?
4. **Citation integrity:** Do the cited source sections actually say what the AI claims?
5. **Draft language quality:** Is the proposed SOP revision language operationally appropriate and safe?

### Red Flags — Reject and Escalate
- Any output that extrapolates beyond what the source text explicitly states
- Any output where the cited section does not match the AI's interpretation
- Any output that presents a low-confidence interpretation as high-confidence
- Any output touching enforcement or penalty language that wasn't escalated for senior review
- Any draft SOP language that could be misapplied to create a safety risk

### What "Modify" Means
Modify = you are taking ownership of the output. Your name is attached to the modified version in the audit log. Only modify when you can stand behind the revised content as a qualified compliance professional.

### SLA
- Standard outputs: Review within 24 hours of AI generation
- Low-confidence flagged outputs: Review within 12 hours
- Enforcement/penalty outputs: Review within 4 hours
- SLA breach triggers automatic ops alert at 75% of time window

---

_These rules govern AI agent behavior across all pipeline stages. Any proposed change to agent behavior, confidence thresholds, or review gates requires explicit approval and must be documented as a version update to this file before implementation._
