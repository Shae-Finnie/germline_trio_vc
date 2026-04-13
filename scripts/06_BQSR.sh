#!/bin/bash
#
# 06_BQSR.sh
# Identify inaccurate base scores that were produced by systemic errors during sequencing 
# Two passes: 1. BaseRecalibrator (builds model), 2. apply BQSR (corrects scores)
# Outputs Bams that are ready for haplotype calling
#
# Env: GATK
# usage: bash scripts/06_BQSR.sh
# Run in root of germline_trio_vc
#

set -euo pipefail 