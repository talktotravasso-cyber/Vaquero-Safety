# memory-decisions.md
# `.claude/rules/memory-decisions.md`
# Vaquero Safety Inc.

**Rule:** Append-only. Never overwrite or delete prior entries.
**Format:** `[DATE] | DECISION: [what was decided] | RATIONALE: [why] | LINKED FILES: [paths]`

---

[2026-05-31] | DECISION: Routing Engine and Obsidian Persistence Engine created as standalone operating rule files | RATIONALE: Enforce deterministic output routing (Claude Desktop vs Cursor), mandatory Obsidian persistence, and structured search trigger rules across all sessions; prevents knowledge drift and vault inconsistency as client count grows | LINKED FILES: .claude/rules/routing-engine.md | .claude/rules/obsidian-persistence.md | SKILL.md Section 16

[2026-05-31] | DECISION: Obsidian vault adopts hybrid structure — operational numbered folders retained for daily ops; all project knowledge routed under Vaquero_Safety_Inc/ parent | RATIONALE: Existing numbered folder structure was built before routing engine existed; hybrid avoids full migration disruption while establishing clean project knowledge layer | LINKED FILES: .claude/rules/obsidian-persistence.md v1.1.0 | .claude/rules/routing-engine.md v1.1.0

2026-05-31 | DECISION | Phase 2 Decisions batch complete — 14 notes written to Obsidian via Cursor MCP. 5 ADRs flagged (PENDING-001 through 005). 3 pre-launch blockers confirmed: CEL reconciliation mechanism, MSA legal review, Compliance Posture Page Day 1. | Vaquero_Safety_Inc/Compliance/saas-failure-mode-risk-assessment-20260531.md
