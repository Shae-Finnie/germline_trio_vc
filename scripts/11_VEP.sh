#!/bin/bash
#
# 11_VEP.sh
# Annotates filtered trio VCF with Ensembl VEP
# Adds consequence, ClinVar, gnomAD frequencies, and ACMG gene flags
#
# Env: vep
# Usage: bash scripts/11_VEP.sh
# Run from germline_trio_vc/ root
#

set -euo pipefail

# Config

VCF_DIR="data/vcf"
RESULTS_DIR="results/vep"
CACHE_DIR="${HOME}/.vep"
ACMG_GENES="config/acmg_sf_v3.2_genes.txt"

INPUT="${VCF_DIR}/trio_filtered.vcf.gz"
OUTPUT="${RESULTS_DIR}/trio_vep.vcf.gz"
STATS="${RESULTS_DIR}/trio_vep_stats.html"

THREADS=8

# Dir setup

mkdir -p "${RESULTS_DIR}"

# Main

echo " ************************************** "
echo " Step 11: VEP Annotation"
echo " Input   : ${INPUT}"
echo " Output  : ${OUTPUT}"
echo " ************************************** "

vep \
    --input_file "${INPUT}" \
    --output_file "${OUTPUT}" \
    --vcf \
    --compress_output bgzip \
    --stats_file "${STATS}" \
    --cache \
    --merged \
    --dir_cache "${CACHE_DIR}" \
    --assembly GRCh38 \
    --offline \
    --everything \
    --fork "${THREADS}" \
    --gene_phenotype \
    --check_existing \
    --af_gnomadg \
    --filter_common \
    --custom file="${ACMG_GENES}",short_name=ACMG,format=bed,type=overlap \
    --force_overwrite

echo ""
echo " ************************************** "
echo " VEP annotation complete."
echo " Annotated VCF : ${OUTPUT}"
echo " Stats report  : ${STATS}"
echo " ************************************** "