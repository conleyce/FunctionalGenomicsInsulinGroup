#!/bin/bash

## Purpose: Download 3 missing blood RNAseq samples
## Queue: medium
## Cores: 1
## Time: 08:00:00
## Memory: 4gb

source /apps/profiles/modules_asax.sh.dyn
module load sra

MyID=aubclsf0041
DD=/scratch/$MyID/BloodRNAseq/RawData

mkdir -p ${DD}
cd ${DD}

vdb-config --interactive > /dev/null 2>&1 <<EOF
q
EOF

fastq-dump -F --split-files SRR11650142
fastq-dump -F --split-files SRR11650134
fastq-dump -F --split-files SRR11650126
