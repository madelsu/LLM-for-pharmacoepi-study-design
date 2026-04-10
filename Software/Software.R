library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(openxlsx)
library(writexl)
library(stringr)
library(reshape2)

setwd("...")

# Create results output folder
results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)

# ============================================================
# LOAD EXISTING FILES (already generated)
# ============================================================
file_path <- "recreated_excel_file.xlsx"
csv_folder <- "excel_csv_output"

# Read CSVs into named list
csv_files <- list.files(csv_folder, pattern = "\\.csv$", full.names = TRUE)
sheet_list <- lapply(csv_files, read.csv)
names(sheet_list) <- tools::file_path_sans_ext(basename(csv_files))

# Get sheet names from Excel file
sheets <- getSheetNames(file_path)

# ============================================================
# ANALYSIS
# ============================================================
final_summary_table <- data.frame()
plot_data <- data.frame()

sheets2 <- sheets
sheets <- sheets[-3]  # Remove third sheet — adjust index if needed

for (sheet in sheets) {
  
  df <- read_excel(file_path, sheet = sheet)
  df[df == "N/A"] <- ""
  
  columns_to_analyze <- grep("Likert", colnames(df))
  
  for (col_num in columns_to_analyze) {
    if (col_num <= ncol(df)) {
      col_name <- colnames(df)[col_num]
      
      # Extract column and coerce to numeric
      summary_table <- df %>%
        select(all_of(col_name)) %>%
        mutate(across(everything(), as.numeric)) %>%
        mutate(Sheet = sheet, Column = col_name, Column_Num = col_num)
      
      # Compute summary stats (available for later use)
      stats_summary <- summary_table %>%
        summarise(
          Mean   = mean(.data[[col_name]], na.rm = TRUE),
          Median = median(.data[[col_name]], na.rm = TRUE)
        ) %>%
        mutate(Sheet = sheet, Column = col_name, Column_Num = col_num)
      
      final_summary_table <- bind_rows(final_summary_table, summary_table)
      
      # Collect data for plotting
      temp_plot_data <- df %>%
        select(all_of(col_name)) %>%
        mutate(
          Sheet      = sheet,
          Column     = col_name,
          Column_Num = col_num
        ) %>%
        pivot_longer(
          cols      = all_of(col_name),
          names_to  = "Metric",
          values_to = "Value"
        ) %>%
        mutate(Value = as.numeric(Value))
      
      plot_data <- bind_rows(plot_data, temp_plot_data)
    }
  }
}

# ============================================================
# EXPORT
# ============================================================
table(plot_data$Sheet)
write.csv(final_summary_table, file.path(results_dir, "summary_results.csv"), row.names = FALSE)

# ============================================================
# FIGURE 1 - Relevance by LLM architecture colored by LLM Type
# ============================================================
plot_data_grouped <- plot_data %>%
  mutate(
    Category = ifelse(grepl("coherence", Column, ignore.case = TRUE), "Qcoherence", "Qrelevance"),
    Question = paste("Question", gsub("[^0-9]", "", Column)),
    Group = case_when(
      grepl("darwin", Sheet, ignore.case = TRUE) ~ "DARWIN",
      grepl("hma|ema", Sheet, ignore.case = TRUE) ~ "HMA_EMA",
      grepl("sentinel", Sheet, ignore.case = TRUE) ~ "Sentinel",
      TRUE ~ "Other"
    )
  ) %>%
  filter(Group %in% c("DARWIN", "HMA_EMA", "Sentinel")) %>%
  mutate(
    LLM = case_when(
      grepl("GPT", Sheet, ignore.case = TRUE) ~ "GPT-4",
      grepl("Irath", Sheet, ignore.case = TRUE) ~ "Irath",
      grepl("DEEPSEEK", Sheet, ignore.case = TRUE) ~ "DEEPSEEK",
      grepl("mistral", Sheet, ignore.case = TRUE) ~ "Mistral",
      grepl("llama", Sheet, ignore.case = TRUE) ~ "LLaMA",
      TRUE ~ "Other"
    ),
    LLM_Type = case_when(
      LLM %in% c("Irath", "LLaMA") ~ "Biomedical",
      TRUE ~ "Non-Biomedical"
    )
  )

