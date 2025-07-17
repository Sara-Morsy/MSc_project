#!/bin/bash

set -euo pipefail

# Configuration
THREADS_PER_JOB=8
TOTAL_CORES=$(nproc)
MAX_JOBS=$(( TOTAL_CORES / THREADS_PER_JOB ))
IN_DIR="./cleaned_reads"
OUT_DIR="cleaned_dedup_bbduk2"
REF_FASTA="output.fasta"

mkdir -p "$OUT_DIR"

# Function to process each sample (single-end FASTQ)
process_sample_se() {
    R1="$1"
    SAMPLE=$(basename "$R1" _clean.fastq)

    echo "🚀 Processing $SAMPLE"

    # Step 1: Deduplicate with clumpify (single-end)
    clumpify.sh \
        in="$R1" \
        out="${OUT_DIR}/${SAMPLE}_dedup.fastq" \
        dedupe subs=1 threads="$THREADS_PER_JOB"

    # Step 2: Filter overrepresented sequences with bbduk (single-end)
    bbduk.sh \
        in="${OUT_DIR}/${SAMPLE}_dedup.fastq" \
        out="${OUT_DIR}/${SAMPLE}_clean.fastq" \
        ref="$REF_FASTA" \
        k=31 hdist=1 threads="$THREADS_PER_JOB" \
        stats="${OUT_DIR}/${SAMPLE}_bbduk_stats.txt"

    echo "✅ Finished $SAMPLE"
}

export -f process_sample_se
export IN_DIR OUT_DIR THREADS_PER_JOB REF_FASTA

# Run in parallel over all *_clean.fastq files
find "$IN_DIR" -maxdepth 1 -name "*_clean.fastq" -print0 \
  | sort -z \
  | parallel -0 -j "$MAX_JOBS" process_sample_se {}

echo "🎉 All samples processed. Output in '$OUT_DIR'"

