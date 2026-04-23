#!/bin/bash

## Purpose: Run FastQC on 3 new raw blood RNAseq samples
## Queue: medium
## Cores: 1
## Time: 02:00:00
## Memory: 8gb

source /apps/profiles/modules_asax.sh.dyn
module load fastqc/0.10.1

MyID=aubclsf0041
DD=/scratch/$MyID/BloodRNAseq/RawData
WD=/scratch/$MyID/BloodRNAseq
RDQ=RawDataQuality

mkdir -p ${WD}/${RDQ}

fastqc ${DD}/SRR11650126_1.fastq ${DD}/SRR11650126_2.fastq \
       ${DD}/SRR11650134_1.fastq ${DD}/SRR11650134_2.fastq \
       ${DD}/SRR11650142_1.fastq ${DD}/SRR11650142_2.fastq \
       --outdir=${WD}/${RDQ}
