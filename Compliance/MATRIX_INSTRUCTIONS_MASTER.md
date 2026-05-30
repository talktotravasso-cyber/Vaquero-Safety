# Vaquero Safety Inc. — Canadian OHS Compliance Matrix
## Master Instruction Summary — Construction, Logging, Commercial Trucking
**Use this document at the start of each new chat session for each industry.**
**Placement:** `C:\Projects\Vaquero_Safety_Inc\compliance\MATRIX_INSTRUCTIONS_MASTER.md`

---

## What Has Already Been Built (Oil & Gas Reference)

The Oil & Gas matrix is complete at v1.7.0 and serves as the template for all three remaining industries. It lives at:
```
C:\Projects\Vaquero_Safety_Inc\compliance\Vaquero_OilGas_Compliance_Matrix_v1.7.0.xlsx
C:\Projects\Vaquero_Safety_Inc\compliance\REGULATORY_MATRIX_SEED_OIL_GAS.md
```

### Workbook Structure — Replicate for Each Industry
| Sheet | Content |
|-------|---------|
| README | Legend, confidence scale, version history, operating rules |
| A — Regulatory Authority | Primary OHS authority per province/territory (13 jurisdictions) |
| B — Credentials | All mandatory and industry-standard credentials per province |
| C — Federal Overlay | Federal legislation that supplements or overrides provincial OHS |
| D — Verify Required Tracker | All VERIFY_REQUIRED items with status, assignee, verified date |
| E — CORA National Registry | Certificate of Recognition Authorities by province and sector |

---

## Confidence Rating System — Apply to Every Cell

| Rating | Label | Meaning | Action |
|--------|-------|---------|--------|
| 3 | Verified — Green | Stable, well-documented regulatory source | Safe as reference baseline |
| 2 | Probable — Yellow | Structurally sound; URL/date needs live verification | Run firecrawl-sync.py before relying |
| 1 | Hypothetical — Orange | Placeholder only | Manual research required before any use |

**`[VERIFY_REQUIRED]`** in any cell = must validate against live official source before production use.

---

## Critical Operating Rules — Must Follow in Every Session

1. **Safety Credentials Guard** — `scripts/verify-compliance.py` MUST execute before any output involving COR, NCSO, or CRSP. LLM scoring of credentials is absolutely prohibited.
2. **Zero Guess Rule** — Never speculate on regulatory content. If ambiguous: `[ERROR: REGULATORY_DATA_AMBIGUOUS. Manual intervention required.]`
3. **Triple-Check Policy** — Every cell verified minimum 3 times before population.
4. **No SOR Invention** — Never cite a regulation number that has not been confirmed from an official source. Flag as `[VERIFY_REQUIRED — SOR number unconfirmed]` if uncertain.
5. **Correction Flagging** — If a prior entry is found to be wrong, flag the corrected cell with `⚠ CORRECTION:` notation. Do not silently overwrite.

---

## Section A — Regulatory Authority: What to Populate Per Province

For each of 13 jurisdictions (AB, BC, SK, MB, ON, QC, NB, NS, PEI, NL, YT, NT, NU):

| Field | What to Find |
|-------|-------------|
| OHS Authority Full Name | Legal name of the governing body (e.g., WorkSafeBC, not just "BC OHS") |
| Enabling Legislation | Act name + RSC/RSA/RSBC citation + year + most recent amendment |
| Applicable Regulations | Regulation codes specific to THIS industry (not just general OHS) |
| Official URL | Direct link to current regulation text on official government site |
| Last Amended | Date of most recent amendment — if unknown, flag `[VERIFY_REQUIRED]` |

**Key jurisdictional notes:**
- NT and NU share WSCC but have separate legislation
- QC uses CNESST — legislation in French; bilingual citations required
- PEI has minimal activity for some industries — retain entry for completeness
- Federal jurisdiction (CLC Part II) overrides provincial for interprovincial undertakings

---

## Section B — Credentials: What to Populate Per Province

For every credential, populate all 9 columns:

| Column | What to Find |
|--------|-------------|
| Province | Two-letter code |
| Credential Full Name | Exact legal or program name — no abbreviations without definition |
| Issuing Body | Full organization name — never assume ABSA, SATCC, or any body without confirming per industry |
| Renewal Period | Exact period — if legislated, cite the regulation section |
| Portability | Nationally portable / Province-specific / Red Seal / CFTA-eligible |
| Legislated or IS | L = Legislated (cite Act/Reg section) / IS = Industry Standard (cite CORA or client requirement) |
| Verification URL | Direct URL to public registry or lookup tool — if none exists, state "contact [body] directly: [contact]" |
| Applies To | Workers / Supervisors / Employers / All — be specific |
| Confidence | 1/2/3 per scale above |

