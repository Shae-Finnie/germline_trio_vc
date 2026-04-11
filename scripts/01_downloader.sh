#!/bin/bash
# =================
# 01_downloader.sh
# =================
# downloads chr17 reads from remote GIAB BAMs for samples "HG005" "HG006" "HG007"
#
# Env: Align
# usage: bash scripts/01_downloader.sh
# run from root germline_trio_vc/
# =================

set -euo pipefail

# config 

CRHOM="chr17"
RAW_DIR="data/raw"

SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

BAM_URLS=(
    "https://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/ChineseTrio/HG005_NA24631_son/NHGRI_Illumina300X_Chinesetrio_novoalign_bams/HG005.GRCh38_full_plus_hs38d1_analysis_set_minus_alts.300x.bam"
    "https://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/ChineseTrio/HG006_NA24694-huCA017E_father/NA24694_Father_HiSeq100x/NHGRI_Illumina100X_Chinesetrio_novoalign_bams/HG006.GRCh38_full_plus_hs38d1_analysis_set_minus_alts.100x.bam"
    "https://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/ChineseTrio/HG007_NA24695-hu38168_mother/NA24695_Mother_HiSeq100x/NHGRI_Illumina100X_Chinesetrio_novoalign_bams/HG007.GRCh38_full_plus_hs38d1_analysis_set_minus_alts.100x.bam"
) 

# directory setup 
mkdir -p "${RAW_DIR}/bam"

# Main 
echo " ************************************** "
echo " Step 1: Download chr17 reads from GIAB"
echo " Target chromosome : ${CHROM}"
echo " ************************************** "

for i in 0 1 2; do
    sample="${SAMPLES[$i]}"
    role="${ROLES[$i]}"
    url="${BAM_URLS[$i]}"
    out_bam="${RAW_DIR}/bam/${sample}_chr17.bam"

echo ""
echo " ************************************** "
echo " Sample: ${sample} (${role})"
echo " ************************************** "

    if [[ -f "${out_bam}" ]]; then
        echo "[INFO] ${sample}: chr17 BAM already exists, skipping"
        continue
    fi

    echo "[INFO] ${sample}: Streaming ${CHROM} reads from GIAB..."
    samtools view -b -o "${out_bam}" "${url}" "${CHROM}"
    samtools index "${out_bam}"
    echo "[INFO] ${sample}: Done -> ${out_bam}"
done

echo ""
echo " ************************************** "
echo " Download finished, BAMs are in: ${RAW_DIR}/bam/"
echo " ************************************** "
