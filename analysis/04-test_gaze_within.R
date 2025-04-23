# install.packages(pkgs = 'Matrix') # Reinstallation may be required due to dependency issues
# install.packages(pkgs = 'lme4') # Does not provide significance test results
# install.packages(pkgs = 'lmerTest') # Provides significance test results

# Set working directory to the current script location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(lme4)
library(lmerTest)

# Load dataset
df = read.table(file = 'processed/gazes_within.csv', header = T, sep = ",", stringsAsFactors = F, as.is = T)
View(df)

# Initial comparison: intercept vs. slope model with Segment
m_intercept = lmer(SocialConnection ~ Segment + (1 | Pid), data = df)
m_slope = lmer(SocialConnection ~ Segment + (1 + Segment | Pid), data = df)
anova(m_intercept, m_slope)
summary(m_slope)

# Define list of gaze-related predictor variables
variables <- c(
  "Segment", "SelfGazeDuration", "PartnerGazeDuration", "EyeContactDuration",
  "TurnSelfGazeDuration", "TurnPartnerGazeDuration", "TurnMutualGazeDuration",
  "GapSelfGazeDuration", "GapPartnerGazeDuration", "GapMutualGazeDuration",
  "SelfTurnSelfGazeDuration", "SelfTurnPaThetnerGazeDuration", "SelfTurnMutualGazeDuration",
  "PartnerTurnSelfGazeDuration", "PartnerTurnPartnerGazeDuration", "PartnerTurnMutualGazeDuration"
)

# Save output to file
sink("results/gaze_within.txt")

# Iterate over each variable and run intercept and slope models
for (var in variables) {
  
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  # Intercept-only model
  m_intercept_formula <- as.formula(paste("SocialConnection ~", var, " + Segment + (1 | Pid)"))
  m_intercept <- lmer(m_intercept_formula, data = df)
  cat("\nSummary of intercept model for", var, ":\n")
  # print(summary(m_intercept))
  
  # Random slope model
  m_slope_formula <- as.formula(paste("SocialConnection ~", var, " + Segment + (1 + Segment | Pid) + (1 +", var, " | Pid)"))
  m_slope <- lmer(m_slope_formula, data = df, na.action = na.exclude)
  cat("\nSummary of slope model for", var, ":\n")
  # print(summary(m_slope))
  
  # Compare models
  cat("\nANOVA between intercept and slope model for", var, ":\n")
  print(anova(m_intercept, m_slope))
  
  # Output final model summary
  cat("\nFinal summary of slope model for", var, ":\n")
  print(summary(m_slope))
  
  # Save residuals for each model
  df[paste(var, "_residuals", sep = "")] <- residuals(m_slope)
}

# End output file
sink()

# Save updated dataframe with residuals
write.csv(df, "results/gaze_within_residual.csv", row.names = FALSE)

#### Additional model comparison for selected variables

# Random slope model for GapPartnerGazeDuration
m_slope_formula <- as.formula(paste("SocialConnection ~ GapPartnerGazeDuration + Segment + (1 + Segment | Pid) + (1 + GapPartnerGazeDuration | Pid)"))
m_slope1 <- lmer(m_slope_formula, data = df, na.action = na.exclude)
print(summary(m_slope1))

# Random slope model for GapMutualGazeDuration
m_slope_formula <- as.formula(paste("SocialConnection ~ GapMutualGazeDuration + Segment + (1 + Segment | Pid) + (1 + GapMutualGazeDuration | Pid)"))
m_slope2 <- lmer(m_slope_formula, data = df, na.action = na.exclude)
print(summary(m_slope2))

# Compare the two models
cat("\nANOVA between slope models for GapPartnerGazeDuration and GapMutualGazeDuration:\n")
print(anova(m_slope1, m_slope2))
