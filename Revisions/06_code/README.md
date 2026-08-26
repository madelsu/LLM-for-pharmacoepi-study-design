# `06_code/` — reproduction code

This folder reproduces **every statistic, table, and figure** reported in the
manuscript (Pharmaceutical Research, Revision 2). Each script is standalone and
reads the released workbooks directly; nothing here calls an LLM API (the model
outputs were generated earlier and are stored in the workbooks).

---

## 0. Inputs (place these in the working directory, or run from `04_data_corrected_originals/`)

| Released name | Corrected copy in this repo | Content |
|---|---|---|
| `Relevance_assessment.xlsx` | `recreated_excel_file_corrected.xlsx` | GPT-4o relevance Likert (`Q*.Likert.scale`) **and** GPT-4o depth-of-reasoning (`Q*.depth.of.reasoning`) |
| `Logic_assessment.xlsx` | `Logic_assessment_corrected.xlsx` | Human logic-of-justification Likert (`Q* human Likert scale`) |
| `Ontology__1.xlsx` | — | Ontology-code mappings (reference OMOP + model outputs) |
| `validation_sample_filled.xlsx` | — | Blinded human validation, filled by the two raters |

Every script **auto-resolves** the filename: it tries the released name first, then
the `_corrected` copy, so it runs unchanged whichever variant is present.

## Dependencies
- **Python:** `pandas numpy scipy statsmodels openpyxl`  ← note: `statsmodels` is required (for the GEE cross-check) and should be added to `requirements.txt`.
- **R:** `openxlsx ordinal dplyr tidyr ggplot2` (see `../install_R_packages.R`).

---

## 1. `reproduce_all_analyses.py`  (and identical `.ipynb`)
**One-file Python pipeline — run this first for all the numbers.**

```bash
pip install pandas numpy scipy statsmodels openpyxl
python reproduce_all_analyses.py
```
Writes `dataflow_table.csv` and `ontology_setmetrics.csv`; prints six blocks:

| Printed block | Reproduces in the manuscript |
|---|---|
| **§1 Data-flow table** | Supplementary Table 3; coverage general-purpose **1,058/1,242** & biomedical **702/828** relevance, human-logic **838/122** |
| **§2 Kruskal–Wallis** | relevance omnibus **H = 384.34, p < 0.001**. *The ordinal model printed here is a Python **GEE cross-check** — the coefficients REPORTED in the paper are the mixed-effects **clmm** from `Comment_5.R` (see note in the script).* |
| **§3 Prompt LTM vs Active** | paired Wilcoxon **p = 0.93**; protocol-cluster bootstrap 95% CI **[−0.16, +0.15]**; unpaired **p = 0.55** (workbook reproduction only) |
| **§4 Reasoning concordance** | **70.7% (705/997) vs 20.2% (135/668)**, χ² = **406**; 3-category distribution (705/292/110; 135/533/34); sensitivity partly-agree=acceptable **73.6% vs 24.1%**, =unacceptable **63.7% vs 19.2%** |
| **§5 Human logic** | complete-case means **4.56 vs 4.16**; differential coverage |
| **§6 Ontology set-metrics** | **477 mappings, 113 matched, 364 errors**; GPT-4o-LTM precision **0.52** / recall 0.28 / F1 **0.33** / exact-set 12.5%; by system ICD F1 **0.50**; convention cases **60**; omissions **268** → Supplementary Tables 5 & 6 |

## 2. `Comment_5.R`  — **primary statistical model (Comment 5)**
```r
source("Comment_5.R")
```
Produces the **mixed-effects coefficients reported in the manuscript** (ordinal
cumulative-link mixed model, random intercept for protocol, `ordinal::clmm`):

