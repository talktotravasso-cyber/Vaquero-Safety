# Architecture Decisions — Vaquero Safety Inc.

**Location:** `C:\Projects\Vaquero_Safety_Inc\compliance\ARCHITECTURE-DECISIONS.md`  
**Status:** Append-only. Never delete or modify existing entries.  
**Format:** `[DATE] | DECISION | COMPLIANCE JUSTIFICATION | ROLLBACK PLAN`  
**Compliance:** PIPEDA / PIPA (Alberta) | Canada Central data residency  
**Version:** v1.0.0

---

> **APPEND-ONLY LOG — IMMUTABLE ONCE WRITTEN**  
> All entries are permanent compliance records. Corrections are added as new entries referencing
> the original entry ID, never by editing prior entries.  
> Entry format enforced by `.github/workflows/compliance-check.yml`.

---

## Entry Format Reference

```
[YYYY-MM-DD] | ADR-NNN | DECISION TITLE
  Decision:   One-sentence statement of what was decided.
  Rationale:  Why this decision was made; alternatives considered.
  Compliance Justification:  Applicable regulation(s), section(s), or audit standard(s).
  Rollback Plan:  Concrete steps to reverse if the decision fails.
  Linked File(s):  Relevant scaffold paths.
  Status:  Active | Superseded by ADR-NNN
```

---

## Decision Log

---

### [2026-05-23] | ADR-001 | Push-Only Delivery Model (No Client Portal Login Required)

**Decision:** All client-facing notifications, approvals, and document deliveries are push-delivered via email, SMS, Teams, and mobile app. Clients never log into a portal to retrieve compliance actions.

**Rationale:** Competitor analysis (ISNetworld, Avetta, Veriforce/ComplyWorks, Cognibox) confirmed all operate pull-portal models. Push-only eliminates the single largest enterprise adoption failure point — client login fatigue and portal abandonment. Approval action buttons embedded in email create a zero-friction response path. The push model is the primary competitive differentiator and cannot be compromised without destroying category positioning.

**Compliance Justification:** PIPEDA s.10 — reasonable notification obligation requires that communication method be appropriate to the circumstance. Push delivery with delivery confirmation satisfies reasonable notification. Email is the legally mandatory minimum channel regardless of contact preference (Stage 1 onboarding finding). All delivery events logged to Compliance Event Log (CEL) with server-side acknowledgement, satisfying evidentiary requirements under PIPA Alberta s.34 accountability provisions.

**Rollback Plan:** If push model is abandoned: (1) Deploy SharePoint-based client portal using existing site-per-client architecture. (2) Redirect approval webhooks to portal action endpoints rather than email tracked links. (3) Retain CEL architecture unchanged — portal actions still write to CEL. (4) No data migration required; SharePoint structure is portal-compatible. Estimated rollback effort: 3–4 weeks of Make.com scenario reconfiguration.

**Linked File(s):**
- `stages/02_specification/Specs.md`
- `stages/05_workflows/AGENTS.md`
- `GTM-Strategy/Strategy.md`

**Status:** Active

---

### [2026-05-23] | ADR-002 | Site-Per-Client SharePoint Architecture

**Decision:** Each client receives a dedicated SharePoint site collection (`vaquero.sharepoint.com/sites/[client_id]`) with no shared document libraries across client sites. No cross-client permission inheritance is permitted at any layer.

**Rationale:** Shared document library architecture was evaluated and rejected. Shared libraries create cross-client data contamination risk through misconfigured permissions, broken inheritance, and Make.com scenario errors that could write to wrong client destinations. Site-per-client guarantees hard isolation at the SharePoint tenant level — a wrong `client_id` in a Make.com scenario writes to the wrong client's isolated site rather than exposing data across clients. At 50+ clients, the operational risk of a shared architecture is unacceptable.

**Compliance Justification:** PIPA Alberta s.7 — collection and storage of personal information must be limited to identified purpose. Site isolation enforces purpose limitation by construction. PIPEDA — Canada Central data residency confirmed at site provisioning and logged in CEL per Microsoft Purview geo-anchor enforcement. ACSA COR Element 8 — each client's audit evidence chain must be independently verifiable without contamination from other client records.

**Rollback Plan:** Architectural rollback is high-cost. If site-per-client is abandoned for a shared library model: (1) Export all client data from individual sites. (2) Rebuild shared library with strict metadata-based partitioning (client_id as mandatory partition key on every item). (3) Implement Row-Level Security equivalent via SharePoint audience targeting + strict permission groups. (4) Revalidate all Make.com scenarios for correct site URL parameterization. (5) Compliance advisor must certify no cross-client data exposure before go-live. Estimated rollback effort: 8–12 weeks. Not recommended.

**Linked File(s):**
- `compliance/COMPLIANCE.md`
- `stages/04_architecture/System-Diagram.md`
- `stages/05_workflows/AGENTS.md`

**Status:** Active

---

### [2026-05-23] | ADR-003 | Compliance Event Log (CEL) as System of Record — Not Make.com Execution History

**Decision:** The SharePoint Compliance Event Log (CEL) per client site is the sole legal audit trail for all compliance events. Make.com execution history is classified as supplementary operational log only and MUST NOT be cited as compliance evidence.

**Rationale:** Make.com Enterprise plan retains execution logs for a maximum of 60 days. COR audit cycles run over 3 years. PIPA and PIPEDA data retention requirements extend to multiple years depending on document type. Reliance on Make.com execution history for compliance evidence would create a systematic audit failure at every COR external audit. CEL is written to SharePoint with Microsoft Purview retention labels enforced — records cannot be deleted before `retention_end_date`. CEL entries are written at the moment each compliance event occurs, not post-hoc.

**Compliance Justification:** ACSA COR Element 8 — program administration requires demonstrable version-controlled, dated, and authorized documentation. A 60-day log does not satisfy a 3-year audit cycle. OHS Act s.33 — incident records retained minimum 2 years. PIPEDA — personal information records must be retained as long as reasonably necessary for identified purpose. Purview retention label enforcement is the technical control that satisfies these obligations.

