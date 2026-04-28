# Scripts #

+ 0_DownloadMissing3.sh – Bash script used to download missing canine RNA-seq FASTQ files from public repositories (SRA/NCBI) to complete the dataset prior to analysis.
+ 0_downloadSRAGroupProject.sh – Initial bulk download script for retrieving raw RNA-seq sequencing data for all canine samples used in the group project.
+ 1_QualityCheck.sh – Runs FastQC on downloaded raw sequencing files to evaluate read quality, GC content, adapter contamination, and other standard QC metrics.
+ 1_RawDataQualityCheck.sh – Original raw read quality-control script for assessing all untrimmed FASTQ files before preprocessing.
+ 1b_RawDataQualityCheck_new3.sh – Updated/raw QC script with modifications for additional samples or revised project dataset handling.
+ 2_Trimmomatic.sh – Adapter trimming and quality-filtering pipeline using Trimmomatic v0.39 with project parameters (HEADCROP:10, LEADING:30, TRAILING:30, SLIDINGWINDOW:6:30, MINLEN:36).
+ 2_cleanTrimmomatic.sh – Cleanup/organization script for processed Trimmomatic outputs, removing temporary files or renaming cleaned FASTQ files for downstream use.
+ 2b_Trimmomatic_new3.sh – Revised trimming pipeline for newly added or replacement samples using the same Trimmomatic workflow.
+ 3a_IndexGenome.sh – Builds HiSat2 index files for the canine reference genome canFam6 (GCF_000002285.5) prior to alignment.
+ 3b_Mapping.sh – Aligns trimmed RNA-seq reads to the canFam6 canine reference genome using HiSat2 v2.2.0 and generates alignment files for quantification.
+ Analysis.R – Analysis.R – R visualization script that imports DESeq2 differential expression results and generates pathway-focused bar plots of IGF/GH and IIS-related genes, highlighting log2 fold-change patterns between small and large dog blood samples.
+ DESeq2_sample_selection_analysis.R – Sensitivity analysis script testing how alternative sample inclusion/exclusion sets affected DESeq2 results, DEG overlap, and IIS gene expression trends across datasets.
