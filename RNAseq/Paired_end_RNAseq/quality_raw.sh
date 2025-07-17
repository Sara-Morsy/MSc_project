#!/bin/bash

set -euo pipefail

# Configuration
IN_DIR=./
OUT_DIR="fastqc_reports"
THREADS_PER_JOB=2
TOTAL_CORES=$(nproc)
MAX_JOBS=$((TOTAL_CORES / THREADS_PER_JOB))

mkdir -p "$OUT_DIR"

# FastQC function for paired-end reads
run_fastqc_pair() {
    R1="$1"
    SAMPLE=$(basename "$R1" _1.fastq.gz)
    R2="${IN_DIR}/${SAMPLE}_2.fastq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "⚠️  Missing R2 for $SAMPLE — skipping"
        return
    fi

    echo "📊 Running FastQC on $SAMPLE"

    fastqc "$R1" "$R2" \
        --outdir "$OUT_DIR" \
        --threads "$THREADS_PER_JOB"
}

export -f run_fastqc_pair
export IN_DIR OUT_DIR THREADS_PER_JOB

# Find all _1.fastq files and process in parallel
find "$IN_DIR" -maxdepth 1 -name "*_1.fastq.gz" -print0 \
    | sort -z | parallel -0 -j "$MAX_JOBS" run_fastqc_pair {}

echo "✅ FastQC complete. HTML reports saved in '$OUT_DIR'"
