#!/bin/bash

## Purpose: Map cleaned blood RNAseq reads to canFam6 reference genome
## Input: Cleaned paired fastq files, canFam6 HiSat2 index
## Output: Sorted BAM files, StringTie counts, count matrix
## Queue: medium
## Cores: 6
## Time: 24:00:00
## Memory: 48gb

########## Load Modules
source /apps/profiles/modules_asax.sh.dyn
module load hisat2/2.2.0
module load stringtie/2.2.1
module load gcc/9.4.0
module load python/3.10.8-zimemtc
module load samtools
module load gffread

ulimit -s unlimited
set -x

########## Define Variables
MyID=aubclsf0041
WD=/scratch/$MyID/BloodRNAseq
CD=/scratch/$MyID/BloodRNAseq/CleanData
REFD=/scratch/$MyID/BloodRNAseq/canFam6_Reference
MAPD=/scratch/$MyID/BloodRNAseq/Map_HiSat2
COUNTSD=/scratch/$MyID/BloodRNAseq/Counts_StringTie
RESULTSD=/home/$MyID/BloodRNAseq/Results
REF=canFam6

########## Make directories
mkdir -p ${MAPD}
mkdir -p ${COUNTSD}
mkdir -p ${RESULTSD}

########## Make list of samples from CleanData
ls ${CD} | grep "_1_paired.fastq" | cut -d "_" -f 1 | sort | uniq > ${WD}/list

########## Move to mapping directory
cd ${MAPD}

########## Map, convert, sort, and count in a loop
while read i;
do
    ## Map with HiSat2
    hisat2 -p 6 --dta --phred33 \
    -x ${REFD}/canFam6_index \
    -1 ${CD}/"$i"_1_paired.fastq \
    -2 ${CD}/"$i"_2_paired.fastq \
    -S "$i".sam

    ## Convert SAM to BAM
    samtools view -@ 6 -bS "$i".sam > "$i".bam

    ## Sort BAM
    samtools sort -@ 6 "$i".bam -o "$i"_sorted.bam

    ## Get mapping statistics
    samtools flagstat "$i"_sorted.bam > "$i"_Stats.txt

    ## Count reads with StringTie
    mkdir -p ${COUNTSD}/"$i"
    stringtie -p 6 -e -B -G ${REFD}/${REF}.gtf \
    -o ${COUNTSD}/"$i"/"$i".gtf \
    -l "$i" ${MAPD}/"$i"_sorted.bam

done<${WD}/list

########## Copy stats to results
cp ${MAPD}/*.txt ${RESULTSD}

########## Make count matrix with prepDE.py
cd ${COUNTSD}
cp /home/${MyID}/graze_class/prepDE.py3 .
prepDE.py3 -i ${COUNTSD}

########## Copy count matrix to results
cp *.csv ${RESULTSD}