p_relevance_grouped <- ggplot(filter(plot_data_grouped, Category == "Qrelevance"),
                              aes(x = LLM, y = Value, fill = LLM_Type)) +
  geom_boxplot() +
  stat_summary(fun = median, geom = "point", color = "black", size = 2.5, shape = 21, fill = "white") +
  coord_flip() +
  theme_minimal() +
  labs(x = "LLM", y = "Likert Scale", fill = "LLM Type") +
  facet_wrap(~ Question, scales = "free") +
  theme(
    axis.text.y = element_text(size = 10),
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white")
  )

print(p_relevance_grouped) #Figure 1
ggsave(filename = file.path(results_dir, "p_relevance_llm_type.png"), plot = p_relevance_grouped, width = 14, height = 12, dpi = 600)

# ============================================================
# FIGURE 2 - Relevance by Prompt Type colored by LLM Type
# ============================================================
plot_data_prompt <- plot_data %>%
  mutate(
    Category = ifelse(grepl("coherence", Column, ignore.case = TRUE), "Qcoherence", "Qrelevance"),
    Question = paste("Question", gsub("[^0-9]", "", Column)),
    PromptType = case_when(
      grepl("LTM", Sheet, ignore.case = TRUE) ~ "LTM",
      grepl("ACT", Sheet, ignore.case = TRUE) ~ "ACT",
      grepl("cot|chain[-_ ]?of[-_ ]?thought", Sheet, ignore.case = TRUE) ~ "Chain-of-thought",
      grepl("instruction", Sheet, ignore.case = TRUE) ~ "Instruction-tuned",
      grepl("baseline", Sheet, ignore.case = TRUE) ~ "Baseline",
      TRUE ~ "Other"
    ),
    LLM = case_when(
      grepl("GPT", Sheet, ignore.case = TRUE) ~ "GPT-4",
      grepl("Irath", Sheet, ignore.case = TRUE) ~ "Irath",
      grepl("DEEPSEEK", Sheet, ignore.case = TRUE) ~ "DEEPSEEK",
      grepl("mistral", Sheet, ignore.case = TRUE) ~ "Mistral",
      grepl("llama", Sheet, ignore.case = TRUE) ~ "LLaMA",
      TRUE ~ "Other"
    ),
    LLM_Type = case_when(
      LLM %in% c("Irath", "LLaMA") ~ "Biomedical",
      TRUE ~ "Non-Biomedical"
    )
  ) %>%
  filter(PromptType != "Other")

