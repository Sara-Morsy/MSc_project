#!/bin/bash
set -euo pipefail

# Define input files and output directory
GENOME_FASTA="genome.fa" #put the downloaded reference from video number 3 in the directory and name them
GTF_FILE="annotations.gtf" #put the downloaded annotation file (GTF) in the directory and name them
OUT_DIR="STAR_genome_index"
NUM_THREADS=8  # Adjust based on your system if you need to

# Create output directory if it doesn't exist
mkdir -p "${OUT_DIR}"

# Run STAR to generate the genome index
STAR \
  --runThreadN "${NUM_THREADS}" \
  --runMode genomeGenerate \
  --genomeDir "${OUT_DIR}" \
  --genomeFastaFiles "${GENOME_FASTA}" \
  --sjdbGTFfile "${GTF_FILE}" \
  --sjdbOverhang 99
