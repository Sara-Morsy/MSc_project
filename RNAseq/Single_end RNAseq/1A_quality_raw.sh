#!/usr/bin/env bash
set -euo pipefail

# Configuration
IN_DIR=./
OUT_DIR="fastqc_reports"
THREADS_PER_JOB=2
TOTAL_CORES=$(nproc)
MAX_JOBS=$((TOTAL_CORES / THREADS_PER_JOB))

mkdir -p "$OUT_DIR"

# FastQC function for single-end .fastq reads
run_fastqc_single() {
    fq="$1"
    sample=$(basename "$fq" .fastq)
    echo "Running FastQC on $sample"
    fastqc "$fq" \
        --outdir "$OUT_DIR" \
        --threads "$THREADS_PER_JOB"
}

export -f run_fastqc_single
export IN_DIR OUT_DIR THREADS_PER_JOB

# Find all .fastq files and process in parallel
find "$IN_DIR" -maxdepth 1 -name "*.fastq" -print0 \
    | sort -z \
    | parallel -0 -j "$MAX_JOBS" run_fastqc_single {}

echo "FastQC complete. Reports are in '$OUT_DIR/'"

