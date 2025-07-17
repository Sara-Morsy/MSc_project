# Load package (install if needed)

BiocManager::install("Rsubread")

library(Rsubread)

# Set parameters
bam_dir <- "./bam"                     # directory with BAM files
gtf_file <- "annotations.gtf"         # GTF annotation file that you used for STAR
output_file <- "gene_counts.txt"      # Output file

# Get list of BAM files
bam_files <- list.files(bam_dir, pattern = "\\.bam$", full.names = TRUE)

# Run featureCounts on all BAM files
fc_result <- featureCounts(
  files = bam_files,
  annot.ext = gtf_file,
  isGTFAnnotationFile = TRUE,
  GTF.featureType = "exon",
  GTF.attrType = "gene_id",
  useMetaFeatures = TRUE,
  nthreads = 8
)

# View results
head(fc_result$counts)

# Write counts to file
write.table(
  fc_result$counts,
  file = output_file,
  sep = "\t",
  quote = FALSE,
  col.names = NA
)
