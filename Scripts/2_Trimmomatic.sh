#!/bin/bash

## Purpose: Trim adapters and low quality regions from raw blood RNAseq reads
## Input: Raw paired-end fastq files from shared group directory
## Output: Trimmed paired and unpaired fastq files + FastQC quality reports
## Queue: medium
## Cores: 6
## Time: 08:00:00
## Memory: 12gb

########## Load Modules
source /apps/profiles/modules_asax.sh.dyn
module load trimmomatic/0.39
module load fastqc/0.10.1

########## Define Variables
MyID=aubclsf0041
DD=/scratch/aubGroupProjectBloodRnaSeq/RawData
CD=/scratch/$MyID/BloodRNAseq/CleanData
WD=/scratch/$MyID/BloodRNAseq
PCQ=PostCleanQuality

########## Make directories
mkdir -p ${CD}
mkdir -p ${WD}/${PCQ}

########## Make list of sample names from shared folder
## saving list to YOUR folder, not the shared folder
ls ${DD} | grep ".fastq" | cut -d "_" -f 1 | sort | uniq > ${WD}/list

########## Run Trimmomatic and FastQC in a loop
while read i
do
    java -jar /apps/x86-64/apps/spack_0.19.1/spack/opt/spack/linux-rocky8-zen3/gcc-11.3.0/trimmomatic-0.39-iu723m2xenra563gozbob6ansjnxmnfp/bin/trimmomatic-0.39.jar \
    PE -threads 6 -phred33 \
    ${DD}/"$i"_1.fastq ${DD}/"$i"_2.fastq \
    ${CD}/"$i"_1_paired.fastq ${CD}/"$i"_1_unpaired.fastq \
    ${CD}/"$i"_2_paired.fastq ${CD}/"$i"_2_unpaired.fastq \
    ILLUMINACLIP:${WD}/AdaptersToTrim_All.fa:2:35:10 HEADCROP:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:6:30 MINLEN:36

    fastqc ${CD}/"$i"_1_paired.fastq --outdir=${WD}/${PCQ}
    fastqc ${CD}/"$i"_2_paired.fastq --outdir=${WD}/${PCQ}

done<${WD}/list

########## Tarball PostCleanQuality results
cd ${WD}/${PCQ}
tar cvzf ${PCQ}.tar.gz ${WD}/${PCQ}/*
