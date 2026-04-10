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
    ├── relevance_assessment.xlsx    # GPT-4o-assessed relevance scores
    ├── excel_csv_output/            # CSV exports of relevance assessment sheets
    └── logic_assessment.xlsx        # Human-rated logic of justification scores
```

Each subfolder contains a `LINKS.md` file with full citations and links to the original sources of all protocols. The `data/` folder contains its own `README.md` with detailed information on protocol selection, characteristics, and concept extraction mapping.

---

## 💡 Motivation

Pharmacoepidemiology is a field focused on enhancing the understanding of the benefits and risks associated with drug use, with the goal of informing clinical decisions and shaping public health policies. The quality of evidence generated from pharmacoepidemiological studies is directly proportional to the quality of their design and data sources. Rapid evidence generation is crucial for gaining a deeper understanding of the benefits and risks of interventions in diverse populations underrepresented in clinical trials, as well as for evaluating the comparative effectiveness of interventions against standard care.

During the last decade, artificial intelligence (AI) has promised to introduce intelligent automation to optimize time- and resource-demanding steps in pharmacoepidemiology, delivering fast and reliable evidence that meets regulatory standards. More recently, generative AI (GAI) — and large language models (LLMs) in particular — has been envisioned to catalyze this automation. General-purpose LLMs such as ChatGPT, BERT, and Gemini are already applied across numerous biomedical fields and tasks in healthcare. Both the U.S. Food and Drug Administration (FDA) and the European Medicines Agency (EMA) have begun exploring and formalizing the use of LLMs in their regulatory workflows.

However, it remains unclear to what extent LLMs can effectively support pharmacoepidemiological study design. Initial attempts using off-the-shelf general-purpose LLMs have identified key limitations, including coding inaccuracies and suboptimal identification of design elements. It is also unclear whether these limitations stem from the models' training data or the prompting strategies employed. Additionally, concerns have been raised about the reliability of LLMs trained on internet-scale data for research and healthcare purposes, as they may produce inaccurate information lacking scientific rigor. The comparative performance of biomedically fine-tuned LLMs versus general-purpose models in this domain has also remained unknown.

This study addresses these gaps by systematically evaluating both general-purpose and biomedical LLMs, combined with state-of-the-art prompt engineering techniques, across multiple performance dimensions using real-world pharmacoepidemiological study protocols as the benchmark.

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

## 📊 Results summary

GPT-4o and DeepSeek-R1 paired with LTM prompting consistently achieved the highest relevance and logic of justification scores. GPT-4o–LTM reached a median relevance score of 4 in 8 out of 9 questions for HMA-EMA protocols. Biomedical LLMs showed lower overall relevance and frequently produced insufficient justification. All models demonstrated limited proficiency in ontology-code mapping, though LTM provided the most consistent improvements in reasoning stability. Performance was sensitive to protocol source and structure, with HMA-EMA protocols yielding the most stable outputs.

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
