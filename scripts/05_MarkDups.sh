#!/bin/bash

# 05_Markdups.sh
# Marks duplicates present in sorted bams 
# Output files sorted and marked duplicates, ready for variant calling 
#
# Env: GATK
# usage bash scripts/05_Markdups.sh
# run in germline_trio_vc/ root
#

set -euo pipefail 

# Config 

ALIGNED_DIR="data/aligned"
METRICS_DIR="data/metrics"
MARKEDDUP_DIR="data/marked"

SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

# Dir setup

mkdir -p "${METRICS_DIR}"
mkdir -p "${MARKEDDUP_DIR}"

# Main 

echo " ************************************** "
echo " Step 5: Mark Duplicates with GATK"
echo " Input     : ${ALIGNED_DIR}"
echo " Output    : ${MARKEDDUP_DIR}"
echo " Metrics   : ${METRICS_DIR}"
echo " ************************************** "

for i in "${!SAMPLES}"; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"

    INPUT="${ALIGNED_DIR}/${sample}_sorted.bam"
    OUTPUT="${MARKEDDUP_DIR}/${sample}_markdup.bam"
    METRICS="${METRICS_DIR}/${sample}_markdup_metrics.txt"

    echo ""
    echo " ************************************** "
    echo " Sample: ${sample} (${role})"
    echo " ************************************** "
