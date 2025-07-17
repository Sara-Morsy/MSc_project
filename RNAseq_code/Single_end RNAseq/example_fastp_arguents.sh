#!/usr/bin/env bash
#
# batch_rescue_trim_fastp.sh
#
# Batch rescue trimming for all single-end samples with fastp:
#   Input: cleaned_dedup_bbduk2/*clean_dedup.trimmed.fastq
#   Steps for each sample:
#     1) Remove first 10 bases
#     2) Remove last 10 bases
#     3) Sliding-window trim ends at mean Q<28 (window size 4)
#     4) Trim poly-G and poly-X tails
#     5) Discard reads shorter than 30 nt
#     6) Filter low-complexity reads (entropy <30)
#     7) Auto-detect and trim residual adapters/primers
#
# Usage:
#   chmod +x batch_rescue_trim_fastp.sh
#   ./batch_rescue_trim_fastp.sh

INDIR="./To"
OUTDIR="./trimmed_rescue"
mkdir -p "${OUTDIR}"

echo "Starting batch rescue trimming for files in ${INDIR}..."

# Loop over all FASTQ files named *clean_dedup.trimmed.fastq
for INFASTQ in "${INDIR}"/*clean_dedup.trimmed.fastq; do
    [[ -e "${INFASTQ}" ]] || continue

    # Derive sample name by stripping directory and suffix
    BASENAME=$(basename "${INFASTQ}")
    SAMPLE=${BASENAME%%_clean_dedup.trimmed.fastq}

    # Define output FASTQ filename (uncompressed)
    OUTFASTQ="${OUTDIR}/${SAMPLE}.rescue.fastq"

    echo ">>> Processing ${SAMPLE}: ${INFASTQ} → ${OUTFASTQ}"

    # Execute fastp with corrected flags
    fastp \
        -i "${INFASTQ}" \
        -o "${OUTFASTQ}" \
        --trim_front1 10 \
        --trim_tail1 10 \
        --cut_window_size 4 \
        --cut_mean_quality 28 \
        --trim_poly_g \
        --trim_poly_x \
        --length_required 30 \
        --complexity_threshold 30 \
        

done

echo "Batch rescue trimming complete! Trimmed files are in '${OUTDIR}/'"

