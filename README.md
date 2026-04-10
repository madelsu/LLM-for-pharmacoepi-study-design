# 💊 Employing General-Purpose and Biomedical Large Language Models with Advanced Prompt Engineering for Pharmacoepidemiologic Study Design

This repository contains the data, code, and documentation supporting the study evaluating the performance of general-purpose and biomedical large language models (LLMs) in supporting pharmacoepidemiological study design, using advanced prompt engineering strategies.

---

## 📁 Overview

```
llm-pharmacoepi-study-design/
├── data/
│   ├── darwin/              # 16 DARWIN EU® protocols
│   ├── hma-ema/             # 15 non-DARWIN HMA-EMA Catalogue protocols
│   ├── sentinel/            # 15 Sentinel System protocols
│   └── pre-assessment/      # 3 protocols used to select the Top-5 LLM–prompt combinations
├── software/
│   ├── Software.R           # R script for all analyses and figures
│   └── PROMPTS.md           # Active Prompting and LTM prompt templates
└── results/
    ├── relevance_assessment.xlsx    # Relevance scores
    ├── excel_csv_output/            # CSV exports of relevance assessment sheets
    └── logic_assessment.xlsx        # Logic of justification scores
```

Each subfolder contains a `LINKS.md` file with full citations and links to the original sources of all protocols. The `data/` folder contains its own `README.md` with detailed information on protocol selection, characteristics, and concept extraction mapping.

---

## 💡 Motivation

Pharmacoepidemiology focuses on understanding the benefits and risks of drug use to inform clinical decisions and public health policy.[^1] The quality of evidence it generates depends directly on the quality of study design.[^2][^3] Over the last decade, AI — and more recently large language models (LLMs) — has been envisioned to automate and accelerate time-intensive steps in this process. General-purpose LLMs are already applied across numerous biomedical fields and tasks in healthcare,[^4][^5] but little is currently known regarding their application in pharmacoepidemiological study design.

However, it remains unclear to what extent LLMs can reliably support pharmacoepidemiological study design. Initial attempts have revealed limitations including coding inaccuracies and suboptimal identification of design elements, with uncertainty about whether these stem from training data or prompting strategies. Concerns also persist about the reliability of internet-trained models for research purposes, and the comparative value of biomedically fine-tuned LLMs over general-purpose models in this domain remains unknown.

This study addresses these gaps by systematically evaluating general-purpose and biomedical LLMs combined with state-of-the-art prompt engineering techniques, benchmarked against real-world pharmacoepidemiological study protocols.

[^1]: Strom, B.L., Kimmel, S.E. and Hennessy, S. (2020). *Pharmacoepidemiology*. Hoboken, NJ: Wiley-Blackwell.
[^2]: Rim, J.G., Jackman, J.G., Hornik, C.P., et al. (2024). Accelerating evidence generation: Addressing critical challenges and charting a path forward. *Journal of Clinical and Translational Science*, 8(1). https://doi.org/10.1017/cts.2024.621
[^3]: Califf, R.M. (2023). Now is the time to fix the evidence generation system. *Clinical Trials*, 20(1). https://doi.org/10.1177/17407745221147689
[^4]: SAP. (2024). What is a large language model (LLM)? Available at: https://www.sap.com/resources/what-is-large-language-model
[^5]: Holdsworth, J. and Stryker, C. (2024). What is natural language processing? IBM. Available at: https://www.ibm.com/topics/natural-language-processing
---

## 🔬 Methodology

A total of 46 publicly available pharmacoepidemiological study protocols (2018–2024) were retrieved from the HMA-EMA Catalogue of Real-World Data Studies (including all available DARWIN EU® protocols) and the Sentinel System. These protocols served as the human expert gold standard against which LLM outputs were evaluated.

Two general-purpose LLMs (GPT-4o and DeepSeek-R1) and two biomedically fine-tuned LLMs (QuantFactory/Bio-Medical-Llama-3-8B-GGUF and Irathernotsay/qwen2-1.5B-medical_qa-Finetune) were evaluated using two advanced prompt engineering strategies: Least-to-Most (LTM) prompting and Active Prompting. The nine pharmacoepidemiological concepts assessed were selected based on the HARPER checklist.

Model outputs were evaluated across four dimensions:

- **Relevance** — degree of concordance with human expert answers, assessed by GPT-4o on a 5-point Likert scale
- **Logic of justification** — soundness and coherence of model reasoning, assessed by a human rater on a 5-point scale
- **Ontology-code agreement** — percentage agreement between LLM-generated codes and reference codes from the protocols across multiple coding systems (ICD-9, ICD-10, ATC, CPT, HCPCS, SNOMED, RxNorm)
- **Error frequency** — qualitative review of predefined error types across model outputs

---

## 🛠️ Technical stack

All statistical analyses and visualizations were performed in R (version 4.5.1).

| Package | Version | Purpose |
|---|---|---|
| `ggplot2` | 3.5.1 | Box plots and bar charts |
| `tidyverse` | 2.0.0 | Data handling and plotting |
| `readxl` | — | Reading Excel input files |
| `dplyr` | — | Data manipulation |
| `tidyr` | — | Data reshaping |
| `openxlsx` | — | Reading Excel sheet names |
| `writexl` | — | Exporting Excel files |
| `stringr` | — | String operations |
| `reshape2` | — | Reshaping data for heatmap |

See `software/README.md` for full setup and usage instructions.

---

## 🗂️ Data

All 46 study protocols used in this analysis are publicly available documents retrieved from their respective official sources:

- [HMA-EMA Catalogue of Real-World Data Studies](https://catalogues.ema.europa.eu/node/491/field_ema_web_summary_of_studies/summary)
- [Sentinel System](https://www.sentinelinitiative.org/methods-data-tools/sentinel-distributed-database/distributed-database-studies)

No modifications were made to the original protocol files. Full citations and links for all 46 protocols are provided in the `LINKS.md` files within each data subfolder. See `data/README.md` for a detailed description of the dataset, selection criteria, and concept extraction mapping.

---

## ⚖️ Ethics and data use

All protocols included in this repository are publicly available documents retrieved from their respective official regulatory sources. As no patient-level or individual-level data were used at any stage of this study, ethical approval and informed consent were not required. This repository does not contain any personally identifiable information.

---

## 🔁 License and reproducibility

The workflow is fully reproducible. All code, package versions, data extraction rules, and transformations are documented in this repository. 

---

## 📖 Citation

If you use this code, data, or methodology in your research, please cite the original article:

```
@article{[to be completed upon publication],
  author  = {[authors]},
  title   = {Employing General-Purpose and Biomedical Large Language Models with Advanced Prompt Engineering for Pharmacoepidemiologic Study Design},
  year    = {[year]},
  journal = {[journal]}
}
```

*This section will be updated with the full citation upon publication.*

---

## 📬 Contact and support

For questions, issues, or collaboration opportunities:

- **Email:** maurizio.sessa@sund.ku.dk
- **Corresponding author:** Maurizio Sessa
- **Institution:** Department of Drug Design and Pharmacology, University of Copenhagen

Please open a [GitHub Issue](../../issues) for bug reports or technical questions related to the code.