**Rollback Plan:** If SharePoint CEL becomes unavailable: (1) Export all CEL list data to structured JSON/CSV via Microsoft Graph API before any outage or migration. (2) Retain exported records in `compliance/archive/` with original timestamps preserved. (3) Make.com execution logs serve as corroborating evidence only during transition. (4) Restore CEL to new SharePoint tenant with retention labels re-applied before accepting new compliance events.

**Linked File(s):**
- `compliance/COMPLIANCE.md`
- `compliance/DATA_LIFECYCLE.md`
- `stages/05_workflows/AGENTS.md`

**Status:** Active

---

### [2026-05-23] | ADR-004 | Role-Based Signatory Model (Not Individual-Based)

**Decision:** DocuSign signing authority is stored and managed by role (e.g., "Safety Manager," "Executive") not by individual name. Make.com looks up the current holder of each role from the SharePoint Signatories List at envelope creation time.

**Rationale:** Individual-name signing chains break on every personnel change. In the Alberta oil and gas sector, Safety Manager turnover is frequent. An individual-based model would produce a systematic pattern of envelope routing to departed employees, creating compliance gaps, voided envelopes, and unsigned documents that generate COR audit risk. Role-based lookup at envelope creation time means signatory changes update one record (Signatories List) and all future envelopes are automatically correct without scenario modification.

**Compliance Justification:** ACSA COR Element 1 — management commitment requires signed policy statement by an authorized officer. The MSA defines signing authority by role, not by name. Alberta Electronic Transactions Act SA 2001 c E-5.5 — electronic signatures carry equivalent legal standing to wet signatures when executed by an individual with signing authority at time of signing. Role-based model preserves this authorization chain. DocuSign Certificate of Completion records the individual who held the role at signing — the audit trail captures both role and individual identity.

**Rollback Plan:** If role-based model is abandoned for individual-based: (1) Rebuild Signatories List schema to individual-only fields. (2) Update all Make.com scenarios to read individual fields directly. (3) Implement a personnel-change notification workflow to manually update individual names. (4) No data migration required on SharePoint. Operational risk increases significantly — not recommended. Rollback effort: 2–3 weeks.

**Linked File(s):**
- `stages/05_workflows/AGENTS.md`
- `compliance/COMPLIANCE.md`
- `stages/02_specification/Specs.md`

**Status:** Active

---

### [2026-05-23] | ADR-005 | Email as Mandatory Minimum Approval Channel

**Decision:** Email is the mandatory minimum delivery channel for all approval workflows regardless of contact notification preference. SMS, Teams, and mobile app push notifications may supplement but cannot substitute for email on any action requiring an Approve or Amend response.

**Rationale:** Phase 1 finding: clients with SMS-only or Teams-only preferences generated approval chain gaps when those channels failed delivery silently (no bounce notification, no read receipt, no response). Email provides server-side delivery acknowledgement (bounce detection), tracked hyperlink click events, and a legally recognized notification medium. Approval audit trails that rely on SMS-only delivery cannot be reconstructed reliably if Twilio logs are unavailable. The email channel is the compliance-grade evidentiary backbone; other channels are operational convenience layers.

**Compliance Justification:** PIPEDA — reasonable notification requires a communication method appropriate to the circumstance; email satisfies this standard. PIPA Alberta s.34 accountability — compliance advisor must demonstrate notification was delivered; email delivery confirmation and bounce detection provide this evidence. ACSA COR Element 8 — approval chains must be documentable; email tracked links provide click-event records tied to specific notification_id, contact_id, and timestamp.

**Rollback Plan:** No rollback anticipated — this is a floor constraint, not a feature choice. If email delivery becomes systematically unreliable: (1) Add DocuSign as a mandatory alternate delivery channel (envelope + in-app notification). (2) Treat DocuSign delivery confirmation as equivalent to email delivery confirmation for CEL purposes. (3) Reconfigure Make.com to use DocuSign delivery path as primary. Estimated effort: 3–4 weeks.

**Linked File(s):**
- `stages/04_architecture/System-Diagram.md`
- `stages/05_workflows/AGENTS.md`
- `compliance/COMPLIANCE.md`

**Status:** Active

---

### [2026-05-23] | ADR-006 | Approve / Amend Only — No Reject Action

**Decision:** Client-facing approval workflows present only two action options: Approve and Amend. Reject is not a permitted action in the platform.

**Rationale:** A "Reject" action without a mandatory remediation path creates unresolvable compliance state. If a client rejects a regulatory-required SOP update, the underlying compliance obligation does not disappear — it creates a documented gap that exposes the client to COR audit risk and Vaquero to liability for facilitating non-compliance. Amend routes the client through an advisor-mediated revision cycle that always terminates in an Approve action. This guarantees that all open compliance items resolve to a documented outcome (approval, formal non-response notice, or amended approval) with no orphaned rejections in the system.

**Compliance Justification:** OHS Act (Alberta) — employer cannot contract out of statutory safety obligations. A Reject action that halts a required SOP update without resolution would create a documented gap in the client's safety program with Vaquero's name on the notification chain. Amend-only model ensures advisor review of every objection, which protects both client and Vaquero from undocumented compliance gaps. ACSA COR Element 8 — all program administration actions must have traceable resolution.

**Rollback Plan:** If a Reject action is required for specific document types (e.g., client disputes regulatory applicability): (1) Add a "Dispute" variant of the Amend path that routes to a senior compliance advisor + legal flag queue. (2) Dispute path never terminates the compliance obligation — it creates a documented advisory record and suspends the alert cycle pending resolution. (3) No system architecture change required — add new webhook action value `action="dispute"` and a new routing branch in Stage 4 Make.com scenario. Estimated effort: 1 week.

**Linked File(s):**
- `stages/05_workflows/AGENTS.md`
- `stages/02_specification/Specs.md`

**Status:** Active

---

### [2026-05-23] | ADR-007 | Human-in-the-Loop Gate for Regulatory Change Classification

