# Revision 2 — Resubmission Package

**Manuscript:** *Employing General-Purpose and Biomedical Large Language Models with Advanced Prompt Engineering for Pharmacoepidemiologic Study Design*
**Journal:** *Pharmaceutical Research*
**Revision round:** 2

This package contains the point-by-point response, the tracked-changes manuscript, the supplementary tables, the corrected source data, the derived analysis datasets, and a single end-to-end reproducible analysis script. Every reported value has been recomputed from the released data and cross-checked against the manuscript, the response letter, and the reviewer's stated figures.

---

## 1. Overview of this revision

Reviewer #1 accepted the manuscript. Reviewer #2 raised eight detailed methodological comments (C1–C8). The revision addresses each of them:

| Comment | Topic | How it was addressed |
|---|---|---|
| C1 | Acceptance | Acknowledged. |
| C2 | Overview of concerns | Summary of the changes below. |
| C3 | Outcome provenance; two "logic" constructs; a column-alignment error; the 70.7%/20.2% figure | Methods now specify each outcome's evaluator, rater count, and blinding; the two constructs are separated and relabelled; the *sentinel-gpt-ltm* Q7 displacement is corrected; the denominator rule is disclosed and sensitivity analyses added. |
| C4 | Differential missingness | A full data-flow table (Supplementary Table S1) is added; coverage is reported by configuration and source; spurious rows are removed; adverse-case sensitivity analyses are described; Figures 4–6 carry an explicit caution. |
| C5 | Dependence/clustering; paired prompt structure; reproducibility | Relevance is re-analysed with an ordinal cumulative-logit model with protocol-level clustering; the prompt comparison uses a paired test plus a protocol-cluster bootstrap; class contrasts are descriptive; a single end-to-end script reproduces every statistic. |
| C6 | Concordance vs validity; protocol format; memorization | The study is reframed as concordance with reference protocols; protocol-format causal claims are removed; protocol release dates and a memorization caveat are added. |
| C7 | Comparator/screening; inference environment; prompt claims | The complete 42-configuration screening table (Supplementary Table S4) is added; the inference environment and quantization are reported; the "strongly influenced" prompt claim is removed. |
| C8 | Ontology evaluation | Set-based metrics (precision, recall, F1, Jaccard, exact-set) are reported; native-vs-OMOP cases are treated separately as coding-convention differences; the error taxonomy is reconciled with the narrative. |

---

## 2. Package contents

```
README.md                              this file
01_rebuttal/
    Rebuttal_letter_revised_R2.docx    point-by-point responses (C1–C8)
02_manuscript/
    Manuscript_revised_track_R2.docx   manuscript with tracked changes (author: revision)
03_supplementary/
    Supplementary_Tables_R2.docx       S1 data-flow; S2/S3 ontology set-metrics;
                                       S4 screening (42 configurations); S5 protocol dates
    Supplementary_screening_and_dates.xlsx   source tables for S4/S5
04_data_corrected_originals/
    recreated_excel_file_corrected.xlsx      relevance workbook, corrections applied in place
    Logic_assessment_corrected.xlsx          human-logic workbook, corrections applied in place
05_data_derived/
    analysis_datasets_corrected.xlsx         all cleaned long-format datasets + summary tables
    relevance_long_corrected.csv
    human_logic_long_corrected.csv
    reasoning_concordance_long_corrected.csv
    ontology_mappings_metrics.csv            per-mapping set-metrics + error taxonomy
    dataflow_table.csv
    protocol_dates_final.csv
    error_counts_biomedical.csv              §3.5 error-type tabulation (from Software.R)
06_code/
    reproduce_all_analyses.ipynb             end-to-end reproducible pipeline (Colab-ready)
    reproduce_all_analyses.py                script mirror
```

To reproduce every statistic: open `06_code/reproduce_all_analyses.ipynb` in Google Colab, upload the three source workbooks (`recreated_excel_file.xlsx`, `Logic_assessment.xlsx`, `Ontology__1_.xlsx`), and run all cells.

---

## 3. Data corrections applied (audited)

All corrections were confirmed against the raw workbooks. None changes any substantive conclusion.

1. **sentinel-gpt-ltm, Q7 column displacement.** The "Q7 human Likert scale" column held evaluator prose in 12 of 15 rows, with the GPT Likert value displaced into the adjacent response column. The workbook is realigned (GPT Likert restored, human rating left blank as genuinely missing). Because these cells were non-numeric, they were already treated as missing in every summary, so no reported statistic changes. An audit of all sheets and questions found no other displacement.
2. **Spurious extra rows removed.** A populated 16th row in *sentinel-llama-ltm* and an analogous 16th row in *hma-irath-ltm* (both outside the 15 Sentinel/HMA protocols) are excluded from all numerators. Spillover rows beyond the protocol count in the GPT-LTM relevance sheets are removed.
3. **Protocol restriction.** All sheets are restricted to the pre-specified 46 protocols (DARWIN = 16, HMA-EMA = 15, Sentinel = 15) × 9 questions × configuration.
4. **DARWIN_GPT_LTM inclusion.** The original `Software.R` dropped this worksheet (`sheets[-3]`) before building the relevance summaries/Figures 1–3; this was an inadvertent artefact. It is now included. Impact is negligible (general-purpose relevance mean 4.00 → 3.92; all medians and the class gap unchanged).

