
print("Running AI Kernels model...")
library(caret)
folds <- createFolds(factor(phenotypes$Set), k = K, list = TRUE, returnTrain = TRUE)
results <- list()

base_dir <- getwd()

library(BGLR)
library(proxy)
library(proxy)

# Define the file path for the RDA file
matrices_file <- "dist_matrices.rda"

# Check if the RDA file exists
if (file.exists(matrices_file)) {
  # Load the matrices
  load(matrices_file)
  print("Loaded distance matrices from file.")
  
#   Check if dimensions and row names match
  if (!all(dim(D_G)[1] == dim(X) [1]) || !all(rownames(D_G) == rownames(X))) {
    stop("D_G does not match X in dimensions or row names.")
  }
  if (!all(dim(D_B)[1] == dim(O)[1]) || !all(rownames(D_B) == rownames(O))) {
    stop("D_B does not match O in dimensions or row names.")
  }
  if (!all(dim(D_G_B)[1] == dim(O_X)[1]) || !all(rownames(D_G_B) == rownames(O_X))) {
    stop("D_G_B does not match O_X in dimensions or row names.")
  }
  
} else {
  # Calculate D_G
  D_G <- as.matrix(proxy::dist(X, method = "euclidean"))
  D_G <- D_G^2
  D_G <- D_G / mean(D_G)
  rownames( D_G ) <- rownames(X)
  print("Decomposed X")
  
  # Calculate D_B
  D_B <- as.matrix(proxy::dist(O, method = "euclidean"))
  D_B <- D_B^2
  D_B <- D_B / mean(D_B)
  rownames( D_B) <- rownames(O)
  print("Decomposed O")
  
  # Calculate D_G_B
  D_G_B <- as.matrix(proxy::dist(O_X, method = "euclidean"))
  D_G_B <- D_G_B^2
  D_G_B <- D_G_B / mean(D_G_B)
  rownames( D_G_B ) <- rownames(O_X)
  print("Decomposed O_X")
  
  # Save the matrices to an RDA file
  save(D_G, D_B, D_G_B, file = matrices_file)
  print("Saved distance matrices to file.")
}


print("BGLR Prep")
h <- c(0.0001, 0.01, 0.1, 1, 5,100)
print(h)
G_KList <- list()
for(i in 1:length(h))
    {
     G_KList[[i]]<-list(K=exp(-h[i]*D_G),model='RKHS')
}
G_KList[["FIXED "]] <- list(~factor(Set), data = phenotypes, model = 'FIXED')
G_B_KList <- list()
for(i in 1:length(h))
    {
     G_B_KList[[i]] <- list(K=exp(-h[i]*D_G),model='RKHS')
     G_B_KList[[i + length(h)]] <- list(K=exp(-h[i]*D_B),model='RKHS')
}
G_B_KList[["FIXED "]] <- list(~factor(Set), data = phenotypes, model = 'FIXED')
G_B_Omega_KList <- list()
for(i in 1:length(h))
    {
     G_B_Omega_KList[[i]] <- list(K=exp(-h[i]*D_G),model='RKHS')
    G_B_Omega_KList[[i + length(h)]] <- list(K=exp(-h[i]*D_B),model='RKHS')
     G_B_Omega_KList[[i + (2*length(h))]] <- list(K=exp(-h[i]*D_G_B),model='RKHS')
}
G_B_Omega_KList[["FIXED "]] <- list(~factor(Set), data = phenotypes, model = 'FIXED')
print("BGLR Prep Done")
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
  fm_G <- BGLR(y = yNA, ETA = G_KList, nIter = nIter, burnIn = burnIn,verbose = F,saveAt = "fm_G_")
  print(paste("Model G: Fold", k)) 
  # Model 2: G + B
  fm_G_B <- BGLR(y = yNA, ETA = G_B_KList, nIter = nIter, burnIn = burnIn,verbose = F,saveAt = "fm_G_B_")
  print(paste("Model G + B: Fold", k))   
  fm_G_B_OMEGA <- BGLR(y = yNA, ETA =   G_B_Omega_KList, nIter = nIter, burnIn = burnIn,verbose = F,saveAt = "fm_G_B_OMEGA")
  print(paste("Model G + B + Omega: Fold", k)) 
  PMSE_G = mean((Y[tst]-fm_G$yHat[tst])^2)
    PMSE_G_B = mean((Y[tst]-fm_G_B$yHat[tst])^2)
    PMSE_G_B_OMEGA =mean((Y[tst]-fm_G_B_OMEGA$yHat[tst])^2)
  results[[k]] <- list(
    PMSE_G = mean((Y[tst]-fm_G$yHat[tst])^2),
    PMSE_G_B = mean((Y[tst]-fm_G_B$yHat[tst])^2),
    PMSE_G_B_OMEGA =mean((Y[tst]-fm_G_B_OMEGA$yHat[tst])^2),
    R2_G = 1- PMSE_G /mean((Y[tst]-mean(Y[-tst]))^2),
    R2_G_B = 1- PMSE_G_B /mean((Y[tst]-mean(Y[-tst]))^2),
    R2_G_B_OMEGA = 1- PMSE_G_B_OMEGA /mean((Y[tst]-mean(Y[-tst]))^2),
    cor_G = cor(Y[tst], fm_G$yHat[tst]),
    cor_G_B = cor(Y[tst], fm_G_B$yHat[tst]),
    cor_G_B_OMEGA = cor(Y[tst], fm_G_B_OMEGA$yHat[tst]))
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
  R2 = c(R2_G, R2_G_B, R2_G_B_OMEGA))

# Print the summary table to console
print(results_summary)
# Write the summary table to a CSV file
write.csv(results_summary, "RKHS.results_summary.csv", row.names = FALSE)

setwd(code_dir)
