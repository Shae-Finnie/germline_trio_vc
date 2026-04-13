#!/usr/bin/env python3
#
# 12_ACMGfilter.py
# Filters VEP-annotated trio VCF to variants in ACMG Secondary Findings v3.2 genes
# Parses SYMBOL from VEP CSQ field and cross-references against gene list
#
# Env: vep
# Usage: python scripts/12_ACMGfilter.py
# Run from germline_trio_vc/ root
#

import gzip
import sys

# Config
VEP_VCF    = "results/vep/trio_vep.vcf.gz"
ACMG_GENES = "config/acmg_sf_v3.2_genes.txt"
OUTPUT     = "results/vep/trio_acmg.vcf.gz"

# Load ACMG gene list — skip comment lines
acmg_genes = set()
with open(ACMG_GENES) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith("#"):
            acmg_genes.add(line)

print(f"[INFO] Loaded {len(acmg_genes)} ACMG genes")

# Parse VEP VCF and filter to ACMG genes
csq_index = None
kept = 0
total = 0

with gzip.open(VEP_VCF, "rt") as vcf_in, gzip.open(OUTPUT, "wt") as vcf_out:
    for line in vcf_in:

        # Write header lines through unchanged
        if line.startswith("#"):
            # Extract CSQ field order from VEP header
            if "ID=CSQ" in line:
                csq_fields = line.split("Format: ")[1].strip().rstrip('">').split("|")
                csq_index = csq_fields.index("SYMBOL")
            vcf_out.write(line)
            continue

        total += 1
        cols = line.strip().split("\t")
        info = cols[7]

        # Extract SYMBOL from CSQ annotations
        symbols = set()
        for field in info.split(";"):
            if field.startswith("CSQ="):
                for transcript in field[4:].split(","):
                    parts = transcript.split("|")
                    if csq_index is not None and len(parts) > csq_index:
                        symbols.add(parts[csq_index])

        # Keep variant if any transcript overlaps an ACMG gene
        if symbols & acmg_genes:
            vcf_out.write(line)
            kept += 1

print(f"[INFO] Total variants processed : {total}")
print(f"[INFO] Variants in ACMG genes   : {kept}")
print(f"[INFO] Output written to        : {OUTPUT}")