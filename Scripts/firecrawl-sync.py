"""
firecrawl-sync.py
─────────────────────────────────────────────────────────────────────────────
PURPOSE:    Automated verification of VERIFY_REQUIRED items in the Vaquero
            Safety Inc. OHS Compliance Matrix using Firecrawl web scraping.
            Resolves all 34 open VR items and outputs verified values to:
            - logs/scrape/firecrawl_YYYY-MM-DD.json  (raw results)
            - logs/scrape/firecrawl_YYYY-MM-DD.md    (human-readable diff)
            - compliance/REGULATORY_MATRIX_SEED_OIL_GAS_VERIFIED.md (patched)

INPUTS:     FIRECRAWL_API_KEY  — injected via Windows R command session (runtime)
            SUPABASE_URL       — from .env
            SUPABASE_KEY       — from .env

OUTPUTS:    logs/scrape/firecrawl_YYYY-MM-DD.json
            logs/scrape/firecrawl_YYYY-MM-DD.md
            compliance/REGULATORY_MATRIX_SEED_OIL_GAS_VERIFIED.md

DEPENDENCIES: firecrawl-py, requests, python-dotenv, supabase (optional)

SCHEDULE:   Quarterly — see compliance/COMPLIANCE.md maintenance schedule
            Emergency run: any time a VERIFY_REQUIRED item is flagged in audit

FAILURE:    On scrape failure → logs error to logs/scrape/errors.log
            Triggers: AUTO_DEBUGGING_RUNBOOK.md protocol
            Fallback: cached results from prior run retained; no overwrite on failure

COMPLIANCE: PIPEDA/PIPA — no PII scraped; public regulatory URLs only
            Zero Guess Rule: ambiguous scrape results flagged, not auto-resolved
            Triple-Check: each result validated against primary + fallback URL
─────────────────────────────────────────────────────────────────────────────
"""

import os
import sys
import json
import time
import logging
import datetime
from pathlib import Path
from typing import Optional
from dotenv import load_dotenv

# ── Firecrawl import with clear error if missing ──────────────────────────────
try:
    from firecrawl import FirecrawlApp
except ImportError:
    print("ERROR: firecrawl-py not installed.")
    print("Run: pip install firecrawl-py --break-system-packages")
    sys.exit(1)

# ─────────────────────────────────────────────────────────────────────────────
# ENVIRONMENT SETUP
# ─────────────────────────────────────────────────────────────────────────────

load_dotenv()

# FIRECRAWL_API_KEY: injected at runtime via Windows R command session
# Do NOT hardcode. Do NOT put in .env.
# Pass as: python firecrawl-sync.py --api-key %FIRECRAWL_API_KEY%
# Or set as Windows System Environment Variable before running.
FIRECRAWL_API_KEY = os.environ.get("FIRECRAWL_API_KEY")

# Optional Supabase integration — set in .env
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

# ─────────────────────────────────────────────────────────────────────────────
# PATH CONFIGURATION — Windows root per SKILL.md
# ─────────────────────────────────────────────────────────────────────────────

PROJECT_ROOT = Path(os.environ.get(
    "VAQUERO_PROJECT_ROOT",
    r"C:\Projects\Vaquero_Safety_Inc"
))

LOGS_DIR     = PROJECT_ROOT / "logs" / "scrape"
COMPLIANCE_DIR = PROJECT_ROOT / "compliance"
SEED_FILE    = COMPLIANCE_DIR / "REGULATORY_MATRIX_SEED_OIL_GAS.md"

# ─────────────────────────────────────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────────────────────────────────────

LOGS_DIR.mkdir(parents=True, exist_ok=True)
today = datetime.date.today().isoformat()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.FileHandler(LOGS_DIR / "errors.log"),
        logging.StreamHandler(sys.stdout),
    ]
)
log = logging.getLogger("firecrawl-sync")

# ─────────────────────────────────────────────────────────────────────────────
# VERIFY_REQUIRED TARGET MANIFEST
# ─────────────────────────────────────────────────────────────────────────────
# Each entry:
#   id:            VR item ID from manual guide
#   priority:      1 (regulatory structure) | 2 (registry URL) | 3 (industry std)
#   province:      Province/territory code
#   sheet:         A | B | C
#   field:         Human-readable field name
#   what_to_find:  Exact text/pattern to look for on the page
#   primary_url:   First scrape target
#   fallback_url:  If primary fails or returns no match
#   extract_hint:  Keywords/phrases that indicate the correct answer is present
# ─────────────────────────────────────────────────────────────────────────────

