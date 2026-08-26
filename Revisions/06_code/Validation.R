# =====================================================================
# Blinded human validation of GPT-4o scoring (relevance + reasoning)
#
#   STEP 1  export a stratified sample to fill by hand (column 'agreement')
#   STEP 2  upload the completed file and report human-vs-GPT-4o agreement
#
# Standalone: needs only the relevance workbook and the 'openxlsx' package.
# install.packages("openxlsx")
# =====================================================================
library(openxlsx)
set.seed(2026)                              # reproducibility (change for a new draw)

REL_FILE <- "recreated_excel_file_corrected.xlsx"     # = Results/Relevance_assessment.xlsx
QN       <- 9
PROT     <- c(DARWIN = 16L, "HMA-EMA" = 15L, Sentinel = 15L)
PER_REL  <- 70    # relevance items per configuration (5 configs -> n = 350, ~20%)
PER_REAS <- 72    # reasoning items per configuration (5 configs -> n = 360, ~20%)

# --- map a worksheet name to source / model / prompt / configuration ----------
parse_sheet <- function(sh) {
  U <- toupper(sh)
  src <- if (grepl("DARWIN", U)) "DARWIN" else if (grepl("HMA|EMA", U)) "HMA-EMA" else if (grepl("SENTINEL", U)) "Sentinel" else NA_character_
  llm <- if (grepl("GPT", U)) "GPT-4o" else if (grepl("DEEPSEEK", U)) "DeepSeek-R1" else if (grepl("IRATH", U)) "Qwen2-med" else if (grepl("LLAMA", U)) "BioLlama" else NA_character_
  prm <- if (grepl("ACT", U)) "ACT" else if (grepl("LTM", U)) "LTM" else NA_character_
  list(source = src, llm = llm, prompt = prm, config = paste(llm, prm, sep = "-"))
}

# --- long table for one metric, incl. LLM answer + reference comparison --------
#     metric: "relevance" (1-5) or "reasoning" (Agree / Partly agree / Disagree)
build_long <- function(path, metric) {
  rows <- list()
  for (sh in getSheetNames(path)) {
    m <- parse_sheet(sh); if (is.na(m$source)) next
    d <- read.xlsx(path, sheet = sh, sep.names = " ")               # keep original names
    d <- d[seq_len(min(nrow(d), PROT[[m$source]])), , drop = FALSE]  # 46-protocol restriction
    for (n in seq_len(QN)) {
      qflag <- grepl(paste0("^Q0*", n, "([^0-9]|$)"), names(d))
      lik <- names(d)[qflag & grepl("Likert", names(d), ignore.case = TRUE) &
                             !grepl("human",  names(d), ignore.case = TRUE)]
      dep <- names(d)[qflag & grepl("depth",  names(d), ignore.case = TRUE)]
      ans <- names(d)[names(d) == paste0("Q", n)]                    # LLM answer  ("Qn")
      cmp <- names(d)[qflag & grepl("Comparison", names(d), ignore.case = TRUE)]
      answer <- if (length(ans)) as.character(d[[ans[1]]]) else NA_character_
      comp   <- if (length(cmp)) as.character(d[[cmp[1]]]) else NA_character_
      if (metric == "relevance") {
        if (length(lik) == 0) next
        val <- suppressWarnings(as.numeric(d[[lik[1]]]))
      } else {
        if (length(dep) == 0) next
        s <- tolower(trimws(as.character(d[[dep[1]]])))
        val <- ifelse(startsWith(s, "agree"), "Agree",
                ifelse(grepl("part", s), "Partly agree",
                ifelse(startsWith(s, "disagree"), "Disagree", NA_character_)))
      }
      keep <- !is.na(val)
      rows[[length(rows) + 1]] <- data.frame(
        config   = m$config, source = m$source, question = n,
        protocol = paste0(substr(m$source, 1, 3), seq_len(nrow(d))),
        gpt_value = as.character(val), llm_answer = answer,
        reference_comparison = comp, stringsAsFactors = FALSE)[keep, , drop = FALSE]
    }
  }
  do.call(rbind, rows)
}

