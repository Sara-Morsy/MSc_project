#!/bin/bash

set -euo pipefail

# ========= CONFIG =========
IN_DIR="bbduk_filtered_reads"
OUT_DIR="fastqc_bbduk_reports"
THREADS=4

mkdir -p "$OUT_DIR"

echo "🧬 Running FastQC on BBDuk-filtered files..."

# Run FastQC on all filtered fastq files
find "$IN_DIR" -maxdepth 1 -name "*_filtered.fastq" | while read -r FILE; do
    echo "🔍 Assessing: $(basename "$FILE")"
    fastqc "$FILE" --threads "$THREADS" --outdir "$OUT_DIR"
done

echo "✅ FastQC complete. Reports saved in: $OUT_DIR"

