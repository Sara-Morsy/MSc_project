#!/bin/bash

set -euo pipefail

# Configuration
THREADS_PER_JOB=8
TOTAL_CORES=$(nproc)
MAX_JOBS=$((TOTAL_CORES / THREADS_PER_JOB))
IN_DIR="."
OUT_DIR="cleaned_reads"

mkdir -p "$OUT_DIR"

# Fastp processing function
run_fastp_clean() {
    R1="$1"
    SAMPLE=$(basename "$R1" _1.fastq)
    R2="${IN_DIR}/${SAMPLE}_2.fastq"

    if [[ ! -f "$R2" ]]; then
        echo "Missing pair for $SAMPLE — skipping"
        return
    fi

    echo "Processing $SAMPLE"

    fastp \ #it has all the arguments, adjust based on what you want
        -i "$R1" -I "$R2" \
        -o "$OUT_DIR/${SAMPLE}_1_clean.fastq" \
        -O "$OUT_DIR/${SAMPLE}_2_clean.fastq" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 20 \
        --length_required 20 \
        --low_complexity_filter \
        --cut_front \
        --cut_front_window_size 4 \
        --cut_front_mean_quality 20 \
        --trim_front1 10 \
        --trim_front2 10 \
        --thread "$THREADS_PER_JOB" \
        
}

export -f run_fastp_clean
export IN_DIR OUT_DIR THREADS_PER_JOB

# Run for all *_1.fastq.gz files in parallel
find "$IN_DIR" -maxdepth 1 -name "*_1.fastq" -print0 \
  | sort -z | parallel -0 -j "$MAX_JOBS" run_fastp_clean {}

echo "All FASTQ files processed and saved in '$OUT_DIR'"