| Output | Manuscript value |
|---|---|
| Kruskal–Wallis | **H = 384.34** |
| clmm, ref GPT-4o-LTM | BioLlama-LTM **β = −1.44**; Qwen2-med-LTM **β = −2.73**; DeepSeek-R1-LTM **β = +0.30 (p = 0.044)**; GPT-4o-ACT **β = −0.03 (p = 0.83)**; sourceHMA-EMA **+1.63**; sourceSentinel **−0.21** |
| Prompt LTM vs Active | paired **p = 0.93**; bootstrap **[−0.16, +0.15]**; unpaired **p = 0.55** |
| Relevance (descriptive) | median **4 vs 3**; mean **3.93 vs 2.80**; rank-biserial **r = 0.51** |
| Reasoning concordance | **70.7% vs 20.2%**; reasoning clmm class contrast **β = −2.52 (p < 0.001)** |

> This is the script that regenerates the coefficients cited in Results §relevance and §reasoning.

## 3. `Comment_4.R`  — differential missingness + adverse-case (Comment 4)
```r
source("Comment_4.R")
```
Writes `dataflow_table.xlsx` and four figures; reproduces:

| Output | Manuscript |
|---|---|
| Data-flow / coverage table | Supplementary Table 3; relevance ~85% coverage, human-logic **67.5%** (GP) vs **15%** (Bio) |
| Adverse-case sensitivity (human logic) | complete-case **4.56 vs 4.16**; missing-as-failure **3.40 vs 1.47**; best-case bound **4.70 vs 4.88** |
| `fig_coverage_all_outcomes.png`, `fig_humanlogic_coverage.png`, `fig_humanlogic_gaps.png`, `fig_sensitivity_missingness.png` | support the Comment-4 caution on interpreting Figures 4–6 |

## 4. `Validation.R`  — blinded human validation (Comment 3)
Two steps:
```r
source("Validation.R")   # STEP 1 writes validation_sample.xlsx (blank template)
# raters fill the 'agreement' column -> validation_sample_filled.xlsx
# re-run STEP 2 block to score the filled file
```
Reproduces the validation reported in Methods/Results:

| Output | Manuscript |
|---|---|
| Relevance validation | **347/350** scored, **100%** agreement (expert-vs-expert and human-vs-GPT-4o); per-config n = **70, 70, 70, 67, 70** |
| Reasoning-concordance validation | **360/360**, **100%** agreement; per-config n = **72** each |

## 5. `Software_corrected.R`  — relevance figures + error heatmap
```r
source("Software_corrected.R")
```
Writes to `results/`: `p_relevance_*.png`, `heatmap_llm_errors.png` (**Supplementary Figure 1**),
`summary_results.csv`, `summary_results_reasoning.csv`.
Includes the **`sheets[-3]` correction** (the `DARWIN_GPT_LTM` worksheet is retained;
general-purpose relevance mean 4.00 → **3.93**, medians and ordering unchanged).

## 6. `figures_redesigned_corrected.R`  — main-text Figures 1–6 (Reviewer 1)
```r
source("figures_redesigned_corrected.R")
```
Writes to `results_redesigned/` the redesigned main-text figures:

| File | Manuscript figure |
|---|---|
| `Fig1_relevance_LLM_divergingbar.png` | Figure 1 — relevance by model |
| `Fig2_relevance_prompt_bubble.png` | Figure 2 — relevance by prompt |
| `Fig3_relevance_source_histogram.png` | Figure 3 — relevance by source |
| `Fig4_logic_LLM_heatmap.png` | Figure 4 — logic by model |
| `Fig5_logic_source_lollipop.png` | Figure 5 — logic by source |
| `Fig6_logic_prompt_violin.png` | Figure 6 — logic by prompt |

---

## Suggested run order
1. `reproduce_all_analyses.py` — all headline statistics in one pass.
2. `Comment_5.R` — the mixed-effects coefficients as reported (clmm).
3. `Comment_4.R` — missingness table + adverse-case + coverage figures.
4. `Validation.R` — 100%-agreement validation.
5. `Software_corrected.R` and `figures_redesigned_corrected.R` — figures.

Scripts are independent and can be run in any order; only `Validation.R` STEP 2
needs the filled `validation_sample_filled.xlsx` (already provided).

## One deliberate reporting difference
`reproduce_all_analyses.py` prints omissions as a share of **all** mappings
(“268/477, 56.2%”); the manuscript reports them as a share of **errors**
(“268/364, 73.6%”). The count (**268**) is identical; only the denominator differs.
