# General-Purpose and Biomedical LLMs for Pharmacoepidemiologic Study Design

Code and data accompanying the manuscript *"Employing General-Purpose and Biomedical Large Language Models with Advanced Prompt Engineering for Pharmacoepidemiologic Study Design"* (Pharmaceutical Research, **Revision 2**).

The study benchmarks five model–prompt configurations — **GPT-4o** (LTM, Active), **DeepSeek-R1** (LTM), **Bio-Medical-Llama-3-8B** (LTM), and **Qwen2-1.5B-medical** (LTM) — against **46 public protocols** (DARWIN EU®/HMA-EMA Catalogue and the Sentinel System), across four outcomes: relevance, GPT-4o-assessed reasoning concordance, human-rated logic of justification, and ontology-code mapping. This release reproduces **every reported statistic, effect size, table, and figure** from the released workbooks and implements all Revision-2 changes.

## Repository structure
```
04_data_corrected_originals/   corrected source workbooks, original + redesigned figures, results
   recreated_excel_file_corrected.xlsx   = Results/Relevance_assessment.xlsx (relevance + reasoning)
   Logic_assessment_corrected.xlsx       human logic-of-justification ratings (MS+XZ consensus)
   Ontology__1.xlsx                      ontology-code mappings (reference OMOP + model outputs)
   validation_sample_filled.xlsx       blinded human validation of GPT-4o scoring
   fig_*.png ; results/ ; results_redesigned/   figures (Comment 4; Figures 1-6)
05_data_derived/               analysis-ready derived tables
   relevance_long_corrected.csv ; reasoning_concordance_long_corrected.csv
   human_logic_long_corrected.csv ; ontology_mappings_metrics.csv (477 mappings)
   protocol_dates_final.csv ; dataflow_table.csv ; error_counts_biomedical.csv
06_code/                       reproduction code
   reproduce_all_analyses.py / .ipynb   end-to-end Python pipeline (all statistics)
   Software_corrected.R                 relevance boxplots + Figure 7 error heatmap
   figures_redesigned_corrected.R       redesigned Figures 1-6 (Reviewer 1)
   Comment_4.R                          missingness / data-flow + adverse-case sensitivity
   Comment_5.R                          ordinal mixed-effects (clmm), paired test, bootstrap
   Validation.R                         blinded-validation sampling + agreement
```

## Reproducing the analyses
**Python (one file reproduces every statistic):**
```bash
pip install pandas numpy scipy openpyxl
python 06_code/reproduce_all_analyses.py     # or open the .ipynb
```
Uses the released filenames (`Relevance_assessment.xlsx`, `Logic_assessment.xlsx`); all worksheets included.

**R (figures + dependence-aware models):**
```r
install.packages(c("openxlsx","ordinal","dplyr","tidyr","ggplot2"))
source("06_code/Comment_5.R")   # clmm mixed-effects, paired Wilcoxon, protocol-cluster bootstrap
source("06_code/Comment_4.R")   # data-flow table, coverage heatmaps, adverse-case sensitivity
source("06_code/Validation.R")  # export blinded sample -> read completed file -> report agreement
source("06_code/figures_redesigned_corrected.R")
```

## Key results (all reproducible)
| Outcome | Result |
|---|---|
| Relevance present | GP 1,058/1,242; Bio 702/828; median 4 vs 3; mean 3.93 vs 2.80 |
| Relevance omnibus | Kruskal-Wallis H = 384.34 (df 4), p < 0.001; rank-biserial r = 0.51 |
| Ordinal mixed-effects (clmm; ref GPT-4o-LTM; random intercept protocol) | BioLlama-LTM beta = -1.44, Qwen2-med-LTM beta = -2.73 (p<0.001); GPT-4o-ACT beta = -0.03 (p=0.83); DeepSeek-R1-LTM beta = +0.30 (p=0.044, not surviving multiple-comparison adjustment) |
| Prompt (GPT-4o LTM vs Active) | paired Wilcoxon p = 0.93; protocol-cluster bootstrap 95% CI [-0.16, +0.15]; unpaired p = 0.55 (workbook reproduction only) |
| Reasoning concordance (agree, partly excluded) | GP 70.7% (705/997) vs Bio 20.2% (135/668); chi-square = 406.1; clmm class beta = -2.52 (p<0.001) |
| Human logic (consensus) | GP 838/1,242 (67.5%); Bio 122/828 (14.7%) - differential, plausibly informative missingness |
| Adverse-case sensitivity | complete-case 4.56 vs 4.16; missing-as-failure 3.40 vs 1.47; best-case bound 4.70 vs 4.88 |
| Blinded validation of GPT-4o scoring | relevance 347/350, reasoning 360/360: 100% agreement (MS-vs-XZ and human-vs-GPT-4o), per configuration |
| Ontology mapping | 477 mappings: 113 matched, 364 errors; omission 268/364 (73.6%), wrong-system/convention 62/364 (17.0%), parent-level 9/364 (2.5%) |
| Ontology set metrics (produced-row basis) | GPT-4o-LTM precision 0.52 / recall 0.28 / F1 0.33 / exact-set 12.5%; by system ICD F1 0.50, ATC 0.35, CPT 0.37, HCPCS 0.32 |
| Protocol dates vs GPT-4o cutoff (Oct 2023) | 36/46 (78%) predate; range 2018-2024 |

## Corrections and clarifications made in Revision 2
- **`sheets[-3]` fixed.** The original `Software.R` dropped the third worksheet (`DARWIN_GPT_LTM`) before the relevance summaries/Figures 1-3, with backup `sheets2` unused. Corrected scripts include **all worksheets**; impact negligible (GP relevance mean 4.00 -> 3.93; medians and ordering unchanged).
- **Released filename.** Scripts now read the released `Relevance_assessment.xlsx` (earlier `recreated_excel_file.xlsx` was an identical local copy).
- **Screening-label mapping (Appendix 1).** `PMC-LLAMA` in the screening workbook = the retained **Bio-Medical-Llama-3-8B** (QuantFactory GGUF Q4_K_M); `mradermacher` = DeepSeek-r1-Medical-Mini-GGUF (no scorable output, 0/7); `Plaban81` = gemma-medical_qa-Finetune; `Irathernotsay` = qwen2-1.5B-medical. Full mapping + decision rule in `Appendix_1`.
- **Column-alignment fix.** The sentinel-gpt-ltm Q7 evaluator-prose/Likert displacement was corrected; those cells were non-numeric (already treated as missing), so no reported statistic changes.
- **Inference environment.** General-purpose models via hosted API at full precision; the biomedical Llama as a GGUF Q4_K_M build - reported as a deployability/precision asymmetry, so conclusions pertain to readily deployable configurations rather than to biomedical specialization per se.

## Data provenance
Relevance and GPT-4o-assessed reasoning concordance were assigned by **GPT-4o** (`gpt-4o-2024-08-06`) as a single automated evaluator against a protocol-derived reference. The reference set and human logic-of-justification ratings were produced by **two pharmacoepidemiologists (MS, XZ)** by plenary consensus. Protocol release dates: DARWIN/HMA-EMA from the HMA-EMA Catalogue export; Sentinel from the Sentinel Initiative catalogue.
