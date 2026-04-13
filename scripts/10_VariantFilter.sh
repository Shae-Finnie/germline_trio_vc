#!/bin/bash
#
# 10_VariantFilter.sh
# Hard filtering of SNPs and indels from joint-genotyped trio VCF
# VQSR not used — cohort too small to train model
# Outputs a single filtered VCF with FILTER tags applied
#
# Env: GATK
# Usage: bash scripts/10_VariantFilter.sh
# Run from germline_trio_vc/ root
#

set -euo pipefail

# Config

VCF_DIR="data/vcf"
REF="data/reference/chr17.fa"

INPUT="${VCF_DIR}/trio_genotyped.vcf.gz"
SNP_TMP="${VCF_DIR}/trio_snps_filtered.vcf.gz"
INDEL_TMP="${VCF_DIR}/trio_indels_filtered.vcf.gz"
OUTPUT="${VCF_DIR}/trio_filtered.vcf.gz"

# Dir setup

mkdir -p "${VCF_DIR}"

# Main #
# Hard filter thresholds follow GATK best practices for small cohorts where
# VQSR is not viable. QD normalises variant quality by depth to catch weak
# calls at well-covered sites. FS measures strand bias 
# on both strands; artifact-heavy thresholds differ between SNPs (60) and
# indels (200) since indels have natural strand bias from alignment. MQ flags
# sites with poor mapping quality across reads. MQRankSum and ReadPosRankSum
# are rank-sum tests comparing ref vs alt reads — negative values indicate
# the alt allele is enriched in poorly mapped reads or read ends respectively,
# both signatures of sequencing artifacts rather than true variants.

echo " ************************************** "
echo " Step 10: Variant Filtration"
echo " Input  : ${INPUT}"
echo " Output : ${OUTPUT}"
echo " ************************************** "

# extract and filter SNPs
echo "[INFO] Filtering SNPs..."
gatk SelectVariants -R "${REF}" -V "${INPUT}" --select-type-to-include SNP -O "${SNP_TMP}"

gatk VariantFiltration -R "${REF}" -V "${SNP_TMP}" \
    --filter-expression "QD < 2.0"    --filter-name "QD2" \
    --filter-expression "FS > 60.0"   --filter-name "FS60" \
    --filter-expression "MQ < 40.0"   --filter-name "MQ40" \
    --filter-expression "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    --filter-expression "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -O "${SNP_TMP/.vcf.gz/_tagged.vcf.gz}"

# extract and filter indels
echo "[INFO] Filtering indels..."
gatk SelectVariants -R "${REF}" -V "${INPUT}" --select-type-to-include INDEL -O "${INDEL_TMP}"

gatk VariantFiltration -R "${REF}" -V "${INDEL_TMP}" \
    --filter-expression "QD < 2.0"    --filter-name "QD2" \
    --filter-expression "FS > 200.0"  --filter-name "FS200" \
    --filter-expression "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O "${INDEL_TMP/.vcf.gz/_tagged.vcf.gz}"

# merge filtered SNPs and indels back together
echo "[INFO] Merging filtered SNPs and indels..."
gatk MergeVcfs \
    -I "${SNP_TMP/.vcf.gz/_tagged.vcf.gz}" \
    -I "${INDEL_TMP/.vcf.gz/_tagged.vcf.gz}" \
    -O "${OUTPUT}"

echo ""
echo " ************************************** "
echo " Filtration complete."
echo " Filtered VCF : ${OUTPUT}"
echo " ************************************** "