**Decision:** No client-facing action (SOP update, certification alert change, informational notice) may fire as a result of a detected regulatory change until a named compliance advisor has reviewed and classified the change. AI assistance may flag anomalies but classification requires human sign-off.

**Rationale:** A misclassified regulatory change at the advisor level propagates incorrectly to all 50+ clients simultaneously. An automated classification error that triggers a spurious SOP update across 50 clients creates mass operational disruption, potential legal liability, and immediate credibility loss. The asymmetry is extreme: one incorrect automated classification = 50 incorrect client notifications. Human classification gate with a 48-hour SLA is operationally acceptable; the compliance risk of removing the gate is not.

**Compliance Justification:** OHS Act (Alberta) — employer duty of care for accurate safety documentation. Vaquero's advisory relationship (not employer relationship) per MSA requires that recommended actions be professionally reviewed before delivery. ACSA COR audit tool — regulatory change management requires documented review process with named accountability. PIPA Alberta s.34 — designated data steward (compliance advisor) must authorize actions affecting client personal information records.

**Rollback Plan:** This is a process constraint, not a system architecture constraint. If advisor capacity becomes the bottleneck: (1) Add AI pre-classification with confidence scoring — high-confidence (≥0.95) classifications with a 24-hour advisor review window rather than active sign-off. (2) Low-confidence (<0.95) classifications always require active sign-off. (3) Implement a second-advisor review requirement for Classification A (SOP update) events affecting >10 clients. (4) No Make.com scenario changes required — add confidence score field to Regulatory Change Candidate record and a conditional routing branch.

**Linked File(s):**
- `stages/05_workflows/AGENTS.md`
- `docs/llm-guardrails/SYSTEM_PROMPT_GUARDRAILS.md`
- `compliance/COMPLIANCE.md`

**Status:** Active

---

### [2026-05-23] | ADR-008 | DocuSign Certificate of Completion as Primary Compliance Evidence

**Decision:** The DocuSign Certificate of Completion plus signed PDF, auto-archived to the client's SharePoint site on `envelope-completed` webhook event, is the primary compliance evidence for safety program documents, SOPs, policy statements, training acknowledgements, orientation sign-offs, and most recurring compliance documents.

**Rationale:** DocuSign Certificate of Completion contains: envelope ID (permanent in DocuSign repository), per-recipient delivered/viewed/signed timestamps, IP address and geolocation, SHA-256 document integrity hash, authentication method, signing sequence confirmation, and Electronic Record and Signature Disclosure consent. This is a stronger evidentiary record than most wet-signature processes used in the industry. COR auditors have accepted DocuSign certificates as audit evidence. Alberta Electronic Transactions Act SA 2001 c E-5.5 grants electronic signatures equivalent legal standing.

**Compliance Justification:** Alberta Electronic Transactions Act SA 2001 c E-5.5 — electronic records and signatures have equivalent standing to paper. ACSA COR Elements 1 and 8 — management commitment and program administration require signed, dated, versioned documents with authorization chain. DocuSign Certificate satisfies all three requirements. DocuSign retains transaction data permanently even after subscription ends — no retention risk on the DocuSign side. Note: confined space entry permits (OHS Code Part 5 s.45) and specific OHS Code "written" form requirements are flagged for legal review before DocuSign is confirmed as sole acceptable format — see ADR-009.

**Rollback Plan:** If DocuSign is deprecated or becomes legally insufficient for specific document types: (1) Migrate to Adobe Sign or equivalent with equivalent Certificate of Completion capability. (2) SharePoint auto-archive webhook path is platform-agnostic — update Make.com module from DocuSign to replacement platform. (3) Existing signed PDFs and Certificates in SharePoint are unaffected — they are stored documents, not live DocuSign records. (4) New envelopes route through replacement platform. Estimated effort: 3–5 weeks per e-signature platform migration.

**Linked File(s):**
- `stages/05_workflows/AGENTS.md`
- `compliance/COMPLIANCE.md`
- `stages/13-DocuSign-Completed/` (client SharePoint path)

**Status:** Active

---

### [2026-05-23] | ADR-009 | Legal Review Flag — Confined Space Entry Permits and Wet Signature Risk

**Decision:** DocuSign is used as the default execution method for confined space entry permits pending legal confirmation. A [FLAG FOR LEGAL REVIEW] status is recorded in the platform for this document type until Alberta OHS confirms electronic entry permits are acceptable under OHS Code Part 5 s.45.

**Rationale:** OHS Code Part 5 s.45 requires a "written" entry permit. Alberta's Electronic Transactions Act SA 2001 c E-5.5 grants electronic records equivalent standing to paper, but the interaction between a general electronic transactions statute and a specific OHS Code technical requirement has not been confirmed by Alberta OHS in writing. Operating on an unconfirmed assumption for a high-risk confined space procedure creates unacceptable compliance exposure. Platform proceeds with DocuSign as default but flags this document type for explicit legal confirmation before finalizing.

**Compliance Justification:** OHS Code Part 5 s.45 — written confined space entry permit required. ETA SA 2001 c E-5.5 — electronic equivalent standing. Unresolved intersection requires legal opinion. ACSA COR Element 3 — hazard control procedures must be compliant with applicable regulation. Operating with an unverified assumption on a life-safety document type is not acceptable.

**Rollback Plan:** If legal review confirms wet signature required: (1) Remove confined space entry permits from DocuSign execution workflow. (2) Build a paper-form-to-scan ingestion path specifically for this document type — existing Stage 2 paper scan path handles this. (3) Add `wet_signature_required = "Y"` field to document metadata schema. (4) Compliance dashboard flags all confined space permits for paper-origin verification. Estimated effort: 1 week to implement paper fallback path for this document type specifically.

**Linked File(s):**
- `compliance/COMPLIANCE.md`
- `stages/02_specification/Specs.md`
- `docs/llm-guardrails/SYSTEM_PROMPT_GUARDRAILS.md`

