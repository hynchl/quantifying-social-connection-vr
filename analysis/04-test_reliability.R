# install.packages(pkgs = 'Matrix') # Reinstallation may be required due to dependency issues
# install.packages(pkgs = 'lme4') # Does not provide significance test results
# install.packages(pkgs = 'lmerTest') # Provides significance test results

# Set working directory to the current script location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(lme4)
library(lmerTest)

# Load dataset
df = read.table(file = 'processed/subjective_rating.csv', header = T, sep = ",", stringsAsFactors = F, as.is = T)
View(df)

# Convert conversation variable to factor for grouping
df$Session_x <- factor(df$conversation)

# Define predictor variables
variables <- c("ReliabilityVoice", "ReliabilityGaze", "ReliabilityPose", "ReliabilityFacial")

# Null model (for ICC estimation or baseline)
m0 = lmer(formula = SocialConnection ~ (1 | Session_x), data = df)
summary(m0)

# Additional baseline models for other dependent variables
m0 = lmer(formula = Colocation ~ (1 | Session_x), data = df)
summary(m0)

m0 = lmer(formula = Attention ~ (1 | Session_x), data = df)
summary(m0)

m0 = lmer(formula = Enjoy ~ (1 | Session_x), data = df)
summary(m0)

m0 = lmer(formula = Flow ~ (1 | Session_x), data = df)
summary(m0)

m0 = lmer(formula = Connection ~ (1 | Session_x), data = df)
summary(m0)

# Save results to file: SocialConnection ~ reliability predictors
sink("results/reliability_socialconnection.txt")

# Fit linear models for each reliability predictor
for (var in variables) {
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  
  f1 <- as.formula(paste("SocialConnection ~", var))
  m1 <- lm(f1, data = df)
  
  cat("\nFinal summary of linear model for", var, ":\n")
  print(summary(m1))
}

sink() # End writing to file

# Save results to file: Colocation ~ reliability predictors
sink("results/reliability_colocation.txt")

for (var in variables) {
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  
  f1 <- as.formula(paste("Colocation ~", var))
  m1 <- lm(f1, data = df)
  
  cat("\nFinal summary of linear model for", var, ":\n")
  print(summary(m1))
}

sink()

# Save results to file: Attention ~ reliability predictors
sink("results/reliability_attention.txt")

for (var in variables) {
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  
  f1 <- as.formula(paste("Attention ~", var))
  m1 <- lm(f1, data = df)
  
  cat("\nFinal summary of linear model for", var, ":\n")
  print(summary(m1))
}

sink()

# Save results to file: Enjoy ~ reliability predictors (mixed model)
sink("results/reliability_enjoy.txt")
dv = "Enjoy"

for (var in variables) {
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  
  m_intercept_formula <- as.formula(paste(dv, " ~", var, " + (1 | Session_x)"))
  m_intercept <- lmer(m_intercept_formula, data = df)
  cat("\nSummary of intercept model for", var, ":\n")
  cat("\nFinal summary of slope model for", var, ":\n")
  print(summary(m_intercept))
}

sink()

# Save results to file: Flow ~ reliability predictors (mixed model)
sink("results/reliability_flow.txt")
dv = "Flow"

for (var in variables) {
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  
  m_intercept_formula <- as.formula(paste(dv, " ~", var, " + (1 | Session_x)"))
  m_intercept <- lmer(m_intercept_formula, data = df)
  cat("\nSummary of intercept model for", var, ":\n")
  cat("\nFinal summary of slope model for", var, ":\n")
  print(summary(m_intercept))
}

sink()

# Save results to file: Connection ~ reliability predictors (mixed model)
sink("results/reliability_connection.txt")
dv = "Connection"

for (var in variables) {
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  
  m_intercept_formula <- as.formula(paste(dv, " ~", var, " + (1 | Session_x)"))
  m_intercept <- lmer(m_intercept_formula, data = df)
  cat("\nSummary of intercept model for", var, ":\n")
  cat("\nFinal summary of slope model for", var, ":\n")
  print(summary(m_intercept))
}

sink()
