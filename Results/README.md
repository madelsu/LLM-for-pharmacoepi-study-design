# 📂 Resource Files

This document describes the input files required to run `Software.R`.

---

## Files

### `relevance_assessment.xlsx`

Excel file containing GPT-4o-assessed relevance scores. The file contains one sheet per LLM–protocol–prompt combination. Within each sheet, columns are organized per question and include the raw LLM response, the Likert relevance score assigned by GPT-4o, a depth of reasoning field, and a comparison field. For example, for Q1 the columns would be: `Q1`, `Q1 Likert scale`, `Q1 depth of reasoning`, `Q1 Comparison`. Each row corresponds to one protocol, identified by `Case.no` and `A.AI`. The script extracts all columns matching `Likert` for analysis.

---

### `excel_csv_output/`

Folder containing CSV exports of the individual sheets from `relevance_assessment.xlsx`. Each CSV corresponds to one sheet (i.e., one LLM–protocol–prompt combination) and follows the same column structure described above.

---

### `Logic_assessment.xlsx`

Excel file containing logic of justification scores, structured identically to `relevance_assessment.xlsx` — one sheet per LLM–protocol–prompt combination. Within each sheet, columns are organized per question and include the GPT Likert score, the GPT response, the human Likert scale rating, a comparison between GPT and human ratings, and a reason/justification field. For example, for Q9 the columns would be: `Q9 GPT Likert Scale`, `Q9 GPT response`, `Q9 human Likert scale`, `Q9 Comparison`, `Q9 Reason`. The script extracts all columns matching `human Likert` for analysis.

---

## Notes

- Sheet names across both Excel files follow the naming convention `[DataSource]-[LLM]-[PromptType]` (e.g., `Darwin-GPT-LTM`, `HMA-Irath-ACT`). The script uses pattern matching on sheet names to classify protocol source, LLM architecture, and prompt strategy.
- Missing or `"N/A"` values in `relevance_assessment.xlsx` are treated as empty strings. In `Logic_assessment.xlsx` they are treated as `NA` and excluded from summary statistics.