**Mandatory credentials to cover for every industry (minimum):**
- Standard First Aid + CPR Level C
- WHMIS 2015 (amended HPR — transition ended December 14, 2025)
- TDG (where applicable)
- Fall Protection
- Confined Space Entry
- COR (Certificate of Recognition) — identify correct CORA per industry per province
- NCSO (National Construction Safety Officer) — CFCSA trademark via provincial CORAs
- CRSP (Canadian Registered Safety Professional) — BCRSP registry

**For each trade within Construction specifically — see CONSTRUCTION_INSTRUCTIONS.md**

---

## Section C — Federal Overlay: Standing Entries to Include

These apply to every industry matrix. Copy from Oil & Gas v1.7.0 and adjust applicability:

| Entry | Applicability note |
|-------|-------------------|
| Canada Labour Code Part II + SOR/86-304 | Federally regulated workers only — adjust trigger description per industry |
| TDG Regulations (SOR/2001-286) | Applies wherever DG are transported — confirm relevant UN classes per industry |
| WHMIS / HPA / HPR | Universal — note transition ended December 14, 2025 |
| Fisheries Act s.35 | Relevant for logging and construction near watercourses |
| CEPA / Bill S-5 | Relevant for industrial operations with toxic substance exposure |
| Impact Assessment Act / SCC 2023 | Relevant for large projects in construction and logging |
| Duty to Consult / UNDRIP / Kebaowek 2025 | Relevant for all industries operating near Indigenous territories |
| GGPPA / Carbon Pricing | Relevant for large emitters — less applicable to trucking/construction |
| Bill C-59 Greenwashing | Relevant to all industries making environmental claims |

**Industry-specific federal entries to add:**
- Construction: Canada Labour Code (construction on federal property), National Building Code
- Logging: Migratory Birds Convention Act, Species at Risk Act, CPRA for crown timber
- Trucking: Motor Vehicle Transport Act, NSC Standards, HOS Regulations, ELD mandate, CVSA

---

## Delivery Format

For each industry, deliver:
1. **XLSX** — `Vaquero_[Industry]_Compliance_Matrix_v1.0.0.xlsx` (seed version)
2. **Markdown** — `REGULATORY_MATRIX_SEED_[INDUSTRY].md`

Both placed at:
```
C:\Projects\Vaquero_Safety_Inc\compliance\
```

Version as `v1.0.0-SEED`. Subsequent research passes increment to `v1.1.0`, `v1.2.0`, etc.

---

## Perplexity Verification Protocol

After the seed matrix is generated, the following items must go through a Perplexity verification pass before production use:

**Priority 1 — Regulatory structure (do first):**
- Confirm current legislation name + amendment date per province for THIS industry
- Identify industry-specific regulations (not just general OHS)
- Confirm correct CORA for THIS industry in each province

**Priority 2 — Registry URLs:**
- All trade licence verification URLs
- All apprenticeship board lookups
- Red Seal portability per trade

**Priority 3 — Industry-specific standards:**
- Training program names and renewal periods
- Any industry standard that may have changed post-2022

**Perplexity prompt structure (reuse for each batch):**
```
I need verified answers for [N] specific Canadian OHS credential or regulatory
items for the [INDUSTRY] industry. For each, provide: (a) the exact answer,
(b) the direct official URL, (c) the date the source was last updated.
Only answer from official government or regulatory body sources.

[LIST ITEMS 1-9 with province, field, and specific question]
```

---

## File Naming Convention

```
Vaquero_OilGas_Compliance_Matrix_v1.7.0.xlsx          ← Complete (current)
Vaquero_Construction_Compliance_Matrix_v1.0.0.xlsx    ← To build
Vaquero_Logging_Compliance_Matrix_v1.0.0.xlsx         ← To build
Vaquero_Trucking_Compliance_Matrix_v1.0.0.xlsx        ← To build
```

---

## Version History Reference

| Version | Milestone |
|---------|-----------|
| v1.0.0-SEED | Initial matrix — all jurisdictions populated, all VERIFY_REQUIRED flags set |
| v1.1.0+ | Each research pass closes/updates VERIFY_REQUIRED items |
| v1.7.0 | Production release — minimum Conf 2 standard, 0 open items (Oil & Gas) |

*Zero Guess Rule enforced throughout. Triple-Check Policy applied to every cell.*
*Compliance jurisdiction: PIPEDA/PIPA (Alberta) | Canada Central data residency.*