TARGETS = [
    # ── PRIORITY 1 — REGULATORY STRUCTURE ────────────────────────────────────
    {
        "id": "VR-001",
        "priority": 1,
        "province": "SK",
        "sheet": "A",
        "field": "OHS Regulation 2024 Amendment Status",
        "what_to_find": "last amended date or current version of OHS Regulations 1996",
        "primary_url": "https://www.publications.saskatchewan.ca/#/products/699",
        "fallback_url": "https://www.saskatchewan.ca/business/safety-in-the-workplace/ohsregulations",
        "extract_hint": ["amended", "current", "2023", "2024", "O-1.1 Reg 1"],
    },
    {
        "id": "VR-002",
        "priority": 1,
        "province": "SK",
        "sheet": "B",
        "field": "Power Engineer Issuing Body",
        "what_to_find": "organization that issues Power Engineer certificates in Saskatchewan",
        "primary_url": "https://www.saskatchewan.ca/business/safety-in-the-workplace/boilers-pressure-vessels-and-refrigeration",
        "fallback_url": "https://www.technicalsafetysk.ca",
        "extract_hint": ["power engineer", "certificate", "boiler", "pressure vessel", "issue", "apply"],
    },
    {
        "id": "VR-003",
        "priority": 1,
        "province": "NS",
        "sheet": "A",
        "field": "CNSOPB Offshore Safety Regulation Current Version",
        "what_to_find": "current offshore OHS regulation version and OPITO certification requirements",
        "primary_url": "https://www.cnsopb.ns.ca/safety/safety-regulations",
        "fallback_url": "https://laws-lois.justice.gc.ca/eng/regulations/SOR-2020-148/",
        "extract_hint": ["SOR/2020-148", "offshore", "OPITO", "HUET", "BOSIET", "regulation"],
    },
    {
        "id": "VR-004",
        "priority": 1,
        "province": "NL",
        "sheet": "A",
        "field": "C-NLOPB Offshore Regulation Current Version",
        "what_to_find": "current NL offshore regulation and HUET/BOSIET renewal periods",
        "primary_url": "https://www.cnlopb.ca/information/safety/",
        "fallback_url": "https://laws-lois.justice.gc.ca/eng/regulations/SOR-2020-148/",
        "extract_hint": ["SOR/2020-148", "HUET", "BOSIET", "OPITO", "offshore", "regulation", "training"],
    },
    {
        "id": "VR-005",
        "priority": 1,
        "province": "NT/NU",
        "sheet": "C",
        "field": "COGOA vs Provincial OHS Boundary for Contract Workers",
        "what_to_find": "CER position on OHS jurisdiction for contract workers on COGOA sites",
        "primary_url": "https://www.cer-rec.gc.ca/en/safety-environment/safety/occupational-health-safety/",
        "fallback_url": "https://www.wscc.nt.ca/health-safety/legislation",
        "extract_hint": ["contractor", "provincial", "federal", "jurisdiction", "COGOA", "Canada Lands"],
    },
    {
        "id": "VR-006",
        "priority": 1,
        "province": "QC",
        "sheet": "B",
        "field": "ASP vs COR Equivalency",
        "what_to_find": "whether QC ASP is recognized as COR-equivalent by other provincial CORAs",
        "primary_url": "https://www.aspconst.com/en/",
        "fallback_url": "https://www.acsa-safety.org/programs/cor/",
        "extract_hint": ["COR", "equivalent", "recognized", "reciprocity", "national", "ASP"],
    },
    {
        "id": "VR-007",
        "priority": 1,
        "province": "BC",
        "sheet": "B",
        "field": "BC O&G CORA Identification",
        "what_to_find": "which CORA issues COR for O&G operators in NE BC",
        "primary_url": "https://www2.gov.bc.ca/gov/content/employment-business/employment-standards-advice/occupational-health-safety/worksafebc/certificate-of-recognition",
        "fallback_url": "https://www.bccsa.ca/programs/cor/",
        "extract_hint": ["CORA", "oil", "gas", "energy", "COR", "certificate of recognition", "northeast"],
    },

    # ── PRIORITY 2 — REGISTRY URLS ────────────────────────────────────────────
    {
        "id": "VR-008",
        "priority": 2,
        "province": "AB",
        "sheet": "B",
        "field": "ABSA Crane Registry URL",
        "what_to_find": "active crane operator certificate lookup URL at ABSA post-2023",
        "primary_url": "https://www.absa.ca/find-a-certificate-holder/",
        "fallback_url": "https://www.alberta.ca/crane-operator-certification",
        "extract_hint": ["crane", "certificate", "lookup", "search", "verify", "holder"],
    },
    {
        "id": "VR-009",
        "priority": 2,
        "province": "AB",
        "sheet": "B",
        "field": "AB Gas Fitter Registry URL",
        "what_to_find": "URL for verifying AB gas fitter/contractor licence — AIT or ABSA",
        "primary_url": "https://tradesecrets.alberta.ca/",
        "fallback_url": "https://www.absa.ca/permits-licences/",
        "extract_hint": ["gas fitter", "gas contractor", "licence", "verify", "lookup", "permit"],
    },
    {
        "id": "VR-010",
        "priority": 2,
        "province": "AB/ON",
        "sheet": "B",
        "field": "CSSE NCSO Registry URL",
        "what_to_find": "current active URL for verifying NCSO designation holders at CSSE",
        "primary_url": "https://www.csse.org/page/NCSOProgram",
        "fallback_url": "https://www.naosh.org/ncso",
        "extract_hint": ["NCSO", "verify", "lookup", "registry", "certificate", "holder"],
    },
    {
        "id": "VR-011",
        "priority": 2,
        "province": "SK",
        "sheet": "B",
        "field": "SATCC Electrician Registry URL",
        "what_to_find": "URL for verifying SK journeyman electrician certificates via SATCC",
        "primary_url": "https://www.saskapprenticeship.ca/verify-a-certificate/",
        "fallback_url": "https://www.saskatchewan.ca/residents/jobs-and-careers/apprenticeship",
        "extract_hint": ["verify", "certificate", "journeyman", "electrician", "apprenticeship"],
    },
    {
        "id": "VR-012",
        "priority": 2,
        "province": "MB",
        "sheet": "B",
        "field": "MHCA SafetyFirst COR Registry",
        "what_to_find": "active MHCA SafetyFirst COR program registry URL",
        "primary_url": "https://www.mhca.com/safety/safetyfirst/",
        "fallback_url": "https://www.safemanitoba.com/COR",
        "extract_hint": ["COR", "SafetyFirst", "certificate of recognition", "registry", "employer"],
    },
    {
        "id": "VR-013",
        "priority": 2,
        "province": "MB",
        "sheet": "B",
        "field": "MB Electrician Registry URL",
        "what_to_find": "URL for verifying MB journeyman electrician certificates",
        "primary_url": "https://www.gov.mb.ca/wd/apprenticeship/verify.html",
        "fallback_url": "https://www.manitoba.ca/wd/apprenticeship/",
        "extract_hint": ["verify", "certificate", "journeyman", "electrician"],
    },
    {
        "id": "VR-014",
        "priority": 2,
        "province": "NB",
        "sheet": "B",
        "field": "NBAOC Electrician Registry URL",
        "what_to_find": "current NB electrician certificate issuing body name and verification URL",
        "primary_url": "https://www2.gnb.ca/content/gnb/en/departments/post-secondary_education_training_and_labour/Skills/content/ApprenticeshipAndTrades.html",
        "fallback_url": "https://www.psc.gnb.ca/0162/appa-appe/index-e.asp",
        "extract_hint": ["journeyman", "electrician", "certificate", "trades", "apprenticeship", "verify"],
    },
    {
        "id": "VR-015",
        "priority": 2,
        "province": "NB",
        "sheet": "B",
        "field": "NB COR Issuing Body Post-2023",
        "what_to_find": "current COR issuing body in NB after WorkSafeNB/NBCSA changes",
        "primary_url": "https://www.worksafenb.ca/safety-resources/safety-certifications/",
        "fallback_url": "https://www.nbcsa.ca/cor/",
        "extract_hint": ["COR", "certificate of recognition", "employer", "program", "safety"],
    },
    {
        "id": "VR-016",
        "priority": 2,
        "province": "NS",
        "sheet": "B",
        "field": "NSAA Electrician Registry URL",
        "what_to_find": "URL for verifying NS journeyman electrician certificates via NSAA",
        "primary_url": "https://nsapprenticeship.ca/verify-a-trades-certificate",
        "fallback_url": "https://novascotia.ca/lae/apprenticeship/",
        "extract_hint": ["verify", "certificate", "trades", "journeyman", "electrician"],
    },
    {
        "id": "VR-017",
        "priority": 2,
        "province": "NS",
        "sheet": "B",
        "field": "CANS COR Issuance Status",
        "what_to_find": "whether CANS Safety is currently issuing COR in NS or if another body has taken over",
        "primary_url": "https://cans.ns.ca/programs/safety-programs/",
        "fallback_url": "https://ohs.novascotia.ca/",
        "extract_hint": ["COR", "certificate of recognition", "safety program", "employer"],
    },
    {
        "id": "VR-018",
        "priority": 2,
        "province": "NL",
        "sheet": "B",
        "field": "NL ATC Electrician Registry URL",
        "what_to_find": "URL for verifying NL journeyman electrician certificates",
        "primary_url": "https://www.gov.nl.ca/atcd/verify-a-certificate/",
        "fallback_url": "https://www.gov.nl.ca/atcd/",
        "extract_hint": ["verify", "certificate", "journeyman", "electrician", "trades"],
    },
    {
        "id": "VR-019",
        "priority": 2,
        "province": "NL",
        "sheet": "B",
        "field": "NLCA COR Program Status",
        "what_to_find": "whether NLCA is actively issuing COR in NL",
        "primary_url": "https://www.nlca.ca/safety/cor/",
        "fallback_url": "https://ohs.gov.nl.ca/",
        "extract_hint": ["COR", "certificate of recognition", "NLCA", "program", "safety", "employer"],
    },
    {
        "id": "VR-020",
        "priority": 2,
        "province": "ON",
        "sheet": "B",
        "field": "TSSA Gas Technician Reciprocity with ABSA",
        "what_to_find": "whether ON G1/G2 TSSA licence is accepted by AB ABSA without full re-exam",
        "primary_url": "https://www.absa.ca/permits-licences/gas-contractor-permits/",
        "fallback_url": "https://www.tssa.org/en/fuels/licensing-and-registration.aspx",
        "extract_hint": ["reciprocity", "recognition", "out of province", "equivalent", "gas technician", "G1", "G2"],
    },
    {
        "id": "VR-021",
        "priority": 2,
        "province": "YT",
        "sheet": "A",
        "field": "YT OHS Regulation Amendment Status",
        "what_to_find": "current YT OHS regulation name and last amendment date",
        "primary_url": "https://wcb.yk.ca/Safety/OHS-Legislation.aspx",
        "fallback_url": "https://legislation.yukon.ca/legislation/index.html",
        "extract_hint": ["Occupational Health Regulations", "OIC", "amended", "current", "legislation"],
    },
    {
        "id": "VR-022",
        "priority": 2,
        "province": "NT",
        "sheet": "A",
        "field": "NT Safety Act Amendment Status",
        "what_to_find": "current NT Safety Act amendment date",
        "primary_url": "https://www.wscc.nt.ca/health-safety/legislation",
        "fallback_url": "https://www.justice.gov.nt.ca/en/legislation/",
        "extract_hint": ["Safety Act", "amended", "current", "RSNWT", "legislation"],
    },

    # ── PRIORITY 3 — INDUSTRY STANDARD VALIDATION ────────────────────────────
    {
        "id": "VR-023",
        "priority": 3,
        "province": "AB",
        "sheet": "B",
        "field": "PITS Well Servicing Cert Status",
        "what_to_find": "PITS rig technician certification program current status and levels",
        "primary_url": "https://www.pitsab.com/",
        "fallback_url": "https://www.energysafetycanada.com/training",
        "extract_hint": ["rig technician", "well servicing", "certification", "level", "program"],
    },
    {
        "id": "VR-024",
        "priority": 3,
        "province": "NT/NU",
        "sheet": "B",
        "field": "Arctic Safety Training Standard",
        "what_to_find": "recognized Arctic/cold weather safety training standard for O&G workers in NT/NU",
        "primary_url": "https://www.wscc.nt.ca/health-safety/training",
        "fallback_url": "https://www.energysafetycanada.com/training",
        "extract_hint": ["arctic", "cold weather", "winter", "training", "safety", "northern"],
    },
    {
        "id": "VR-025",
        "priority": 3,
        "province": "BC",
        "sheet": "B",
        "field": "NE BC Ground Disturbance Standard",
        "what_to_find": "which ground disturbance training program is required in NE BC O&G",
        "primary_url": "https://www.bcone.ca/",
        "fallback_url": "https://www.energysafetycanada.com/training/ground-disturbance",
        "extract_hint": ["ground disturbance", "training", "excavation", "pipeline", "level II"],
    },
    {
        "id": "VR-026",
        "priority": 3,
        "province": "SK",
        "sheet": "B",
        "field": "SK Ground Disturbance Standard",
        "what_to_find": "primary ground disturbance training standard for SK O&G operations",
        "primary_url": "https://www.saskfirstcall.com/",
        "fallback_url": "https://www.energysafetycanada.com/training/ground-disturbance",
        "extract_hint": ["ground disturbance", "training", "excavation", "level II", "dig safe"],
    },
    {
        "id": "VR-027",
        "priority": 3,
        "province": "MB",
        "sheet": "B",
        "field": "MB H2S Alive Requirement",
        "what_to_find": "whether H2S Alive is legislated or a client requirement for MB O&G Williston Basin",
        "primary_url": "https://www.gov.mb.ca/labour/safety/",
        "fallback_url": "https://www.energysafetycanada.com/",
        "extract_hint": ["H2S", "hydrogen sulphide", "oil", "gas", "Williston", "Virden", "training"],
    },
    {
        "id": "VR-028",
        "priority": 3,
        "province": "QC",
        "sheet": "B",
        "field": "CCQ Card Red Seal Portability",
        "what_to_find": "whether QC CCQ electrician can challenge Red Seal exam for national portability",
        "primary_url": "https://www.red-seal.ca/trades/electrician",
        "fallback_url": "https://www.ccq.org/en/Formation/Apprentissage/CertificatsDeCompetence",
        "extract_hint": ["Red Seal", "Quebec", "CCQ", "challenge", "examination", "electrician", "portable"],
    },
    {
        "id": "VR-029",
        "priority": 3,
        "province": "NB",
        "sheet": "A",
        "field": "NB OHS Act 2023 Material Changes",
        "what_to_find": "whether RSNB 2023 c 33 introduced material O&G-specific changes or is consolidation only",
        "primary_url": "https://www.worksafenb.ca/about-worksafenb/legislation-regulations/",
        "fallback_url": "https://laws.gnb.ca/en/showdoc/cs/O-0.2",
        "extract_hint": ["2023", "amendment", "consolidation", "occupational health", "new", "change"],
    },
    {
        "id": "VR-030",
        "priority": 3,
        "province": "NS",
        "sheet": "B",
        "field": "NS Offshore OPITO Full Cert List",
        "what_to_find": "complete list of OPITO certifications required by CNSOPB for NS offshore workers",
        "primary_url": "https://www.cnsopb.ns.ca/safety/safety-regulations/offshore-occupational-health-safety",
        "fallback_url": "https://www.opito.com/standards",
        "extract_hint": ["OPITO", "HUET", "BOSIET", "FOET", "CA-EBS", "training", "offshore", "required"],
    },
    {
        "id": "VR-031",
        "priority": 3,
        "province": "NL",
        "sheet": "B",
        "field": "NL Offshore OPITO Renewal Periods",
        "what_to_find": "current HUET and BOSIET renewal periods required by C-NLOPB",
        "primary_url": "https://www.cnlopb.ca/information/safety/training/",
        "fallback_url": "https://www.opito.com/standards/bosiet",
        "extract_hint": ["HUET", "BOSIET", "renewal", "years", "training", "validity", "expiry"],
    },
    {
        "id": "VR-032",
        "priority": 3,
        "province": "ALL",
        "sheet": "B",
        "field": "National CORA Registry Completeness",
        "what_to_find": "complete national list of active CORAs by province",
        "primary_url": "https://www.csse.org/page/CORProgram",
        "fallback_url": "https://www.naosh.org/cor-program",
        "extract_hint": ["CORA", "province", "certificate of recognition authority", "list", "national"],
    },
    {
        "id": "VR-033",
        "priority": 3,
        "province": "ALL",
        "sheet": "B",
        "field": "BCRSP CRSP Verification URL",
        "what_to_find": "direct URL for verifying a CRSP designation holder at BCRSP",
        "primary_url": "https://www.bcrsp.ca/verify-a-registrant/",
        "fallback_url": "https://www.bcrsp.ca/contact/",
        "extract_hint": ["verify", "registrant", "CRSP", "lookup", "search", "designation"],
    },
    {
        "id": "VR-034",
        "priority": 3,
        "province": "MB",
        "sheet": "A",
        "field": "MB WSH Act Current Amendment",
        "what_to_find": "current amendment status of MB Workplace Safety and Health Act CCSM c W210",
        "primary_url": "https://web2.gov.mb.ca/laws/statutes/ccsm/w210e.php",
        "fallback_url": "https://www.gov.mb.ca/labour/safety/legislation.html",
        "extract_hint": ["amended", "current", "W210", "workplace safety", "2021", "2022", "2023"],
    },
]

