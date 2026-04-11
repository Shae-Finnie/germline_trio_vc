#!/bin/bash
# 
# 02_bam_to_fastq
# Converts chr17 bams to FASTQs for each trio samples
# 
# Env: Align
# Usage: bash scripts/02_bam_to_fastq.sh
# Run from germline_trio_vc/ root 
#

set -euo pipefail

# Config
RAW_DIR="data/raw"
THREADS=4
SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

# Make dir
mkdir -p "${RAW_DIR}/fastq"

# Main
echo "***********************************************"
echo " Step 2: BAM to FASTQ converter"
echo "***********************************************"

for i in 0 1 2; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"
    in_bam="${RAW_DIR}/bam/${sample}_chr17.bam"
    r1="${RAW_DIR}/fastq/${sample}_R1.fastq.gz"
    r2="${RAW_DIR}/fastq/${sample}_R2.fastq.gz"

    echo ""
    echo "───────────────────────────────────────────────"
    echo " Sample: ${sample} (${role})"
    echo "───────────────────────────────────────────────"

    if [[ ! -f "${in_bam}" ]]; then
        echo "[ERROR] ${sample}: BAM not found at ${in_bam}"
        echo "        Run 01_download.sh first"
        exit 1
    fi

    if [[ -f "${r1}" ]]; then
        echo "[INFO] ${sample}: FASTQs already exist, skipping"
        continue
    fi

    echo "[INFO] ${sample}: Converting BAM to FASTQ..."
    samtools fastq \
        -@ "${THREADS}" \
        -1 "${r1}" \
        -2 "${r2}" \
        -0 /dev/null \
        -s /dev/null \
        -n \
        "${in_bam}"
    echo "[INFO] ${sample}: Done -> ${r1}, ${r2}"
done

echo ""
echo "***********************************************"
echo " BAM to FASTQ complete. FASTQs in: ${RAW_DIR}/fastq/"
echo "***********************************************"
