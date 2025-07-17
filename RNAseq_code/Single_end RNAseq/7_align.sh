#!/bin/bash

# Set strict error handling
set -euo pipefail

# Number of threads (adjust for your system)
THREADS=4

# STAR genome index directory
GENOME_DIR="./STAR_index"

# Directory containing input FASTQ files
INPUT_DIR="./filtered_reads"

# Output base directory
OUTPUT_BASE="./STAR_outputs2"
mkdir -p "$OUTPUT_BASE"

# Loop through all fastq files with the expected suffix
for FASTQ in "$INPUT_DIR"/*_no_contam.fastq; do
    # Skip if no matching files
    [[ -e "$FASTQ" ]] || continue

    # Extract sample name (keep full name without .fastq)
    BASE=$(basename "$FASTQ")
    SAMPLE="${BASE%.fastq}"

    # Create output directory for this sample
    OUT_DIR="$OUTPUT_BASE/$SAMPLE"
    mkdir -p "$OUT_DIR"

    echo "Running STAR for sample: $SAMPLE"

    # Run STAR_You can add arguments here
    STAR \
      --runThreadN "$THREADS" \
      --genomeDir "$GENOME_DIR" \
      --readFilesIn "$FASTQ" \
      --outFileNamePrefix "$OUT_DIR/${SAMPLE}_" \
      --outSAMtype BAM SortedByCoordinate \
      --limitBAMsortRAM 2000000000

    echo "Finished STAR for $SAMPLE"
done