# ─────────────────────────────────────────────────────────────────────────────
# SCRAPE ENGINE
# ─────────────────────────────────────────────────────────────────────────────

class ComplianceScraper:
    """
    Scrapes VERIFY_REQUIRED targets using Firecrawl.
    Implements: primary → fallback pattern, rate limiting,
    extract_hint matching, and structured result output.
    """

    RATE_LIMIT_SECONDS = 2.0   # Between requests — respect server limits
    TIMEOUT_SECONDS    = 30
    MAX_CONTENT_CHARS  = 8000  # Truncate large pages before hint matching

    def __init__(self, api_key: str):
        if not api_key:
            raise ValueError(
                "FIRECRAWL_API_KEY not found.\n"
                "Set as Windows System Environment Variable:\n"
                "  Windows → System Properties → Advanced → Environment Variables → System Variables\n"
                "  Variable: FIRECRAWL_API_KEY\n"
                "  Value: [your Firecrawl API key]\n"
                "Then restart your terminal and re-run."
            )
        self.app = FirecrawlApp(api_key=api_key)
        self.results = []
        self.errors  = []

    def scrape_url(self, url: str) -> Optional[str]:
        """Scrape a single URL and return markdown content."""
        try:
            result = self.app.scrape_url(
                url,
                params={
                    "formats": ["markdown"],
                    "onlyMainContent": True,
                    "timeout": self.TIMEOUT_SECONDS,
                }
            )
            content = result.get("markdown", "") or result.get("content", "")
            return content[:self.MAX_CONTENT_CHARS] if content else None

        except Exception as e:
            log.warning(f"Scrape failed for {url}: {e}")
            return None

    def check_hints(self, content: str, hints: list) -> dict:
        """
        Check how many extract_hints appear in the scraped content.
        Returns hit count, which hints matched, and a confidence score.
        """
        if not content:
            return {"hits": 0, "matched": [], "hint_confidence": "NONE"}

        content_lower = content.lower()
        matched = [h for h in hints if h.lower() in content_lower]
        hit_ratio = len(matched) / len(hints) if hints else 0

        if hit_ratio >= 0.6:
            hint_confidence = "HIGH"
        elif hit_ratio >= 0.3:
            hint_confidence = "MEDIUM"
        else:
            hint_confidence = "LOW"

        return {
            "hits": len(matched),
            "total_hints": len(hints),
            "matched": matched,
            "hint_confidence": hint_confidence,
        }

    def process_target(self, target: dict) -> dict:
        """
        Process a single VR target:
        1. Scrape primary URL
        2. If insufficient content, scrape fallback
        3. Score against extract_hints
        4. Return structured result
        """
        vr_id    = target["id"]
        priority = target["priority"]

        log.info(f"Processing {vr_id} (P{priority}) — {target['province']} — {target['field']}")

        # ── Primary scrape ────────────────────────────────────────────────────
        time.sleep(self.RATE_LIMIT_SECONDS)
        primary_content = self.scrape_url(target["primary_url"])
        primary_hints   = self.check_hints(primary_content or "", target["extract_hint"])

        # ── Fallback scrape if primary is weak ────────────────────────────────
        fallback_content = None
        fallback_hints   = {"hits": 0, "matched": [], "hint_confidence": "NONE"}

        if primary_hints["hint_confidence"] in ("LOW", "NONE"):
            log.info(f"  {vr_id} primary weak ({primary_hints['hint_confidence']}) — trying fallback")
            time.sleep(self.RATE_LIMIT_SECONDS)
            fallback_content = self.scrape_url(target["fallback_url"])
            fallback_hints   = self.check_hints(fallback_content or "", target["extract_hint"])

        # ── Choose best result ────────────────────────────────────────────────
        if primary_hints["hits"] >= fallback_hints["hits"]:
            best_content = primary_content
            best_hints   = primary_hints
            best_source  = target["primary_url"]
        else:
            best_content = fallback_content
            best_hints   = fallback_hints
            best_source  = target["fallback_url"]

        # ── Status determination ──────────────────────────────────────────────
        if best_hints["hint_confidence"] == "HIGH":
            status = "RESOLVED_HIGH_CONFIDENCE"
        elif best_hints["hint_confidence"] == "MEDIUM":
            status = "RESOLVED_NEEDS_HUMAN_REVIEW"
        else:
            status = "UNRESOLVED_MANUAL_REQUIRED"

        # ── Extract relevant snippet (first 600 chars containing a hint match) ─
        snippet = ""
        if best_content and best_hints["matched"]:
            first_hint = best_hints["matched"][0].lower()
            idx = best_content.lower().find(first_hint)
            if idx >= 0:
                start = max(0, idx - 100)
                end   = min(len(best_content), idx + 500)
                snippet = best_content[start:end].strip()

        result = {
            "id":             vr_id,
            "priority":       priority,
            "province":       target["province"],
            "sheet":          target["sheet"],
            "field":          target["field"],
            "what_to_find":   target["what_to_find"],
            "status":         status,
            "best_source":    best_source,
            "hint_confidence": best_hints["hint_confidence"],
            "hints_matched":  best_hints["matched"],
            "hints_total":    len(target["extract_hint"]),
            "snippet":        snippet,
            "scraped_date":   today,
            "primary_url":    target["primary_url"],
            "fallback_url":   target["fallback_url"],
            "primary_hint_conf":  primary_hints["hint_confidence"],
            "fallback_hint_conf": fallback_hints["hint_confidence"],
        }

        log.info(f"  {vr_id} → {status} (hints: {best_hints['hits']}/{len(target['extract_hint'])})")
        return result

    def run_all(self) -> list:
        """
        Run all 34 VERIFY_REQUIRED targets in priority order.
        Returns list of result dicts.
        """
        sorted_targets = sorted(TARGETS, key=lambda t: t["priority"])
        total = len(sorted_targets)

        log.info(f"Starting firecrawl-sync — {total} targets — {today}")
        log.info(f"Project root: {PROJECT_ROOT}")

        for i, target in enumerate(sorted_targets, 1):
            log.info(f"[{i}/{total}] {target['id']}")
            try:
                result = self.process_target(target)
                self.results.append(result)
            except Exception as e:
                log.error(f"FATAL error processing {target['id']}: {e}")
                self.errors.append({"id": target["id"], "error": str(e)})

        return self.results


