# explanationhere: https://www.sthda.com/english/wiki/cox-proportional-hazards-model
# ggforest: https://rpkgs.datanovia.com/survminer/reference/ggforest.html 
#dataset preparation
#in GSE111177.txt, create a new count matrix containing only the significant genes from the meta-analysis using this code
counts_matrix <- read.delim("GSE111177_norm.tsv", comment.char="#", stringsAsFactors=FALSE)
meta-analysis_genes<-rbind(up,down)
subset_matrix <- count_matrix[rownames(count_matrix) %in% meta-analysis_genes, ]
subset_matrix$Time<-Data$Time
subset_matrix$Status<-Data$Status






library(survival)  # core survival analysis package
library(survminer)
# y = ax +b
s = Surv(subset_matrix$Time, subset_matrix$Status)
#univariate, loop across the variable
significant_vars <- list()

for (var in setdiff(names(subset_matrix), c("Time", "Status"))) {
  formula <- as.formula(paste("Surv(Time, Status) ~", var))
  model <- coxph(formula, data = subset_matrix)
  summary_model <- summary(model)
  
  p_value <- summary_model$coefficients[, "Pr(>|z|)"]
  
  if (p_value < 0.05) {
    cat("\nSignificant variable:", var, "\n")
    print(summary_model)
    significant_vars[[var]] <- summary_model
  }
}

#multivariate
fit = coxph(Surv(time, status)~only_significant_genes_from_univariate, data=subset_matrix)
summary(fit)

#plot the Hazard ratio
ggforest(
  fit,
  data = fit,
  main = "Hazard ratio",
  cpositions = c(0.02, 0.22, 0.4),
  fontsize = 0.7,
  refLabel = "reference",
  noDigits = 2

)
