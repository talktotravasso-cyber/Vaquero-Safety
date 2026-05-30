# Vaquero Safety Inc — Follow-Up Action Items
**Source:** Phase 2 End-to-End Workflow Specification  
**Classification:** Pre-Go-Live Blockers + Ongoing Build Tasks  
**Format:** Priority | Stage | Item | Owner | Status

---

## TIER 1 — GO-LIVE BLOCKERS (Cannot automate until resolved)

| # | Stage | Item | Owner | Status |
|---|-------|------|-------|--------|
| 1 | S2/S5 | **DocuSign legality for confined space entry permits** — OHS Code Part 5 s.45 requires "written" entry permit. Alberta's *Electronic Transactions Act* SA 2001 c E-5.5 gives electronic records equivalent standing, but written confirmation from Alberta OHS or labour counsel is required before confined space permits enter the DocuSign pipeline. | External: Alberta Labour Lawyer / Alberta OHS | 🔴 UNRESOLVED |
| 2 | S7 | **CVIP weight threshold confirmation** — Whether 11,794 kg is the correct CVIP applicability threshold for Alberta, and whether semi-annual inspections apply to specific vehicle categories. Confirm with Alberta Transportation before automated alert logic is built for client vehicle fleets. | External: Alberta Transportation | 🔴 UNRESOLVED |
| 3 | S8 | **Environmental record submission obligations (EPEA)** — Stage 8 in full [TEMPORARY] status. Each client's EPEA approval conditions must be individually reviewed to determine monitoring, recording, and government submission requirements before any Stage 8 automation is built. | External: Environmental Consultant (per client) | 🔴 UNRESOLVED — per client |
| 4 | S5 | **Wet signature requirements for additional OHS Code documents** — First Aid Program (OHS Code Part 11), Mine site entry documents (Part 36), and union CBA documents may require wet signature. Confirm with Alberta OHS counsel before routing to DocuSign. | External: Labour Lawyer | 🔴 UNRESOLVED |
| 5 | S8 | **AER OneStop API availability** — Confirm whether AER OneStop has an API for automated submission status monitoring, or if web portal only. Current assumption: no API. | External: AER / Tech Team | 🟡 ASSUMED — confirm |

---

## TIER 2 — BUILD DEPENDENCIES (Required before automation is reliable)

| # | Stage | Item | Owner | Status |
|---|-------|------|-------|--------|
| 6 | S1 | **PnP PowerShell site template build** — The 13-library SharePoint template with all metadata schemas must be built and tested before client onboarding automation goes live. | Tech Team | 🟡 PENDING BUILD |
| 7 | S1 | **Signatories List schema finalization** — Role-based signing model requires finalized field schema (role, name, email, channel, signing_order) and edge case handling for vacant roles before any DocuSign automation is tested. | Tech Team + Compliance Advisor | 🟡 PENDING |
| 8 | S2 | **AI classification module confidence threshold** — Define the confidence score below which documents route to human advisor queue vs. auto-classify. No threshold documented in spec. Requires calibration on real document set. | Tech Team + Compliance Advisor | 🟡 UNDEFINED |
| 9 | S3 | **Web scraper hash comparison logic** — For AER, ACSA, BCRSP, CSSE, Transport Canada (no RSS feed). Make.com HTTP GET + page hash comparison must be built and tested per regulatory URL. False positive rate must be evaluated before live deployment. | Tech Team | 🟡 PENDING BUILD |
| 10 | S3 | **CRSP CPD point tracking mechanism** — Spec notes CRSP CPD status updated "when available from BCRSP." No ingestion mechanism defined. Confirm whether BCRSP exposes any data programmatically or if this is manual entry only. | Compliance Advisor + Tech Team | 🟡 UNDEFINED |
| 11 | S4 | **Tracked approval link architecture** — Approve/Amend action buttons must route to a Make.com webhook with notification_id + contact_id + action. URL tracking mechanism (including non-tracked browser handling) must be spec'd and tested for email deliverability (SPF/DKIM, link scanner false positives). | Tech Team | 🟡 PENDING BUILD |
| 12 | S4 | **Twilio SMS approval pathway** — SMS delivers a link to an approval response page, not inline action buttons. That response page must be designed, built, and tested independently. | Tech Team | 🟡 PENDING BUILD |
| 13 | S5 | **DocuSign "Correct" vs. void-and-reissue decision tree** — When a signatory change is flagged mid-envelope, the workflow calls for DocuSign "Correct" if no signing has occurred, void+reissue if correction isn't possible. This logic must be codified as a Make.com decision branch, not left to advisor judgment in the moment. | Tech Team + Compliance Advisor | 🟡 NEEDS CODIFICATION |
| 14 | S6 | **Dispatcher + Child Scenario pattern** — SOP propagation to 50+ clients will timeout in a single Make.com scenario (45-min limit). Master dispatcher scenario → per-client child scenarios via webhooks must be built and load-tested before any multi-client propagation runs. | Tech Team | 🔴 CRITICAL — timeout risk |
| 15 | S7 | **Semi-annual CVIP applicability categories** — [UNVERIFIED] in spec. Do not build semi-annual alert logic until Alberta Transportation confirms specific vehicle categories. Build annual-only first; add semi-annual as a config flag. | Tech Team | 🟡 FLAGGED |
| 16 | S8 | **Digital-only SDS on mobile app in no-connectivity sites** — Whether a read-only PDF on mobile app without paper backup satisfies OHS Code Part 4 in remote sites is unconfirmed. Maintain paper backup protocol and document it in client onboarding until confirmed. | Compliance Advisor + Legal | 🟡 UNCONFIRMED |