**Status:** Active — Pending Legal Review

---

### [2026-05-23] | ADR-010 | Make.com as Automation Layer — Not System of Record

**Decision:** Make.com is the workflow automation execution layer only. It is not a system of record. All compliance data, document versions, event logs, and audit trails reside in SharePoint. Make.com scenarios are stateless relative to compliance data — they read from and write to SharePoint; they do not hold state.

**Rationale:** Make.com has a 45-minute scenario execution timeout, a 50-concurrent-run limit on webhook scenarios, and a maximum 60-day execution log retention on Enterprise plan. None of these characteristics are compatible with a system-of-record role in a multi-year compliance management platform. Treating Make.com as stateless execution infrastructure eliminates all three constraints: scenario timeouts are managed by dispatcher-to-child-scenario patterns, concurrency limits are managed by queue serialization (no data loss), and log retention is irrelevant because CEL captures all events at execution time.

**Compliance Justification:** See ADR-003. Make.com execution logs MUST NOT be cited as compliance evidence per ADR-003. This ADR extends that principle: Make.com is not a data store at any layer. All data persistence is SharePoint. This separation is enforceable — Make.com scenarios do not have a persistent database; all reads and writes go through SharePoint modules with explicit `client_id` scoping.

**Rollback Plan:** If Make.com is replaced as the automation layer: (1) All compliance data remains in SharePoint — no migration required. (2) Re-implement scenario logic in replacement platform (n8n, Power Automate, or custom) against the same SharePoint lists and document libraries. (3) CEL structure, Signatories List, SOP Propagation Tracker, and all other SharePoint lists are platform-agnostic. (4) DocuSign webhooks are pointed to replacement platform webhook endpoints. Estimated replacement effort: 8–12 weeks for full scenario rebuild. Data risk: zero.

**Linked File(s):**
- `stages/05_workflows/AGENTS.md`
- `stages/04_architecture/System-Diagram.md`
- `compliance/COMPLIANCE.md`

**Status:** Active

---

### [2026-05-23] | ADR-011 | Dispatcher Pattern for Multi-Client SOP Propagation at Scale

**Decision:** SOP propagation to 50+ clients is implemented as a dispatcher-to-child-scenario pattern. A master dispatcher scenario iterates client records and sends a webhook per client to an independent child scenario. Each child scenario handles one client's full propagation cycle independently.

**Rationale:** A single Make.com scenario processing 50+ clients sequentially will exceed the 40-minute execution timeout before completion. Parallel execution in a single scenario is bounded by the 50-concurrent-run webhook limit. The dispatcher pattern eliminates both constraints: the dispatcher scenario runs in seconds (it only sends webhooks, it does not execute propagation logic), and each child scenario runs within its own 40-minute execution window against a single client. This pattern is also fault-tolerant — a child scenario failure for Client A does not affect Client B's propagation cycle.

**Compliance Justification:** ACSA COR Element 8 — SOP propagation must be complete and verifiable across all clients. A pattern that systematically fails to complete propagation for clients beyond position 30 in a queue (due to timeout) would create systematic compliance gaps that are invisible until a COR audit. Dispatcher pattern ensures each client's propagation is independently traceable and independently retryable.

**Rollback Plan:** If dispatcher pattern fails at scale (>200 clients): (1) Implement batch processing — dispatcher groups clients into batches of 10; each batch child scenario processes 10 clients sequentially. (2) Batch size tunable without architecture change. (3) Alternative: migrate to a queue-based architecture (Azure Service Bus or equivalent) with Make.com HTTP module as producer and a lightweight consumer service. Estimated effort for queue migration: 3–4 weeks.

**Linked File(s):**
- `stages/05_workflows/AGENTS.md`
- `stages/04_architecture/System-Diagram.md`

**Status:** Active

---

### [2026-05-23] | ADR-012 | Canada Central Data Residency Lock

**Decision:** All client data — including SharePoint site collections, CEL lists, document libraries, and all Make.com data written to SharePoint — is anchored to the Canada Central Azure region. No client personal information or compliance record is permitted to reside outside Canada Central.

**Rationale:** PIPA Alberta and PIPEDA require that personal information be protected with security appropriate to its sensitivity. Canada Central residency is the strongest practical guarantee available within the Microsoft 365 ecosystem for Canadian clients. Alberta oil and gas clients operating under AER and OHS Act jurisdiction have regulatory exposure if personal safety records (worker certifications, incident reports, training records) are processed or stored in foreign jurisdictions. Canada Central residency is confirmed at SharePoint site provisioning and logged in CEL — this is not a configuration setting that can be changed post-hoc without a data migration.

**Compliance Justification:** PIPA Alberta — protection of personal information. PIPEDA Principle 7 (Safeguards) — appropriate security measures for sensitivity of information. Canada Central data residency eliminates cross-border transfer risk for Alberta-sourced personal information. MSA with each client confirms data residency as a contractual obligation. `.env` file contains Canada Central endpoint confirmations per SKILL.md requirements.

**Rollback Plan:** If Canada Central becomes unavailable or a client requires a different residency: (1) Migrate affected client site collection to the required region using SharePoint migration tooling (Microsoft 365 Migration Manager). (2) Update `client_id` to region-specific endpoint references in Make.com scenarios. (3) Update MSA addendum to reflect changed residency. (4) Log residency change event in CEL with advisor authorization. Note: cross-region migration of a SharePoint site collection requires careful execution to preserve metadata, version history, and retention labels. This is a high-effort operation — estimated 2–4 weeks per client.

**Linked File(s):**
- `compliance/COMPLIANCE.md`
- `.env` (Canada Central endpoint confirmation — gitignored)
- `stages/01_discovery/output/`

**Status:** Active

---

### [2026-05-23] | ADR-013 | Safety Credentials Verified by Deterministic Python Script — LLM Scoring Prohibited

**Decision:** All verification of COR, NCSO, and CRSP certifications is handled exclusively by `scripts/verify-compliance.py` (deterministic Python). LLM scoring, AI inference, or probabilistic evaluation of safety credentials is absolutely prohibited as a substitute or supplement to script execution.

