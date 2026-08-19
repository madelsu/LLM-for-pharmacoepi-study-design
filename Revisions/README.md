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
