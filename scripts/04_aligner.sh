#!/bin/bash
#
# 04_Aligner.sh
# Aligns trimmed paired-end reads to GRCh38 using BWA-MEM2
# Sorted outputs
#
# Env: Align
# Usage: bash scripts/04_align.sh
# run in germline_trio_vc/
# 

set -euo pipefail

# Config

TRIMMED_DIR="data/trimmed"
ALIGNED_DIR="data/aligned"
REF="data/reference/chr17.fa"

SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

THREADS=8

# Directory setup

mkdir -p "${ALIGNED_DIR}"

# Main

echo " ************************************** "
echo " Step 4: Alignment with BWA-MEM2"
echo " Reference : ${REF}"
echo " Input     : ${TRIMMED_DIR}"
echo " Output    : ${ALIGNED_DIR}"
echo " ************************************** "

for i in 0 1 2; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"

    r1="${TRIMMED_DIR}/${sample}_R1_trimmed.fastq.gz"
    r2="${TRIMMED_DIR}/${sample}_R2_trimmed.fastq.gz"

    sorted_bam="${ALIGNED_DIR}/${sample}_sorted.bam"

    echo ""
    echo " ************************************** "
    echo " Sample: ${sample} (${role})"
    echo " ************************************** "

    if [[ -f "${sorted_bam}" ]]; then
        echo "[INFO] ${sample}: Sorted BAM already exists, skipping"
        continue
    fi

    # Read group tag — required by GATK downstream
    RG="@RG\tID:${sample}\tSM:${sample}\tPL:ILLUMINA\tLB:${sample}_lib1\tPU:unit1"

    echo "[INFO] ${sample}: Aligning with BWA-MEM2..."
    bwa-mem2 mem \
        -t "${THREADS}" \
        -R "${RG}" \
        "${REF}" \
        "${r1}" "${r2}" \
    | samtools sort \
        -@ "${THREADS}" \
        -o "${sorted_bam}"

    samtools index "${sorted_bam}"

    echo "[INFO] ${sample}: Bam sorted -> ${sorted_bam}" 
done

echo ""
echo " ************************************** "
echo " Alignment complete."
echo " Aligned BAMs : ${ALIGNED_DIR}"
echo " ************************************** "

