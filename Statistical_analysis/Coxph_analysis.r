# explanationhere: https://www.sthda.com/english/wiki/cox-proportional-hazards-model
# ggforest: https://rpkgs.datanovia.com/survminer/reference/ggforest.html 
#dataset preparation
#in GSE111177.txt, create a new count matrix containing only the significant genes from the meta-analysis using this code
#I have already cleaned the sample names, so you only need to convert entrez ID to Gene symbols, then create a new count matrix of meta-analysis genes only from GSE111177_norm.csv
library(readr)
counts_matrix <- read_csv("GSE111177_norm.csv")
meta-analysis_genes<-rbind(up,down)
#convert the entrez to genesymbol and make genesymbol as rownames
# this is for you to do on your own :) :D

#then do these to create a new count matrix of meta-analysis genes only from GSE111177_norm.csv
subset_matrix <- count_matrix[rownames(count_matrix) %in% meta-analysis_genes, ]
subset_matrix$Time<-Data$Time
subset_matrix$Status<-Data$Status

#These are the steps for conducting a Cox proportional hazards model, which is used to assess how gene expression influences the time to development of treatment resistance.
library(survival)  # core survival analysis package
library(survminer)
library(gtsummary)
library(caret) #machine learning R package, we use it for the logistic regression
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

#These are the steps for conducting a logistic regression analysis to identify which genes are associated with an increased risk of developing treatment resistance in prostate cancer.
#univariate logistic regression
significant_vars <- list()

for (var in setdiff(names(subset_matrix), "Status")) {
  formula <- as.formula(paste("Status ~", var))
  model <- glm(formula, data = subset_matrix, family = binomial)
  summary_model <- summary(model)

  p_value <- summary_model$coefficients[2, "Pr(>|z|)"]

  if (p_value < 0.05) {
    cat("\nSignificant variable:", var, "\n")
    print(summary_model)
    significant_vars[[var]] <- summary_model
  }
}


#multi-variate logistic regression
model1 <- glm(Status ~ significant_genes_from_the univariate, data=subset_matrix, family = binomial)

# Display table for regression model1
model1_tbl<-model1 %>% 
tbl_regression(exponentiate = TRUE) %>%   
  # add table captions
  as_gt() %>%
  gt::tab_header(title = "Table . Logistic Regression Analysis for Tumor Response to Treatment",
                 subtitle = " Dataset: Trial {gtsummary}")

model1_tbl
