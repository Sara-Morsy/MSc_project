#!/bin/bash

set -euo pipefail

# Configuration
IN_DIR="cleaned_reads"
OUT_DIR="fastqc"
THREADS_PER_JOB=2
TOTAL_CORES=$(nproc)
MAX_JOBS=$((TOTAL_CORES / THREADS_PER_JOB))

mkdir -p "$OUT_DIR"

# FastQC runner for single-end cleaned reads
run_fastqc_single_cleaned() {
    FILE="$1"
    SAMPLE=$(basename "$FILE" _clean.fastq)

    echo "Running FastQC on $SAMPLE"

    fastqc "$FILE" \
        --outdir "$OUT_DIR" \
        --threads "$THREADS_PER_JOB"
}

export -f run_fastqc_single_cleaned
export IN_DIR OUT_DIR THREADS_PER_JOB

# Run FastQC on all *_clean.fastq.gz files
find "$IN_DIR" -maxdepth 1 -name "*_clean.fastq" -print0 \
    | sort -z | parallel -0 -j "$MAX_JOBS" run_fastqc_single_cleaned {}

echo "FastQC complete. Reports saved in '$OUT_DIR'"
