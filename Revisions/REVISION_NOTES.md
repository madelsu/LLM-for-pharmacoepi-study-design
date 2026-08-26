# Revision 2 - response-to-reviewers changelog

Maps each reviewer comment to the change and the artifact that supports it.

**Reviewer 1** - Comment 1: accepted the revised manuscript (no change).

**Reviewer 2**
- **C2 (overview):** summary of (i)-(vii); details under C3-C8.
- **C3 - outcomes & evaluators / self-evaluation.** New Methods "Outcomes and evaluators" subsection (evaluator, raters, blinding, GPT-4o snapshot per outcome). Reasoning relabelled "GPT-4o-assessed reasoning concordance"; full 3-category distribution + sensitivity (Supplementary Table 5/6). Blinded human validation added (relevance 347/350, reasoning 360/360; 100% agreement; kappa undefined with single-category endorsement, reported as percent agreement). sentinel-gpt-ltm Q7 alignment corrected. Limitation on self-evaluation tempered by the validation result.
- **C4 - differential missingness.** Data-flow table for every model-prompt-source (Supplementary Table 3); missingness mechanism (informative/MNAR) stated; adverse-case sensitivity (missing-as-failure) + bounds; Figures 4-6 caution; Figure 5 no source-by-class claim where DARWIN x biomedical = 0; 16th Sentinel row audited/excluded. `Comment_4.R`, `dataflow_table.csv`, `fig_*.png`.
- **C5 - dependence & reproducibility.** Ordinal cumulative-logit **mixed-effects** model with random intercept for protocol; paired Wilcoxon for the model-controlled prompt comparison (p = 0.93) + protocol-cluster bootstrap 95% CI [-0.16, +0.15]; class contrasts descriptive; single end-to-end script using released filenames; `DARWIN_GPT_LTM` inclusion (no `sheets[-3]`). `Comment_5.R`, `reproduce_all_analyses.*`.
- **C6 - concordance vs validity / memorization.** Reframed throughout as concordance with historical reference protocols; protocol-format causal claims removed; protocol release dates for all 46 (Supplementary Table 4); memorization discussed; prospective post-cutoff evaluation identified. `protocol_dates_final.csv`.
- **C7 - comparability / screening / prompt claims.** Inference environment + quantization reported (API full precision vs GGUF Q4_K_M); complete 42-combination screening table with decision rule and label mapping (Appendix 1); Abstract "strongly influenced" removed (paired p = 0.93); prompt comparisons framed as configuration-specific/descriptive. Label mapping: PMC-LLAMA = Bio-Medical-Llama-3-8B (retained); mradermacher = DeepSeek-r1-Medical-Mini (no scorable output); Plaban81 = gemma.
- **C8 - ontology evaluation.** Set-based metrics (precision, recall, F1, Jaccard, exact-set) by configuration and coding system (Supplementary Table 6); native SNOMED CT/RxNorm vs OMOP reported separately as coding-convention differences; taxonomy described as form (not cause); denominator stated (477 mappings, 113 matched, 364 errors); covers 3 of 5 configurations (workbook has GPT-4o LTM/ACT + DeepSeek-R1 only); common-vs-rare not stratified (no frequency measure); crosswalk + concept-identification isolation noted as limitations. `ontology_mappings_metrics.csv`.

## Files added/changed for the revision
- `README.md`, `REVISION_NOTES.md` (this file)
- `Appendix_1` (corrected: actual-model mapping, 5 retained rows, decision-rule legend, set-metrics)
- Supplementary Tables 3-7 (data-flow, dates, ontology taxonomy, error definitions, set metrics)
- `06_code/`: `Comment_4.R`, `Comment_5.R`, `Validation.R`, `reproduce_all_analyses.*`, corrected `Software_corrected.R`, `figures_redesigned_corrected.R`
- `05_data_derived/`: derived long tables + `ontology_mappings_metrics.csv`


## Supplementary table map (final)
T1 TRIPOD-LLM · T2 CHART · T3 data-flow · T4 protocol dates · T5 ontology error taxonomy · T6 set-based ontology metrics · T7 error definitions; Appendix 1 = 42-combination screening.
