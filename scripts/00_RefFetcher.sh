#!/bin/bash
#
# 00_RefFetcher.sh
# Env: Align
# usage scripts/00_RefFetcher.sh
# Use in root of germline_trio_vc

# Main

set -euo pipefail

REF_DIR="data/reference"
CHROM="chr17"

mkdir -p "${REF_DIR}"

# Download full VCFs + indexes
echo "[INFO downloading dbSNP]"
wget -q -P "${REF_DIR}" "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.40.gz"
wget -q -P "${REF_DIR}" "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.40.gz.tbi"

wget -q -P "${REF_DIR}" "https://ddbj.nig.ac.jp/public/public-human-genomes/GRCh38/fasta/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
wget -q -P "${REF_DIR}" "https://ddbj.nig.ac.jp/public/public-human-genomes/GRCh38/fasta/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi"
echo "[INFO downloading Mills]"

# Slice chr17 and index
echo "[INFO] slicing ${CHROM} from dbSNP"
bcftools view -r "${CHROM}" -O z -o "${REF_DIR}/dbsnp_155.hg38.chr17.vcf.gz" "${REF_DIR}/GCF_000001405.40.gz"
bcftools index -t "${REF_DIR}/dbsnp_155.hg38.chr17.vcf.gz"
echo "[INFO] dbSNP chr17 done"

echo "[INFO] slicing ${CHROM} from Mills"
bcftools view -r "${CHROM}" -O z -o "${REF_DIR}/Mills_and_1000G_gold_standard.indels.hg38.chr17.vcf.gz" "${REF_DIR}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
bcftools index -t "${REF_DIR}/Mills_and_1000G_gold_standard.indels.hg38.chr17.vcf.gz"
echo "[INFO] Mills chr17 done"

# Both need .tbi indexes, -t 
