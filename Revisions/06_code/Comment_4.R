# =====================================================================
# Reviewer C4 - missingness / data-flow visualisations
#   data-flow table + coverage heatmaps + adverse-case sensitivity
# Needs: recreated_excel_file.xlsx (relevance + reasoning-concordance)
#        Logic_assessment.xlsx     (human logic ratings)
# install.packages(c("openxlsx","ggplot2","dplyr","tidyr"))
# =====================================================================
library(openxlsx); library(ggplot2); library(dplyr); library(tidyr)

.resolve <- function(candidates, label) {
  for (cand in candidates) if (file.exists(cand)) return(cand)
  stop(sprintf("%s workbook not found. Looked for: %s. Place the released\nworkbook (or its corrected copy) in the working directory.", label,
               paste(candidates, collapse = ", ")))
}
REL_FILE <- .resolve(c("Relevance_assessment.xlsx",
                       "recreated_excel_file_corrected.xlsx",
                       "recreated_excel_file.xlsx"), "Relevance")
LOG_FILE <- .resolve(c("Logic_assessment.xlsx",
                       "Logic_assessment_corrected.xlsx"), "Logic")
QN   <- 9
PROT <- c(DARWIN = 16L, "HMA-EMA" = 15L, Sentinel = 15L)

parse_sheet <- function(sh) {
  U <- toupper(sh)
  src <- if (grepl("DARWIN", U)) "DARWIN" else if (grepl("HMA|EMA", U)) "HMA-EMA" else if (grepl("SENTINEL", U)) "Sentinel" else NA_character_
  llm <- if (grepl("GPT", U)) "GPT-4o" else if (grepl("DEEPSEEK", U)) "DeepSeek-R1" else if (grepl("IRATH", U)) "Qwen2-med" else if (grepl("LLAMA", U)) "BioLlama" else NA_character_
  prm <- if (grepl("ACT", U)) "ACT" else if (grepl("LTM", U)) "LTM" else NA_character_
  cls <- if (llm %in% c("Qwen2-med","BioLlama")) "Biomedical" else "General-purpose"
  list(source = src, llm = llm, prompt = prm,
       config = paste(llm, prm, sep = "-"), class = cls)
}

# ---------- counts per model-prompt-source, WITH and WITHOUT truncation -------
count_cell <- function(path, regex, exclude_human = FALSE) {
  out <- list()
  for (sh in getSheetNames(path)) {
    m <- parse_sheet(sh); if (is.na(m$source)) next
    d <- read.xlsx(path, sheet = sh, sep.names = " ")
    n_raw <- nrow(d)
    d16   <- d[seq_len(min(nrow(d), PROT[[m$source]])), , drop = FALSE]  # 46-protocol restriction
    cols  <- grep(regex, names(d16), value = TRUE, ignore.case = TRUE)
    if (exclude_human) cols <- cols[!grepl("human", cols, ignore.case = TRUE)]
    present <- sum(vapply(cols, function(cn) {
      v <- suppressWarnings(as.numeric(d16[[cn]])); sum(!is.na(v) & v >= 1 & v <= 5)
    }, numeric(1)))
    # extra rows beyond the pre-specified protocol count that carry a rating
    extra <- 0L
    if (n_raw > PROT[[m$source]]) {
      dx <- d[(PROT[[m$source]] + 1):n_raw, , drop = FALSE]
      extra <- sum(vapply(cols, function(cn) {
        v <- suppressWarnings(as.numeric(dx[[cn]])); sum(!is.na(v) & v >= 1 & v <= 5)
      }, numeric(1)))
    }
    out[[length(out) + 1]] <- data.frame(
      config = m$config, class = m$class, llm = m$llm, prompt = m$prompt,
      source = m$source, expected = PROT[[m$source]] * QN,
      present = present, spurious_extra_rows = extra, stringsAsFactors = FALSE)
  }
  do.call(rbind, out)
}

relevance <- count_cell(REL_FILE, "Likert", exclude_human = TRUE)
reasoning <- count_cell(REL_FILE, "depth")
humanlog  <- count_cell(LOG_FILE, "human.*Likert")

