
print("Running GBLUP model...")
folds <- sample(rep(1:K, length.out = nrow(phenotypes)))
results <- list()

base_dir <- getwd()

library(BGLR)
library(caret)
folds <- createFolds(factor(phenotypes$Set), k = K, list = TRUE, returnTrain = TRUE)

base_dir <- getwd()
for (k in 1:K) {
  print(paste("Running fold", k))
  fold_dir <- file.path(base_dir, paste("Fold", k))
  dir.create(fold_dir)
  setwd(fold_dir)
  trn <- folds[[k]]
  tst <- setdiff(1:nrow(phenotypes),  trn)
  
  yNA <- Y
  yNA[tst] <- NA  # Mask testing data for model fitting
  
  # Model 1: G
  ETA_G <- list(FIXED = list(~factor(Set), data = phenotypes, model = 'FIXED'),
                G = list(V = EVD.G$vectors, d = EVD.G$values, model = 'RKHS'))
  fm_G <- BGLR(y = yNA, ETA = ETA_G, nIter = nIter, burnIn = burnIn,verbose = F)
  print(paste("Model G: Fold", k)) 
  # Model 2: G + B
  ETA_G_B <- list(FIXED = list(~factor(Set), data = phenotypes, model = 'FIXED'),
                  G = list(V = EVD.G$vectors, d = EVD.G$values, model = 'RKHS'),
                  B = list(V = EVD.B$vectors, d = EVD.B$values, model = 'RKHS'))
  fm_G_B <- BGLR(y = yNA, ETA = ETA_G_B, nIter = nIter, burnIn = burnIn,verbose = F)
  print(paste("Model G + B: Fold", k))   
  # Model 3: G + B + OMEGA
  ETA_G_B_OMEGA <- list(FIXED = list(~factor(Set), data = phenotypes, model = 'FIXED'),
                        G = list(V = EVD.G$vectors, d = EVD.G$values, model = 'RKHS'),
                        B = list(V = EVD.B$vectors, d = EVD.B$values, model = 'RKHS'),
                        OMEGA = list(V = EVD.O_X$vectors, d = EVD.O_X$values, model = 'RKHS'))
  fm_G_B_OMEGA <- BGLR(y = yNA, ETA = ETA_G_B_OMEGA, nIter = nIter, burnIn = burnIn,verbose = F)
  print(paste("Model G + B + Omega: Fold", k)) 
  PMSE_G = mean((Y[tst]-fm_G$yHat[tst])^2)
  PMSE_G_B = mean((Y[tst]-fm_G_B$yHat[tst])^2)
  PMSE_G_B_OMEGA =mean((Y[tst]-fm_G_B_OMEGA$yHat[tst])^2)
  # Store the results
  results[[k]] <- list(
    PMSE_G = mean((Y[tst]-fm_G$yHat[tst])^2),
    PMSE_G_B = mean((Y[tst]-fm_G_B$yHat[tst])^2),
    PMSE_G_B_OMEGA =mean((Y[tst]-fm_G_B_OMEGA$yHat[tst])^2),
    R2_G = 1- PMSE_G /mean((Y[tst]-mean(Y[-tst]))^2),
    R2_G_B = 1- PMSE_G_B /mean((Y[tst]-mean(Y[-tst]))^2),
    R2_G_B_OMEGA = 1- PMSE_G_B_OMEGA /mean((Y[tst]-mean(Y[-tst]))^2),
    cor_G = cor(Y[tst], fm_G$yHat[tst]),
    cor_G_B = cor(Y[tst], fm_G_B$yHat[tst]),
    cor_G_B_OMEGA = cor(Y[tst], fm_G_B_OMEGA$yHat[tst]),
    var_G = c((fm_G$ETA$G$varU )/ (fm_G$ETA$G$varU + fm_G$varE ),fm_G$ETA$G$varU,fm_G$varE ),
    var_G_B = c((fm_G_B$ETA$G$varU + fm_G_B$ETA$B$varU)/(fm_G_B$ETA$G$varU + fm_G_B$ETA$B$varU+ fm_G_B$varE ),
                fm_G_B$ETA$G$varU ,fm_G_B$ETA$B$varU,fm_G_B$varE ),
    var_G_B_OMEGA = c((fm_G_B_OMEGA$ETA$G$varU + fm_G_B_OMEGA$ETA$B$varU + fm_G_B_OMEGA$ETA$OMEGA$varU) / 
                        (fm_G_B_OMEGA$ETA$G$varU + fm_G_B_OMEGA$ETA$B$varU + fm_G_B_OMEGA$ETA$OMEGA$varU + fm_G_B_OMEGA$varE ),
                      fm_G_B_OMEGA$ETA$G$varU,fm_G_B_OMEGA$ETA$B$varU,fm_G_B_OMEGA$ETA$OMEGA$varU,fm_G_B_OMEGA$varE))
  setwd(base_dir)
}

