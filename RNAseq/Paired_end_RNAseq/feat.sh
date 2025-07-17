#!/bin/bash

# Path to annotation file
GTF="gencode.gtf"

# Output file
OUTPUT="gene_counts.txt"

# Create an empty list of BAM files
BAM_FILES=""

# Loop over all folders beginning with SRR*
for folder in SRR*; do
    BAM="${folder}/${folder}_Aligned.sortedByCoord.out.bam"
    if [[ -f "$BAM" ]]; then
        BAM_FILES+="$BAM "
    else
        echo "WARNING: BAM file not found for $folder"
    fi
done

# Run featureCounts
featureCounts -T 8 \
  -a "$GTF" \
  -o "$OUTPUT" \
  -g gene_id \
  -t exon \
  -p -B -C \
  $BAM_FILES
