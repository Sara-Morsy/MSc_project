#!/bin/bash

# Configuration
GENOME_DIR="./GRCh38_STAR_index2"  # STAR index directory
THREADS=16
INPUT_DIR="./"  # Directory with FASTQ files
OUTDIR_BASE="./star_aligned"

# Loop through all *_1_clean.fastq.gz files
for READ1 in "$INPUT_DIR"/*_1_clean.fastq.gz; do
  # Get the sample name by removing the _1_clean.fastq.gz suffix
  SAMPLE=$(basename "$READ1" _1_clean.fastq.gz)
  READ2="${INPUT_DIR}/${SAMPLE}_2_clean.fastq.gz"

  # Confirm both reads exist
  if [[ ! -f "$READ2" ]]; then
    echo "Skipping $SAMPLE: $READ2 not found."
    continue
  fi

  # Define output directory
  OUTDIR="${OUTDIR_BASE}/${SAMPLE}"
  mkdir -p "$OUTDIR"

  echo "Processing sample: $SAMPLE"

  # Run STAR
  STAR \
    --runThreadN "$THREADS" \
    --genomeDir "$GENOME_DIR" \
    --readFilesIn "$READ1" "$READ2" \
    --readFilesCommand zcat \
    --outFileNamePrefix "${OUTDIR}/${SAMPLE}_" \
    --outSAMtype BAM SortedByCoordinate \
    --quantMode TranscriptomeSAM \
    --limitBAMsortRAM 28000000000

  echo "STAR alignment complete for $SAMPLE"
  echo "Output BAM: ${OUTDIR}/${SAMPLE}_Aligned.sortedByCoord.out.bam"
  echo "Transcriptome BAM: ${OUTDIR}/${SAMPLE}_Aligned.toTranscriptome.out.bam"
  echo "---------------------------------------------"
done

echo "All samples processed."

