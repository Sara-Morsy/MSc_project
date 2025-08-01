# explanationhere: https://www.sthda.com/english/wiki/cox-proportional-hazards-model
# ggforest: https://rpkgs.datanovia.com/survminer/reference/ggforest.html 

library(survival)  # core survival analysis package
library(survminer)

s = Surv(Data$Time, Data$Status)
#univariate, loop across the variable
significant_vars <- list()

for (var in setdiff(names(Data), c("Time", "Status"))) {
  formula <- as.formula(paste("Surv(Time, Status) ~", var))
  model <- coxph(formula, data = Data)
  summary_model <- summary(model)
  
  p_value <- summary_model$coefficients[, "Pr(>|z|)"]
  
  if (p_value < 0.05) {
    cat("\nSignificant variable:", var, "\n")
    print(summary_model)
    significant_vars[[var]] <- summary_model
  }
}

#multivariate
fit = coxph(Surv(time, status)~only_significant_genes_from_uni, data=pdata)
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