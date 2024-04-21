rm(list=ls())
load("dir_parameters.R")
setwd(paste(code_dir,"/Example/",sep=""))
# Run the example

file.copy("1.Import_Genotypes_parameters.R", 
          paste(results_dir,"/1.Import_Genotypes/input/1.Import_Genotypes_parameters.R",sep=""), 
          overwrite = TRUE)

file.copy("2.QC_parameters.R", paste(results_dir,"/2.QC/input/2.QC_parameters.R",sep=""), 
          overwrite = TRUE)

file.copy("3.Matrix_Structure_parameters.R", 
          paste(results_dir,"/3.Matrices/input/3.Matrix_Structure_parameters.R",sep=""), 
          overwrite = TRUE)

file.copy("4.Running_Models_parameters.R", 
          paste(results_dir,"/4.Running_Models/input/4.Running_Models_parameters.R",sep=""), 
          overwrite = TRUE)

setwd(code_dir)