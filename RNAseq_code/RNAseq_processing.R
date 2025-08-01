
#use GSE197609 for validation and GSE80609 (include in the meta-analysis)
library(DESeq2)
library(readr)
library(MetaIntegrator)
library(AnnotationDbi)
library(org.Hs.eg.db)

# Read in the raw count matrix from featureCounts output
raw_counts <- read.delim("GSE197609.txt", comment.char="#", stringsAsFactors=FALSE)

# Clean up data (remove non-gene rows like meta-information columns)
count_data <- raw_counts[, -c(2:6)]

# Remove version numbers from Ensembl IDs)
count_data$Geneid <- sub("\\..*", "", count_data$Geneid)
# convert ENSEMBL to gene symbol
count_data$Gene_symbol<-mapIds(org.Hs.eg.db,
                         keys = count_data$Geneid,
                         column = "SYMBOL",
                         keytype = "ENSEMBL",
                         multiVals = "first")
# average duplicate gene names
# Make sure gene symbol column is character
count_data$Gene_symbol <- as.character(count_data$Gene_symbol)

# Remove rows with missing gene symbols
count_data <- count_data[!is.na(count_data$Gene_symbol) & count_data$Gene_symbol != "", ]

# Aggregate (average) rows with the same gene symbol
library(dplyr)

# If Gene_symbol is not the first column, move it
count_data_avg <- count_data %>%
  group_by(Gene_symbol) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE)) %>%
  ungroup()

# Set gene symbols as row names
count_data_avg <- as.data.frame(count_data_avg)
rownames(count_data_avg) <- count_data_avg$Gene_symbol
count_data_avg$Gene_symbol <- NULL

# View result
head(count_data_avg)

# remove genes with zero counts in all samples
count_data_avg <- count_data_avg[rowSums(count_data_avg) > 0, ]
# read pheno_data
GSE197609_pheno <- read_csv("GSE197609.csv")
# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(
  countData = count_data_avg,
  colData = GSE197609_pheno,
  design = ~ Status
)

# Normalization and transformation
dds <- estimateSizeFactors(dds)
norm_counts <- counts(dds, normalized = TRUE)

# Log2 transformation with pseudocount
log2_norm_counts <- log2(norm_counts + 1)

# Write to CSV 
write.csv(log2_norm_counts, "GSE197609_log2_normalized_counts.csv")

#create list for meta-analysis, the same as you did for the microarray
