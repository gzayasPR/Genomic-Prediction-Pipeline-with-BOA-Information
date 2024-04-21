rm(list = ls())
load("dir_parameters.R")
setwd(code_dir)
# Library
library(data.table)
library(stringr)
library(dplyr)
library(tidyr)
options(datatable.verbose=TRUE)
# Function to load genotype data and create marker matrix
create_marker_matrix <- function(path_map, path_geno, marker_type, output_file, var_name) {
  # Load SNP map
  map_data <- fread(path_map, header = TRUE)
  map_data$NUM <- 1:nrow(map_data)
  colnames(map_data) <- c("SNP", "CHR", "POS", "NUM")
  
  # List of marker names in the same order as the data file
  marker_names <- as.vector(seq(1:nrow(map_data)))
  
  # Load genotypic data
  geno_data <- fread(path_geno, header = TRUE)
  geno_data <- geno_data[order(geno_data$IID), ]
  columns_exclude <- c("FID", "PAT", "MAT","SEX","PHENOTYPE")
  marker_file <- geno_data[, !colnames(geno_data) %in%   columns_exclude, with = FALSE]
  ID <- marker_file$IID
  marker_names <- names(marker_file)[-1]
  names(marker_file)[-1] <- 1:(ncol(marker_file) - 1)
  M <- as.matrix(marker_file[, !colnames(marker_file) %in% c("IID"), with = FALSE])
  rownames(M) <- ID
  colnames(M) <- marker_names
  
  # Print marker matrix information
  cat(paste("Dimension of", marker_type, "marker matrix:", dim(M), "\n"))
  
  # Save marker matrix with specified variable name
  assign(var_name, M)
  save(list = var_name, file = output_file)
  cat(paste(marker_type, "matrix created:", output_file, "\n"))
}

# Create SNP marker matrix with variable name "SNP_matrix"
setwd(file.path(results_dir, "/1.Import_Genotypes/output/"))
source("../input/1.Import_Genotypes_parameters.R")
create_marker_matrix(path_snp_map, path_snp_geno, "SNP", "SNP_matrix.RData", var_name = "M")

# Create BOA marker matrix with variable name "BOA_matrix"
create_marker_matrix(path_BOA_map, path_BOA_geno, "BOA", "BOA_matrix.RData", var_name = "B")
setwd(code_dir)


