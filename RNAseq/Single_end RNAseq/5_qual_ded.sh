#!/bin/bash

set -euo pipefail

# Configuration
IN_DIR="cleaned_dedup_bbduk2"
OUT_DIR="fastqc_dedup_reports"
THREADS_PER_JOB=2
TOTAL_CORES=$(nproc)
MAX_JOBS=$(( TOTAL_CORES / THREADS_PER_JOB ))

mkdir -p "$OUT_DIR"

# FastQC runner for single-end deduplicated FASTQ files
run_fastqc_dedup_se() {
    R1="$1"
    SAMPLE=$(basename "$R1" _clean.fastq)

    echo "📊 Running FastQC on $SAMPLE"
    fastqc "$R1" \
        --outdir "$OUT_DIR" \
        --threads "$THREADS_PER_JOB"
}

export -f run_fastqc_dedup_se
export IN_DIR OUT_DIR THREADS_PER_JOB

# Run FastQC on all *_clean.fastq.gz files in parallel
find "$IN_DIR" -maxdepth 1 -name "*_clean.fastq" -print0 \
  | sort -z \
  | parallel -0 -j "$MAX_JOBS" run_fastqc_dedup_se {}

echo "✅ FastQC complete. Reports saved in '$OUT_DIR'"
