# install.packages(pkgs = 'Matrix') # Reinstallation may be required due to dependency issues
# install.packages(pkgs = 'lme4') # Does not provide significance test results
# install.packages(pkgs = 'lmerTest') # Provides significance test results

# specify working directory to current directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

library(lme4)
library(lmerTest)


# Read the CSV file
df = read.table(file = 'processed/nodding_across.csv', header = T, sep=",", stringsAsFactors=F, as.is=T) # read csv
View(df)

# Define the list of variables
variables <- c("Segment", "NoddingCount","NoddingCountSelf","NoddingCountPartner", "SelfTurnSelfNod", "PartnerTurnSelfNod", "SelfTurnPartnerNod", "PartnerTurnPartnerNod","TurnNod","TurnSelfNod","TurnPartnerNod","GapNod","GapSelfNod","GapPartnerNod")

# Specify the file to save results
sink("results/nodding_across.txt")

# Generate and summarize models for each variable in the list
for (var in variables) {
  
  cat("===================================================== ")
  cat(var)
  cat(" =====================================================")
  
  # Intercept model
  f1 <- as.formula(paste("SocialConnection ~", var))
  m1 <- lm(f1, data = df)
  
  # Print final model summary
  cat("\nFinal summary of linear model for", var, ":\n")
  print(summary(m1))
}

# Stop writing to file
sink()