#!/bin/bash

## Purpose: Build HiSat2 index for canFam6 dog reference genome
## Input: canFam6.fa (reference genome) and canFam6.gtf (annotation)
## Output: HiSat2 index files (.ht2)
## Queue: large
## Cores: 1
## Time: 24:00:00
## Memory: 120gb

########## Load Modules
source /apps/profiles/modules_asax.sh.dyn
module load hisat2/2.2.0
module load gffread

ulimit -s unlimited
set -x

########## Define Variables
MyID=aubclsf0041
REFD=/scratch/$MyID/BloodRNAseq/canFam6_Reference
REF=canFam6

########## Make directory
mkdir -p ${REFD}

########## Move to reference directory
cd ${REFD}

########## Copy reference files from graze_class
cp /home/${MyID}/graze_class/references/canFam6/canFam6.fa .
cp /home/${MyID}/graze_class/references/canFam6/canFam6.gtf .

########## Extract splice sites and exons
hisat2_extract_splice_sites.py ${REF}.gtf > ${REF}.ss
hisat2_extract_exons.py ${REF}.gtf > ${REF}.exon

########## Build HiSat2 index
hisat2-build --ss ${REF}.ss --exon ${REF}.exon ${REF}.fa ${REF}_index
