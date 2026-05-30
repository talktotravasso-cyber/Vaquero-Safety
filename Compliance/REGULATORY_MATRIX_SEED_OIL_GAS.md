# Vaquero Safety Inc. — Canadian OHS Compliance Matrix
## Industry: Oil & Gas (Upstream, Midstream, Downstream, Well Servicing)
**Version:** 1.0.0-SEED  
**Status:** SEED DATA — Requires `firecrawl-sync.py` verification pass before production use  
**Placement:** `C:\Projects\Vaquero_Safety_Inc\compliance\REGULATORY_MATRIX_SEED_OIL_GAS.md`  
**Confidence Scale:** 1=Hypothetical | 2=Probable | 3=Verified  
**`[VERIFY_REQUIRED]`** = Must validate against live official source before any production use  

---

## CRITICAL OPERATING RULES

- `scripts/verify-compliance.py` MUST execute before any output involving COR, NCSO, or CRSP
- LLM scoring of safety credentials is **absolutely prohibited**
- Zero Guess Rule: all ambiguous cells flagged — do not remove flags without verified source
- 34 VERIFY_REQUIRED items identified — see Sheet D of companion XLSX for tracker

---

## SECTION A — PRIMARY REGULATORY AUTHORITY

### Oil & Gas — Applicable OHS Authority by Province/Territory

