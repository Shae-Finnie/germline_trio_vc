# Scripts for VC calling pipeline 

## 00_RefFetcher.sh 
Downloads chr17 slices of the GATK known sites VCFs (dbSNP and Mills indels) required for base quality score recalibration. Full VCFs are downloaded, sliced to chr17, and indexed with tabix.
## 01_downloader.sh
Streams chr17 reads from the publicly available GIAB whole-genome BAMs for all three trio members (HG005 proband, HG006 father, HG007 mother) using samtools, avoiding a full genome download.
## 02_bam_to_fastq.sh
Converts the chr17 BAMs to paired-end FASTQ files using samtools fastq, preparing reads for trimming and re-alignment under controlled pipeline conditions.
## 03_fastp.sh 
Trims adapters and low-quality bases from raw reads using fastp. Applies PE adapter auto-detection, Q20 quality filtering, 50bp minimum length, and read correction. HTML and JSON QC reports are generated per sample.
## 04_aligner.sh
Aligns trimmed paired-end reads to the GRCh38 chr17 reference using BWA-MEM2. Read group tags required by GATK are added at this stage. Output is coordinate-sorted and indexed.
## 05_markdups.sh
Marks PCR and optical duplicate reads in the sorted BAMs using GATK MarkDuplicates. Duplicates are flagged rather than removed. Per-sample duplication metrics are written to data/metrics/.
## 06_BQSR.sh
Performs Base Quality Score Recalibration in two passes using GATK. BaseRecalibrator builds a recalibration model using dbSNP and Mills indels as known sites, and ApplyBQSR rewrites the BAM with corrected quality scores. Outputs analysis-ready BAMs.
## 07_HaplotypeCaller.sh
Calls variants per-sample in GVCF mode using GATK HaplotypeCaller. Produces one .g.vcf.gz per sample containing both variant and reference block records, designed for downstream joint genotyping.
## 08_GenomicsDBImport.sh
Merges the three per-sample GVCFs into a GenomicsDB datastore using GATK GenomicsDBImport. This consolidation step is required before joint genotyping and is restricted to chr17.
## 09_GenotypeGVCFs.sh
Performs joint genotyping across all three trio members simultaneously from the GenomicsDB datastore using GATK GenotypeGVCFs. Produces a single multi-sample VCF with genotype calls for all samples at every variant site.
## 10_VariantFiltration.sh 
Applies GATK hard filters separately to SNPs and indels using established best practice thresholds (QD, FS, MQ, MQRankSum, ReadPosRankSum). VQSR is not used as the cohort size is insufficient. Filtered variants are tagged rather than removed and the two variant types are merged back into a single VCF.
## 11_VEP.sh
Annotates the filtered VCF using Ensembl VEP with the merged GRCh38 cache (v115). Adds consequence predictions, HGVS notation, SIFT and PolyPhen scores, gnomAD genome allele frequencies, ClinVar significance, and existing variant identifiers.
## 12_ACMGfilter.py
Filters the VEP-annotated VCF to variants overlapping the 80 ACMG Secondary Findings v3.2 genes. Variants with a gnomAD genome allele frequency above 1% are excluded as likely benign population polymorphisms.
## 13_Report.py
Parses the ACMG-filtered VCF and generates a human-readable TSV report with one row per variant. Columns include gene, consequence, HGVS notation, SIFT/PolyPhen predictions, gnomAD AF, ClinVar significance, and genotypes for all three trio members.