**Rationale:** Safety credentials in the Alberta oil and gas sector have direct legal standing. An NCSO or CRSP credential that appears valid but has expired, been suspended, or is fraudulently represented creates OHS Act liability for the employer and reputational risk for Vaquero. LLMs cannot reliably verify the current status of a certification against the certifying body's registry — they can only pattern-match against training data, which is both stale and non-authoritative. The Python script uses deterministic logic against current registry data; it produces a binary verified/unverified output that is legally defensible. AI-generated confidence scores are not.

**Compliance Justification:** OHS Act (Alberta) — employer duty to verify worker competency. ACSA COR audit requirements — certifications must be current and verifiable. NCSO (CSSE) and CRSP (BCRSP) are issued and maintained by certifying bodies with live registries. Platform verification must reflect registry state at time of query, not LLM training data state. PIPA Alberta s.34 — named compliance advisor is accountable for certification verification — script output provides the deterministic basis for that accountability.

**Rollback Plan:** If `verify-compliance.py` fails (script error, registry API unavailability): (1) Make.com error handler alerts compliance advisor immediately. (2) Human advisor performs manual verification against CSSE and BCRSP registries directly. (3) Manual verification is documented in CEL with: verified_by, verification_method = "manual_registry_check", timestamp, registry_response. (4) No output involving COR/NCSO/CRSP credentials proceeds until verification is complete — automated or manual. Script failure does not default to LLM scoring under any circumstances.

**Linked File(s):**
- `scripts/verify-compliance.py`
- `docs/llm-guardrails/SYSTEM_PROMPT_GUARDRAILS.md`
- `compliance/COMPLIANCE.md`

**Status:** Active

---

### [2026-05-23] | ADR-014 | Stage 8 Environmental and Well Tracking Workflows Are Temporary Pending Legal Review

**Decision:** Stage 8 workflows for soil/water sampling, well tracking, and environmental monitoring logs are implemented as store-and-notify only. No automated regulatory submission to Alberta Environment, AER, or any other government body is built until legal and environmental consultant review is complete per client.

**Rationale:** Environmental Protection and Enhancement Act (EPEA) and AER reporting obligations vary by client, by operation type, by approval condition, and by specific incident type. Building automated submission workflows against unconfirmed regulatory thresholds creates a systematic risk of either under-reporting (regulatory violation) or over-reporting (nuisance reporting that affects client standing with regulators). Petrinex and AER OneStop are external government systems — platform does not attempt to replicate or integrate them. The risk asymmetry strongly favors a manual confirmation model: compliance advisor confirms each submission obligation per client, confirms submission completed externally, and CEL records the confirmation.

**Compliance Justification:** EPEA — specific obligations vary by approval conditions per operator. AER — Petrinex submission requirements vary by well activity and licence type. Any automated submission that fires against the wrong client's approval conditions creates a regulatory compliance event that cannot be undone. The 2025 [FLAG FOR LEGAL REVIEW] flags in the workflow specification are operative — these flags block automated submission until resolved.

**Rollback Plan:** Not applicable — this decision is a deliberate constraint on automation scope. As legal review is completed per client: (1) Lift [FLAG FOR LEGAL REVIEW] status for confirmed document types per client. (2) Build specific automated notification workflows (not submission workflows) that alert advisors when thresholds are approached. (3) Government submissions remain external — platform records advisor confirmation of external submission with AER reference numbers. Stage 8 will never be fully automated; it will move from store-and-notify to store-and-alert-and-confirm.

**Linked File(s):**
- `stages/02_specification/Specs.md`
- `compliance/COMPLIANCE.md`
- `docs/llm-guardrails/SYSTEM_PROMPT_GUARDRAILS.md`

**Status:** Active — Pending Legal Review

---

### [2026-05-23] | ADR-015 | Mobile App + Office Scan Hybrid Field Data Capture with Metadata Distinction

**Decision:** Field data capture supports two paths with explicit metadata distinction: (1) Primary — mobile app (online and offline sync), capturing GPS, device timestamp, worker digital signature, and form version. (2) Backup — paper form with office scan upload, capturing paper_record_date, uploading_user_id, site_location, reason_paper_used. Both paths are valid compliance records; paper scan records are flagged for compliance advisor acknowledgement and noted separately in COR audit packages.

**Rationale:** Remote oil and gas and construction sites in Alberta frequently have no cellular coverage. A mobile-only model without an offline capability or paper backup creates operational gaps that manifest as missing records in the audit trail. Missing records are worse than paper records — they are undocumented gaps. The hybrid model ensures no field event goes unrecorded while the metadata distinction allows the compliance dashboard to track the paper scan ratio as a quality KPI (target: <5% of total field records).

**Compliance Justification:** OHS Act (Alberta) — inspection and safety records must be maintained. The regulation does not prescribe a digital-only capture method; paper records are legally valid. ACSA COR audit tool — field-captured records accepted in any legible format with adequate metadata. Paper scan records with explanation are not disqualifying in a COR audit. The metadata distinction (`capture_method` field) satisfies the audit requirement for transparency about record origin.

**Rollback Plan:** If mobile app is deprecated or replaced: (1) New app platform must write to the same SharePoint API endpoint with identical metadata schema. (2) `capture_method` field values updated to reflect new platform identifier. (3) Office scan backup path is app-independent — no change required. (4) COR audit package generation reads metadata fields, not app platform identity. Estimated effort: 2–3 weeks for API integration with replacement app platform.

**Linked File(s):**
- `stages/02_specification/Specs.md`
- `stages/05_workflows/AGENTS.md`
- `src/` (mobile app API integration)

**Status:** Active

---

### [2026-05-23] | ADR-016 | MCP Credential Architecture — Windows System Environment Variables

**Decision:** Cursor MCP server credentials (Supabase access tokens) are stored exclusively as Windows System Environment Variables using the `%CURSOR_MCP_[CLIENTNAME]%` naming convention. `.env` files are not used for MCP credentials due to process-scope read failures with N8N. MCP JSON configuration references environment variables only — no hardcoded tokens in `mcp.json`.

