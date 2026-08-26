###############################################################################
# Redesigned manuscript figures (Reviewer 1, Comment 3)
#
# The original Figures 1-6 were all faceted box plots, which the reviewer noted
# look too similar. This script reproduces the SAME six analyses, with the SAME
# groupings/combinations shown in the original box plots, but each rendered with
# a DISTINCT, fit-for-purpose visualization type:
#
#   Fig | Original grouping (matches box plot)      | New chart type
#   ----|--------------------------------------------|--------------------------
#   1   | Relevance  x LLM        (4 LLMs)            | diverging stacked Likert bar
#   2   | Relevance  x Prompt     (LTM/ACT)          | bubble plot (facet by class)
#   3   | Relevance  x Source     (3 sources)         | faceted histogram
#   4   | Logic      x LLM        (4 LLMs)            | annotated heatmap
#   5   | Logic      x Source     (3 sources)         | Cleveland lollipop (+/- SEM)
#   6   | Logic      x Prompt     (LTM/ACT)          | violin + jitter
#
# As in the original box plots, the four LLMs are GPT-4 and DEEPSEEK
# (Non-Biomedical) and Irath and LLaMA (Biomedical); colour encodes LLM class.
# Prompt comparisons contain ACT only for GPT (the others were run with LTM only),
# exactly as in the source data and the original figures.
#
# Data sources (same as the original Software.R):
#   - recreated_excel_file.xlsx : Q*.Likert.scale = relevance (1-5)
#   - Logic_assessment.xlsx     : "Q* human Likert scale" = logic of justification (1-5)
###############################################################################

suppressPackageStartupMessages({
  library(openxlsx); library(dplyr); library(tidyr); library(stringr)
  library(ggplot2); library(forcats); library(scales)
})
# NOTE: read with openxlsx, NOT readxl. Some qualitative cells contain non-BMP
# emoji (e.g. U+1F7E9) that crash readxl ("invalid Unicode point 56063").
# openxlsx tolerates them. read.xlsx() turns spaces in headers into ".", so the
# header matching below uses loose grep() patterns.

setwd("04_data_corrected_originals")


results_dir <- "results_redesigned"; dir.create(results_dir, showWarnings = FALSE)
rel_path   <- "recreated_excel_file_corrected.xlsx"
logic_path <- "Logic_assessment_corrected.xlsx"

# ---- labels / palette matching the original box plots ------------------------
# Change these display names here if you prefer the full model names from the
# manuscript text (e.g. "GPT-4o", "DeepSeek-R1", "Qwen2-1.5B-medical",
# "Bio-Medical-Llama-3-8B"). The grouping/colours are unaffected.
LLM_LEVELS <- c("LLaMA","Irath","GPT-4","DEEPSEEK")        # top -> bottom as in box plots
BIOMED     <- c("Irath","LLaMA")                            # the two biomedical models
GP_COL <- "#1f9e9e"; BM_COL <- "#e8745b"                   # teal / salmon (box-plot scheme)
class_pal <- c("Non-Biomedical" = GP_COL, "Biomedical" = BM_COL)

theme_pub <- theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"),
        plot.background = element_rect(fill = "white", colour = NA),
        panel.background = element_rect(fill = "white", colour = NA))

# ---- parse a sheet name into source / llm / prompt ---------------------------
parse_meta <- function(sheet) {
  U <- toupper(sheet)
  tibble(
    sheet  = sheet,
    source = case_when(str_detect(U,"DARWIN") ~ "DARWIN",
                       str_detect(U,"HMA|EMA") ~ "HMA-EMA",
                       str_detect(U,"SENTINEL") ~ "Sentinel", TRUE ~ "Other"),
    llm    = case_when(str_detect(U,"GPT") ~ "GPT-4",
                       str_detect(U,"DEEPSEEK") ~ "DEEPSEEK",
                       str_detect(U,"IRATH|QWEN") ~ "Irath",
                       str_detect(U,"LLAMA|BIO") ~ "LLaMA", TRUE ~ "Other"),
    prompt = case_when(str_detect(U,"LTM") ~ "LTM",
                       str_detect(U,"ACT") ~ "ACT", TRUE ~ "Other"))
}
add_class <- function(df) df %>%
  mutate(class = ifelse(llm %in% BIOMED, "Biomedical", "Non-Biomedical"),
         llm   = factor(llm, levels = LLM_LEVELS))

# Pre-specified protocol counts (46 protocols = 16 + 15 + 15).
# Used to remove spurious spillover / extra 16th rows that lie beyond the
# 46 protocols in some worksheets (Revision 2 data audit).
PROT <- c(DARWIN = 16L, "HMA-EMA" = 15L, Sentinel = 15L)

