# install.packages(pkgs = 'Matrix') # Reinstallation may be required due to dependency issues
# install.packages(pkgs = 'lme4') # Does not provide significance test results
# install.packages(pkgs = 'lmerTest') # Provides significance test results

# specify working directory to current directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(lme4)
library(lmerTest)



df = read.table(file = 'processed/voice_across.csv', header = T, sep=",", stringsAsFactors=F, as.is=T) # read csv
View(df)

# Calculate balance metric
df['Balance'] = 0.5 - abs(df['SpeakingTimeRatio'] - 0.5)

# Null model for comparison (no predictors)
m0 = lm(formula = SocialConnection ~ 1, data = df)

# Variables to test
variables <- c("VRT", "SelfVRT", "PartnerVRT", "Count",
               "SelfSpeakingTime", "PartnerSpeakingTime", 
               "SpeakingTime", "SpeakingTimeRatio", "Balance")

# File to save results
sink("results/voice_across.txt")

# Loop through variables and fit models
for (var in variables) {
  cat("===================================================== ")
  cat(var)
  cat("===================================================== ")
  
  f <- as.formula(paste("SocialConnection ~", var))
  m1 <- lm(f, data = df)
  
  cat("\nSummary of linear model:\n")
  print(summary(m1))
  
  cat("\nANOVA compared to null model:\n")
  print(anova(m0, m1))
  
  cat("\n\n")
}

# Stop writing to file
sink()