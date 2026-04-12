#!/bin/bash
#
# 00_RefFetcher.sh
# Env: Align
# usage scripts/00_RefFetcher.sh
# Use in root of germline_trio_vc

# Main

bcftools view -r chr17 -O z -o data/reference/dbsnp_146.hg38.vcf.gz \
    "ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz"

bcftools index -t data/reference/dbsnp_146.hg38.vcf.gz

bcftools view -r chr17 -O z -o data/reference/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
    "ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"

bcftools index -t data/reference/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

# Both need .tbi indexes, -t 
