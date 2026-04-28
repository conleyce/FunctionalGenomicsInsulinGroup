### R Analysis – Claire Conley 

# Load packages 

library(data.table)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)

library(clusterProfiler)
library(org.Cf.eg.db)

# Set working directory to where the DESeq2 results CSV is located

df <- fread("DESeq2_Blood_results_7samples(in).csv")

colnames(df) <- tolower(colnames(df))

df$log2foldchange <- as.numeric(df$log2foldchange)
df$padj <- as.numeric(df$padj)

# Set a minimum p-value threshold to avoid issues with -log10(0) and filter out NA values

df$padj <- pmax(df$padj, 1e-300)
df <- df %>% filter(!is.na(padj))

# Remove version numbers from gene symbols (e.g., "GENE|123" -> "GENE")

df$gene <- sub("\\|.*", "", df$gene)

# Define significance thresholds (adjust as needed)

sig_up <- df %>% filter(padj < 0.1 & log2foldchange > 0.5)
sig_down <- df %>% filter(padj < 0.05 & log2foldchange < -1)

genes <- sig_up$gene

mapped <- bitr(
  genes,
  fromType = "SYMBOL",
  toType   = "ENTREZID",
  OrgDb    = org.Cf.eg.db
)



if (nrow(mapped) == 0) stop("No genes mapped. Check gene symbols vs OrgDb compatibility.")

# Fig 3: IGF / GH Signaling Axis

igf_genes <- c("IGF1","IGF2","IGF1R","GHR",
               "IRS1","IRS2",
               "PIK3CA","PIK3CB",
               "AKT1","AKT2",
               "MTOR","FOXO1","FOXO3",
               "STAT5A","STAT5B","ESR1","ACE2")

igf_df <- df %>%
  filter(gene %in% igf_genes)

# diagnostic (important)
print(igf_df)

if (nrow(igf_df) == 0) {
  stop("No IGF pathway genes detected in dataset")
}

fig1 <- ggplot(igf_df,
               aes(x = reorder(gene, log2foldchange),
                   y = log2foldchange,
                   fill = log2foldchange > 0)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#d73027", "FALSE" = "#4575b4")) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "IGF / GH Pathway Genes Detected in DESeq2 Results",
    x = "Gene",
    y = "Log2 Fold Change"
  ) +
  theme_minimal()

print(fig1)

ggsave("figure1_igf_axis.png", fig1, width = 8, height = 5)