# ---------- DATA-FLOW TABLE (one row per model-prompt-source) -----------------
dataflow <- relevance %>%
  select(config, class, source, expected,
         relevance_present = present, relevance_spurious = spurious_extra_rows) %>%
  left_join(reasoning %>% select(config, source, reasoning_present = present),
            by = c("config","source")) %>%
  left_join(humanlog %>% select(config, source,
                                humanlogic_present = present,
                                humanlogic_spurious = spurious_extra_rows),
            by = c("config","source")) %>%
  mutate(relevance_missing   = expected - relevance_present,
         reasoning_missing   = expected - reasoning_present,
         humanlogic_missing  = expected - humanlogic_present) %>%
  arrange(class, config, source)

cat("\n================  DATA-FLOW TABLE  ================\n")
print(as.data.frame(dataflow), row.names = FALSE)
write.xlsx(dataflow, "dataflow_table.xlsx")

# class-level totals (the reviewer's headline numbers)
cat("\n---- class totals ----\n")
dataflow %>% group_by(class) %>%
  summarise(expected = sum(expected),
            relevance_present  = sum(relevance_present),
            reasoning_present  = sum(reasoning_present),
            humanlogic_present = sum(humanlogic_present),
            humanlogic_cov = sprintf("%.0f%%", 100*sum(humanlogic_present)/sum(expected)),
            relevance_cov  = sprintf("%.0f%%", 100*sum(relevance_present)/sum(expected)),
            .groups = "drop") %>%
  as.data.frame() %>% print(row.names = FALSE)

# 16th-row audit flag
cat("\n---- spurious rows beyond the 46 protocols (to audit, NOT to count) ----\n")
sp <- dataflow %>% filter(relevance_spurious > 0 | humanlogic_spurious > 0)
if (nrow(sp)) print(as.data.frame(sp[, c("config","source","relevance_spurious","humanlogic_spurious")]), row.names = FALSE) else cat("none\n")

# =====================================================================
# VISUAL 1 - human-logic coverage heatmap (model x source), with counts
# =====================================================================
hl <- humanlog %>%
  mutate(coverage = 100 * present / expected,
         label = paste0(present, "/", expected, "\n", round(coverage), "%"),
         model = factor(paste0(llm, "-", prompt)),
         source = factor(source, levels = c("DARWIN","HMA-EMA","Sentinel")))

p1 <- ggplot(hl, aes(source, model, fill = coverage)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = label), size = 3) +
  scale_fill_gradient2(low = "#b2182b", mid = "#fddbc7", high = "#2166ac",
                       midpoint = 50, limits = c(0,100), name = "Coverage %") +
  labs(title = "Human-logic ratings: coverage by model x source",
       subtitle = "present / expected  (expected = protocols x 9 questions)",
       x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(panel.grid = element_blank())
ggsave("fig_humanlogic_coverage.png", p1, width = 7, height = 4.5, dpi = 300)

# =====================================================================
# VISUAL 2 - coverage of all three outcomes side by side
# =====================================================================
long_cov <- dataflow %>%
  transmute(config, class, source,
            Relevance  = 100 * relevance_present  / expected,
            Reasoning  = 100 * reasoning_present  / expected,
            `Human logic` = 100 * humanlogic_present / expected) %>%
  pivot_longer(c(Relevance, Reasoning, `Human logic`),
               names_to = "outcome", values_to = "coverage")

p2 <- ggplot(long_cov, aes(source, paste(config), fill = coverage)) +
  geom_tile(color = "white") +
  facet_wrap(~ outcome) +
  scale_fill_gradient2(low = "#b2182b", mid = "#fddbc7", high = "#2166ac",
                       midpoint = 50, limits = c(0,100), name = "Coverage %") +
  labs(title = "Outcome coverage by model-prompt x source",
       x = NULL, y = NULL) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 30, hjust = 1))
ggsave("fig_coverage_all_outcomes.png", p2, width = 11, height = 5, dpi = 300)