print(trait.name)
# Aggregate and summarize results for correlations (predictive abilities)
mean_cor_G <- mean(sapply(results, `[[`, "cor_G"))
mean_cor_G_B <- mean(sapply(results, `[[`, "cor_G_B"))
mean_cor_G_B_OMEGA <- mean(sapply(results, `[[`, "cor_G_B_OMEGA"))

sd_cor_G <- sd(sapply(results, `[[`, "cor_G"))
sd_cor_G_B <- sd(sapply(results, `[[`, "cor_G_B"))
sd_cor_G_B_OMEGA <-sd(sapply(results, `[[`, "cor_G_B_OMEGA"))

# Aggregate and summarize results for variance components (explanatory power)
mean_var_G <- mean(sapply(results, `[[`, "var_G")[1])
mean_var_G_B <- mean(sapply(results, `[[`, "var_G_B")[1])
mean_var_G_B_OMEGA <- mean(sapply(results, `[[`, "var_G_B_OMEGA")[1])

# Aggregate and summarize results for variance components (explanatory power)
R2_G <- mean(sapply(results, `[[`, "R2_G"))
R2_G_B <- mean(sapply(results, `[[`, "R2_G_B"))
R2_G_B_OMEGA <- mean(sapply(results, `[[`, "R2_G_B_OMEGA"))

closeAllConnections()
setwd(base_dir)
# Create a dataframe with all results
results_summary <- data.frame(
  Model = c("G", "G+B", "G+B+Omega"),
  Mean_Correlation = c(mean_cor_G, mean_cor_G_B, mean_cor_G_B_OMEGA),
  SD_Correlation = c(sd_cor_G, sd_cor_G_B, sd_cor_G_B_OMEGA),
  Mean_Variance = c(mean_var_G, mean_var_G_B, mean_var_G_B_OMEGA),
  R2 = c(R2_G, R2_G_B, R2_G_B_OMEGA))

# Print the summary table to console
print(results_summary)
# Write the summary table to a CSV file
write.csv(results_summary, "GBLUP.results_summary.csv", row.names = FALSE)


# Assuming 'results' is your final results list and it's structured correctly
summary_table <- data.frame(
  Model_G = c(mean(sapply(results, `[[`, "var_G")[2]),NA,NA,
              mean(sapply(results, `[[`, "var_G")[3]),mean_var_G),
  Model_G_B = c(mean(sapply(results, `[[`, "var_G_B")[2]),mean(sapply(results, `[[`, "var_G_B")[3]),NA,
                mean(sapply(results, `[[`, "var_G_B")[4]),mean_var_G_B),
  Model_G_B_Omega =  c(mean(sapply(results, `[[`, "var_G_B_OMEGA")[2]),mean(sapply(results, `[[`, "var_G_B_OMEGA")[3]),mean(sapply(results, `[[`, "var_G_B_OMEGA")[4]),
                       mean(sapply(results, `[[`, "var_G_B_OMEGA")[5]),mean_var_G_B_OMEGA))

row.names(summary_table) <- c("G","B","G*B","Residual","Proportion_of_Variance_Explained")

print(summary_table)

write.csv(summary_table,"GBLUP Variance Componenets.csv")
setwd(code_dir)
