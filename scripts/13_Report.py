#!/usr/bin/env python3
#
# 13_Report.py
# Generates a human-readable TSV report from ACMG-filtered VEP VCF
# One row per variant with gene, consequence, predictions, gnomAD AF,
# ClinVar significance, and trio genotypes
#
# Env: vep
# Usage: python scripts/13_Report.py
# Run from germline_trio_vc/ root
#

import gzip
import csv

# Config
INPUT   = "results/vep/trio_acmg.vcf.gz"
OUTPUT  = "results/vep/trio_acmg_report.tsv"
SAMPLES = ["HG005", "HG006", "HG007"]

# Fields to extract from VEP CSQ
CSQ_FIELDS = [
    "SYMBOL", "Consequence", "IMPACT", "HGVSc", "HGVSp",
    "SIFT", "PolyPhen", "gnomADg_AF", "CLIN_SIG", "Existing_variation"
]

def parse_csq_header(line):
    return line.split("Format: ")[1].strip().rstrip('">').split("|")

def get_csq_values(csq_str, csq_header, fields):
    """Return values from the most severe transcript consequence."""
    transcripts = csq_str[4:].split(",")
    for t in transcripts:
        parts = t.split("|")
        vals = {f: parts[csq_header.index(f)] if f in csq_header and len(parts) > csq_header.index(f) else "." for f in fields}
        if vals.get("IMPACT") in ("HIGH", "MODERATE"):
            return vals
    # Fall back to first transcript if none are high/moderate impact
    parts = transcripts[0].split("|")
    return {f: parts[csq_header.index(f)] if f in csq_header and len(parts) > csq_header.index(f) else "." for f in fields}

csq_header = None
rows = []

with gzip.open(INPUT, "rt") as vcf:
    for line in vcf:
        if line.startswith("##"):
            if "ID=CSQ" in line:
                csq_header = parse_csq_header(line)
            continue

        if line.startswith("#CHROM"):
            header_cols = line.strip().split("\t")
            sample_indices = {s: header_cols.index(s) for s in SAMPLES if s in header_cols}
            continue

        cols = line.strip().split("\t")
        chrom, pos, _, ref, alt, qual, filt = cols[:7]
        info = cols[7]
        fmt  = cols[8].split(":")

        # Extract genotypes
        genotypes = {}
        for sample, idx in sample_indices.items():
            gt_fields = cols[idx].split(":")
            gt = gt_fields[fmt.index("GT")] if "GT" in fmt else "."
            genotypes[sample] = gt

        # Extract CSQ
        csq_str = next((f for f in info.split(";") if f.startswith("CSQ=")), None)
        if csq_str and csq_header:
            csq = get_csq_values(csq_str, csq_header, CSQ_FIELDS)
        else:
            csq = {f: "." for f in CSQ_FIELDS}

        rows.append({
            "CHROM":       chrom,
            "POS":         pos,
            "REF":         ref,
            "ALT":         alt,
            "FILTER":      filt,
            "GENE":        csq["SYMBOL"],
            "CONSEQUENCE": csq["Consequence"],
            "IMPACT":      csq["IMPACT"],
            "HGVSc":       csq["HGVSc"],
            "HGVSp":       csq["HGVSp"],
            "SIFT":        csq["SIFT"],
            "PolyPhen":    csq["PolyPhen"],
            "gnomAD_AF":   csq["gnomADg_AF"],
            "ClinVar":     csq["CLIN_SIG"],
            "rsID":        csq["Existing_variation"],
            "HG005_GT":    genotypes.get("HG005", "."),
            "HG006_GT":    genotypes.get("HG006", "."),
            "HG007_GT":    genotypes.get("HG007", "."),
        })

# Write TSV
fieldnames = [
    "CHROM", "POS", "REF", "ALT", "FILTER", "GENE", "CONSEQUENCE",
    "IMPACT", "HGVSc", "HGVSp", "SIFT", "PolyPhen", "gnomAD_AF",
    "ClinVar", "rsID", "HG005_GT", "HG006_GT", "HG007_GT"
]

with open(OUTPUT, "w", newline="") as out:
    writer = csv.DictWriter(out, fieldnames=fieldnames, delimiter="\t")
    writer.writeheader()
    writer.writerows(rows)

print(f"[INFO] Variants written : {len(rows)}")
print(f"[INFO] Report saved to  : {OUTPUT}")