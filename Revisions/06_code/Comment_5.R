# =====================================================================
# Reviewer Comment 5 - dependence-aware reanalysis + full reproducibility
#   * ordinal MIXED-EFFECTS model with protocol-level clustering
#   * PAIRED test for the model-controlled GPT-4o LTM vs Active comparison
#   * protocol-cluster BOOTSTRAP confidence interval
#   * class contrasts presented DESCRIPTIVELY (2 models per class)
#   * uses the RELEASED filenames; DARWIN_GPT_LTM is INCLUDED (no sheets[-3])
# install.packages(c("openxlsx","ordinal","dplyr","tidyr"))
# =====================================================================
library(openxlsx); library(ordinal); library(dplyr); library(tidyr)
set.seed(2026)

REL_FILE <- "Relevance_assessment.xlsx"   # released name (= Results/Relevance_assessment.xlsx)
LOG_FILE <- "Logic_assessment.xlsx"
QN   <- 9
PROT <- c(DARWIN = 16L, "HMA-EMA" = 15L, Sentinel = 15L)

parse_sheet <- function(sh) {
  U <- toupper(sh)
  src <- if (grepl("DARWIN", U)) "DARWIN" else if (grepl("HMA|EMA", U)) "HMA-EMA" else if (grepl("SENTINEL", U)) "Sentinel" else NA_character_
  llm <- if (grepl("GPT", U)) "GPT-4o" else if (grepl("DEEPSEEK", U)) "DeepSeek-R1" else if (grepl("IRATH", U)) "Qwen2-med" else if (grepl("LLAMA", U)) "BioLlama" else NA_character_
  prm <- if (grepl("ACT", U)) "ACT" else if (grepl("LTM", U)) "LTM" else NA_character_
  cls <- if (llm %in% c("Qwen2-med","BioLlama")) "Biomedical" else "General-purpose"
  list(source=src, llm=llm, prompt=prm, config=paste(llm,prm,sep="-"), class=cls)
}

# ---- long-format loader (ALL sheets incl. DARWIN_GPT_LTM) --------------------
load_long <- function(path, metric) {   # metric = "relevance" | "reasoning"
  rows <- list()
  for (sh in getSheetNames(path)) {
    m <- parse_sheet(sh); if (is.na(m$source)) next
    d <- read.xlsx(path, sheet = sh, sep.names = " ")
    d <- d[seq_len(min(nrow(d), PROT[[m$source]])), , drop = FALSE]     # 46 protocols; NO sheets[-3]
    for (n in seq_len(QN)) {
      qf <- grepl(paste0("^Q0*", n, "([^0-9]|$)"), names(d))
      if (metric == "relevance") {
        col <- names(d)[qf & grepl("Likert", names(d), ignore.case=TRUE) & !grepl("human", names(d), ignore.case=TRUE)]
        if (!length(col)) next
        val <- suppressWarnings(as.numeric(d[[col[1]]]))
      } else {
        col <- names(d)[qf & grepl("depth", names(d), ignore.case=TRUE)]
        if (!length(col)) next
        s <- tolower(trimws(as.character(d[[col[1]]])))
        val <- ifelse(startsWith(s,"disagree"), "1_Disagree",
                ifelse(grepl("part",s), "2_Partly", ifelse(startsWith(s,"agree"), "3_Agree", NA)))
      }
      rows[[length(rows)+1]] <- data.frame(
        protocol = paste0(m$source, "_", seq_len(nrow(d))),
        source = m$source, config = m$config, class = m$class,
        question = factor(n), value = val, stringsAsFactors = FALSE)
    }
  }
  do.call(rbind, rows)[!is.na(do.call(rbind, rows)$value), ]
}

# ================= RELEVANCE =================
R <- load_long(REL_FILE, "relevance"); R$relevance <- as.numeric(R$value)
R$config <- relevel(factor(R$config), ref = "GPT-4o-LTM")
R$source <- factor(R$source)
R$rel_ord <- factor(R$relevance, levels = 1:5, ordered = TRUE)
cat(sprintf("Relevance: %d ratings, %d configs, %d protocols | DARWIN_GPT_LTM present: %s\n",
    nrow(R), nlevels(R$config), length(unique(R$protocol)),
    any(R$config=="GPT-4o-LTM" & R$source=="DARWIN")))

