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
setwd(paste(data_dir,"/Example/",sep=""))


# Define the paths to your .gz files
gz_file1 <- "BOA.raw.gz"
gz_file2 <- "SNP.raw.gz"

# Specify the directory where you want to extract the contents
extract_to_directory <- paste(data_dir,"/Example/",sep="")

# Unzip the first .gz file
gz1 <- gzfile(gz_file1, "rb")
unzipped_file1 <- paste0(extract_to_directory, "BOA.raw")  # Adjust the output file name as needed
writeLines(readLines(gz1), unzipped_file1)
close(gz1)

# Unzip the second .gz file
gz2 <- gzfile(gz_file2, "rb")
unzipped_file2 <- paste0(extract_to_directory, "SNP.raw")  # Adjust the output file name as needed
writeLines(readLines(gz2), unzipped_file2)
close(gz2)
setwd(code_dir)
