#!/bin/bash
#
# 06_BQSR.sh
# Identify inaccurate base scores that were produced by systemic errors during sequencing 
# Two passes: 1. BaseRecalibrator (builds model), 2. apply BQSR (corrects scores)
# Outputs Bams that are ready for haplotype calling
#
# Env: GATK
# usage: bash scripts/06_BQSR.sh
# Run in root of germline_trio_vc
#

set -euo pipefail 

# Config

MARKED_DIR="data/marked"
BQSR_DIR="data/bqsr"
REF="/data/reference/chr17.fa"

DBSNP="data/reference/dbsnp_155.hg38.chr17.vcf.gz"
MILLS="data/reference/Mills_and_1000G_gold_standard.indels.hg38.chr17.vcf.gz"

SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

# Dir setup

mkdir -p "${BQSR_DIR}"

# Main

echo " ************************************** "
echo " Step 6: Base Quality Score Recalibration"
echo " Input   : ${MARKED_DIR}"
echo " Output  : ${BQSR_DIR}"
echo " ************************************** "

for i in "${!SAMPLES[@]}"; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"

    INPUT=
    TABLE=
    OUTPUT=