**Rationale:** `.env` files were evaluated and rejected for MCP credential storage after documented process-scope read failures with N8N on Windows. Windows System Environment Variables are read natively by Cursor at process start without file loading. The `cmd /c` wrapper is required for all MCP entries on Windows — raw `npx` without this wrapper fails. Client credential isolation is maintained by the `%CURSOR_MCP_[CLIENTNAME]%` naming convention — each client has a uniquely named environment variable that maps to a uniquely named MCP server entry.

**Compliance Justification:** PIPA Alberta s.34 — accountability requires that credential access be controlled and auditable. System environment variables are not readable by application code without explicit access and are not committed to source control. `.env` files with tokens committed to git (even accidentally) would constitute a credential exposure event. Windows System Variables eliminate the git-exposure vector entirely for MCP credentials. No credentials appear in `mcp.json`, `args[]`, source files, comments, or logs.

**Rollback Plan:** If Windows System Environment Variables become unavailable (e.g., migration to Linux development environment): (1) Migrate to a secrets manager (HashiCorp Vault, Azure Key Vault, or Doppler) with environment-variable injection at process start. (2) MCP server configuration references the same `%VAR_NAME%` pattern — the injection mechanism changes, not the reference pattern. (3) Update `.env.example` to reflect new secret source. (4) Audit all MCP configurations to confirm no tokens appear in `args[]` after migration. Estimated effort: 1 week.

**Linked File(s):**
- `~/.cursor/mcp.json` (global Cursor config)
- `.env.example`
- `compliance/COMPLIANCE.md`
- `references/mcp-config.md`

**Status:** Active

---

*End of initial decision log — v1.0.0*

*All subsequent decisions MUST be appended below this line following the entry format defined at the top of this document. Do not modify entries above this line.*

---

### [2026-05-30] | ADR-017 | PageCrawl API Token Hardcoded in mcp.json Headers — CREDENTIAL-EXCEPTION-01

**Decision:** The PageCrawl API token is stored directly (hardcoded) in the `headers{}` field of the `pagecrawl` entry in `C:\Users\ajohn\.cursor\mcp.json`. This is a named, documented exception to the credential architecture defined in ADR-016.

**Rationale:** The standard credential architecture (ADR-016) requires all MCP tokens to be stored as Windows System Environment Variables and referenced via `%ENV_VAR%` syntax. This was attempted for PageCrawl — `%PAGECRAWL_API_KEY%` was correctly set as a Windows System Environment Variable. However, Cursor does not expand `%ENV_VAR%` references inside `headers{}` fields at runtime. Expansion only works reliably in `args[]` fields. PageCrawl's MCP transport is HTTP headers only — it has no `args[]` path. The result was a persistent `401 Unauthorized` error despite the environment variable being correctly set. The root cause was confirmed by: (1) `echo %PAGECRAWL_API_KEY%` returning the correct token value in Command Prompt, and (2) the `401` persisting after Cursor restart, ruling out env var absence as the cause. No alternative transport method exists for this server. Hardcoding in `mcp.json` is the only functional path. `[CONFIDENCE: 3 — root cause confirmed by elimination]`

**Risk Assessment:**
- `mcp.json` is a local machine file at `C:\Users\ajohn\.cursor\mcp.json` — outside `C:\Projects\Vaquero_Safety_Inc\` and never in Git
- PageCrawl token scope is limited to PageCrawl page monitoring — no access to Supabase, SharePoint, or any compliance data
- Token is revocable and regenerable instantly from the PageCrawl API settings page
- Single-developer machine — no shared environment risk
- Risk classification: **Low** — scoped, revocable, local-only, no compliance data access

**Compliance Justification:** PIPA Alberta s.34 — this entry constitutes the named accountability record for the intentional deviation. The exception is bounded: it applies to one token, one local file, one non-compliance-data service. The credential does not appear in any project file, source code, Git repository, or compliance record. The `mcp.json` file must never be committed to any Git repository — confirmed at time of decision.

**Mitigations in Place:**
1. `mcp.json` confirmed outside Git repo scope
2. PageCrawl token noted for rotation if machine is compromised
3. This ADR entry serves as the audit record — the deviation is intentional and documented, not accidental
4. Token must be rotated and this entry updated (new ADR superseding this one) if the machine is shared, rebuilt, or compromised

**Rollback Plan:** If Cursor adds native `%ENV_VAR%` expansion support in `headers{}` fields in a future release: (1) Add `PAGECRAWL_API_KEY` back as a Windows System Environment Variable. (2) Replace the hardcoded token in `mcp.json` with `%PAGECRAWL_API_KEY%`. (3) Restart Cursor and confirm no `401` error. (4) Append a new ADR entry superseding this one, marking CREDENTIAL-EXCEPTION-01 as resolved. (5) Rotate the previously hardcoded token.

**Linked File(s):**
- `~/.cursor/mcp.json` (`C:\Users\ajohn\.cursor\mcp.json`)
- `references/mcp-config.md`
- `.claude/rules/memory-decisions.md` (CREDENTIAL-EXCEPTION-01 tag)

**Exception Tag:** `CREDENTIAL-EXCEPTION-01`

**Status:** Active — Exception in force pending Cursor `headers{}` env var expansion fix

---

### [2026-05-30] | ADR-018 | Obsidian API Token Hardcoded in mcp.json — CREDENTIAL-EXCEPTION-02

**Decision:** The Obsidian Local REST API token is stored directly (hardcoded) in the `mcp.json` entry for the `obsidian` server, passed via the `--header` flag in `args[]`. This is a named, documented exception to the credential architecture defined in ADR-016. Additionally, the Obsidian Local REST API plugin uses plain `http` (not `https`) for localhost connections — the URL is `http://127.0.0.1:27123/mcp/`.