p_relevance_prompt <- ggplot(filter(plot_data_prompt, Category == "Qrelevance"),
                             aes(x = PromptType, y = Value, fill = LLM_Type)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  stat_summary(fun = mean, geom = "point",
               aes(group = LLM_Type, shape = "Mean"),
               color = "white", size = 3, fill = "black",
               position = position_dodge(width = 0.8),
               show.legend = FALSE) +
  coord_flip() +
  theme_minimal() +
  labs(x = "Prompt Type", y = "Likert Scale", fill = "LLM Type") +
  facet_wrap(~ Question, scales = "free") +
  theme(
    axis.text.y = element_text(size = 10),
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white")
  )

print(p_relevance_prompt) #Figure 2
ggsave(filename = file.path(results_dir, "p_relevance_prompt_type.png"), plot = p_relevance_prompt, width = 14, height = 12, dpi = 600)

# ============================================================
# FIGURE 3 - Relevance by Protocol Source split by LLM Type
# ============================================================
plot_data_grouped <- plot_data_grouped %>%
  mutate(
    PromptType = case_when(
      grepl("LTM", Sheet, ignore.case = TRUE) ~ "LTM",
      grepl("ACT", Sheet, ignore.case = TRUE) ~ "ACT",
      TRUE ~ "Other"
    )
  )

p_relevance_grouped <- ggplot(filter(plot_data_grouped, Category == "Qrelevance"),
                              aes(x = Group, y = Value, fill = LLM_Type)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  stat_summary(fun = mean, geom = "point",
               aes(group = LLM_Type),
               color = "white", size = 3, fill = "white",
               position = position_dodge(width = 0.8),
               show.legend = FALSE) +
  scale_shape_manual(name = "Statistic", values = c(Median = 16)) +
  coord_flip() +
  theme_minimal() +
  labs(x = "Group", y = "Likert Scale", fill = "Type") +
  facet_wrap(~ Question, scales = "free") +
  theme(
    axis.text.y = element_text(size = 10),
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white")
  )

print(p_relevance_grouped) #Figure 3
ggsave(filename = file.path(results_dir, "p_relevance_grouped_llmtype.png"), plot = p_relevance_grouped, width = 14, height = 12, dpi = 600)

# ============================================================
# REASONING
# ============================================================
file_path_reasoning <- "Logic_assessment.xlsx"  

sheets <- getSheetNames(file_path_reasoning)
sheets2 <- sheets

final_summary_table_reasoning <- data.frame()
plot_data_reasoning <- data.frame()

for (sheet in sheets) {
  
  df <- read_excel(file_path_reasoning, sheet = sheet)
  df[df == "N/A"] <- NA
  
  columns_to_analyze <- grep("human Likert", colnames(df))
  
  for (col_num in columns_to_analyze) {
    if (col_num <= ncol(df)) {
      col_name <- colnames(df)[col_num]
      
      df[[col_name]] <- as.numeric(df[[col_name]])
      
      summary_stats <- df %>%
        summarise(
          Mean   = mean(.data[[col_name]], na.rm = TRUE),
          Median = median(.data[[col_name]], na.rm = TRUE)
        ) %>%
        mutate(Sheet = sheet, Column = col_name, Column_Num = col_num)
      
      final_summary_table_reasoning <- bind_rows(final_summary_table_reasoning, summary_stats)
      
      temp_plot_data <- df %>%
        select(all_of(col_name)) %>%
        mutate(Sheet = sheet, Column = col_name, Column_Num = col_num) %>%
        pivot_longer(cols = all_of(col_name), names_to = "Metric", values_to = "Value")
      
      plot_data_reasoning <- bind_rows(plot_data_reasoning, temp_plot_data)
    }
  }
}

table(plot_data_reasoning$Sheet)

write.csv(final_summary_table_reasoning, file.path(results_dir, "summary_results_reasoning.csv"), row.names = FALSE)

# ============================================================
# FIGURE 4 - Reasoning by LLM architecture colored by LLM Type
# ============================================================
plot_data_reasoning <- plot_data_reasoning %>%
  mutate(
    Category = "Reasoning",
    Question  = paste("Question", gsub("[^0-9]", "", Column)),
    Sheet     = toupper(Sheet)
  )

plot_data_reasoning <- plot_data_reasoning %>%
  separate(
    Sheet,
    into   = c("DataSource", "LLM", "Prompt"),
    sep    = "-",
    remove = FALSE
  )

plot_data_grouped_reasoning <- plot_data_reasoning %>%
  mutate(
    Group = case_when(
      grepl("darwin",   Sheet, ignore.case = TRUE) ~ "DARWIN",
      grepl("hma|ema",  Sheet, ignore.case = TRUE) ~ "HMA_EMA",
      grepl("sentinel", Sheet, ignore.case = TRUE) ~ "Sentinel",
      TRUE ~ "Other"
    ),
    LLM = case_when(
      grepl("GPT",      Sheet, ignore.case = TRUE) ~ "GPT-4",
      grepl("IRATH",    Sheet, ignore.case = TRUE) ~ "Irath",
      grepl("DEEPSEEK", Sheet, ignore.case = TRUE) ~ "DEEPSEEK",
      grepl("MISTRAL",  Sheet, ignore.case = TRUE) ~ "Mistral",
      grepl("LLAMA",    Sheet, ignore.case = TRUE) ~ "LLaMA",
      TRUE ~ "Other"
    ),
    LLM_Type = case_when(
      LLM %in% c("Irath", "LLaMA") ~ "Biomedical",
      TRUE ~ "Non-Biomedical"
    )
  ) %>%
  filter(Group %in% c("DARWIN", "HMA_EMA", "Sentinel"))

p_reasoning_llm_type <- ggplot(plot_data_grouped_reasoning,
                               aes(x = LLM, y = Value, fill = LLM_Type)) +
  geom_boxplot() +
  stat_summary(fun = median, geom = "point", color = "black", size = 2.5, shape = 21, fill = "white") +
  coord_flip() +
  theme_minimal() +
  labs(x = "LLM", y = "Likert Scale", fill = "LLM Type") +
  facet_wrap(~ Question, scales = "free") +
  theme(
    axis.text.y = element_text(size = 10),
    panel.background = element_rect(fill = "white"),
    plot.background  = element_rect(fill = "white")
  )

print(p_reasoning_llm_type) #Figure 4
ggsave(filename = file.path(results_dir, "p_relevance_llm_type_reasoning.png"), plot = p_reasoning_llm_type, width = 14, height = 12, dpi = 600)

# ============================================================
# FIGURE 5 - Reasoning by Protocol Source split by LLM Type
# ============================================================
p_reasoning_grouped <- ggplot(plot_data_grouped_reasoning,
                              aes(x = Group, y = Value, fill = LLM_Type)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  stat_summary(fun = mean, geom = "point",
               aes(group = LLM_Type),
               color = "white", size = 3, fill = "white",
               position = position_dodge(width = 0.8),
               show.legend = FALSE) +
  scale_shape_manual(name = "Statistic", values = c(Median = 16)) +
  coord_flip() +
  theme_minimal() +
  labs(x = "Group", y = "Likert Scale", fill = "Type") +
  facet_wrap(~ Question, scales = "free") +
  theme(
    axis.text.y = element_text(size = 10),
    panel.background = element_rect(fill = "white"),
    plot.background  = element_rect(fill = "white")
  )

print(p_reasoning_grouped) #Figure 5
ggsave(filename = file.path(results_dir, "p_relevance_grouped_llmtype_reasoning.png"), plot = p_reasoning_grouped, width = 14, height = 12, dpi = 600)

# ============================================================
# FIGURE 6 - Reasoning by Prompt Type colored by LLM Type
# ============================================================
plot_data_prompt_reasoning <- plot_data_reasoning %>%
  mutate(
    PromptType = case_when(
      grepl("LTM",                             Sheet, ignore.case = TRUE) ~ "LTM",
      grepl("ACT",                             Sheet, ignore.case = TRUE) ~ "ACT",
      grepl("cot|chain[-_ ]?of[-_ ]?thought",  Sheet, ignore.case = TRUE) ~ "Chain-of-thought",
      grepl("instruction",                     Sheet, ignore.case = TRUE) ~ "Instruction-tuned",
      grepl("baseline",                        Sheet, ignore.case = TRUE) ~ "Baseline",
      TRUE ~ "Other"
    ),
    LLM = case_when(
      grepl("GPT",      Sheet, ignore.case = TRUE) ~ "GPT-4",
      grepl("Irath",    Sheet, ignore.case = TRUE) ~ "Irath",
      grepl("DEEPSEEK", Sheet, ignore.case = TRUE) ~ "DEEPSEEK",
      grepl("mistral",  Sheet, ignore.case = TRUE) ~ "Mistral",
      grepl("llama",    Sheet, ignore.case = TRUE) ~ "LLaMA",
      TRUE ~ "Other"
    ),
    LLM_Type = case_when(
      LLM %in% c("Irath", "LLaMA") ~ "Biomedical",
      TRUE ~ "Non-Biomedical"
    )
  ) %>%
  filter(PromptType != "Other")

p_reasoning_prompt <- ggplot(plot_data_prompt_reasoning,
                             aes(x = PromptType, y = Value, fill = LLM_Type)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  stat_summary(fun = mean, geom = "point",
               aes(group = LLM_Type, shape = "Mean"),
               color = "white", size = 3, fill = "black",
               position = position_dodge(width = 0.8),
               show.legend = FALSE) +
  coord_flip() +
  theme_minimal() +
  labs(x = "Prompt Type", y = "Likert Scale", fill = "LLM Type") +
  facet_wrap(~ Question, scales = "free") +
  theme(
    axis.text.y = element_text(size = 10),
    panel.background = element_rect(fill = "white"),
    plot.background  = element_rect(fill = "white")
  )

print(p_reasoning_prompt) #Figure 6
ggsave(filename = file.path(results_dir, "p_relevance_prompt_type_reasoning.png"), plot = p_reasoning_prompt, width = 14, height = 12, dpi = 600)

# ============================================================
# FIGURE 7 - Heatmap of LLM Errors
# ============================================================

error_types <- c(
  "Prompt echoing",
  "Overuse of conditional language",
  "Non-Adherence to the algorithm",
  "Long answer",
  "Lack of Justification",
  "Irrelevant auto-generated questions",
  "Instruction drift",
  "Incomplete answer",
  "Model crash",
  "Generate inconsistency language"
)

q_labels_quan  <- paste0("Q", 1:10, "-Quan-Llama-LTM")
q_labels_irath <- paste0("Q", 1:10, "-Irath-Qwen-LTM")
all_cols <- c(q_labels_quan, q_labels_irath)

count_matrix <- rbind(
  # Prompt echoing
  c(1, 1, 0, 1, 0, 0, 0, 0, 0, 1,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  # Overuse of conditional language
  c(0, 0, 1, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  # Non-Adherence to the algorithm (unchanged)
  c(0, 0, 0, 0, 0, 0, 0, 0, 0, 11,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  # Long answer (unchanged)
  c(0, 1, 1, 0, 1, 1, 1, 1, 3, 8,   4, 1, 2, 2, 1, 2, 2, 4, 1, 0),
  # Lack of Justification (unchanged)
  c(4, 8, 13, 8, 4, 5, 6, 6, 6, 0,  11, 7, 5, 4, 4, 4, 4, 3, 3, 0),
  # Irrelevant auto-generated questions (unchanged)
  c(2, 18, 13, 20, 28, 26, 20, 19, 32, 11,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  # Instruction drift
  c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  # Incomplete answer (unchanged)
  c(5, 1, 0, 1, 0, 0, 0, 0, 2, 2,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  # Model crash
  c(0, 0, 0, 0, 1, 0, 0, 0, 1, 4,   1, 0, 0, 0, 0, 0, 0, 1, 0, 0),
  # Generate inconsistency language
  c(0, 0, 0, 0, 0, 0, 0, 0, 0, 2,   1, 0, 1, 0, 0, 0, 0, 0, 0, 0)
)
rownames(count_matrix) <- error_types
colnames(count_matrix) <- all_cols

# Compute row-wise deviation (value - row mean)
row_means  <- rowMeans(count_matrix)
dev_matrix <- sweep(count_matrix, 1, row_means, "-")

# Reshape to long format for ggplot
count_long <- melt(count_matrix, varnames = c("ErrorType", "Question"), value.name = "Count")
dev_long   <- melt(dev_matrix,   varnames = c("ErrorType", "Question"), value.name = "Deviation")
plot_df    <- merge(count_long, dev_long, by = c("ErrorType", "Question"))

# Factor levels to match original plot order
plot_df$ErrorType <- factor(plot_df$ErrorType, levels = rev(error_types))
plot_df$Question  <- factor(plot_df$Question,  levels = all_cols)

# Label inside each cell: count on top, deviation below
plot_df$label <- paste0(plot_df$Count, "\nDev ", round(plot_df$Deviation, 1))

p_heatmap <- ggplot(plot_df, aes(x = Question, y = ErrorType, fill = Deviation)) +
  geom_tile(color = "white", linewidth = 0.4) +
  geom_text(aes(label = label), size = 2.1, lineheight = 0.9, color = "black") +
  scale_fill_gradient2(
    low      = "#2166AC",
    mid      = "white",
    high     = "#D6231A",
    midpoint = 0,
    limits   = c(-15, 15),
    oob      = scales::squish,
    name     = "Deviation"
  ) +
  scale_x_discrete(position = "bottom") +
  labs(x = "Questions", y = "Error Type") +
  theme_minimal(base_size = 10) +
  theme(
    axis.text.x      = element_text(angle = 45, hjust = 1, size = 7.5),
    axis.text.y      = element_text(size = 9),
    axis.title       = element_text(size = 10),
    legend.title     = element_text(size = 9),
    legend.text      = element_text(size = 8),
    panel.grid       = element_blank(),
    plot.background  = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

print(p_heatmap) #Figure 7
ggsave(filename = file.path(results_dir, "heatmap_llm_errors.png"), plot = p_heatmap,
       width = 16, height = 6.5, dpi = 150, bg = "white")
