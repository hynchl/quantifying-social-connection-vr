# install.packages(pkgs = 'Matrix') # Reinstallation may be required due to dependency issues
# install.packages(pkgs = 'lme4') # Does not provide significance test results
# install.packages(pkgs = 'lmerTest') # Provides significance test results

# Set working directory to the current script location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(lme4)
library(lmerTest)

# Load dataset
df = read.table(file = 'processed/nodding_within.csv', header = T, sep = ",", stringsAsFactors = F, as.is = T)
View(df)

# Basic comparison of intercept-only vs slope model with Segment
m_intercept = lmer(SocialConnection ~ Segment + (1 | Pid), data = df)
m_slope = lmer(SocialConnection ~ Segment + (1 + Segment | Pid), data = df)
anova(m_intercept, m_slope)
summary(m_slope)

library(lme4)

# Define list of nodding-related predictor variables
variables <- c(
  "Segment", "NoddingCount", "NoddingCountSelf", "NoddingCountPartner",
  "SelfTurnSelfNod", "PartnerTurnSelfNod", "SelfTurnPartnerNod", "PartnerTurnPartnerNod",
  "TurnNod", "TurnSelfNod", "TurnPartnerNod",
  "GapNod", "GapSelfNod", "GapPartnerNod"
)

# Specify output file for storing results
sink("results/nodding_within.txt")

# Loop through each variable, fit models, and summarize results
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
  
  # Final model summary
  cat("\nFinal summary of slope model for", var, ":\n")
  print(summary(m_slope))
  
  # Save residuals
  df[paste(var, "_residuals")] <- residuals(m_slope)
}

# Close output file
sink()

# Save updated dataframe with residuals
write.csv(df, "./results/nodding_within_residual.csv", row.names = FALSE)

#########

# Compare two nodding features in random slope models
m_slope_formula <- as.formula(paste("SocialConnection ~ PartnerTurnPartnerNod + Segment + (1 + PartnerTurnPartnerNod + Segment | Pid)"))
m_slope_partner <- lmer(m_slope_formula, data = df)

m_slope_formula <- as.formula(paste("SocialConnection ~ SelfTurnPartnerNod + Segment + (1 + SelfTurnPartnerNod + Segment | Pid)"))
m_slope_self <- lmer(m_slope_formula, data = df)

print(summary(m_slope))

# Compare the two slope models
cat("\nANOVA between intercept and slope model for", var, ":\n")
print(anova(m_slope_partner, m_slope_self))

# Output final summary
cat("\nFinal summary of slope model for", var, ":\n")
print(summary(m_slope))

############

# Compare GapNod vs TurnNod models
m_slope_formula1 <- as.formula(paste("SocialConnection ~ GapNod + Segment + (1 + Segment | Pid) + (1 + GapNod | Pid)"))
m_slope1 <- lmer(m_slope_formula1, data = df, na.action = na.exclude)
print(summary(m_slope1))

m_slope_formula2 <- as.formula(paste("SocialConnection ~ TurnNod + Segment + (1 + Segment | Pid) + (1 + TurnNod | Pid)"))
m_slope2 <- lmer(m_slope_formula2, data = df, na.action = na.exclude)
print(summary(m_slope2))

# Compare models
cat("\nANOVA between intercept and slope model for", var, ":\n")
print(anova(m_slope1, m_slope2))
