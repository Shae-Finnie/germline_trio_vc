#!/bin/bash

#
# 03_fastp.sh
# Adapter trimming and QC with fastp for samples HG005, HG006, HG007
#
# Env: Align
# Usage: bash scripts/03_trim_qc.sh
# Run from germline_trio_vc/ root
#

set -euo pipefail 

# Config 

FASTQ_DIR="data/raw/fastq"
TRIMMED_DIR="data/trimmed"
QC_DIR="results/qc/fastp"

SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

THREADS=8

# Dir Setup

mkdir -p "${TRIMMED_DIR}"
mkdir -p "${QC_DIR}"

# Main 

echo " ************************************** "
echo " Step 3: Adapter Trimming and QC"
echo " Tool    : fastp"
echo " Input   : ${FASTQ_DIR}"
echo " Trimmed : ${TRIMMED_DIR}"
echo " Reports : ${QC_DIR}"
echo " ************************************** "

for i in 0 1 2; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"

    r1_in="${FASTQ_DIR}/${sample}_R1.fastq.gz"
    r2_in="${FASTQ_DIR}/${sample}_R2.fastq.gz"

    r1_out="${TRIMMED_DIR}/${sample}_R1_trimmed.fastq.gz"
    r2_out="${TRIMMED_DIR}/${sample}_R2_trimmed.fastq.gz"

    html_report="${QC_DIR}/${sample}_fastp.html"
    json_report="${QC_DIR}/${sample}_fastp.json"

    echo ""
    echo " ************************************** "
    echo " Sample: ${sample} (${role})"
    echo " ************************************** "

    if [[ -f "${r1_out}" && -f "${r2_out}" ]]; then
        echo "[INFO] ${sample}: Trimmed FASTQs already exist, skipping"
        continue
    fi

    echo "[INFO] ${sample}: Running fastp..."

        fastp \
        --in1 "${r1_in}" \
        --in2 "${r2_in}" \
        --out1 "${r1_out}" \
        --out2 "${r2_out}" \
        --html "${html_report}" \
        --json "${json_report}" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 20 \
        --length_required 50 \
        --correction \
        --thread "${THREADS}" \
        --report_title "${sample} fastp QC"

    echo "[INFO] ${sample}: Done -> ${r1_out}, ${r2_out}"
    echo "[INFO] ${sample}: QC report -> ${html_report}"
done

echo ""
echo " ************************************** "
echo " Trimming complete."
echo " Trimmed FASTQs : ${TRIMMED_DIR}"
echo " QC reports     : ${QC_DIR}"
echo " ************************************** "