# Clear the workspace
rm(list = ls())
# Load the directory parameters
load("dir_parameters.R")
setwd(code_dir)
# Change the working directory to the results directory
setwd(file.path(results_dir, "2.QC/output/"))

# Load QC parameters
source("../input/2.QC_parameters.R")

# List all genotype files in the specified directory
geno_files <- list.files(path = geno_path, pattern = "*.RData")

# Load genotype files
for (i in geno_files) {
  load(paste(geno_path, i, sep="/"))
}

# Define a function to process the genotype matrices
process_matrix <- function(M, NA_freq, MAF) {
  # Extract SNP IDs and update column names
  SNP_ID <- gsub("_[A-X]$", "", colnames(M))
  colnames(M) <- SNP_ID
  
  # Calculate the proportion of missing values per column and filter based on NA_freq
  NaNs <- apply(M, 2, function(col) sum(is.na(col)) / length(col))
  index.1 <- which(NaNs <= NA_freq)
  X <- M[, index.1]
  
  # Calculate the proportion of missing values per row and filter again
  NaNs <- apply(X, 1, function(row) sum(is.na(row)) / length(row))
  index.1 <- which(NaNs <= NA_freq)
  X <- X[index.1, ]
  
  # Calculate minor allele frequency and filter columns based on MAF threshold
  P <- colMeans(X, na.rm = TRUE) / 2
  Q <- 1 - P
  minor_allele <- ifelse(P <= Q, P, Q)
  index.2 <- which(minor_allele >= MAF)
  X <- X[, index.2]
  
  # Return the filtered matrix
  return(X)
}

# Process the matrices M and B using the defined function
M_processed <- process_matrix(M, NA_freq, MAF)
B_processed <- process_matrix(B, NA_freq, MAF)


# Find SNPs common to both M and B processed matrices
snps_common <- intersect(colnames(M_processed), colnames(B_processed))

# Subset the M processed matrix to include only common SNPs
X_snps <- M_processed[, snps_common]
O_snps<- B_processed[, snps_common]

dim(X_snps)
dim(O_snps)
# Find SNPs common to both M and B processed matrices
ids_common <- intersect(rownames(M_processed), rownames(B_processed))

# Subset the M processed matrix to include only common SNPs
X <- X_snps[ids_common ,]
O <- O_snps[ids_common ,]

# Output the dimensions of the cleaned matrix
dim(X)

dim(O)
save(X,O, file = "Clean_Matrices.rda")
setwd(code_dir)

