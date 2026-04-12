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

# For each sample, mark PCR/optical duplicates in the sorted BAM using GATK Markduplicates
for i in "${!SAMPLES[@]}"; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"

    INPUT="${ALIGNED_DIR}/${sample}_sorted.bam"
    OUTPUT="${MARKEDDUP_DIR}/${sample}_markdup.bam"
    METRICS="${METRICS_DIR}/${sample}_markdup_metrics.txt"

    echo ""
    echo " ************************************** "
    echo " Sample: ${sample} (${role})"
    echo " ************************************** "

    if [[ -f "${OUTPUT}" ]]; then
        echo "[INFO] ${sample}: Marked BAM already exists, skipping"
        continue
    fi

# MarkDups flags duplicate reads in the sorted BAM, writes a metrics
# file, auto-indexes the output and logs completion.
 echo "[INFO] ${sample}: Marking duplicates..."
    gatk MarkDuplicates \
        -I "${INPUT}" \
        -O "${OUTPUT}" \
        -M "${METRICS}" \
        --CREATE_INDEX true

    echo "[INFO] ${sample}: Marked BAM -> ${OUTPUT}"
done

echo ""
echo " ************************************** "
echo " Mark duplicates complete."
echo " Marked BAMs : ${MARKEDDUP_DIR}"
echo " Metrics     : ${METRICS_DIR}"
echo " ************************************** "