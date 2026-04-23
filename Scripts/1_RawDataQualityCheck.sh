bash#!/bin/bash

## Purpose: Run FastQC on raw blood RNAseq data for group project
## Input: Raw paired-end fastq files from shared group directory
## Output: FastQC quality reports (.html and .zip) for each file
## Queue: medium
## Cores: 1
## Time: 02:00:00
## Memory: 8gb

########## Load Modules
source /apps/profiles/modules_asax.sh.dyn
module load fastqc/0.10.1

########## Define Variables
MyID=aubclsf0041
DD=/scratch/aubGroupProjectBloodRnaSeq/RawData
WD=/scratch/$MyID/BloodRNAseq
RDQ=RawDataQuality

########## Make output directory
mkdir -p ${WD}/${RDQ}

########## Run FastQC on all raw fastq files
fastqc ${DD}/*.fastq --outdir=${WD}/${RDQ}

########## Tarball  and download 
cd ${WD}/${RDQ}
tar cvzf ${RDQ}.tar.gz ${WD}/${RDQ}/*
