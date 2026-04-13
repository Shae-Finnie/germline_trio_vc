#!/bin/bash
#
# 09_GenotypeGVCF.sh
# Joint genotyping across all trio samples from GenomicsDB datastore
# Produces a multi-sample VCF ready for filtration
#
# Env: GATK
# Usage: bash scripts/09_GenotypeGVCFs.sh
# Run from germline_trio_vc/ root
#

set -euo pipefail

# Config

DB_DIR="data/genomicsdb"
VCF_DIR="data/vcf"
REF="data/reference/chr17.fa"

# Dir setup

mkdir -p "${VCF_DIR}"

# Main

echo " ************************************** "
echo " Step 9: Joint Genotyping with GenotypeGVCFs"
echo " Input   : ${DB_DIR}"
echo " Output  : ${VCF_DIR}"
echo " ************************************** "

# Joint genotype all three samples simultaneously from the combined datastore
gatk GenotypeGVCFs \
    -R "${REF}" \
    -V "gendb://${DB_DIR}" \
    -O "${VCF_DIR}/trio_genotyped.vcf.gz" \
    -L chr17

echo ""
echo " ************************************** "
echo " Joint genotyping complete."
echo " VCF : ${VCF_DIR}/trio_genotyped.vcf.gz"
echo " ************************************** "