**Rationale:** Two sequential issues were encountered configuring the Obsidian MCP. First, the initial URL used `https://127.0.0.1:27123/mcp/` which produced a `fetch failed` error — the Obsidian Local REST API plugin runs over plain `http` on loopback and does not use TLS. This was corrected to `http`. Second, the standard credential approach (`%CURSOR_MCP_OBSIDIAN%` as a Windows System Environment Variable passed via `--header "Authorization: Bearer %CURSOR_MCP_OBSIDIAN%"` in `args[]`) failed to authenticate. The `--header` flag in `mcp-remote` passes the value as a literal string at the subprocess level — `%ENV_VAR%` expansion does not occur in this context on Windows in the same way it does for direct `args[]` values. The root cause is the same class of limitation as ADR-017: Cursor's Windows subprocess environment does not expand `%ENV_VAR%` references inside header-bearing arguments reliably. Hardcoding the token in the `--header` value is the only functional resolution. `[CONFIDENCE: 3 — confirmed by authentication failure with env var set correctly]`

**Risk Assessment:**
- `mcp.json` is a local machine file at `C:\Users\ajohn\.cursor\mcp.json` — outside `C:\Projects\Vaquero_Safety_Inc\` and never in Git
- Obsidian Local REST API token scope is limited to read/write access to the local Obsidian vault — no access to Supabase, SharePoint, or any compliance data
- Token is revocable from the Obsidian Local REST API plugin settings
- Single-developer machine — no shared environment risk
- Risk classification: **Low** — local vault only, no compliance data access, local machine file

**Compliance Justification:** PIPA Alberta s.34 — this entry constitutes the named accountability record for the intentional deviation. The exception is bounded: it applies to one token, one local file, one local-only service (Obsidian vault). The credential does not appear in any project file, source code, Git repository, or compliance record. The `mcp.json` file must never be committed to any Git repository — confirmed at time of decision.

**Mitigations in Place:**
1. `mcp.json` confirmed outside Git repo scope
2. Obsidian token noted for rotation if machine is compromised
3. This ADR entry serves as the audit record — the deviation is intentional and documented, not accidental
4. Token must be rotated and this entry updated (new ADR superseding this one) if the machine is shared, rebuilt, or compromised

**Rollback Plan:** If `mcp-remote` adds reliable Windows `%ENV_VAR%` expansion in `--header` arguments in a future release: (1) Add `CURSOR_MCP_OBSIDIAN` back as a Windows System Environment Variable. (2) Replace the hardcoded token in the `--header` argument in `mcp.json` with `%CURSOR_MCP_OBSIDIAN%`. (3) Restart Cursor and confirm no authentication error. (4) Append a new ADR entry superseding this one, marking CREDENTIAL-EXCEPTION-02 as resolved. (5) Rotate the previously hardcoded token.

**Linked File(s):**
- `~/.cursor/mcp.json` (`C:\Users\ajohn\.cursor\mcp.json`)
- `references/mcp-config.md`
- `.claude/rules/memory-decisions.md` (CREDENTIAL-EXCEPTION-02 tag)

**Exception Tag:** `CREDENTIAL-EXCEPTION-02`

**Status:** Active — Exception in force pending mcp-remote Windows env var expansion fix

---

### [2026-05-31] | ADR-019 | ROUTING ENGINE AND OBSIDIAN PERSISTENCE ENGINE ESTABLISHED

**Decision:** Two standalone operating rule files created — routing-engine.md and obsidian-persistence.md — governing output routing, tool selection, search triggers, and Obsidian knowledge persistence for all Claude Desktop sessions.

**Rationale:** Prior state had no enforced routing between Claude Desktop, Obsidian, and Cursor. Knowledge created in sessions was not persisting reliably. Obsidian vault was inconsistently populated, making it untrustworthy as a future reasoning source. Separate files chosen over embedding in SKILL.md to allow independent evolution and easier targeted consultation. Cursor population of Obsidian explicitly prohibited — knowledge flow is Layer 1 (Claude Desktop) → Layer 2 (Obsidian) → Layer 3 (Cursor) only.

**Compliance Justification:** N/A — internal operational architecture decision. Does not affect CEL, SharePoint compliance evidence, or any client-facing workflow.

**Rollback Plan:** Remove routing-engine.md and obsidian-persistence.md from `.claude/rules/`. Remove Section 16 and Rule 14 from SKILL.md. Revert SKILL.md to v2.1.0. Remove ADR-019 from memory-decisions.md is not permitted — append a supersession note instead.

**Linked File(s):**
- `.claude/rules/routing-engine.md`
- `.claude/rules/obsidian-persistence.md`
- `.claude/rules/memory-decisions.md`
- `SKILL.md` Section 16 (v2.2.0)

**Status:** Active

---


[2026-05-31] | ADR-PENDING-001 | CEL RECONCILIATION MECHANISM
  Decision:                 Implement a daily Make.com reconciliation scenario that compares expected CEL entries against actual entries written to SharePoint, using a make_scenario_execution_id field and cel_write_confirmed boolean on every CEL record.
  Rationale:                Make.com operational logs expire at 60 days and are not compliance evidence. Silent scenario failures (timeout, retry, service disruption) can produce CEL gaps or duplicates that are undetectable without a verification layer. CEL integrity is the core architectural differentiator — a gap at audit time has direct regulatory consequence.
  Compliance Justification: COR audit standard — CEL must provide unbroken event chain for audit period. Alberta OHS Act — incident and training records must be accurate and complete. SKILL.md Rule 12 — CEL is system of record, Make.com logs are not.
  Rollback Plan:            Remove cel_write_confirmed field and reconciliation scenario. Revert to manual advisor spot-checks of CEL completeness. Accept increased audit risk until replacement mechanism is designed.
  Linked File(s):           compliance/ARCHITECTURE-DECISIONS.md | Vaquero_Safety_Inc/Architecture/cel-reconciliation-mechanism.md
  Status:                   Active


[2026-05-31] | ADR-PENDING-002 | SOP STAGED PROPAGATION PROTOCOL
  Decision:                 SOP propagation fires in staged batches — Batch 1 is a single pilot client, Batch 2 is up to 10 clients, Batch 3 is the remainder. A batch_number field and batch_gate_approved boolean are added to the SOP Propagation Tracker. Stage 6 dispatcher reads batch_gate_approved before firing each batch. Batch gate approval is a human action by the compliance advisor.
  Rationale:                Simultaneous propagation across 50+ clients creates a blast radius where a template error or misclassification reaches every client before detection. Staged batching adds a post-propagation-start detection layer at low operational cost. Dual advisor review before template_status = Ready_for_propagation reduces probability of error but does not eliminate it.
  Compliance Justification: COR audit standard — SOP currency and version control are auditable elements. Stage 6 existing dual review requirement — SKILL.md Section 8, Stage 6.
  Rollback Plan:            Remove batch_number and batch_gate_approved fields. Revert Stage 6 dispatcher to simultaneous propagation. Increase pre-propagation review stringency as compensating control.
  Linked File(s):           compliance/ARCHITECTURE-DECISIONS.md | Vaquero_Safety_Inc/Architecture/sop-staged-propagation-protocol.md
  Status:                   Active


[2026-05-31] | ADR-PENDING-003 | MAKE.COM MIGRATION THRESHOLD
  Decision:                 Make.com is confirmed as the correct automation layer for 0–30 clients. Migration is triggered when any of the following conditions are met: (a) concurrent device sync events per client regularly approach the 30 req/s ceiling, (b) SOP propagation batch size exceeds 30 clients and batch gates add 48h+ of advisor overhead per propagation event, (c) monthly Make.com operations cost exceeds a founder-defined threshold (value to be set). Preferred migration target is Azure Logic Apps given existing SharePoint/M365 stack alignment.
  Rationale:                Make.com constraints — 5MB payload ceiling, 30 req/s rate limit, no native idempotency — create a defined scaling failure point. Documenting exit conditions now costs nothing. Discovering the ceiling at 40 clients with no migration plan is a 3–6 month emergency engineering project while clients are live. This is planned technical debt, not an oversight.
  Compliance Justification: SKILL.md Rule 12 — CEL integrity cannot depend on Make.com reliability at scale. SKILL.md Section 15 — Make.com dependency is an accepted architectural constraint for the build phase.
  Rollback Plan:            No rollback required — this ADR documents a future migration decision, not a current change. If migration trigger conditions are never reached, Make.com remains the automation layer indefinitely.
  Linked File(s):           compliance/ARCHITECTURE-DECISIONS.md | Vaquero_Safety_Inc/Architecture/make-com-migration-threshold.md | Vaquero_Safety_Inc/Architecture/make-com-as-mvp-sync-endpoint.md
  Status:                   Active


[2026-05-31] | ADR-PENDING-004 | OFFLINE CEL ENTRY DUAL TIMESTAMP DESIGN
  Decision:                 All CEL entries written from a mobile device must carry two non-overwriting timestamp fields: event_timestamp_device (device clock at time of action, ISO 8601 UTC) and event_timestamp_server (SharePoint write timestamp, ISO 8601 UTC). A calculated field offline_duration_seconds is derived from the difference. All timestamps stored in UTC; localization at display layer only. Values of offline_duration_seconds exceeding a defined threshold trigger an advisor review flag.
  Rationale:                A single timestamp overwritten on server receipt records sync time, not event time. For a field inspection completed Tuesday that syncs Thursday, a single timestamp records Thursday — factually incorrect and producing an audit gap. In a COR audit or OHS Act s.33 incident investigation, the distinction between when an event occurred and when it was synced is material. The dual timestamp design is the minimum viable approach to preserve audit integrity for offline events.
  Compliance Justification: Alberta OHS Act s.33 — incident investigation records must accurately reflect when events occurred. COR audit standard — inspection completion records are auditable with date accuracy requirements. SKILL.md Stage 2 — capture_method field already distinguishes online vs offline sync.
  Rollback Plan:            Remove event_timestamp_device and offline_duration_seconds fields. Retain event_timestamp_server as the single timestamp. Document the limitation explicitly in the COR evidence package certification process so advisors flag offline records during audit preparation.
  Linked File(s):           compliance/ARCHITECTURE-DECISIONS.md | Vaquero_Safety_Inc/Architecture/offline-cel-entry-dual-timestamp.md
  Status:                   Active


[2026-05-31] | ADR-PENDING-005 | SYNC CONFLICT RESOLUTION — SERVER-AUTHORITATIVE
  Decision:                 Sync conflict resolution strategy is server-authoritative with device-timestamp preservation. On sync, the server accepts the CEL entry as written by the device, stamps the server-receipt timestamp, and writes to SharePoint. The device timestamp is preserved exactly as recorded and never overwritten. If a duplicate make_scenario_execution_id is detected, the second write is rejected and flagged for compliance advisor review — not silently merged, not silently discarded. No automated conflict resolution. All conflicts surface to human review.
  Rationale:                CRDT and operational transformation are designed for concurrent editing of shared documents — not applicable to append-only compliance log entries written once by one device. CEL entries document facts, not states. Conflict on a fact record means something unexpected happened and requires human review, not algorithmic resolution. An auto-merged CEL entry is legally weaker in an OHS incident investigation or COR audit than one that was human-reviewed and confirmed.
  Compliance Justification: Alberta OHS Act s.33 — incident investigation records must be accurate. COR audit standard — CEL is the evidence source; its integrity is non-negotiable. SKILL.md Rule 12 — CEL is system of record.
  Rollback Plan:            Remove duplicate detection logic on make_scenario_execution_id. Revert to last-write-wins on all sync writes. Accept increased risk of duplicate or overwritten CEL entries. Implement compensating manual reconciliation by compliance advisor.
  Linked File(s):           compliance/ARCHITECTURE-DECISIONS.md | Vaquero_Safety_Inc/Architecture/sync-conflict-resolution-strategy.md
  Status:                   Active
