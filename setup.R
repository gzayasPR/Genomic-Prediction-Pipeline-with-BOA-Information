### Setup directories for analysis ###
proj_dir <- getwd()
subdirs <- c("data", "code", "results")

# Create main directories if they don't exist
for (subdir in subdirs) {
  if (!file.exists(file.path(proj_dir, subdir))) {
    dir.create(file.path(proj_dir, subdir))
  }
}

data_dir <- file.path(proj_dir, "data")
code_dir <- file.path(proj_dir, "code")
results_dir <- file.path(proj_dir, "results")

setwd(results_dir)

results_subdirs <- c("1.Import_Genotypes","2.QC", "3.Matrices","4.Running_Models") 

# Create subdirectories within the "results" directory if they don't exist
for (subdir in results_subdirs) {
  if (!file.exists(file.path(results_dir, subdir))) {
    dir.create(file.path(results_dir, subdir))
    dir.create(paste(file.path(results_dir, subdir,"input/"),sep=""))
    dir.create(paste(file.path(results_dir, subdir,"output/"),sep=""))
  }
}
setwd(code_dir)
save(proj_dir,data_dir,code_dir,results_dir,file =  "dir_parameters.R")
install.packages("data.table")
install.packages("stringr")
install.packages("dplyr")
install.packages("tidyr")
install.packages("BGLR")
install.packages("proxy")
install.packages("caret")
setwd(proj_dir)