# --- equal allocation of 'per' items per configuration ------------------------
sample_per_config <- function(long, per) {
  do.call(rbind, lapply(split(long, long$config),
                        function(g) g[sample(nrow(g), min(per, nrow(g))), ]))
}

# --- build one sheet with a shuffled ID and an empty 'agreement' column --------
make_sheet <- function(long, per) {
  s <- sample_per_config(long, per)
  s$item_id   <- sample(sprintf("V%04d", seq_len(nrow(s))))   # shuffled item IDs
  s$agreement <- NA_integer_                                  # <- fill with 1 / 0
  s <- s[order(s$item_id),
         c("item_id", "config", "source", "question", "protocol",
           "gpt_value", "llm_answer", "reference_comparison", "agreement")]
  rownames(s) <- NULL; s
}

# =====================================================================
# STEP 1 - create the file to be filled by hand
# =====================================================================
rel_long  <- build_long(REL_FILE, "relevance")
reas_long <- build_long(REL_FILE, "reasoning")
cat("Available -> relevance:", nrow(rel_long), "| reasoning:", nrow(reas_long), "\n")

wb <- createWorkbook()
addWorksheet(wb, "relevance"); writeData(wb, "relevance", make_sheet(rel_long,  PER_REL))
addWorksheet(wb, "reasoning"); writeData(wb, "reasoning", make_sheet(reas_long, PER_REAS))
setColWidths(wb, "relevance", cols = 7:8, widths = 60)
setColWidths(wb, "reasoning", cols = 7:8, widths = 60)
freezePane(wb, "relevance", firstRow = TRUE)
freezePane(wb, "reasoning", firstRow = TRUE)
saveWorkbook(wb, "validation_sample.xlsx", overwrite = TRUE)
cat("Wrote validation_sample.xlsx (sheets 'relevance' + 'reasoning').\n",
    "Fill the 'agreement' column with 1 (both agree) / 0 (both disagree) / 2 (one agree/the other disagree or viceversa), save, then run STEP 2.\n")

# =====================================================================
# STEP 2 - read the completed file and report agreement
# Run AFTER filling 'agreement'. Empty/invalid 'agreement' cells are
# ignored (not counted) in every calculation.
# =====================================================================

# >>> set the path to your completed file (edit this line) <
FILLED_FILE <- "validation_sample_filled.xlsx"
# examples:
#   Windows: FILLED_FILE <- "C:/Users/you/Documents/validation_sample.xlsx"
#   macOS  : FILLED_FILE <- "~/Documents/validation_sample.xlsx"

report_agreement <- function(path = FILLED_FILE) {
  if (!file.exists(path)) stop("File not found: ", normalizePath(path, mustWork = FALSE))
  for (m in list(c("relevance", "RELEVANCE"),
                 c("reasoning", "REASONING-CONCORDANCE"))) {
    v <- read.xlsx(path, sheet = m[1], sep.names = " ")
    v$agreement <- suppressWarnings(as.integer(v$agreement))

    n_total   <- nrow(v)
    keep      <- !is.na(v$agreement) & v$agreement %in% c(0, 1)   # scored rows only
    n_missing <- sum(!keep)
    v         <- v[keep, , drop = FALSE]                          # drop unscored rows

    cat("\n===============  ", m[2], "validation  ===============\n")
    if (n_missing > 0)
      cat(sprintf("Ignored %d of %d rows with missing/invalid 'agreement'.\n",
                  n_missing, n_total))
    if (nrow(v) == 0) { cat("No scored rows - nothing to compute.\n"); next }

    cat(sprintf("n scored = %d | MS & XZ vs GPT-4o agreement = %.1f%%\n",
                nrow(v), mean(v$agreement) * 100))
    agg <- aggregate(agreement ~ config, v,
                     function(x) c(n = length(x), pct = mean(x) * 100))
    print(data.frame(config = agg$config, n = agg$agreement[, "n"],
                     agreement_pct = agg$agreement[, "pct"]), row.names = FALSE)
  }
}

# run it:
report_agreement()                         # uses FILLED_FILE