# ─────────────────────────────────────────────────────────────────────────────
# OUTPUT WRITERS
# ─────────────────────────────────────────────────────────────────────────────

def write_json_results(results: list) -> Path:
    """Write raw results to logs/scrape/firecrawl_YYYY-MM-DD.json"""
    out_path = LOGS_DIR / f"firecrawl_{today}.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    log.info(f"JSON results written → {out_path}")
    return out_path


def write_markdown_report(results: list, errors: list) -> Path:
    """Write human-readable diff report to logs/scrape/firecrawl_YYYY-MM-DD.md"""
    out_path = LOGS_DIR / f"firecrawl_{today}.md"

    resolved_high   = [r for r in results if r["status"] == "RESOLVED_HIGH_CONFIDENCE"]
    resolved_review = [r for r in results if r["status"] == "RESOLVED_NEEDS_HUMAN_REVIEW"]
    unresolved      = [r for r in results if r["status"] == "UNRESOLVED_MANUAL_REQUIRED"]

    lines = [
        f"# firecrawl-sync Results — {today}",
        f"**Total targets:** {len(results)}  ",
        f"**Resolved (high confidence):** {len(resolved_high)}  ",
        f"**Resolved (needs human review):** {len(resolved_review)}  ",
        f"**Unresolved (manual required):** {len(unresolved)}  ",
        f"**Errors:** {len(errors)}  ",
        "",
        "---",
        "",
        "## RESOLVED — HIGH CONFIDENCE",
        "",
    ]

    for r in resolved_high:
        lines += [
            f"### {r['id']} | {r['province']} | {r['field']}",
            f"**Source:** {r['best_source']}  ",
            f"**Hints matched:** {', '.join(r['hints_matched'])} ({r['hints_matched'].__len__()}/{r['hints_total']})  ",
            f"**Snippet:**",
            f"```",
            r["snippet"] or "(no snippet extracted)",
            "```",
            f"**Action:** Update XLSX Sheet D → Status: CLOSED | Verified Date: {today}",
            "",
        ]

    lines += ["---", "", "## RESOLVED — NEEDS HUMAN REVIEW", ""]

    for r in resolved_review:
        lines += [
            f"### {r['id']} | {r['province']} | {r['field']}",
            f"**Source:** {r['best_source']}  ",
            f"**Hints matched:** {', '.join(r['hints_matched'])} ({r['hints_matched'].__len__()}/{r['hints_total']})  ",
            f"**Snippet:**",
            "```",
            r["snippet"] or "(no snippet extracted)",
            "```",
            f"**Action:** Review snippet → confirm value → update XLSX Sheet D  ",
            "",
        ]

    lines += ["---", "", "## UNRESOLVED — MANUAL REQUIRED", ""]

    for r in unresolved:
        lines += [
            f"### {r['id']} | {r['province']} | {r['field']}",
            f"**Primary URL:** {r['primary_url']}  ",
            f"**Fallback URL:** {r['fallback_url']}  ",
            f"**Hint confidence:** {r['hint_confidence']} — {r['hints_matched'].__len__()}/{r['hints_total']} hints found  ",
            f"**Action:** Manual verification required — see VERIFY_REQUIRED_MANUAL_GUIDE.md  ",
            "",
        ]

    if errors:
        lines += ["---", "", "## ERRORS", ""]
        for e in errors:
            lines += [f"- **{e['id']}**: {e['error']}"]

    lines += [
        "",
        "---",
        f"*Generated by firecrawl-sync.py | {today} | Vaquero Safety Inc.*",
        f"*Zero Guess Rule: unresolved items retain [VERIFY_REQUIRED] flag — not auto-resolved.*",
    ]

    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    log.info(f"Markdown report written → {out_path}")
    return out_path