---

## 4. Evaluator provenance

- **Relevance (1–5)** and **reasoning-concordance (Agree/Disagree/Partly agree)** were assigned by **GPT-4o** (snapshot `gpt-4o-2024-08-06`) acting as a single automated evaluator. The potential for model-family self-evaluation bias is disclosed as a limitation.
- **Human logic of justification** (Figures 4–6) and the **protocol-derived reference set** were produced by **two pharmacoepidemiologists (M. Sessa and X. Zhang)**, who discussed all items and reached consensus in plenary discussion (a single agreed value per item). Because ratings were reconciled to consensus rather than scored independently, a formal independent inter-rater reliability is not reported.

**Inference environment.** GPT-4o (`gpt-4o-2024-08-06`) and DeepSeek-R1 were accessed through hosted APIs at full precision. Bio-Medical-Llama-3-8B was run as a GGUF-quantized build (`QuantFactory/Bio-Medical-Llama-3-8B-GGUF`, Q4_K_M) and Qwen2-1.5B-medical from its public checkpoint. This precision/quantization asymmetry is disclosed as a confound.

---

## 5. Key results (verified against raw data)

**Relevance**
- Coverage: general-purpose 1058/1242 (85.2%), biomedical 702/828 (84.8%).
- Median 4 (general-purpose) vs 3 (biomedical); rank-biserial r = 0.51 (reported descriptively).
- Kruskal-Wallis across 5 configurations: H = 384.3.
- Dunn post-hoc: the three general-purpose configurations do not differ (adjusted p = 1.00); each exceeds both biomedical configurations (adjusted p < 0.001).
- Prompt (GPT-4o LTM vs Active): paired Wilcoxon p = 0.93 (unpaired p = 0.55); protocol-cluster bootstrap mean-difference 95% CI [−0.16, +0.16].
- Ordinal GEE (protocol-clustered): BioLlama β = −1.36, Qwen2-med β = −2.50 (p < 0.001); Active β = −0.06 (p = 0.69).

**Reasoning-concordance (GPT-4o-assessed; distinct from human logic)**
- Distribution — general-purpose 705/292/110; biomedical 135/533/34.
- Excluding "partly agree": 70.7% vs 20.2% (χ² = 406.1, p < 0.001).
- Sensitivity — "partly agree" as acceptable: 73.6% vs 24.1%; as unacceptable: 63.7% vs 19.2%.

**Human logic (differential missingness)**
- Coverage: general-purpose 838/1242 (67.5%), biomedical 122/828 (14.7%). GPT-4o-LTM has 0/135 for Sentinel; DeepSeek-R1-LTM has 56/144 for DARWIN; neither biomedical model has DARWIN human ratings.

**Ontology-code mapping (3 of 5 configurations; the workbook contains only GPT-4o and DeepSeek columns)**
- 477 mappings; 113 correct; 364 errors.
- Taxonomy: omission 268/364 (73.6%); wrong-system 62/364 (17.0%); overly broad/parent-level 9/364 (2.5%); correct-system non-matching 18/364 (4.9%); malformed 5/364 (1.4%); ingredient-vs-product 1; clinical-vs-administrative 1.
- Set-metrics (GPT-4o-LTM): precision 0.52, recall 0.28, F1 0.33, exact-set 12.5%. By system: ICD F1 0.50; ATC/CPT/HCPCS F1 0.32–0.37; SNOMED/RxNorm ≈ 0 (native-vs-OMOP coding-convention differences, reported separately).

**Biomedical error types (§3.5; from the Software.R error matrix, two biomedical models × Q1–Q10)**
- Irrelevant auto-generated questions 189; lack of justification 105; long answers 36; non-adherence 11; remaining types (incomplete answer, model crash, inconsistency, prompt echoing, overuse of conditional language, instruction drift) less frequent.

---

## 6. Consistency and verification

Every value above was recomputed from the released workbooks and cross-checked three ways: (i) internal consistency across the Abstract, Results, Discussion, figures, and supplementary tables; (ii) agreement with the response letter and the derived datasets; and (iii) agreement with every figure the reviewer stated (70.7%/20.2%; 705/292/110; the Q7 12-of-15 displacement; 838/1242 and 122/828; 0/135 and 56/144; 1058/1242 and 702/828; unpaired p = 0.55; PMC-LLAMA Plan-and-Solve 3.70 vs LTM 3.59; and the 268/62/9 error taxonomy). The reasoning-concordance figure is 70.7% (general-purpose 705/292/110); it is computed over all reasoning-concordance labels, independently of relevance completeness. The official repository (`Results/Relevance_assessment.xlsx`) reproduces these same values.

---

## 7. Items to finalise before submission

- **Protocol year distribution.** The manuscript's year breakdown is being verified/corrected manually by the authors; `protocol_dates_final.csv` (Sentinel from the Sentinel Initiative catalogue; DARWIN/HMA-EMA from the HMA-EMA Catalogue export) is provided for reference.
- **Descriptive counts (§3.1).** Study topics and data-source counts derive from protocol metadata compiled by the authors; they are internally consistent (topics sum to 46) but were not independently recomputed here.
- **Supplementary numbering.** The new tables are provided as a standalone document (S1–S5); they can be merged into the existing supplementary file and renumbered to fit the journal's scheme.
