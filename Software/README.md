# Software

This folder contains the R script used for all statistical analyses and visualizations reported in:

> **Employing General-Purpose and Biomedical Large Language Models with Advanced Prompt Engineering for Pharmacoepidemiologic Study Design**

---

## File

| File | Description |
|---|---|
| `Software.R` | Main analysis script — data loading, Likert score processing, figure generation, and error heatmap |

---

## Requirements

### R version
R 4.5.1 or higher is recommended.

### Required packages
Install all dependencies by running the following in R:

```r
install.packages(c(
  "readxl",
  "dplyr",
  "ggplot2",
  "tidyr",
  "openxlsx",
  "writexl",
  "stringr",
  "reshape2"
))
```

| Package | Version used | Purpose |
|---|---|---|
| `readxl` | — | Reading Excel input files |
| `dplyr` | — | Data manipulation |
| `ggplot2` | 3.5.1 | Figure generation |
| `tidyr` | — | Data reshaping |
| `openxlsx` | — | Reading Excel sheet names |
| `writexl` | — | Exporting Excel files |
| `stringr` | — | String operations |
| `reshape2` | — | Reshaping data for heatmap |

---

## Input files

Before running the script, set your working directory at the top of `Software.R`:

```r
setwd("path/to/your/working/directory")
```

The script expects the following input files in your working directory:

| File | Description |
|---|---|
| `relevance_assessment.xlsx` | Excel file containing GPT-4o-assessed relevance scores, with one sheet per LLM–protocol–prompt combination. Within each sheet, columns are organized per question and include: the raw LLM response, the Likert relevance score assigned by GPT-4o, a depth of reasoning field, and a comparison field (e.g., `Q1`, `Q1 Likert scale`, `Q1 depth of reasoning`, `Q1 Comparison`). Each row corresponds to one protocol (identified by `Case.no` and `A.AI`). The script extracts all columns matching `Likert` for analysis. |
| `excel_csv_output/` | Folder containing CSV exports of the sheets from `relevance_assessment.xlsx` |
| `Logic_assessment.xlsx` | Excel file containing logic of justification scores, structured identically to `recreated_excel_file.xlsx` — one sheet per LLM–protocol–prompt combination. Within each sheet, columns are organized per question and include: the GPT Likert score, the GPT response, the human Likert scale rating, a comparison between GPT and human ratings, and a reason/justification field (e.g., `Q9 GPT Likert Scale`, `Q9 GPT response`, `Q9 human Likert scale`, `Q9 Comparison`, `Q9 Reason`). The script extracts columns matching `human Likert` for analysis. |

---

## Output

Running the script will create a `results/` folder in your working directory containing the following files:

| File | Figure | Description |
|---|---|---|
| `summary_results.csv` | — | Summary table of Likert relevance scores across all sheets and questions |
| `summary_results_reasoning.csv` | — | Summary table of logic of justification scores |
| `p_relevance_llm_type.png` | Figure 1 | Relevance scores by LLM architecture, colored by LLM type (biomedical vs non-biomedical) |
| `p_relevance_prompt_type.png` | Figure 2 | Relevance scores by prompt strategy (LTM vs Active Prompt), colored by LLM type |
| `p_relevance_grouped_llmtype.png` | Figure 3 | Relevance scores by protocol source (Sentinel, HMA-EMA, DARWIN), split by LLM type |
| `p_relevance_llm_type_reasoning.png` | Figure 4 | Logic of justification scores by LLM architecture, colored by LLM type |
| `p_relevance_grouped_llmtype_reasoning.png` | Figure 5 | Logic of justification scores by protocol source, split by LLM type |
| `p_relevance_prompt_type_reasoning.png` | Figure 6 | Logic of justification scores by prompt strategy, colored by LLM type |
| `heatmap_llm_errors.png` | Figure 7 | Heatmap of error type frequencies and deviations from the mean across biomedical LLMs (QuantFactory/Bio-Medical-Llama-3-8B and Irathernotsay/qwen2-1.5B) |

All figures are saved at 600 dpi (150 dpi for the heatmap) in PNG format.

---

## Script structure

The script is organized into the following sections:

1. **Setup** — load libraries, set working directory, create output folder
2. **Data loading** — read Excel and CSV input files, extract Likert-scored columns
3. **Relevance analysis** — loop over sheets, compute summary statistics, collect data for plotting
4. **Figures 1–3** — boxplots of relevance scores by LLM architecture, prompt strategy, and protocol source
5. **Logic of justification analysis** — read `Logic_assessment.xlsx`, extract human Likert scores
6. **Figures 4–6** — boxplots of justification scores by LLM architecture, prompt strategy, and protocol source
7. **Figure 7** — error frequency heatmap for biomedical LLMs across 9 pharmacoepidemiological questions

---

## Notes

- Sheet names in the input Excel files are expected to follow the naming convention `[DataSource]-[LLM]-[PromptType]` (e.g., `Darwin-GPT-LTM`, `HMA-Irath-ACT`). The script uses pattern matching on sheet names to classify LLM type, prompt strategy, and protocol source.
- The third sheet in `relevance_assessment.xlsx` is excluded from analysis by default (`sheets <- sheets[-3]`). Adjust this index if your file structure differs.
- Missing or `"N/A"` values in relevance sheets are treated as empty strings; in the reasoning sheet they are treated as `NA` and excluded from summary statistics.
