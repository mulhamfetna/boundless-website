# SRC2 Knowledge Base — Analysis and Reuse Plan

**Date:** 2026-07-29
**Scope:** All 152 files (403 MB) under `knowledge_base/SRC2 - Scientific Research Camp V2/`
**Method:** Full inline extraction and reading — `python-docx`, `openpyxl`, `pdftotext`. No delegated analysis.
**Companion documents:** `2026-07-28-boundless-website-design.md` (site design), `docs/legal/` (contract drafts this analysis triggered)

---

## 1. Why this changes the project

### 1.1 The website is a contracted deliverable

The SRC2 Concept Note lists, under *Expected Outcomes & Sustainability*:

> The launch of the "Boundless Research Blog" as a sustainable platform to publish articles and comprehensive guides produced by the community.

This site is owed to a donor as a project outcome. It is not discretionary, and its delay is a reportable delivery gap.

### 1.2 SRC2 has just closed

The camp ran **27 April – 27 July 2026**. Media posts are published from 28 April onward. As of this analysis the camp closed two days ago.

Consequence: the first Edition page can be authored now, but **every number in the archive is a target, not a result**. The MEAL charter schedules the final donor report for one week after camp close (~3 August 2026). Until it exists, there is no verified impact figure to publish.

### 1.3 The crediting system rests on nothing

The Volunteering Agreement and Code of Conduct are thorough on confidentiality:

- Outputs, financial data and beneficiary demographics are *"the exclusive property of Boundless"*
- Publishing internal photos or documents is forbidden
- Cross-department data sharing requires CEO approval
- Violation terminates the contract and forfeits certificates

They contain **no clause granting Boundless the right to publish a contributor's name or photograph**, and **no promise of public attribution**. The entire incentive structure behind the site's crediting system — the reason a volunteer works unpaid — is currently unenforceable in both directions. This is the highest-severity gap in the archive.

---

## 2. Inventory

| Type | Count | Notes |
|---|---|---|
| PDF | 38 | Mostly CVs; 1 curriculum deck (statistics) |
| JPG | 38 | Trainer portraits, session photography |
| DOCX | 32 | Governance, contracts, drafts, trainer bios |
| MP4 | 26 | Session footage, launch reel raw material |
| XLSX | 7 | Backlog, finance, risk, HR, applicants, media |
| PNG / JSON / CSV / M4A / drawio | 8 | Org chart, ranked applicants, audio |

**Structural note:** the folder `Sessions Files (Sicentific Content)/` contains exactly one file, and it is empty. The actual scientific session PDFs live in `Boundless/Gamified-sessions/`, outside this archive.

---

## 3. Reuse map

### 3.1 Ready to use with minimal transformation

| Source | Destination | Notes |
|---|---|---|
| `بيانات المحاضرين/` — 4 trainers, each with bio + photo + topic outline | **Person pages** | Dr. Abdul Razzaq Hammal (Aleppo University, PhD Applied Chemistry, RSC Chartered Scientist, ACS member); Mzit Kourani (PhD researcher, mathematical statistics, 7 yrs data science); Mulham Fetna (founder/CEO); Nadra Rabie (social researcher, MEAL, 10+ yrs, GIZ consultant, MSc). Bios are publication-quality Arabic; need English translation per D2. |
| `SRC2 - Concept Note - EN.docx` + `AR.docx` | **Program page** | Already exists in both languages — rare in this archive, and directly satisfies the translation gate. |
| Applicant JSON (83 records) | **Aggregate statistics** | 83 applied → 50 accepted (60%). Degrees: 5 PhD, 19 Master's, 15 graduates, 44 undergraduate. Names and emails never leave the archive. |
| Risk register, MEAL charter, RACI, org chart, three team charters | **Partnership Principles page** | Evidence of governance maturity, restated as principles per D11 — not published verbatim (Code of Conduct forbids it). |

### 3.2 The article backlog — 33 topics, fully scoped

Trainer topic outlines decompose directly into the atomic, one-topic-per-article structure the site is built for. Four topic hubs:

