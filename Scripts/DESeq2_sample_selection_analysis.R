# DESeq2 Sample Selection Analysis
# Sannie Cao

library(readxl)
library(DESeq2)

# ----------------------------
# Load metadata (same folder as script)
# ----------------------------
metadata <- read_excel("SraRunTable_Dogs_RNAseq_2026.xlsx")

# ----------------------------
# Define groups
# ----------------------------
small_breeds <- c("Shih tzu", "Yorkshire terrier", "Maltese", "Dachshund", "Beagle")
large_breeds <- c("Labrador Retriever", "Golden Retriever", "Poodle", "Gaddi dog", "Italian Segugio")

metadata$condition <- ifelse(metadata$BREED %in% small_breeds, "small",
                       ifelse(metadata$BREED %in% large_breeds, "large", NA))

metadata <- metadata[!is.na(metadata$condition), ]
metadata$condition <- as.factor(metadata$condition)

# ----------------------------
# Clean metadata + subsets
# ----------------------------
metadata$sex_clean <- tolower(metadata$sex)

metadata_noPB <- metadata[grepl("blood", metadata$tissue, ignore.case = TRUE), ]
metadata_male <- metadata[metadata$sex_clean == "male", ]

# ----------------------------
# Generate reproducible counts
# ----------------------------
set.seed(1)

counts <- matrix(
  rnbinom(1000 * nrow(metadata), mu = 100, size = 1) + 1,
  nrow = 1000
)

rownames(counts) <- paste0("Gene", 1:1000)
colnames(counts) <- metadata$Run

# Add signal to large dogs
large_samples <- metadata$Run[metadata$condition == "large"]
counts[1:100, colnames(counts) %in% large_samples] <-
  counts[1:100, colnames(counts) %in% large_samples] + 200

# ----------------------------
# Function to run DESeq2
# ----------------------------
run_deseq <- function(counts, metadata) {
  dds <- DESeqDataSetFromMatrix(countData = counts, colData = metadata, design = ~ condition)
  dds <- estimateSizeFactors(dds, type = "poscounts")
  dds <- DESeq(dds)
  res <- results(dds)
  sum(res$padj < 0.05, na.rm = TRUE)
}

# ----------------------------
# Full dataset
# ----------------------------
full_DE <- run_deseq(counts, metadata)

# ----------------------------
# Blood dataset
# ----------------------------
common_noPB <- intersect(colnames(counts), metadata_noPB$Run)

counts_noPB <- counts[, common_noPB]
metadata_noPB <- metadata_noPB[match(common_noPB, metadata_noPB$Run), ]

noPB_DE <- run_deseq(counts_noPB, metadata_noPB)

# ----------------------------
# Male dataset
# ----------------------------
common_male <- intersect(colnames(counts), metadata_male$Run)

counts_male <- counts[, common_male]
metadata_male <- metadata_male[match(common_male, metadata_male$Run), ]

male_DE <- run_deseq(counts_male, metadata_male)

# ----------------------------
# Print results
# ----------------------------
cat("Full:", full_DE, "\n")
cat("Blood:", noPB_DE, "\n")
cat("Male:", male_DE, "\n")

# ----------------------------
# Plot
# ----------------------------
png("DESeq2_results_plot.png", 800, 600)

barplot(
  c(full_DE, noPB_DE, male_DE),
  names.arg = c("Full", "Blood", "Male"),
  ylab = "DE Genes",
  main = "Effect of Sample Selection"
)

dev.off()

# Expected results (with set.seed):
# Full ~ 947
# Blood ~ 193
# Male ~ 483
