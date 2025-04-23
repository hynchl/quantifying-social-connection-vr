# install.packages(pkgs = 'Matrix') # Reinstallation may be required due to dependency issues
# install.packages(pkgs = 'lme4') # Does not provide significance test results
# install.packages(pkgs = 'lmerTest') # Provides significance test results

# Set working directory to the current script's directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(lme4)
library(lmerTest)

# Load dataset
df = read.table(file = './processed/voice_within.csv', header = T, sep=",", stringsAsFactors=F, as.is=T)
View(df)

# Compute turn-taking balance
df['Balance'] = 0.5 - abs(df['SpeakingTimeRatio'] - 0.5)

# Define variables to iterate over
variables <- c("Segment", "Count", "SpeakingTime", "SelfSpeakingTime", "PartnerSpeakingTime",
               "SpeakingTimeRatio", "VRT", "SelfVRT", "PartnerVRT", "VRTV", "SelfVRTV", "PartnerVRTV", "Balance")

# Specify output file to store results
sink("results/voice_within.txt")

# Loop through each variable, fit models, and compare
for (var in variables) {
  
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  # Intercept model
  m_intercept_formula <- as.formula(paste("SocialConnection ~", var, " + Segment + (1 | Pid)"))
  m_intercept <- lmer(m_intercept_formula, data = df)
  cat("\nSummary of intercept model for", var, ":\n")
  # print(summary(m_intercept))
  
  # Random slope model
  m_slope_formula <- as.formula(paste("SocialConnection ~", var, " + Segment + (1 + Segment | Pid) + (1 +", var, " | Pid)"))
  m_slope <- lmer(m_slope_formula, data = df, na.action = na.exclude)
  cat("\nSummary of slope model for", var, ":\n")
  # print(summary(m_slope))
  
  # Model comparison using ANOVA
  cat("\nANOVA between intercept and slope model for", var, ":\n")
  print(anova(m_intercept, m_slope))
  
  # Print final summary of the slope model
  cat("\nFinal summary of slope model for", var, ":\n")
  print(summary(m_slope))
  
  # Store residuals from the slope model
  df[paste(var, "_residuals", sep="")] <- residuals(m_slope)
}

# Close the output file
sink()

# Save updated dataframe with residuals
write.csv(df, "results/voice_within_residual.csv", row.names = FALSE)