| Hub | Articles | Source |
|---|---|---|
| **Scientific publishing & journals** | 16 | Dr. Abdul Razzaq Hammal — what research is, paper types, quality criteria and journal ranking, legitimate vs. illegitimate ranking escalation, choosing a journal, detecting predatory journals, the nine stages of the publishing journey, open-access fees and waivers, global publishing strategy |
| **Research instruments & evaluation** | 8 | Nadra Rabie — questionnaire design, common question-wording errors, validation stages, literature review, reliability analysis (validity, Cronbach's alpha), instrument construction, AI in research and its common errors, quantitative vs. qualitative indicators |
| **Researcher digital presence** | 5 | Mulham Fetna — AI tools for researchers (Perplexity, SciSpace), professional digital presence (LinkedIn, ORCID, ResearchGate, Google Scholar), professional correspondence and networking, CV construction |
| **Statistics & data analysis** | 4 | Mzit Kourani — importance of statistics in research, stages of statistical study, descriptive statistics, advanced analysis and outputs |

This matches the stated content model exactly: one curriculum spanning roughly thirty single-topic articles.

**Constraint:** these are *outlines*, not drafts. Each requires authoring, bilingual production, and the enforced article template (answer paragraph, takeaways, FAQ, credits). The 33 figure is scope, not progress.

### 3.3 Evidence, blocked on consent

64 media assets (26 video, 38 photo) covering sessions, the launch reel, and camera-operator raw footage. Unusable until participant image consent exists (§5).

One item is disproportionately valuable: a recorded interview with SRC1 beneficiaries (`ريل مقابلة مع مستفيدين المعسكر السابق`) — the only testimonial material in the archive.

### 3.4 The strongest credibility asset

**10 of 13 internal team applicants are SRC1 graduates**, self-identified as *"أنا خريج/ـة معسكر البحث العلمي 1"*. Additional SRC1 alumni appear in the public applicant pool.

SRC1 participants returned to *staff* SRC2. That is a demonstrated pipeline — the single most persuasive claim available to the site — and it currently exists only as a column in a spreadsheet.

### 3.5 Explicitly not for publication

- All CVs (~30 files) and registration responses — personal data
- Financial Study — internal procurement; note its consolidated budget sheet is **empty**, so no total exists
- Stakeholder contact details
- Entrepreneurial Research Camp draft — in development, hidden per D4
- Meeting minutes, WhatsApp protocol, internal charters — Code of Conduct forbids publication

---

## 4. Corrections forced on the site design

### 4.1 Role vocabulary is too thin

The approved vocabulary has 14 roles. The org chart, RACI and HR application form prove eight more exist, and that one approved role is a harmful over-simplification.

**Add:** `logistics`, `meal-lead`, `meal-planner`, `meal-monitor`, `camera-operator`, `graphic-designer`, `video-editor`, `qa`, `copywriter`

**Split:** the single `media` role currently collapses camera operation, graphic design, video editing, copywriting and quality assurance into one label. That is precisely the flattening the crediting system exists to prevent — five people's distinct contributions rendered identical.

### 4.2 Partners need a role field

SANAD is simultaneously **primary funder**, **venue provider** (Sanad Mechanics Center, Aleppo) and **strategic partner**. UNFPA is the **donor** behind the funding. A flat partner entity cannot express this, and getting funder attribution wrong on a credibility site is a serious error.

Add a `role` field to the partner relation: `donor` · `funder` · `strategic` · `venue` · `implementing` · `in-kind`.

### 4.3 An unresolved factual contradiction

- Concept Note: *"Donor: United Nations Population Fund (UNFPA Syria)"*, with SANAD as strategic partner
- Risk & Stakeholder Register: *"Sanad – Initiative Department | Primary Funder"*

Both may be true if UNFPA funds through SANAD, but the site must state one relationship accurately. **This requires your confirmation before any partner page is published.**

### 4.4 Editions need a lessons-learned relation

The risk register carries dedicated SRC1 columns — *Previous Experience (SRC1)*, *Resolution Taken (SRC1)* — feeding *Preventive Actions (SRC2)*. Six risks are documented this way; R-007 through R-016 are empty stubs.

This edition-to-edition learning chain is real institutional knowledge and the Edition content type should model it, not discard it.

---

## 5. Gaps, by severity

| # | Gap | Blocks | Owner | Timing |
|---|---|---|---|---|
| G1 | No attribution or image-release clause in volunteer contract | Naming anyone; all 64 media assets | Mulham + legal review | Before any person is published |
| G2 | Final MEAL report and all actual results | Entire achievements record | MEAL Lead | ~3 Aug 2026 |
| G3 | No SRC1 record beyond risk-register columns | The claim "building on the success of the first edition" | Reconstruct or drop the claim | Before program page |
| G4 | Donor approval to display UNFPA / SANAD names and marks | Partner pages, edition evidence | SANAD | Before Phase 4 |
| G5 | Participant photo/video consent | 64 media assets | Retroactive collection | Before evidence gallery |
| G6 | Funder relationship ambiguity (§4.3) | Partner attribution accuracy | Mulham | Before partner pages |
| G7 | Scientific session PDFs absent from archive | Article authoring source material | Copy from `Gamified-sessions/` | Before Phase 3 |
| G8 | Delivery tracking went stale mid-execution | Any claim about what was delivered | Reconstruct from media + MEAL | With G2 |
| G9 | Visual identity, domain | Phase 4 | Mulham | Phase 4 |

### On G8

The Agile Backlog holds 70 tasks: 13 Done, 28 To Do, 7 Waiting, 4 In Progress, with deadlines stopping at 20 June and a single SRC2-closing task. The Media Backlog shows 22 items, 8 published, 3 in design.

Tracking did not survive delivery. Neither register can evidence what SRC2 actually produced, so the achievements record cannot be reconstructed from project management artefacts — it depends entirely on G2.

---

## 6. Plan

### Decisions taken

- **Structure first, numbers later.** Phase 2 builds the full content model with schema enforcing at least one impact number per edition. The SRC2 edition page is authored as `draft: true` — invisible and exempt from the translation gate — until the MEAL report lands. The machine is ready the day the data exists.
- **Fix the contracts.** Draft an attribution and image-release addendum, plus a retroactive consent form for existing SRC2 contributors and participants. Drafts in `docs/legal/`, for review by someone qualified in the applicable jurisdiction.

### Sequence

**Phase 2 — Content model** (unblocked, start now)
Programs, editions, people, partners. Extended role vocabulary (§4.1). Partner role field (§4.2). Edition lessons-learned relation (§4.4). Schema validation. SRC2 program page from the bilingual concept note. Four trainer person pages. SRC2 edition page as draft.

**Phase 2.5 — Consent** (parallel, human-gated)
Contract addendum reviewed and adopted. Retroactive consent collected. Only then do person pages go live and media become usable.

**Phase 3 — Content engine**
Articles, topic hubs, credits rendering, citation blocks, SEO/GEO stack. The 33-topic backlog becomes the authoring queue, four hubs in the order of §3.2.

**Phase 4 — Aggregation and launch**
Achievements and archive generation, static pages, forms, analytics, identity, domain. Gated on G2, G4, G6, G9.

### Immediate non-blocking actions

1. Copy the scientific session PDFs from `Gamified-sessions/` into the archive (G7)
2. Confirm the funder relationship (G6) — one sentence, unblocks partner pages
3. Ask the MEAL Lead to prioritise the actuals the site needs: attendance, satisfaction mean, pre/post learning gain, research teams formed, papers submitted or published
4. Move `knowledge_base/` outside the repository (§7)

---

## 7. Data protection

`knowledge_base/` contains roughly 30 CVs, 83 applicant records with names and emails, 35 team applications including WhatsApp numbers, dates of birth and personality-test results, and stakeholder contact details.

**Actions taken:** the directory is gitignored, with the reason recorded in `.gitignore`. Hugo does not publish it — verified, zero files reach `public/`.

**Residual risk:** it still sits inside the repository working tree. A `git add -f`, a misconfigured backup, or a future contributor's tooling could expose it. It should live outside the repository, with only derived, consented content transcribed in.

Nothing from this archive should reach the site by copying. Everything published is transcribed deliberately, with consent, in the knowledge that the Code of Conduct classifies most of it as confidential.
