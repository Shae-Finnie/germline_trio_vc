#!/bin/bash
#
# 07_HaplotypeCaller.sh
# Per-sample variant calling in GVCF mode using GATK HaplotypeCaller
# Produces one .g.vcf.gz per sample for joint genotyping in 08_GenomicsDB.sh
#
# Env: GATK
# Usage: bash scripts/07_HaplotypeCaller.sh
# Run from germline_trio_vc/ root
#

set -euo pipefail

# Config

BQSR_DIR="data/bqsr"
GVCF_DIR="data/gvcf"
REF="data/reference/chr17.fa"

SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

# Dir setup

mkdir -p "${GVCF_DIR}"

# Main

echo " ************************************** "
echo " Step 7: HaplotypeCaller (GVCF mode)"
echo " Input   : ${BQSR_DIR}"
echo " Output  : ${GVCF_DIR}"
echo " ************************************** "

for i in "${!SAMPLES[@]}"; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"

    INPUT="${BQSR_DIR}/${sample}_bqsr.bam"
    OUTPUT="${GVCF_DIR}/${sample}.g.vcf.gz"

    echo ""
    echo " ************************************** "
    echo " Sample: ${sample} (${role})"
    echo " ************************************** "

    if [[ -f "${OUTPUT}" ]]; then
        echo "[INFO] ${sample}: GVCF already exists, skipping"
        continue
    fi

    # Call variants in GVCF mode — produces per-sample intermediate for joint calling
    echo "[INFO] ${sample}: Running HaplotypeCaller..."
    gatk HaplotypeCaller \
        -I "${INPUT}" \
        -R "${REF}" \
        -O "${OUTPUT}" \
        -ERC GVCF \
        -L chr17

    echo "[INFO] ${sample}: GVCF -> ${OUTPUT}"
done

echo ""
echo " ************************************** "
echo " HaplotypeCaller complete."
echo " GVCFs : ${GVCF_DIR}"
echo " ************************************** "