# ---- generic long-format loader for a per-question metric --------------------
load_metric <- function(path, col_regex, value_name) {
  sheets <- getSheetNames(path)
  out <- lapply(sheets, function(sh) {
    d <- read.xlsx(path, sheet = sh); meta <- parse_meta(sh)
    ## CORRECTION (Rev.2): restrict each sheet to its pre-specified protocol
    ## count, dropping spurious spillover rows (e.g. DARWIN_GPT_LTM rows 17+,
    ## blank Case.no) and the extra 16th rows in sentinel-llama / hma-irath.
    if (meta$source %in% names(PROT)) {
      d <- d[seq_len(min(nrow(d), PROT[[meta$source]])), , drop = FALSE]
    }
    cols <- grep(col_regex, names(d), value = TRUE, ignore.case = TRUE)
    lapply(cols, function(cn) {
      q <- as.integer(str_extract(cn, "[0-9]+"))
      ## NOTE (Rev.2): as.numeric() coerces the mis-aligned sentinel-gpt-ltm Q7
      ## evaluator prose to NA (a genuinely-missing human rating), which is then
      ## dropped by the !is.na(value) filter below. No further Q7 fix is needed.
      tibble(meta, question = q, value = suppressWarnings(as.numeric(d[[cn]])))
    }) %>% bind_rows()
  }) %>% bind_rows()
  out %>% filter(source != "Other", llm != "Other", prompt != "Other", !is.na(value)) %>%
    add_class() %>% rename(!!value_name := value)
}

rel   <- load_metric(rel_path,   "Likert",       "relevance")          # Q*.Likert.scale
# logic: match "human Likert" (5-point human rating) in Logic_assessment.xlsx
logic <- load_metric(logic_path, "human.*Likert", "logic")

# ============================================================
# (Rev.2) SELF-CHECK — confirms the corrections took effect
# ============================================================
cat("\n===== Rev.2 self-check (figures_redesigned) =====\n")
cat("Relevance present by class (expect Non-Biomedical = 1058, Biomedical = 702):\n")
print(as.data.frame(rel   %>% count(class, name = "n")))
cat("Human-logic present by class (expect Non-Biomedical = 838, Biomedical = 122):\n")
print(as.data.frame(logic %>% count(class, name = "n")))
cat("DARWIN + GPT-4 + LTM relevance rows (must be > 0 => DARWIN_GPT_LTM included):",
    nrow(rel %>% filter(source == "DARWIN", llm == "GPT-4", prompt == "LTM")), "\n")
cat("=================================================\n\n")

#==============================================================================
# FIGURE 1 - diverging stacked Likert bar : relevance distribution x LLM
#==============================================================================
lik <- rel %>% count(llm, relevance) %>% group_by(llm) %>%
  mutate(pct = 100*n/sum(n)) %>% ungroup() %>%
  mutate(relevance = factor(relevance, levels = 1:5)) %>%
  arrange(llm, relevance) %>% group_by(llm) %>%
  mutate(off = -(sum(pct[relevance %in% c("1","2")]) + sum(pct[relevance=="3"])/2),
         xmin = off + cumsum(lag(pct, default = 0)), xmax = xmin + pct) %>% ungroup()
likpal <- c("1"="#b2182b","2"="#ef8a62","3"="#f7f7f7","4"="#67a9cf","5"="#2166ac")
ylab_cols <- class_pal[ifelse(LLM_LEVELS %in% BIOMED,"Biomedical","Non-Biomedical")]
f1 <- ggplot(lik) +
  geom_rect(aes(xmin=xmin, xmax=xmax,
                ymin=as.integer(llm)-0.4, ymax=as.integer(llm)+0.4, fill=relevance),
            colour="white") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey30") +
  scale_y_continuous(breaks = seq_along(LLM_LEVELS), labels = LLM_LEVELS) +
  scale_fill_manual(values = likpal, name = "Likert") +
  labs(
       x = "Percent of protocol-questions  (lower <- | -> higher relevance)", y = NULL) +
  theme_pub + theme(axis.text.y = element_text(colour = rev(ylab_cols)))
ggsave(file.path(results_dir,"Fig1_relevance_LLM_divergingbar.png"), f1, width=9, height=3.8, dpi=600, bg="white")

#==============================================================================
# FIGURE 2 - bubble plot : mean relevance x prompt strategy (facet by class)
#==============================================================================
bub <- rel %>% group_by(class, prompt, question) %>%
  summarise(mean_rel = mean(relevance), .groups = "drop") %>%
  mutate(prompt = factor(prompt, levels = c("ACT","LTM")),
         ypos   = as.integer(prompt) + ifelse(class == "Biomedical", -0.18, 0.18))

