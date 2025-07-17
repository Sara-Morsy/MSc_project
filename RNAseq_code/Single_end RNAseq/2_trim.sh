#!/bin/bash

set -euo pipefail

# Configuration
THREADS_PER_JOB=4
TOTAL_CORES=$(nproc)
MAX_JOBS=$((TOTAL_CORES / THREADS_PER_JOB))
IN_DIR="."
OUT_DIR="cleaned_reads_single"

mkdir -p "$OUT_DIR"

# Fastp processing function for single-end data
run_fastp_single() {
    FILE="$1"
    SAMPLE=$(basename "$FILE" .fastq)

    echo "Processing $SAMPLE"
#you can add arguments for trimming here
    fastp \
        -i "$FILE" \
        -o "$OUT_DIR/${SAMPLE}_clean.fastq" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 28 \
        --length_required 20 \
        --low_complexity_filter \
        --thread "$THREADS_PER_JOB"
}

export -f run_fastp_single
export IN_DIR OUT_DIR THREADS_PER_JOB

# Run in parallel on all .fastq.gz files in the input directory
find "$IN_DIR" -maxdepth 1 -name "*.fastq" -print0 \
  | sort -z | parallel -0 -j "$MAX_JOBS" run_fastp_single {}

echo "All single-end FASTQ files processed and saved in '$OUT_DIR'"

