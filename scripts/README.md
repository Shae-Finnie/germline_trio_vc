# Scripts for VC calling pipeline 

## 01_downloader.sh
Streams chr17 reads directly from the GIAB remote BAMs for all three trio samples using samtools view, avoiding a full genome download. Outputs per-sample chr17 BAMs to data/raw/bam/
## 02_bam_to_fastq.sh
Converts the chr17 BAMs to paired-end FASTQ files using samtools fastq. Preserves read pairing and discards supplementary/singleton reads. Outputs to data/raw/fastq/
## 03_fastp.sh
Trims adapters and low-quality bases from raw paired-end reads using fastp. Applies PE adapter auto-detection, quality filtering (Q20), minimum length filtering (50bp), and read correction. Outputs trimmed FASTQs to data/trimmed/ and HTML/JSON QC reports to results/qc/fastp/
## 04_aligner.sh
Aligns trimmed paired-end reads to the chr17 GRCh38 reference using bwa-mem2. Adds read group tags required by GATK, pipes directly into samtools sort, and indexes the output. Outputs sorted BAMs to data/aligned/
## 05_Markdups.sh
Marks PCR and optical duplicate reads in the sorted BAMs using GATK MarkDuplicates. Duplicate reads are flagged rather than removed, preserving them for review. Outputs duplicate-marked BAMs to data/marked/ and per-sample metrics to data/metrics/
- since this example project converted bam to fastq back to bam there won't be any meaningful duplicates to mark, this is primarily for practice 


