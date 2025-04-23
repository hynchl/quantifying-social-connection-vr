# install.packages(pkgs = 'Matrix') # Reinstallation may be required due to dependency issues
# install.packages(pkgs = 'lme4') # Does not provide significance test results
# install.packages(pkgs = 'lmerTest') # Provides significance test results

# Specify working directory as the current script's directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(lme4)
library(lmerTest)

# Read the CSV file
df = read.table(file = 'processed/gazes_across.csv', header = TRUE, sep = ",", stringsAsFactors = FALSE, as.is = TRUE)
View(df)

# Define the list of variables
variables <- c("SelfGazeDuration","PartnerGazeDuration", "EyeContactDuration", "TurnSelfGazeDuration","TurnPartnerGazeDuration", "TurnMutualGazeDuration","GapSelfGazeDuration","GapPartnerGazeDuration","GapMutualGazeDuration", "SelfTurnSelfGazeDuration", "SelfTurnPaThetnerGazeDuration","SelfTurnMutualGazeDuration", "PartnerTurnSelfGazeDuration","PartnerTurnPartnerGazeDuration", "PartnerTurnMutualGazeDuration")

# Specify the file to save results
sink("results/gaze_across.txt")

# Generate and summarize models for each variable in the list
for (var in variables) {
  
  cat("=====================================================")
  cat(var)
  cat("-----------------------------------------------------")
  
  # Intercept model
  f1 <- as.formula(paste("SocialConnection ~", var))
  m1 <- lm(f1, data = df)
  
  # Print final model summary
  cat("\nFinal summary of linear model for", var, ":\n")
  print(summary(m1))
}

# Stop writing to file
sink()
