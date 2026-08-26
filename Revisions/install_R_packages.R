# R dependencies for the analysis and figure scripts (Comment_4.R, Comment_5.R,
# Validation.R, Software_corrected.R, figures_redesigned_corrected.R)
pkgs <- c("openxlsx", "ordinal", "dplyr", "tidyr", "ggplot2")
new <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
if (length(new)) install.packages(new, repos = "https://cloud.r-project.org")
invisible(lapply(pkgs, require, character.only = TRUE))
# Reproducibility note: analyses were run with R >= 4.3; clmm from 'ordinal' >= 2022.
# Record your exact versions with sessionInfo().