# =====================================================================
# VISUAL 3 - highlight the empty / near-empty human-logic cells
#            (DARWIN-by-biomedical = 0 ; GPT-4o-LTM Sentinel 0/135 ; etc.)
# =====================================================================
hl <- hl %>% mutate(flag = ifelse(present == 0, "no human data",
                           ifelse(coverage < 50, "sparse (<50%)", "ok")))
p3 <- ggplot(hl, aes(source, model, fill = flag)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = paste0(present, "/", expected)), size = 3) +
  scale_fill_manual(values = c("no human data" = "#b2182b",
                               "sparse (<50%)" = "#f4a582", "ok" = "#92c5de"),
                    name = NULL) +
  labs(title = "Human-logic data availability (Figures 4-6 caution)",
       subtitle = "Red cells carry no human ratings -> not interpretable; e.g. DARWIN x biomedical",
       x = NULL, y = NULL) +
  theme_minimal(base_size = 12) + theme(panel.grid = element_blank())
ggsave("fig_humanlogic_gaps.png", p3, width = 7, height = 4.5, dpi = 300)

# =====================================================================
# SENSITIVITY - adverse-case: treat missing/unassessable human logic as FAILURE
#   observed complete-case mean vs adverse-case (missing scored as 1 = worst)
# =====================================================================
build_logic_long <- function(path) {
  rows <- list()
  for (sh in getSheetNames(path)) {
    m <- parse_sheet(sh); if (is.na(m$source)) next
    d <- read.xlsx(path, sheet = sh, sep.names = " ")
    d <- d[seq_len(min(nrow(d), PROT[[m$source]])), , drop = FALSE]
    for (n in seq_len(QN)) {
      cn <- grep(paste0("^Q0*", n, "([^0-9]|$)"), names(d))
      cn <- cn[grepl("human", names(d)[cn], ignore.case = TRUE) &
               grepl("Likert", names(d)[cn], ignore.case = TRUE)]
      if (!length(cn)) next
      v <- suppressWarnings(as.numeric(d[[names(d)[cn[1]]]]))
      rows[[length(rows)+1]] <- data.frame(class = m$class, config = m$config,
                                           value = v, stringsAsFactors = FALSE)
    }
  }
  do.call(rbind, rows)
}
L <- build_logic_long(LOG_FILE)

sens <- L %>% group_by(class) %>%
  summarise(
    n_expected      = n(),
    n_rated         = sum(!is.na(value)),
    complete_case_mean = mean(value, na.rm = TRUE),                       # observed
    adverse_worst_mean = mean(ifelse(is.na(value), 1, value)),            # missing = 1 (worst)
    best_case_mean     = mean(ifelse(is.na(value), 5, value)),            # missing = 5 (bound)
    .groups = "drop")
cat("\n================  ADVERSE-CASE SENSITIVITY (human logic)  ================\n")
print(as.data.frame(sens), row.names = FALSE)

sens_long <- sens %>%
  select(class, `Complete-case` = complete_case_mean,
         `Adverse (missing=fail)` = adverse_worst_mean,
         `Best-case bound` = best_case_mean) %>%
  pivot_longer(-class, names_to = "scenario", values_to = "mean")

p4 <- ggplot(sens_long, aes(scenario, mean, fill = class)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_text(aes(label = round(mean, 2)), position = position_dodge(0.8),
            vjust = -0.3, size = 3) +
  labs(title = "Human-logic score under missingness assumptions",
       subtitle = "Complete-case vs adverse-case (missing treated as failure) vs best-case bound",
       x = NULL, y = "Mean human-logic score (1-5)") +
  theme_minimal(base_size = 12)
ggsave("fig_sensitivity_missingness.png", p4, width = 8, height = 4.5, dpi = 300)

cat("\nSaved: dataflow_table.xlsx + fig_humanlogic_coverage.png,",
    "fig_coverage_all_outcomes.png, fig_humanlogic_gaps.png,",
    "fig_sensitivity_missingness.png\n")