#!/bin/bash

set -euo pipefail

# References
CONTAM_REF="sequence.fasta"      # your contaminant reference
TRNA_REF="hg19-tRNAs.fa"         # your hg19 tRNA reference

# I/O & threads
IN_DIR="./cleaned_dedup_bbduk2"                       # directory containing *_1_clean.fastq.gz
OUT_DIR="filtered_reads"
THREADS=8
TOTAL_CORES=$(nproc)
MAX_JOBS=$(( TOTAL_CORES / THREADS ))

mkdir -p "$OUT_DIR"

# Batch filter function for paired-end reads
filter_contaminants() {
    R1="$1"
    R2="${R1/_1_clean/_2_clean}"
    SAMPLE=$(basename "$R1" _1_clean.fastq.gz)

    echo "🚀 Filtering contaminants for $SAMPLE"

    if [[ ! -f "$R1" ]]; then echo "❌ R1 not found: $R1"; return 1; fi
    if [[ ! -f "$R2" ]]; then echo "❌ R2 not found: $R2"; return 1; fi

    bbduk.sh \
      in1="$R1" \
      in2="$R2" \
      out1="${OUT_DIR}/${SAMPLE}_1_no_contam.fastq.gz" \
      out2="${OUT_DIR}/${SAMPLE}_2_no_contam.fastq.gz" \
      outm1="${OUT_DIR}/${SAMPLE}_1_contam.fastq.gz" \
      outm2="${OUT_DIR}/${SAMPLE}_2_contam.fastq.gz" \
      ref="${CONTAM_REF},${TRNA_REF}" \
      k=31 \
      ktrim=r \
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

# Run in parallel over all *_1_clean.fastq.gz files
find "$IN_DIR" -maxdepth 1 -name "*_1_clean.fastq.gz" -print0 \
  | sort -z \
  | parallel -0 -j "$MAX_JOBS" filter_contaminants {}

echo "🎉 All samples processed. Clean paired reads in '$OUT_DIR'"

