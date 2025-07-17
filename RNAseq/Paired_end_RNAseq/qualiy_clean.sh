#!/bin/bash

set -euo pipefail

# Configuration
IN_DIR="cleaned_reads"
OUT_DIR="fastqc_cleaned_reports"
THREADS_PER_JOB=2
TOTAL_CORES=$(nproc)
MAX_JOBS=$((TOTAL_CORES / THREADS_PER_JOB))

mkdir -p "$OUT_DIR"

# FastQC runner for paired-end cleaned reads
run_fastqc_cleaned() {
    R1="$1"
    SAMPLE=$(basename "$R1" _1_clean.fastq.gz)
    R2="${IN_DIR}/${SAMPLE}_2_clean.fastq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "⚠️  Missing R2 for $SAMPLE — skipping"
        return
    fi

    echo "📊 Running FastQC on $SAMPLE"

    fastqc "$R1" "$R2" \
        --outdir "$OUT_DIR" \
        --threads "$THREADS_PER_JOB"
}

export -f run_fastqc_cleaned
export IN_DIR OUT_DIR THREADS_PER_JOB

# Run FastQC on all _1_clean.fastq.gz files
find "$IN_DIR" -maxdepth 1 -name "*_1_clean.fastq.gz" -print0 \
    | sort -z | parallel -0 -j "$MAX_JOBS" run_fastqc_cleaned {}

echo "✅ FastQC complete. Reports saved in '$OUT_DIR'"

