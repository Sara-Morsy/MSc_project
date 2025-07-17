#!/bin/bash

set -euo pipefail

TOTAL_THREADS=$(nproc)
THREADS_PER_JOB=8
MAX_JOBS=$((TOTAL_THREADS / THREADS_PER_JOB))

TRIM_DIR="trimmed_reads"
FASTP_LOG_DIR="fastp_logs"

mkdir -p "$TRIM_DIR" "$FASTP_LOG_DIR"

# Export function to run in xargs
process_pair() {
    R1="$1"
    SAMPLE=$(basename "$R1" _1.fastq)
    R2="${SAMPLE}_2.fastq"

    if [ ! -f "$R2" ]; then
        echo "Missing paired file: $R2 for sample $SAMPLE" >&2
        return
    fi

    fastp -i "$R1" -I "$R2" \
        -o "$TRIM_DIR/${SAMPLE}_1_trimmed.fastq.gz" \
        -O "$TRIM_DIR/${SAMPLE}_2_trimmed.fastq.gz" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 20 \
        --length_required 20 \
        --thread "$THREADS_PER_JOB" \
        --html "$FASTP_LOG_DIR/${SAMPLE}.html" \
        --json "$FASTP_LOG_DIR/${SAMPLE}.json"
}

export -f process_pair
export TRIM_DIR FASTP_LOG_DIR THREADS_PER_JOB

# Run in parallel using GNU Parallel or fallback to xargs if not available
if command -v parallel &> /dev/null; then
    ls *_1.fastq | parallel -j "$MAX_JOBS" process_pair {}
else
    ls *_1.fastq | xargs -n 1 -P "$MAX_JOBS" -I {} bash -c 'process_pair "$@"' _ {}
fi
