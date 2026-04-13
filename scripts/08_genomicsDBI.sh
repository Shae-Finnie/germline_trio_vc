#!/bin/bash
#
# 08_GenomicsDBI.sh
# Merges per-sample GVCFs into a GenomicsDB datastore for joint genotyping
# Required input for 09_GenotypeGVCFs.sh
#
# Env: GATK
# Usage: bash scripts/08_GenomicsDBImport.sh
# Run from germline_trio_vc/ root
#

set -euo pipefail

# Config

GVCF_DIR="data/gvcf"
DB_DIR="data/genomicsdb"

SAMPLES=("HG005" "HG006" "HG007")

# Dir setup — GenomicsDBImport requires the output dir to NOT exist
# Remove if re-running

if [[ -d "${DB_DIR}" ]]; then
    echo "[WARN] ${DB_DIR} already exists, removing for fresh import..."
    rm -rf "${DB_DIR}"
fi

# Main

echo " ************************************** "
echo " Step 8: GenomicsDB Import"
echo " Input   : ${GVCF_DIR}"
echo " Output  : ${DB_DIR}"
echo " ************************************** "

# Merge all three per-sample GVCFs into a single combined datastore
gatk GenomicsDBImport \
    -V "${GVCF_DIR}/HG005.g.vcf.gz" \
    -V "${GVCF_DIR}/HG006.g.vcf.gz" \
    -V "${GVCF_DIR}/HG007.g.vcf.gz" \
    --genomicsdb-workspace-path "${DB_DIR}" \
    -L chr17

echo ""
echo " ************************************** "
echo " GenomicsDB import complete."
echo " Datastore : ${DB_DIR}"
echo " ************************************** "