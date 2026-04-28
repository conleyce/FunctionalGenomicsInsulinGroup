# Data Files #

+ DESeq2_Blood_results_7samples.csv – Full differential gene expression results from DESeq2 using canine blood RNA-seq data (7 samples), comparing small vs. large dog groups. Includes log2 fold change, p-values, adjusted p-values, and expression statistics for all detected genes.
+ DESeq2_IIS_genes_results_7samples.csv – Filtered DESeq2 results containing only genes associated with the Insulin/Insulin-like Signaling (IIS) pathway, highlighting expression differences between small and large dogs.
+ DGErankName_7samples.rnk – Ranked gene list generated from differential expression results for use in Gene Set Enrichment Analysis (GSEA). Genes are ordered by statistical significance and/or fold change.
+ IIS_PATHWAY.tsv – Tab-delimited file containing the curated list of genes included in the IIS pathway gene set used for enrichment and pathway-focused analyses.
+ PHENO_DATA.txt – Sample phenotype metadata file containing sample IDs and group assignments (e.g., small breed vs. large breed) for downstream statistical analyses.
+ gene_count_matrix.csv – Raw or normalized gene count matrix from RNA-seq data, with genes as rows and canine blood samples as columns, used as input for DESeq2 and other expression analyses.