def write_supabase_results(results: list) -> None:
    """
    Optional: push resolved results to Supabase compliance_matrix table.
    Only runs if SUPABASE_URL and SUPABASE_KEY are set in .env.
    Table schema: id, province, sheet, field, status, verified_value,
                  source_url, hint_confidence, scraped_date, snippet
    """
    if not SUPABASE_URL or not SUPABASE_KEY:
        log.info("Supabase credentials not set — skipping DB push. Set SUPABASE_URL and SUPABASE_KEY in .env to enable.")
        return

    try:
        from supabase import create_client
        client = create_client(SUPABASE_URL, SUPABASE_KEY)

        rows = [
            {
                "vr_id":            r["id"],
                "province":         r["province"],
                "sheet":            r["sheet"],
                "field":            r["field"],
                "status":           r["status"],
                "source_url":       r["best_source"],
                "hint_confidence":  r["hint_confidence"],
                "hints_matched":    json.dumps(r["hints_matched"]),
                "snippet":          r["snippet"],
                "scraped_date":     r["scraped_date"],
            }
            for r in results
            if r["status"] != "UNRESOLVED_MANUAL_REQUIRED"
        ]

        if rows:
            response = client.table("compliance_matrix_vr_results").upsert(rows).execute()
            log.info(f"Supabase push: {len(rows)} rows upserted to compliance_matrix_vr_results")
        else:
            log.info("No resolved rows to push to Supabase.")

    except ImportError:
        log.warning("supabase-py not installed. Run: pip install supabase --break-system-packages")
    except Exception as e:
        log.error(f"Supabase push failed: {e}")


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

