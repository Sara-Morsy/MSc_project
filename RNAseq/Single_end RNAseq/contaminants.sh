#!/bin/bash

set -euo pipefail

# References
CONTAM_REF="sequence.fasta"      # your contaminant reference
TRNA_REF="hg19-tRNAs.fa"         # your hg19 tRNA reference

# I/O & threads
IN_DIR="./cleaned_dedup_bbduk2"                       # directory containing *_clean.fastq.gz
OUT_DIR="filtered_reads"
THREADS=8
TOTAL_CORES=$(nproc)
MAX_JOBS=$(( TOTAL_CORES / THREADS ))

mkdir -p "$OUT_DIR"

# Batch filter function
filter_contaminants() {
    R1="$1"
    SAMPLE=$(basename "$R1" _clean.fastq)

    echo "🚀 Filtering contaminants for $SAMPLE"

    bbduk.sh \
      in="$R1" \
      out="${OUT_DIR}/${SAMPLE}_no_contam.fastq" \
      outm="${OUT_DIR}/${SAMPLE}_contam.fastq" \
      ref="${CONTAM_REF},${TRNA_REF}" \
      k=31 \
      ktrim=r \               # ← specify trimming direction
      hdist=1 \
      mink=12 \
      minoverlap=12 \
      minlen=20 \
      stats="${OUT_DIR}/${SAMPLE}_bbduk_contam_stats.txt" \
      threads="$THREADS"

    echo "✅ Done filtering $SAMPLE"
}

export -f filter_contaminants
export OUT_DIR CONTAM_REF TRNA_REF THREADS

# Run in parallel over all *_clean.fastq.gz files
find "$IN_DIR" -maxdepth 1 -name "*_clean.fastq" -print0 \
  | sort -z \
  | parallel -0 -j "$MAX_JOBS" filter_contaminants {}

echo "🎉 All samples processed. Clean reads in '$OUT_DIR'"

