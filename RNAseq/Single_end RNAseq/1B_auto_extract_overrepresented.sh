#!/bin/bash

FASTQC_DIR="fastqc_reports"
OUTPUT_FASTA="contaminants_from_html.fasta"

> "$OUTPUT_FASTA"

echo "🔍 Extracting overrepresented sequences from FastQC HTML files..."

for FILE in "$FASTQC_DIR"/*_fastqc.html; do
    SAMPLE=$(basename "$FILE" _fastqc.html)

    # Extract lines between "Overrepresented sequences" table
    awk "/Overrepresented sequences/,/<\/table>/" "$FILE" \
    | grep -Eo '>[ACGTN]+' \
    | sed 's/>//' \
    | awk -v sample="$SAMPLE" '{
        print ">"sample"_seq"NR"\n"$0
    }' >> "$OUTPUT_FASTA"
done

echo "Extracted FASTA saved to: $OUTPUT_FASTA"