# (1) omnibus Kruskal-Wallis (as originally reported, unadjusted)
cat("\n[1] Kruskal-Wallis across configurations:\n"); print(kruskal.test(relevance ~ config, data = R))

# (2) ORDINAL MIXED-EFFECTS with protocol-level clustering
#     fixed: configuration, source, question ; random intercept: protocol
m <- clmm(rel_ord ~ config + source + question + (1 | protocol), data = R, Hess = TRUE)
cat("\n[2] Ordinal mixed-effects (cumulative link mixed model), ref = GPT-4o-LTM:\n")
co <- summary(m)$coefficients
print(round(co[grep("config|source", rownames(co)), c("Estimate","Std. Error","Pr(>|z|)")], 3))

# (3) MODEL-CONTROLLED prompt effect: PAIRED test (GPT-4o LTM vs Active)
gpt <- R %>% filter(config %in% c("GPT-4o-LTM","GPT-4o-ACT"))
wide <- gpt %>% select(protocol, question, config, relevance) %>%
  pivot_wider(names_from = config, values_from = relevance) %>%
  rename(LTM = `GPT-4o-LTM`, ACT = `GPT-4o-ACT`) %>% filter(!is.na(LTM), !is.na(ACT))
cat(sprintf("\n[3] GPT-4o LTM vs Active (model held constant), n pairs = %d\n", nrow(wide)))
cat(sprintf("    PAIRED Wilcoxon signed-rank:  p = %.3f\n", wilcox.test(wide$LTM, wide$ACT, paired=TRUE)$p.value))
cat(sprintf("    Unpaired Mann-Whitney (reproduces released value): p = %.3f\n", wilcox.test(relevance ~ config, data = gpt)$p.value))

# (4) PROTOCOL-CLUSTER BOOTSTRAP CI for mean(LTM - ACT)
wide$diff <- wide$LTM - wide$ACT
cl <- split(wide$diff, wide$protocol); B <- 2000
bootm <- replicate(B, mean(unlist(cl[sample(names(cl), length(cl), replace = TRUE)])))
cat(sprintf("[4] Protocol-cluster bootstrap 95%% CI mean(LTM-ACT): [%.2f, %.2f] (point %.2f)\n",
    quantile(bootm,.025), quantile(bootm,.975), mean(wide$diff)))

# (5) CLASS CONTRAST - DESCRIPTIVE ONLY (two models per class; GPT-4o counts twice)
cat("\n[5] General-purpose vs biomedical (DESCRIPTIVE):\n")
R %>% group_by(class) %>% summarise(n=n(), median=median(relevance),
       IQR=paste0(quantile(relevance,.25),"-",quantile(relevance,.75)),
       mean=round(mean(relevance),2), .groups="drop") %>% as.data.frame() %>% print(row.names=FALSE)
a <- R$relevance[R$class=="General-purpose"]; b <- R$relevance[R$class=="Biomedical"]
rbc <- 2*wilcox.test(a,b)$statistic/(length(a)*length(b)) - 1
cat(sprintf("    rank-biserial r (descriptive) = %.2f ; medians %g vs %g\n", rbc, median(a), median(b)))

# ================= REASONING-CONCORDANCE (chi-square concern) =================
Q <- load_long(REL_FILE, "reasoning")
Q$reas <- factor(Q$value, levels=c("1_Disagree","2_Partly","3_Agree"), ordered=TRUE)
Q$class <- relevel(factor(Q$class), ref="General-purpose")
Q$source <- factor(Q$source)
cat("\n[6] Reasoning-concordance, descriptive proportions ('agree', partly excluded):\n")
Q %>% filter(value!="2_Partly") %>% group_by(class) %>%
  summarise(agree=sum(value=="3_Agree"), n=n(), pct=round(100*mean(value=="3_Agree"),1), .groups="drop") %>%
  as.data.frame() %>% print(row.names=FALSE)
# clustered robustness (addresses the reviewer's chi-square concern)
mq <- clmm(reas ~ class + source + question + (1 | protocol), data = Q, Hess = TRUE)
cq <- summary(mq)$coefficients
cat("[6b] Ordinal mixed-effects for reasoning (protocol-clustered), class effect:\n")
print(round(cq[grep("class", rownames(cq)), c("Estimate","Std. Error","Pr(>|z|)")], 3))

cat("\nDone. All statistics reproduced from released workbooks with protocol-level clustering.\n")