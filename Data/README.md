# Data

This folder contains the 46 pharmacoepidemiological study protocols used to evaluate the performance of general-purpose and biomedical large language models (LLMs) in supporting pharmacoepidemiological study design, as described in:

> **Employing General-Purpose and Biomedical Large Language Models with Advanced Prompt Engineering for Pharmacoepidemiologic Study Design**

---

## Overview

A total of 46 publicly available study protocols were retrieved from two pharmacoepidemiological sources: the HMA-EMA Catalogue of Real-World Data (RWD) Studies and the Sentinel System. All protocols were published between 2018 and 2024, written in English, and publicly available at the time of analysis.

---

## Folder structure

```
data/
├── darwin/          # 16 DARWIN EU® protocols from the HMA-EMA Catalogue
├── hma-ema/         # 15 non-DARWIN expert-developed protocols from the HMA-EMA Catalogue
└── sentinel/        # 15 protocols from the Sentinel System (Drugs section)
```

---

## Sources and selection criteria

### HMA-EMA Catalogue — DARWIN EU® protocols (n = 16)
All DARWIN EU® protocols available in the HMA-EMA Catalogue of RWD Studies at the time of analysis were included.

- Source: [HMA-EMA Catalogue of RWD Studies](https://catalogues.ema.europa.eu/node/491/field_ema_web_summary_of_studies/summary)

### HMA-EMA Catalogue — non-DARWIN protocols (n = 15)
A random sample of expert-developed protocols registered in the HMA-EMA Catalogue that did not belong to DARWIN EU®. Protocols were required to meet all of the following criteria:

- Registered between January 1, 2023 and February 22, 2024 (based on first published date)
- Finalized
- Written in English
- Study protocol publicly available at the time of analysis

- Source: [HMA-EMA Catalogue of RWD Studies](https://catalogues.ema.europa.eu/node/491/field_ema_web_summary_of_studies/summary)

### Sentinel System — Drugs section (n = 15)
Protocols selected from the Sentinel System meeting all of the following criteria:

- Registered between January 1, 2022 and February 22, 2024 (based on last update date)
- Marked as complete
- Study purpose classified as "drug and outcome analysis" or "drug use"
- Study protocol publicly available at the time of analysis

- Source: [Sentinel System](https://www.sentinelinitiative.org/methods-data-tools/sentinel-distributed-database/distributed-database-studies)

---

## Protocol characteristics
 
### Overview
 
A total of 46 protocols were included: 16 from DARWIN EU®, 15 from HMA-EMA, and 15 from the Sentinel network. Countries involved in the DARWIN EU® and HMA-EMA protocols included Belgium, Estonia, Finland, France, Germany, Italy, the Netherlands, Norway, Romania, Spain, and the United Kingdom. Sentinel protocols were from the United States.
 
### Study types (all 46 protocols)
 
| Study type | n |
|---|---|
| Drug utilization | 18 |
| Disease epidemiology | 15 |
| Safety | 11 |
| Effectiveness | 2 |
 
### Databases (all 46 protocols)
 
15 different databases were used across the included protocols.
 
| Database | Number of protocols |
|---|---|
| IQVIA Germany | 23 |
| SIDIAP | 15 |
| Sentinel Distributed Database | 14 |
| IQVIA UK | 11 |
| CPRD GOLD | 11 |
| IQVIA France | 9 |
| IQVIA Belgium | 5 |
| Bordeaux | 4 |
| THIN Spain | 4 |
| THIN Romania | 3 |
| CPRD General | 2 |
| MarketScan | 2 |
| THIN Italy | 2 |
| IQVIA Medical Research Data | 1 |
| Other | 38 |

---

## How protocols were used

For each protocol, all sections related to pharmacoepidemiological study design concepts were extracted by a human expert, forming the **gold standard** against which LLM outputs were evaluated.

The nine concepts were selected based on the **HARPER checklist** (HARmonized Protocol Template to Enhance Reproducibility), originally developed to enhance the transparency, reproducibility, and comparability of pharmacoepidemiological studies in multi-database and multi-center collaborations, and adapted into a tailored set of tasks for each study protocol.

> Wang, S.V., Pottegård, A., Crown, W., Arlett, P., Ashcroft, D.M., Benchimol, E.I., Berger, M.L., Crane, G., Goettsch, W., Hua, W., Kabadi, S., Kern, D.M., Kurz, X., Langan, S., Nonaka, T., Orsini, L., Perez-Gutthann, S., Pinheiro, S., Pratt, N. and Schneeweiss, S. (2022). HARmonized Protocol Template to Enhance Reproducibility of hypothesis evaluating real-world evidence studies on treatment effects: A good practices report of a joint ISPE/ISPOR task force. *Pharmacoepidemiology and Drug Safety*, 32(1), pp.44–55. https://doi.org/10.1002/pds.5507

LLM-generated responses were evaluated for:
- **Relevance** — degree of concordance with the human expert gold standard (assessed using a 5-point Likert scale)
- **Logic of justification** — soundness and coherence of model reasoning (assessed by a human rater on a 5-point scale)
- **Ontology-code agreement** — percentage agreement between LLM-generated codes and reference codes from the protocols (e.g., ICD-10, ATC, CPT, HCPCS, SNOMED, RxNorm)

---

## Concept extraction mapping

The table below shows which protocol sections were used to extract each pharmacoepidemiological concept across the three data sources. This mapping guided the construction of the human expert gold standard.

| Concept | Sentinel | HMA-EMA Catalogue (DARWIN EU®) | HMA-EMA Catalogue (other RWD studies) |
|---|---|---|---|
| **Study design** | Study design | Research methods – Study type and study design | Study design |
| **Index date** | Study design; Exposure; Exposure of interest; Appendix – Specifications defining exposure parameters | Abstract – Research methods – Population; Abstract – Research methods – Data analyses; Research methods – Study population; Table – Operational Definition of Time 0 and other primary time anchors | Study design; Population; Study period; Selection of study cohort |
| **Inclusion and exclusion criteria** | Cohort eligibility criteria; Study design; Appendix – Specifications defining inclusion and exclusion criteria parameters | Research methods – Study population with inclusion and exclusion criteria; Research methods – Inclusion and exclusion criteria; Table – Operational definitions of Inclusion Criteria; Table – Operational Definitions of Exclusion Criteria | Selection criteria; Inclusion criteria; Exclusion criteria; Eligibility criteria; Inclusion/exclusion criteria for the primary outcome; Selection of study cohort |
| **Inclusion and exclusion assessment window** | Cohort eligibility criteria; Exposure of interest; Appendix – Specifications defining inclusion and exclusion criteria parameters | Research methods – Study population with inclusion and exclusion criteria; Research methods – Inclusion and exclusion criteria; Table – Operational definitions of Inclusion/Exclusion Criteria | Selection criteria; Inclusion criteria; Exclusion criteria; Eligibility criteria; Inclusion/exclusion criteria for the primary outcome; Selection of study cohort |
| **Study exposure** | Exposure(s) of interest; Appendix – Specifications defining exposure parameters; Appendix – Specifications defining parameters | Variables – Exposure/s; Table – Exposure of interest; Table – Operational Definitions of Exposure; Table – Operational Definition of Time 0 and other primary time anchors | Primary objective(s); Secondary objective(s); Exposure; Setting; Selection of study cohort |
| **Study outcomes** | Outcome(s) of interest; Study design; Outcome assessment via signal identification; Request description; Appendix – Specifications defining event outcome parameters; Appendix – Specifications defining parameters | Variables – Outcome/s; Table – Operational Definitions of Outcomes | Primary objective(s); Secondary objective(s); Outcome(s); Study Endpoint |
| **Follow-up period** | Follow-up time; Study design | Research methods – Follow-up; Table – Primary and secondary research questions and objectives – Time (when follow-up begins and ends) | Overall study duration and follow-up; Analysis of primary and secondary outcomes; Lost-to-follow-up; Exposure; Study design |
| **Covariates** | Characteristics of interest; Baseline characteristics; Appendix – Specifications defining characteristics parameters; Appendix – Specifications defining parameters | Research methods – Other covariates, including confounders, effect modifiers and other variables; Table – Operational Definitions of Covariates | Variables; Variables at baseline; Covariates |
| **Covariate assessment window** | Characteristics of interest; Baseline characteristics; Appendix – Specifications defining characteristics parameters; Appendix – Specifications defining parameters | Research methods – Other covariates, including confounders, effect modifiers and other variables; Table – Operational Definitions of Covariates | Variables; Variables at baseline; Covariates |
| **Ontology used for concept definitions** | Appendix – List of generic and brand drug names; Appendix – List of ICD-9-CM, ICD-10-CM, and HCPCS codes used to define concepts | ANNEXES – Appendix I/II – Preliminary concept definitions/code list for study variables (e.g., exposure, outcomes) | Appendix; Annexes |

---

## Notes

All protocols included in this repository are publicly available documents retrieved from their respective official sources. As no patient-level or personal data were used, ethical approval and informed consent were not required. No modifications were made to the original protocol files.
