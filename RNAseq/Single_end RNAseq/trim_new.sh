#!/bin/bash

set -euo pipefail

# Configuration
THREADS_PER_JOB=8
TOTAL_CORES=$(nproc)
MAX_JOBS=$(( TOTAL_CORES / THREADS_PER_JOB ))
IN_DIR="."
OUT_DIR="cleaned_reads"

mkdir -p "$OUT_DIR"

# Fastp processing function for single-end reads
run_fastp_clean_se() {
    R1="$1"
    SAMPLE=$(basename "$R1" .fastq)

    echo "Processing $SAMPLE"

    fastp \
        -i "$R1" \
        -o "$OUT_DIR/${SAMPLE}_clean.fastq" \
        --qualified_quality_phred 28 \

        --low_complexity_filter \
        --trim_front1 10 \

        --thread "$THREADS_PER_JOB"
}

export -f run_fastp_clean_se
export IN_DIR OUT_DIR THREADS_PER_JOB

# Run for all *.fastq.gz files in parallel
find "$IN_DIR" -maxdepth 1 -name "*.fastq" -print0 \
  | sort -z \
  | parallel -0 -j "$MAX_JOBS" run_fastp_clean_se {}

echo "All single-end FASTQ files processed and saved in '$OUT_DIR'"