---

## TIER 3 — HUMAN DECISION CHECKPOINTS (Cannot be automated — policy decisions)

| # | Stage | Item | Owner |
|---|-------|------|-------|
| 17 | S1 | Gap assessment classification — AI may flag anomalies but compliance advisor must classify each gap (Critical/Major/Minor) with sign-off. | Compliance Advisor |
| 18 | S1 | Onboarding completion gate — Advisor marks client "Active" only after MSA executed, site provisioned, signatories configured, preferences set, and gap assessment complete. | Compliance Advisor |
| 19 | S1 | **[FLAG FOR LEGAL REVIEW]** — If a client's existing COR was obtained while holding documentation gaps now identified at onboarding, advisory to client on COR audit risk must be issued and logged to CEL. | Compliance Advisor + Legal |
| 20 | S2 | Email-captured approvals may not meet OHS or COR evidentiary standards — Advisor must convert to formal DocuSign-executed version before marking approval_status = "Active." | Compliance Advisor |
| 21 | S3 | Regulatory change classification — Advisor must classify every detected change (A/B/C) within 48 hours. Wrong classification affects all 50+ clients simultaneously. Dual-advisor review recommended for Classification A. | Compliance Advisor + Senior Review |
| 22 | S5 | Signatory change mid-process — Advisor must authorize all DocuSign "Correct" or void+reissue actions. MSA must include clause requiring client notification of signing authority change within 5 business days. | Compliance Advisor |
| 23 | S6 | SOP base template update — Second compliance advisor or manager must review updated template before propagation to clients. | Senior Compliance Professional |
| 24 | S7 | Return-to-service after failed inspection — Advisor must review and authorize; cannot be automated. | Compliance Advisor |
| 25 | S9 | COR evidence package certification — Advisor must certify package completeness before sharing with auditor. | Compliance Advisor |
| 26 | S4 | T+21 formal non-response notice — Must be authorized by named individual; DocuSign issued by compliance advisor + authorized Vaquero officer. | Compliance Advisor + Authorized Officer |

---

## TIER 4 — MSA / LEGAL DRAFTING REQUIREMENTS

| # | Item | Owner |
|---|------|-------|
| 27 | MSA must explicitly state the management-vs-advisory relationship — OHS Act employer responsibility for accurate safety documentation does not transfer to Vaquero. | Legal |
| 28 | MSA clause: client must notify Vaquero within 5 business days of signing authority change. | Legal |
| 29 | MSA/DPA: PIPA s.7 consent for collection of personal information must be explicitly captured. | Legal |
| 30 | MSA: authority verification timing clause — if departing employee signs in final days before system update, DocuSign audit trail governs; MSA must address this explicitly. | Legal |
| 31 | Data processing addendum (DPA) must be finalized and DocuSign-executable before any client onboarding proceeds. | Legal |

---

## TIER 5 — OPERATIONAL MONITORING & REPORTING SETUP

| # | Stage | Item | Owner |
|---|-------|------|-------|
| 32 | S3 | Named on-call compliance advisor for regulatory monitoring must be designated per monitoring schedule. Manual monitoring cannot proceed without a named accountable human. | Operations / HR |
| 33 | S9 | PIPA s.7/24 data subject access request (DSAR) workflow must be designed as a separate operational procedure before onboarding any clients with personal worker data. | Compliance Advisor + Legal |
| 34 | S9 | Paper scan ratio KPI target (<5% of total field records) must be set in client SLAs and tracked from Day 1. | Operations |
| 35 | All | Make.com Enterprise plan retention setting — confirm 60-day execution log retention is configured and that CEL is confirmed as the system of record before go-live. Reconfirm CEL retention labels applied via Purview before first client activation. | Tech Team |
| 36 | S7 | CVIP applicability must be confirmed per client vehicle fleet at onboarding — do not rely on automated threshold logic alone until Tier 1 Item #2 is resolved. | Compliance Advisor (per client) |

---

## OPEN [UNVERIFIED] FLAGS REQUIRING EXTERNAL CONFIRMATION

| Flag | Source Section | Resolution Path |
|------|---------------|-----------------|
| CVIP semi-annual applicability — specific vehicle categories | S3, S7 | Alberta Transportation |
| Digital SDS on mobile in no-connectivity sites | S8 | Alberta OHS Code Part 4 review |
| AER OneStop API availability | S8 | AER directly |
| Several OHS Code provisions lack express retention periods — 5-year default applied | S2, S9 | Legal review per record type |
| EPEA approval conditions for chemical inventory reporting | S8 | Environmental consultant per client |
| Electronic confined space entry permits (ETA equivalence) | S2, S5 | Alberta OHS written confirmation |

---
*Document version: 1.0 | Generated from Phase 2 Workflow Specification*
