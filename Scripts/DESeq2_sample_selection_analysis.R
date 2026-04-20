# DESeq2 Sample Selection Analysis
# Sannie Cao

# Load libraries
library(readxl)
library(DESeq2)

# Set working directory (change if needed)
setwd("~/Downloads")

# Load metadata
metadata <- read_excel("SraRunTable_Dogs_RNAseq_2026.xlsx")

# Define breed groups
small_breeds <- c("Shih tzu", "Yorkshire terrier", "Maltese", "Dachshund", "Beagle")
large_breeds <- c("Labrador Retriever", "Golden Retriever", "Poodle", "Gaddi dog", "Italian Segugio")

# Create condition column
metadata$condition <- ifelse(metadata$BREED %in% small_breeds, "small",
                       ifelse(metadata$BREED %in% large_breeds, "large", NA))

# Remove unclassified samples
metadata <- metadata[!is.na(metadata$condition), ]
metadata$condition <- as.factor(metadata$condition)

# Clean sex column
metadata$sex_clean <- tolower(metadata$sex)

# Create subsets
metadata_noPB <- metadata[grepl("blood", metadata$tissue, ignore.case = TRUE), ]
metadata_male <- metadata[metadata$sex_clean == "male", ]

# ----------------------------
# Generate simulated count data
# ----------------------------

set.seed(1)

num_genes <- 1000
num_samples <- nrow(metadata)

counts <- matrix(
  rnbinom(num_genes * num_samples, mu = 100, size = 1) + 1,
  nrow = num_genes,
  ncol = num_samples
)

rownames(counts) <- paste0("Gene", 1:num_genes)
colnames(counts) <- metadata$Run

# Add differential signal to large dogs
large_samples <- metadata$Run[metadata$condition == "large"]
counts[1:100, colnames(counts) %in% large_samples] <- 
  counts[1:100, colnames(counts) %in% large_samples] + 200

# ----------------------------
# DESeq2 - Full dataset
# ----------------------------

dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = metadata,
  design = ~ condition
)

dds <- estimateSizeFactors(dds, type = "poscounts")
dds <- DESeq(dds)
res_full <- results(dds)

full_DE <- sum(res_full$padj < 0.05, na.rm = TRUE)

# ----------------------------
# DESeq2 - Blood dataset
# ----------------------------

common_samples_noPB <- intersect(colnames(counts), metadata_noPB$Run)

counts_noPB <- counts[, common_samples_noPB]
metadata_noPB2 <- metadata_noPB[metadata_noPB$Run %in% common_samples_noPB, ]
metadata_noPB2 <- metadata_noPB2[match(common_samples_noPB, metadata_noPB2$Run), ]

dds_noPB <- DESeqDataSetFromMatrix(
  countData = counts_noPB,
  colData = metadata_noPB2,
  design = ~ condition
)

dds_noPB <- estimateSizeFactors(dds_noPB, type = "poscounts")
dds_noPB <- DESeq(dds_noPB)
res_noPB <- results(dds_noPB)

noPB_DE <- sum(res_noPB$padj < 0.05, na.rm = TRUE)

# ----------------------------
# DESeq2 - Male dataset
# ----------------------------

common_samples_male <- intersect(colnames(counts), metadata_male$Run)

counts_male <- counts[, common_samples_male]
metadata_male2 <- metadata_male[metadata_male$Run %in% common_samples_male, ]
metadata_male2 <- metadata_male2[match(common_samples_male, metadata_male2$Run), ]

dds_male <- DESeqDataSetFromMatrix(
  countData = counts_male,
  colData = metadata_male2,
  design = ~ condition
)

dds_male <- estimateSizeFactors(dds_male, type = "poscounts")
dds_male <- DESeq(dds_male)
res_male <- results(dds_male)

male_DE <- sum(res_male$padj < 0.05, na.rm = TRUE)

# ----------------------------
# Print results
# ----------------------------

cat("Full dataset DE genes:", full_DE, "\n")
cat("Blood dataset DE genes:", noPB_DE, "\n")
cat("Male dataset DE genes:", male_DE, "\n")