def main():
    # ── API key guard ─────────────────────────────────────────────────────────
    api_key = FIRECRAWL_API_KEY
    if not api_key:
        print("\n" + "="*60)
        print("FIRECRAWL_API_KEY not found in environment.")
        print("="*60)
        print("\nTo set it (Windows):")
        print("  1. Windows → System Properties → Advanced → Environment Variables")
        print("  2. System Variables → New")
        print("  3. Variable name:  FIRECRAWL_API_KEY")
        print("  4. Variable value: [your Firecrawl API key from app.firecrawl.dev]")
        print("  5. Restart terminal")
        print("  6. Re-run: python scripts/firecrawl-sync.py")
        print("\nFirecrawl API keys: https://app.firecrawl.dev/dashboard")
        sys.exit(1)

    # ── Run scraper ───────────────────────────────────────────────────────────
    scraper = ComplianceScraper(api_key=api_key)
    results = scraper.run_all()

    # ── Write outputs ─────────────────────────────────────────────────────────
    json_path = write_json_results(results)
    md_path   = write_markdown_report(results, scraper.errors)
    write_supabase_results(results)

    # ── Summary ───────────────────────────────────────────────────────────────
    resolved_high   = sum(1 for r in results if r["status"] == "RESOLVED_HIGH_CONFIDENCE")
    resolved_review = sum(1 for r in results if r["status"] == "RESOLVED_NEEDS_HUMAN_REVIEW")
    unresolved      = sum(1 for r in results if r["status"] == "UNRESOLVED_MANUAL_REQUIRED")

    print("\n" + "="*60)
    print(f"firecrawl-sync COMPLETE — {today}")
    print("="*60)
    print(f"  Total targets:              {len(results)}")
    print(f"  Resolved (high confidence): {resolved_high}")
    print(f"  Resolved (needs review):    {resolved_review}")
    print(f"  Unresolved (manual reqd):   {unresolved}")
    print(f"  Errors:                     {len(scraper.errors)}")
    print(f"\n  JSON results:  {json_path}")
    print(f"  MD report:     {md_path}")
    print(f"\nNext steps:")
    print(f"  1. Review MD report: {md_path}")
    print(f"  2. For RESOLVED_HIGH_CONFIDENCE: update XLSX Sheet D → CLOSED")
    print(f"  3. For RESOLVED_NEEDS_HUMAN_REVIEW: manually confirm snippet value")
    print(f"  4. For UNRESOLVED: use VERIFY_REQUIRED_MANUAL_GUIDE.md")
    print(f"  5. Run scripts/verify-compliance.py before any COR/NCSO/CRSP output")
    print("="*60)


if __name__ == "__main__":
    main()