| Province | OHS Authority (Full Legal Name) | Enabling Legislation | Key Regulations | Official URL | Last Updated | Conf |
|----------|--------------------------------|---------------------|-----------------|--------------|--------------|------|
| **AB** | Alberta Occupational Health and Safety (OHS) — Alberta Labour and Immigration | Occupational Health and Safety Act, RSA 2000, c O-2 (amended 2018, Bill 30) | OHS Code (Alta Reg 87/2009, amended to 2023); OHS Regulation (Alta Reg 62/2003); OHS Act | https://www.alberta.ca/ohs-legislation-standards-guidelines | OHS Code last amended 2023 | 3 |
| **BC** | WorkSafeBC (Workers' Compensation Board of British Columbia) | Workers Compensation Act, RSBC 2019, c 1 | OHS Regulation (BC Reg 296/97, current to 2024); Petroleum Industry Regs embedded in OHS Reg Part 18 | https://www.worksafebc.com/en/law-policy/occupational-health-safety/searchable-ohs-regulation | Current to 2024 | 3 |
| **SK** | Saskatchewan OHS — Saskatchewan Labour Relations and Workplace Safety | The Occupational Health and Safety Regulations, 1996 (RRS c O-1.1 Reg 1) | OHS Regulations 1996; The Mines Regulations 2003; The Oil and Gas Conservation Act | https://www.saskatchewan.ca/business/safety-in-the-workplace/ohsregulations | `[VERIFY_REQUIRED — confirm 2024 amendment status]` | 2 |
| **MB** | Manitoba Workplace Safety and Health — Dept. of Labour, Consumer Protection and Government Services | The Workplace Safety and Health Act, CCSM c W210 | Workplace Safety and Health Regulation (MR 217/2006); general industry regulation applies (no dedicated O&G reg) | https://www.gov.mb.ca/labour/safety/legislation.html | `[VERIFY_REQUIRED]` | 2 |
| **ON** | Ontario Ministry of Labour, Immigration, Training and Skills Development (MLITSD) | Occupational Health and Safety Act, RSO 1990, c O.1 | Reg 851 (Industrial Establishments); O. Reg 213/91 (Construction); Note: limited upstream O&G in ON — federal facilities common | https://www.ontario.ca/laws/statute/90o01 | Reg 851 last amended 2023 | 3 |
| **QC** | Commission des normes, de l'équité, de la santé et de la sécurité du travail (CNESST) | Act Respecting Occupational Health and Safety, CQLR c S-2.1 | Regulation respecting OHS (LSST); Safety Code for the construction industry (S-2.1, r.4) | https://www.cnesst.gouv.qc.ca/fr/reglementation-et-legislation | `[VERIFY_REQUIRED — confirm 2024 amendments]` | 2 |
| **NB** | WorkSafeNB | Occupational Health and Safety Act, RSNB 2023, c 33 | General Regulation (NB Reg 91-191); Regulation 2012-71 (Confined Spaces) | https://www.worksafenb.ca/about-worksafenb/legislation-regulations/ | `[VERIFY_REQUIRED]` | 2 |
| **NS** | Nova Scotia Dept. of Labour, Skills and Immigration — OHS Division | Occupational Health and Safety Act, SNS 1996, c 7 | OHS General Regulations (NS Reg 44/97); CNSOPB co-jurisdiction for offshore | https://novascotia.ca/lae/healthandsafety/legislation.asp | `[VERIFY_REQUIRED — offshore overlay critical]` | 2 |
| **PEI** | Workers Compensation Board of PEI — OHS Division | Occupational Health and Safety Act, RSPEI 1988, c O-1.01 | General Regulations (EC606/88); Note: No active O&G industry in PEI | https://www.wcb.pe.ca/CategoryDetail/1019 | `[VERIFY_REQUIRED]` | 2 |
| **NL** | Service NL — OHS Branch; C-NLOPB for offshore | OHS Act, RSNL 1990, c O-3; NL Offshore Petroleum Installations Regulations | OHS Regulations (NLR 5/12); Diving Safety Regulations; C-NLOPB Safety Regulations | https://www.servicenl.gov.nl.ca/employers/occupational_health_and_safety/legislation.html | `[VERIFY_REQUIRED — offshore regs change frequently]` | 2 |
| **YT** | Yukon Workers' Compensation Health and Safety Board (YWCHSB) | Occupational Health and Safety Act, RSY 2002, c 159 | Occupational Health Regulations (OIC 1986/164) | https://wcb.yk.ca/Safety/OHS-Legislation.aspx | `[VERIFY_REQUIRED]` | 2 |
| **NT** | Workers' Safety and Compensation Commission (WSCC) — NT/NU | Safety Act, RSNWT 1988, c S-1 | General Safety Regulations (NWT); **COGOA (federal) dominant for O&G** | https://www.wscc.nt.ca/health-safety/legislation | `[VERIFY_REQUIRED — federal overlay dominant]` | 2 |
| **NU** | Workers' Safety and Compensation Commission (WSCC) — NT/NU (shared) | Safety Act, RSNWT (Nu) 1988, c S-1 (duplicated for Nunavut) | General Safety Regulations; **COGOA (federal) dominant** | https://www.wscc.nt.ca/health-safety/legislation | `[VERIFY_REQUIRED — federal overlay dominant]` | 2 |

---

## SECTION B — MANDATORY SAFETY CREDENTIALS & CERTIFICATIONS

> Legend: **L** = Legislated | **IS** = Industry Standard | **NP** = Nationally Portable | **PS** = Province-Specific

---

### ALBERTA (AB)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid + CPR Level C | St. John Ambulance / Red Cross / HSBC-approved | 3 years | NP | L — OHS Code Part 11, s.178 | Provider registry or wallet card | All workers | 3 |
| H2S Alive | Energy Safety Canada (formerly Enform) | 3 years | NP (industry standard) | IS — mandatory for all AB O&G sites | https://www.energysafetycanada.com | All O&G field workers | 3 |
| Fall Protection Training | Competent trainer per OHS Code | 3 years recommended / no legislated renewal | Province-specific training | L — OHS Code Part 9 | Employer records | Workers at height >3m | 3 |
| Confined Space Entry | Competent trainer | 3 years recommended | Concept portable; AB procedures required | L — OHS Code Part 5 | Employer records | Confined space workers | 3 |
| Ground Disturbance Level II | Energy Safety Canada | 3 years | AB; recognized across Western Canada | IS — AB O&G pipeline operations | Energy Safety Canada registry | Ground disturbance supervisors | 3 |
| WHMIS 2015 | Any approved WHMIS provider | Annual refresher recommended | NP | L — OHS Code Part 29; federal HPA | Employer training records | All workers handling hazardous products | 3 |
| TDG (Transportation of Dangerous Goods) | Transport Canada approved trainer | 3 years | Federal — NP | L — federal TDG Act and Regulations | Training certificates; employer records | Workers shipping/receiving DG | 3 |
| Aerial Work Platform (AWP / Scissor Lift) | CSA Z150 / manufacturer-certified trainer | 3 years recommended | Concept portable | IS — OHS Code Part 6 | Employer records | AWP/scissor lift operators | 3 |
| Crane Operator — Mobile (Certificate of Competency) | ABSA / AAMHOIST | 5 years | AB-issued; limited reciprocity BC/SK | L — Engineering and Geoscience Professions Act overlay; OHS Code Part 6 | `[VERIFY_REQUIRED — ABSA registry post-2023 restructuring]` | Mobile crane operators | 2 |
| Pressure Equipment Safety (Boiler/Pressure Vessel Operator) | ABSA (AB authorized inspection authority) | Annual fitness review | AB-issued; TSSA reciprocity partial | L — Safety Codes Act; Alta Reg 49/2006 | https://www.absa.ca | Pressure vessel/boiler operators | 3 |
| Power Engineer Certificate (1st–4th Class) | ABSA exam + Safety Codes Council | Every 5 years | AB-issued; significant national recognition | L — Safety Codes Act | ABSA registry | Plant operators (upgraders, gas plants) | 3 |
| Journeyman Electrician | Alberta Apprenticeship and Industry Training (AIT) | None (licence renewal varies) | Red Seal NP | L — Electrical Utilities Act; Safety Codes Act | https://tradesecrets.alberta.ca | Electricians on O&G sites | 3 |
| Journeyman Pipefitter / Gas Fitter | Alberta AIT | Gas fitter licence annual renewal | Red Seal pipefitter NP; AB gas fitter PS | L — Gas Utilities Act | `[VERIFY_REQUIRED — AIT/ABSA gas contractor registry]` | Pipefitters, gas fitters | 3 |
| COR (Certificate of Recognition) | ACSA or Energy Safety Canada (O&G) | 3-year audit cycle; annual maintenance | AB-issued; recognized nationally; required for many O&G prime contractor bids | IS — effectively mandatory for prime contractors | https://www.acsa-safety.org / https://www.energysafetycanada.com | Employers (prime contractors) | 3 |
| NCSO (National Construction Safety Officer) | CSSE via NAOSH | Annual PD requirement | National | IS (not legislated) | `[VERIFY_REQUIRED — confirm CSSE registry URL]` | Safety officers/supervisors | 2 |
| CRSP (Canadian Registered Safety Professional) | BCRSP | 5-year recertification | National | IS — senior safety designation | https://www.bcrsp.ca | Senior safety professionals | 3 |
| Well Servicing — Rig Technician Certification | Petroleum Industry Training Service (PITS) | Varies by level | AB-issued; recognized in SK | IS — well servicing operations | `[VERIFY_REQUIRED — PITS certification status post-2022]` | Well servicing rig workers | 2 |
| H2S Awareness (online) | Energy Safety Canada or approved provider | 3 years | NP | IS — lower-risk O&G sites | Provider records | All site visitors / low-exposure workers | 3 |

---

### BRITISH COLUMBIA (BC)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid + CPR Level C | WorkSafeBC-approved provider | 3 years | NP | L — OHS Reg Part 3 | Provider certificate | All workers | 3 |
| H2S Alive | Energy Safety Canada | 3 years | NP | IS — required for NE BC O&G operations | Energy Safety Canada registry | All O&G field workers in NE BC | 3 |
| Fall Protection Training | WorkSafeBC-approved trainer | No fixed renewal (competency-based) | BC-specific; concept portable | L — OHS Reg Part 11 | Employer records | Workers at height >3m | 3 |
| Confined Space Entry | WorkSafeBC-approved trainer | No fixed legislated renewal | BC-specific procedures; concept portable | L — OHS Reg Part 9 | Employer records | Confined space workers | 3 |
| Ground Disturbance | BC One Call aligned training | Recommended 3 years | BC O&G standard | IS | Employer records | Ground disturbance workers | 2 |
| WHMIS 2015 | Any approved provider | Annual recommended | NP | L — OHS Reg Part 5.3 | Employer records | All workers | 3 |
| Crane Operator — Mobile (BC Certificate of Qualification) | Technical Safety BC (TSBC) | 5 years | BC-issued; limited reciprocity | L — Safety Standards Act; BC Reg 209/2003 | https://www.technicalsafetybc.ca | Crane operators | 3 |
| Electrician — Journey-level | BC Industry Training Authority (ITA) + TSBC licence | Annual licence via TSBC | Red Seal NP | L — Safety Standards Act; Electrical Safety Regulation | TSBC / ITA registry | Electricians | 3 |
| Gas Fitter — Class A/B | Technical Safety BC | Annual licence renewal | BC-issued; NOT portable to AB without reciprocity application | L — Gas Safety Regulation BC Reg 103/2004 | https://www.technicalsafetybc.ca | Gas fitters | 3 |
| Power Engineer — 1st–4th Class | BCIT exam; TSBC oversight | Annual licence | BC-issued; recognized in AB/SK with application | L — Power Engineers, Boiler, Pressure Vessel and Refrigeration Safety Regulation | TSBC registry | Plant operators | 3 |
| COR | `[VERIFY_REQUIRED — O&G-specific CORA in BC]` | 3-year audit cycle | BC-issued; national recognition | IS — required for many public sector bids | `[VERIFY_REQUIRED — BCCSA vs O&G sector COR issuer]` | Employers | 2 |
| TDG | TC-approved trainer | 3 years | Federal | L — federal | Training records | DG handlers | 3 |

---

### SASKATCHEWAN (SK)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid + CPR Level C | SK-approved provider | 3 years | NP | L — OHS Regs 1996, Part III | Provider certificate | All workers | 3 |
| H2S Alive | Energy Safety Canada | 3 years | NP | IS — mandatory for SK O&G | Energy Safety Canada registry | All O&G field workers | 3 |
| Fall Protection | Competent trainer | No fixed renewal | Concept portable | L — OHS Regs 1996, Part X | Employer records | Workers at height | 3 |
| Confined Space | Competent trainer | No fixed renewal | Concept portable | L — OHS Regs 1996 | Employer records | Confined space workers | 3 |
| Ground Disturbance | Energy Safety Canada or Sask First Call aligned | 3 years | SK/AB recognized | IS | Employer records | Ground disturbance supervisors | 2 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | Employer records | All workers | 3 |
| Journeyman Electrician | Saskatchewan Apprenticeship and Trade Certification Commission (SATCC) | Annual licence renewal | Red Seal portable | L | `[VERIFY_REQUIRED — confirm SATCC registry URL]` | Electricians | 2 |
| Power Engineer | SATCC / equivalent body | Annual licence | SK-issued; recognized with application in AB/MB | L — The Boiler and Pressure Vessel Act, 1999 | `[VERIFY_REQUIRED — confirm current issuing body post-2020 reorg]` | Plant operators | 2 |
| COR | Saskatchewan Construction Safety Association (SCSA) | 3-year audit cycle | SK-issued; nationally recognized | IS — required for many SK O&G client bids | https://www.scsaonline.ca | Employers | 3 |
| TDG | TC-approved trainer | 3 years | Federal | L — federal | Training records | DG handlers | 3 |

---

### MANITOBA (MB)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid | MB WSHS-recognized provider | 3 years | NP | L — WSH Reg, Part 8 | Provider certificate | All workers | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | Employer records | All workers | 3 |
| Fall Protection | Competent trainer | No fixed renewal | Concept portable | L — WSH Reg | Employer records | Workers at height | 3 |
| Confined Space | Competent trainer | No fixed renewal | Concept portable | L — WSH Reg Part 14 | Employer records | CS workers | 3 |
| H2S Alive | Energy Safety Canada | 3 years | NP | IS — MB O&G (Williston Basin) | Energy Safety Canada registry | O&G field workers | 2 |
| COR | Manitoba Heavy Construction Association (MHCA) SafetyFirst | 3-year audit cycle | MB-issued; nationally recognized | IS | `[VERIFY_REQUIRED — MHCA registry URL]` | Employers | 2 |
| Journeyman Electrician | Apprenticeship Manitoba | Annual licence | Red Seal portable | L | `[VERIFY_REQUIRED — MB registry URL]` | Electricians | 2 |
| TDG | TC-approved trainer | 3 years | Federal | L — federal | Training records | DG handlers | 3 |

---

### ONTARIO (ON)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid + CPR Level C | Workplace Emergency Response / Red Cross / Heart & Stroke-approved | 3 years | NP | L — Reg 1101; Industrial Reg 851 | Provider certificate | All workers | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L — OHSA + WHMIS Reg | Employer records | All workers | 3 |
| Fall Protection (Working at Heights) | MOL-approved provider | 3 years | ON-specific approval; content portable | L — O. Reg 213/91 (Construction); Reg 851 (Industrial) | MOL-approved provider records | All workers at height (construction 3m+; industrial 2.4m+) | 3 |
| Confined Space Entry | Competent trainer (OHSA definition) | No fixed renewal | Concept portable | L — O. Reg 632/05 Confined Spaces | Employer records | CS workers | 3 |
| Electrician (309A/442A) | Skilled Trades Ontario (STO) | Annual licence via ESA | Red Seal portable; ESA licence ON-specific | L — Electricity Act 1998; Ontario Electrical Safety Code | https://www.skilledtradesontario.ca | Electricians | 3 |
| Gas Technician (G1/G2/G3) | Technical Standards and Safety Authority (TSSA) | Annual renewal (G1/G2) | ON-issued; NOT portable to AB without reciprocity `[VERIFY_REQUIRED]` | L — Technical Standards and Safety Act 2000 | https://www.tssa.org | Gas fitters/technicians | 3 |
| Crane Operator — Mobile (310T) | Skilled Trades Ontario | Certificate of Qualification — no expiry; on-site competency required | Red Seal portable | L — Skilled Trades and Apprenticeship Act; O. Reg 213/91 | https://www.skilledtradesontario.ca | Crane operators | 3 |
| Power Engineer | TSSA | Annual licence | ON-issued; national recognition with application | L — TSSA; Operating Engineers Act | https://www.tssa.org | Plant operators | 3 |
| TDG | TC-approved trainer | 3 years | Federal | L — federal | Training records | DG handlers | 3 |
| COR | Infrastructure Health & Safety Association (IHSA) | 3-year audit cycle | ON-issued; nationally recognized | IS — required for many ON O&G/energy bids | https://www.ihsa.ca | Employers | 3 |
| NCSO | CSSE | Annual PD | National | IS | `[VERIFY_REQUIRED — confirm CSSE registry URL]` | Safety officers | 2 |

---

### QUEBEC (QC)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid (Secourisme en milieu de travail) | CNESST-approved provider | 3 years | QC-approved list; national providers vary | L — LSST; First Aid Regulation RRQ c S-2.1, r.3 | Provider certificate | All workers | 3 |
| WHMIS 2015 (SIMDUT 2015) | Approved provider | Annual recommended | NP | L — federal HPA + QC SIMDUT Reg | Employer records | All workers | 3 |
| Fall Protection | Competent trainer (CNESST standards) | No fixed renewal | Concept portable | L — RSST; Construction Safety Code s.2.9 | Employer records | Workers at height | 3 |
| Confined Space | Competent trainer | No fixed renewal | Concept portable | L — RSST Part II, s.300+ | Employer records | CS workers | 3 |
| Journeyman Electrician (Compagnon électricien — 5310) | Commission de la construction du Québec (CCQ) | CCQ card annual renewal | QC CCQ card NOT portable without requalification `[VERIFY_REQUIRED]` | L — Electrical Installations Act; CCQ Act | https://www.ccq.org | Electricians (construction industry) | 3 |
| Master Electrician (Maître électricien) | Régie du bâtiment du Québec (RBQ) | Annual licence | QC-issued; not portable | L — An Act respecting building; RBQ | https://www.rbq.gouv.qc.ca | Electrical contractors | 3 |
| Gas Installation (Installateur de gaz) | Régie du bâtiment du Québec (RBQ) | Annual licence | QC-issued; not portable | L — Gas Safety Code; RBQ | https://www.rbq.gouv.qc.ca | Gas fitters | 3 |
| TDG / TMD | TC-approved trainer (bilingual required for QC) | 3 years | Federal (bilingual in QC) | L — federal TMD Act | Training records | DG handlers | 3 |
| COR Equivalent (ASP — Mutuelles de prévention) | ASP Construction / CNESST sector associations | Annual | QC-specific; differs from ROC COR model | L — LSST sector prevention associations; `[VERIFY_REQUIRED — ASP vs COR equivalency mapping]` | ASP/CNESST records | Employers in construction/industrial sector | 2 |

---

### NEW BRUNSWICK (NB)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid | WorkSafeNB-approved provider | 3 years | NP | L — NB OHS Act; General Reg 91-191 | Provider certificate | All workers | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | Employer records | All workers | 3 |
| Fall Protection | Competent trainer | No fixed renewal | Concept portable | L — General Reg s.51+ | Employer records | Workers at height | 3 |
| Confined Space | Competent trainer | No fixed renewal | Concept portable | L — NB Reg 2012-71 | Employer records | CS workers | 3 |
| Journeyman Electrician | NB Apprenticeship and Occupational Certification (NBAOC) | Annual licence | Red Seal portable | L — Electrical Installation and Inspection Act | `[VERIFY_REQUIRED — NBAOC registry URL]` | Electricians | 2 |
| TDG | TC-approved trainer | 3 years | Federal | L — federal | Training records | DG handlers | 3 |
| COR | `[VERIFY_REQUIRED — NBCSA/WSNB COR issuance post-2023 reorg]` | 3-year audit cycle | NB-issued; nationally recognized | IS | `[VERIFY_REQUIRED]` | Employers | 2 |

---

### NOVA SCOTIA (NS)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid | NS OHS-approved provider | 3 years | NP | L — OHS Act; General Regs 44/97 s.30+ | Provider certificate | All workers | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | Employer records | All workers | 3 |
| Fall Protection | Competent trainer | No fixed renewal | Concept portable | L — OHS General Regs | Employer records | Workers at height | 3 |
| Confined Space | Competent trainer | No fixed renewal | Concept portable | L — OHS General Regs | Employer records | CS workers | 3 |
| Journeyman Electrician | Nova Scotia Apprenticeship Agency (NSAA) | Annual licence | Red Seal portable | L — Electrical Installation and Inspection Act SNS 1994-95, c 8 | `[VERIFY_REQUIRED — NSAA registry URL]` | Electricians | 2 |
| Offshore O&G — CNSOPB Safety Regs (HUET + BOSIET + OPITO certifications) | Canada-Nova Scotia Offshore Petroleum Board (CNSOPB) / OPITO-approved centres | 4 years (HUET); BOSIET varies | OPITO internationally recognized | L — Canada-Nova Scotia Offshore Petroleum Resources Accord Implementation Act; `[VERIFY_REQUIRED — current regs version]` | https://www.cnsopb.ns.ca | Offshore workers | 2 |
| TDG | TC-approved trainer | 3 years | Federal | L | Training records | DG handlers | 3 |
| COR | `[VERIFY_REQUIRED — CANS COR issuance status]` | 3-year audit cycle | NS-issued; nationally recognized | IS | `[VERIFY_REQUIRED]` | Employers | 2 |

---

### PRINCE EDWARD ISLAND (PEI)

> **Note:** No active oil and gas industry in PEI. Matrix entry retained for completeness. Core credentials (First Aid, WHMIS, TDG) apply to any O&G contractors working in PEI.

| Credential | Issuing Body | Renewal | Portability | L / IS | Conf |
|-----------|-------------|---------|-------------|--------|------|
| Standard First Aid | WCB PEI-approved provider | 3 years | NP | L | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | 3 |
| TDG | TC-approved trainer | 3 years | Federal | L | 3 |

---

### NEWFOUNDLAND & LABRADOR (NL)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid | NL OHS-approved provider | 3 years | NP | L — OHS Act NL; NLR 5/12 | Provider certificate | All workers | 3 |
| H2S Alive | Energy Safety Canada | 3 years | NP | IS — required for offshore and onshore NL O&G | Energy Safety Canada registry | O&G workers | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | Employer records | All workers | 3 |
| Fall Protection | Competent trainer | No fixed renewal | Concept portable | L — OHS Regs NL | Employer records | Workers at height | 3 |
| Confined Space | Competent trainer | No fixed renewal | Concept portable | L — OHS Regs NL | Employer records | CS workers | 3 |
| Offshore Survival Training (HUET + BOSIET) | Survival Systems / Falck Safety Services (OPITO-certified) | 4 years (HUET); BOSIET varies | OPITO — internationally recognized | L — C-NLOPB Reg; OPITO standard | OPITO registry / employer records | Offshore workers (Hibernia, Terra Nova, etc.) | 3 |
| Journeyman Electrician | NL Apprenticeship and Trades Certification Division (ATC) | Annual licence | Red Seal portable | L | `[VERIFY_REQUIRED — NL ATC registry URL]` | Electricians | 2 |
| TDG | TC-approved trainer | 3 years | Federal | L | Training records | DG handlers | 3 |
| COR | `[VERIFY_REQUIRED — NLCA COR program status]` | 3-year audit cycle | NL-issued; nationally recognized | IS | `[VERIFY_REQUIRED]` | Employers | 2 |

---

### YUKON (YT)

> **Note:** Minimal O&G activity — federal jurisdiction (COGOA) dominant. Core credentials apply.

| Credential | Issuing Body | Renewal | Portability | L / IS | Conf |
|-----------|-------------|---------|-------------|--------|------|
| Standard First Aid | YWCHSB-recognized provider | 3 years | NP | L — OHS Act YT | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | 3 |
| Fall Protection | Competent trainer | No fixed renewal | Concept portable | L | 3 |
| Confined Space | Competent trainer | No fixed renewal | Concept portable | L | 3 |
| TDG | TC-approved trainer | 3 years | Federal | L | 3 |

---

### NORTHWEST TERRITORIES (NT)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid | WSCC-recognized provider | 3 years | NP | L — Safety Act NT | Provider certificate | All workers | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | Employer records | All workers | 3 |
| H2S Alive | Energy Safety Canada | 3 years | NP | IS — required for NT O&G (Mackenzie Valley area) | Energy Safety Canada registry | O&G workers | 2 |
| TDG | TC-approved trainer | 3 years | Federal | L | Training records | DG handlers | 3 |
| Cold Weather / Arctic Safety Training | `[VERIFY_REQUIRED — no national standard]` | No fixed renewal | NT/NU specific | IS — remote Arctic operations | `[VERIFY_REQUIRED — no centralized registry]` | All remote workers | 2 |
| **⚠ COGOA (federal)** applies to most NT O&G operations — see Section C | Federal — CER | Per installation | Federal | L — COGOA | CER | All NT O&G operators | 3 |

---

### NUNAVUT (NU)

| Credential | Issuing Body | Renewal | Portability | L / IS | Verification | Applies To | Conf |
|-----------|-------------|---------|-------------|--------|-------------|------------|------|
| Standard First Aid | WSCC-recognized provider | 3 years | NP | L — Safety Act NU | Provider certificate | All workers | 3 |
| WHMIS 2015 | Approved provider | Annual recommended | NP | L | Employer records | All workers | 3 |
| TDG | TC-approved trainer | 3 years | Federal | L | Training records | DG handlers | 3 |
| Cold Weather / Arctic Safety Training | `[VERIFY_REQUIRED]` | No standard | NU specific | IS | `[VERIFY_REQUIRED]` | All remote workers | 2 |
| **⚠ COGOA (federal)** dominant jurisdiction for O&G in Nunavut | Federal — CER | Per installation | Federal | L — COGOA | CER | All NU O&G operators | 3 |

---

## SECTION C — FEDERAL REGULATORY OVERLAY

| Jurisdiction Scope | Federal Body | Jurisdiction Trigger | Applicable Federal Legislation | Operational Notes | Conf |
|-------------------|-------------|---------------------|-------------------------------|-------------------|------|
| **ALL provinces** | Canada Labour Code Part II (CLC Part II) | Workers employed by federally regulated undertakings: interprovincial pipelines, federal Crown corps, banks, telecom | Canada Labour Code, RSC 1985, c L-2; Canada OHS Regulations (SOR/86-304); Oil and Gas OHS Regulations (SOR/87-612) | Employees of TC Energy, Enbridge (interprovincial pipeline segments) = CLC Part II, NOT provincial OHS. Provincially regulated = field/well site workers for exploration/production companies incorporated provincially. | 3 |
| **ALL provinces** | Canada Energy Regulator (CER) — formerly NEB | Federally regulated pipelines and related facilities crossing provincial/international borders | Canadian Energy Regulator Act, SC 2019, c 28; Onshore Pipeline Regulations (SOR/99-294); Processing Plant Regulation (SOR/2014-139); CER OHS Regulations (SOR/2020-65) | CER jurisdiction: interprovincial and international pipelines, associated facilities. Safety management system requirements under OPR and CER OHS Regs. Workers on CER-regulated assets = federal OHS, not provincial. https://www.cer-rec.gc.ca | 3 |
| **NT / NU / Offshore frontier** | Canada Oil and Gas Operations Act (COGOA) | O&G exploration and production in Canada Lands (NT, NU, offshore frontier areas) | Canada Oil and Gas Operations Act, RSC 1985, c O-7; Canada Oil and Gas Drilling and Production Regulations (SOR/2009-315) | COGOA governs all O&G operations in Canada Lands. Provincial OHS largely displaced. Regulator: CER. Operators must submit safety plans under COGOA. | 3 |
| **NL offshore / NS offshore** | C-NLOPB + CNSOPB (co-managed federal-provincial boards) | Offshore O&G installations in NL and NS offshore areas | Canada-Newfoundland and Labrador Atlantic Accord Implementation Act, SC 1987, c 3; Canada-Nova Scotia Offshore Petroleum Resources Accord Implementation Act, SC 1988, c 28; Offshore Area OHS Regulations (SOR/2020-148) | OPITO offshore survival training mandatory. Diving operations under Canada Shipping Act. C-NLOPB: https://www.cnlopb.ca; CNSOPB: https://www.cnsopb.ns.ca | 3 |
| **ALL provinces** | Transport Canada — TDG | Transport of dangerous goods by road, rail, air, marine | Transportation of Dangerous Goods Act, 1992, SC 1992, c 34; TDG Regulations (SOR/2001-286) including 2023 amendments | Federal — applies in all provinces. Supersedes provincial WHMIS for transport context. Shipper and carrier both liable. TDG training certificate: 3-year renewal. https://tc.canada.ca/en/dangerous-goods | 3 |
| **ALL provinces** | Transport Canada — CMV Safety (CVSA / NSC) | Interprovincial trucking carrying O&G equipment, fluids, proppants; hazmat transport | Motor Vehicle Transport Act, RSC 1985, c 29 (3rd Supp); National Safety Code (NSC) Standards 1-16; Commercial Vehicle Drivers Hours of Service Regulations (SOR/2005-313) | Interprovincial carrier safety fitness certificates issued federally. CVSA roadside inspections federal standard. Hours of Service (HOS): federal ELD mandate since January 2023 for interprovincial carriers. https://tc.canada.ca/en/road-transportation/motor-carrier-program | 3 |
| **ALL provinces** | Health Canada — WHMIS (Hazardous Products Act) | Hazardous products in all workplaces | Hazardous Products Act, RSC 1985, c H-3 (amended 2015); Hazardous Products Regulations (SOR/2015-17) | Federal legislation sets WHMIS classification and SDS requirements. Provinces implement workplace training requirements via provincial OHS legislation. National alignment complete as of 2018. | 3 |
| **ALL provinces** | Environment and Climate Change Canada — CEPA (Environmental overlay) | Release of toxic substances; GHG reporting for O&G operators >10,000 tCO2e/year | Canadian Environmental Protection Act, 1999, SC 1999, c 33; Greenhouse Gas Reporting Program (GHGRP) | Not OHS legislation but operationally relevant: spill reporting, emissions monitoring, regulatory overlap with provincial environmental acts. Note: not a safety credential but triggers operational compliance requirements. | 3 |
| **AB / BC / SK** | CER — Onshore Pipeline Regulations (OPR) | Pipelines under federal CER jurisdiction operating in AB, BC, SK | Onshore Pipeline Regulations, SOR/99-294; CER OHS Regulations SOR/2020-65 | TC Energy, Enbridge, Trans Mountain operating interprovincial pipelines in AB/BC/SK: CER OHS Regs apply, not provincial OHS Codes, for pipeline operations. Field construction crews may still fall under provincial OHS depending on contractor relationship. `[VERIFY_REQUIRED — CER vs provincial boundary for contract workers]` | 2 |

---

## VERIFY_REQUIRED SUMMARY — 34 Open Items

See Sheet D of companion XLSX `Vaquero_OilGas_Compliance_Matrix_v1.0.0.xlsx` for full tracker with assignment fields.

### High Priority (regulatory structure uncertainty)
1. SK — OHS Regulation 2024 amendment status
2. SK — Power Engineer issuing body post-2020 reorganization
3. NS — Offshore CNSOPB safety regulation current version
4. NL — C-NLOPB offshore regulation current version
5. NT/NU — COGOA/CER vs provincial OHS boundary for contract workers
6. AB — ABSA crane operator registry post-2023 restructuring
7. BC — O&G-specific CORA identification for COR issuance in BC
8. QC — ASP vs COR equivalency mapping for ROC recognition

### Medium Priority (registry URL verification)
9. SK — SATCC electrician registry URL
10. MB — MHCA SafetyFirst COR registry URL
11. MB — Apprenticeship Manitoba electrician registry URL
12. NB — NBAOC electrician registry URL
13. NB — NBCSA/WSNB COR program post-2023 reorganization
14. NS — NSAA electrician registry URL
15. NS — CANS COR issuance status
16. NL — ATC electrician registry URL
17. NL — NLCA COR program current status
18. ON — TSSA→ABSA gas technician reciprocity confirmation
19. ON — CSSE NCSO registry URL confirmation

### Low Priority (industry standard validation)
20–34. Various: PITS well servicing cert status; Arctic safety training standard confirmation; Ground disturbance standards for MB/SK/BC; Cold weather training registries for NT/NU

---

## NEXT STEPS — EXECUTION SEQUENCE

```
1. This file → compliance/REGULATORY_MATRIX_SEED_OIL_GAS.md  [DONE]
2. Companion XLSX → compliance/Vaquero_OilGas_Compliance_Matrix_v1.0.0.xlsx  [DONE]
3. Run scripts/firecrawl-sync.py → resolves all 34 VERIFY_REQUIRED items
4. Human review pass → sign off on all Confidence 2 entries
5. scripts/verify-compliance.py → gate all COR/NCSO/CRSP outputs
6. Load to Supabase → import script against supabase-vaquero MCP
7. Schedule quarterly re-verification → compliance/COMPLIANCE.md maintenance schedule
8. Repeat for Construction, Forestry, Commercial Trucking industries
```

---

*All infrastructure details anonymized per `compliance/COMPLIANCE.md §7`. No real server names, IPs, or credentials appear in this document.*  
*Confidence ratings applied per `.claude/rules/global.md` Triple-Check Policy.*
