#!/bin/bash

# 05_Markdups.sh
# Marks duplicates present in sorted bams 
# Output files sorted and marked duplicates, ready for variant calling 
#
# Env: GATK
# usage bash scripts/05_Markdups.sh
# run in germline_trio_vc/ root
#

set -euo pipefail 

# Config 

ALIGNED_DIR="data/aligned"
METRICS_DIR="data/metrics"
MARKEDDUP_DIR="data/marked"

SAMPLES=("HG005" "HG006" "HG007")
ROLES=("proband" "father" "mother")

THREADS=8

# Dir setup

mkdir -p "${METRICS_DIR}"
mkdir -p "${MARKEDDUP_DIR}"

# Main 


