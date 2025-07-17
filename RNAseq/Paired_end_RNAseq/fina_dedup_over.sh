#!/bin/bash

set -euo pipefail

# Configuration
THREADS_PER_JOB=8
TOTAL_CORES=$(nproc)
MAX_JOBS=$((TOTAL_CORES / THREADS_PER_JOB))
IN_DIR="./cleaned_reads"
OUT_DIR="cleaned_dedup_bbduk2"
REF_FASTA="filtered.fasta"

mkdir -p "$OUT_DIR"

# Function to process each sample
process_sample() {
    R1="$1"
    SAMPLE=$(basename "$R1" _1_clean.fastq.gz)
    R2="${IN_DIR}/${SAMPLE}_2_clean.fastq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "⚠️  Missing pair for $SAMPLE — skipping"
        return
    fi

    echo "🚀 Processing $SAMPLE"

    # Step 1: Deduplicate with clumpify
    clumpify.sh \
        in="$R1" in2="$R2" \
        out="${OUT_DIR}/${SAMPLE}_1_dedup.fastq.gz" \
        out2="${OUT_DIR}/${SAMPLE}_2_dedup.fastq.gz" \
        dedupe subs=0 threads="$THREADS_PER_JOB"

    # Step 2: Filter overrepresented sequences with bbduk
    bbduk.sh \
        in="${OUT_DIR}/${SAMPLE}_1_dedup.fastq.gz" \
        in2="${OUT_DIR}/${SAMPLE}_2_dedup.fastq.gz" \
        out="${OUT_DIR}/${SAMPLE}_1_clean.fastq.gz" \
        out2="${OUT_DIR}/${SAMPLE}_2_clean.fastq.gz" \
        ref="$REF_FASTA" \
        k=31 hdist=1 threads="$THREADS_PER_JOB" \
        stats="${OUT_DIR}/${SAMPLE}_bbduk_stats.txt"

    echo "✅ Finished $SAMPLE"
}

export -f process_sample
export IN_DIR OUT_DIR THREADS_PER_JOB REF_FASTA

# Run in parallel
find "$IN_DIR" -maxdepth 1 -name "*_1_clean.fastq.gz" -print0 \
  | sort -z | parallel -0 -j "$MAX_JOBS" process_sample {}

echo "🎉 All samples processed. Output in '$OUT_DIR'"
