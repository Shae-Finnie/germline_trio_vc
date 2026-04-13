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

set -euo pipefail 

# Config

MARKED_DIR="data/marked"
BQSR_DIR="data/bqsr"
REF="data/reference/chr17.fa"

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

    INPUT="${MARKED_DIR}/${sample}_markdup.bam"
    TABLE="${BQSR_DIR}/${sample}_recal.table"
    OUTPUT="${BQSR_DIR}/${sample}_bqsr.bam"

    echo ""
    echo " ************************************** "
    echo " Sample: ${sample} (${role})"
    echo " ************************************** "

    if [[ -f "${OUTPUT}" ]]; then
        echo "[INFO] ${sample}: BQSR BAM already exists, skipping"
        continue
    fi

    # Pass 1 — build recalibration model from known variant sites
    echo "[INFO] ${sample}: Running BaseRecalibrator....."
    gatk BaseRecalibrator \
        -I "${INPUT}" \
        -R "${REF}" \
        --known-sites "${DBSNP}" \
        --known-sites "${MILLS}" \
        -O "${TABLE}"

    # Pass 2 — apply recalibration model to correct base quality scores
    echo "[INFO] ${sample}: Applying BQSR....."
    gatk ApplyBQSR \
        -I "${INPUT}" \
        -R "${REF}" \
        --bqsr-recal-file "${TABLE}" \
        -O "${OUTPUT}"

    echo "[INFO] ${sample}: BQSR complete -> ${OUTPUT}"
done

echo ""
echo " ************************************** "
echo " BQSR complete."
echo " Analysis-ready BAMs : ${BQSR_DIR}"
echo " ************************************** "