f2 <- ggplot(bub, aes(x = factor(question), y = ypos, colour = class, size = mean_rel)) +
  geom_hline(yintercept = 1.5, colour = "grey85") +
  geom_point(alpha = 0.85) +
  geom_text(aes(label = sprintf("%.1f", mean_rel)), size = 2, colour = "grey15") +
  scale_y_continuous(breaks = c(1, 2), labels = c("ACT", "LTM"), limits = c(0.5, 2.5)) +
  scale_colour_manual(values = class_pal, name = "Model class") +
  scale_size_continuous(range = c(3, 11), guide = "none") +
  scale_x_discrete(labels = function(x) paste0("Q", x)) +
  labs(x = "Pharmacoepidemiologic concept", y = "Prompt") +
  theme_pub
ggsave(file.path(results_dir,"Fig2_relevance_prompt_bubble.png"), f2, width=10, height=3.2, dpi=600, bg="white")

#==============================================================================
# FIGURE 3 - faceted histogram : relevance x protocol source (fill by class)
#==============================================================================
f3 <- ggplot(rel, aes(x = relevance, fill = class)) +
  geom_histogram(binwidth = 1, position = "identity", alpha = 0.6, colour = "white") +
  facet_wrap(~ factor(source, levels = c("DARWIN","HMA-EMA","Sentinel"))) +
  scale_fill_manual(values = class_pal, name = "Model class") +
  scale_x_continuous(breaks = 1:5) +
  labs(
       x = "Relevance (1-5)", y = "Count") +
  theme_pub
ggsave(file.path(results_dir,"Fig3_relevance_source_histogram.png"), f3, width=10.5, height=3.6, dpi=600, bg="white")

#==============================================================================
# FIGURE 4 - annotated heatmap : mean logic of justification x LLM x concept
#==============================================================================
hm <- logic %>% group_by(llm, question) %>% summarise(val = mean(logic), .groups="drop")
f4 <- ggplot(hm, aes(x = factor(question), y = llm, fill = val)) +
  geom_tile(colour = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f", val)), size = 2.7) +
  scale_fill_distiller(palette = "RdYlBu", direction = 1, limits = c(1,5),
                       name = "Mean\nlogic") +
  scale_x_discrete(labels = function(x) paste0("Q", x)) +
  labs(
       x = "Pharmacoepidemiologic concept", y = NULL) +
  theme_pub + theme(axis.text.y = element_text(colour = rev(ylab_cols)))
ggsave(file.path(results_dir,"Fig4_logic_LLM_heatmap.png"), f4, width=9, height=3.4, dpi=600, bg="white")

#==============================================================================
# FIGURE 5 - Cleveland lollipop (+/- SEM) : logic x protocol source x class
#  NB: Logic_assessment.xlsx has no biomedical ratings for DARWIN, so that
#      cell is (correctly) absent.
#==============================================================================
lol <- logic %>% group_by(source, class) %>%
  summarise(m = mean(logic), sem = sd(logic)/sqrt(n()), .groups="drop") %>%
  mutate(lab = paste(source, class, sep = " | "), lab = fct_reorder(lab, m))
f5 <- ggplot(lol, aes(x = m, y = lab, colour = class)) +
  geom_segment(aes(x = 1, xend = m, yend = lab), linewidth = 1, alpha = 0.5) +
  geom_errorbarh(aes(xmin = m - sem, xmax = m + sem), height = 0.2) +
  geom_point(size = 4) +
  scale_colour_manual(values = class_pal, name = "Model class") +
  coord_cartesian(xlim = c(1,5)) +
  labs(
       x = "Mean logic of justification (1-5, mean +/- SEM)", y = NULL) +
  theme_pub
ggsave(file.path(results_dir,"Fig5_logic_source_lollipop.png"), f5, width=8.5, height=3.8, dpi=600, bg="white")

#==============================================================================
# FIGURE 6 - violin + jitter : logic x prompt strategy x class
#  (ACT exists for GPT only, as in the source data / original figure.)
#==============================================================================
viol <- logic %>% mutate(cell = paste(prompt, class, sep = "\n"),
                         cell = factor(cell, levels = c("LTM\nNon-Biomedical",
                                                        "LTM\nBiomedical",
                                                        "ACT\nNon-Biomedical")))
f6 <- ggplot(viol, aes(x = cell, y = logic, fill = class)) +
  geom_violin(alpha = 0.4, colour = NA, scale = "width") +
  #geom_jitter(aes(colour = class), width = 0.08, size = 1, alpha = 0.4) +
  stat_summary(fun = median, geom = "crossbar", width = 0.5, linewidth = 0.3) +
  scale_fill_manual(values = class_pal, guide = "none") +
  scale_colour_manual(values = class_pal, guide = "none") +
  labs(
       x = NULL, y = "Logic of justification (1-5)") +
  theme_pub
ggsave(file.path(results_dir,"Fig6_logic_prompt_violin.png"), f6, width=8.5, height=3.8, dpi=600, bg="white")

message("All six redesigned figures written to '", results_dir, "/'.")
