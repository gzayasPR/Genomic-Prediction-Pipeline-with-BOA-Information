# Clear the workspace
rm(list = ls())

# Load the directory parameters
load("dir_parameters.R")
setwd(code_dir)

# Change the working directory to the results directory
setwd(file.path(results_dir, "4.Running_Models/output/"))

# Load QC parameters
source("../input/4.Running_Models_parameters.R")

# List all genotype files in the specified directory and load them
geno_files <- list.files(path = matrices_path, pattern = "*.rda")
for (file in geno_files) {
  load(paste0(matrices_path, "/", file))
}
base_dir <- getwd()
trait_dir <- file.path(base_dir, trait.name)
dir.create(trait_dir)
setwd(trait_dir)
model_dir <- file.path(trait_dir, model.fit)
dir.create(model_dir)
setwd(model_dir)
# Set MCMC parameters

# Set up cross-validation
library(BGLR)
#set.seed(24622253)  # for reproducibility
set.seed(11) 
if (model.fit == "GBLUP") {
  source(paste(code_dir,"Run.CV_GBLUP.R",sep="/"),local = TRUE)
} else if (model.fit %in% c("BRR","BayesA","BL","BayesC","BayesB")){
  source(paste(code_dir,"Run.CV_Bayes.R",sep="/"),local = TRUE)
} else {
  print("model is Not supported, choose GBLUP (RKS) or BRR")
}
setwd(code_dir)