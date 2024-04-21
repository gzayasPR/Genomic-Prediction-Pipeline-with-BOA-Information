# Genomic Prediction Pipeline with BOA Information

## Introduction
This repository hosts a pipeline designed for genomic prediction in beef crossbreed cattle, utilizing Breed of Origin Alleles (BOA) to enhance accuracy. It integrates advanced genomics and bioinformatics tools for comprehensive genetic data analysis.

## Prerequisites
- R 3.6+

## Setup and Installation
To get started, clone this repository using:
```bash
git clone https://github.com/gzayasPR/Genomic-Prediction-Pipeline-with-BOA-Information.git
cd Genomic-Prediction-Pipeline-with-BOA-Information
ml R
Rscript setup.R # This creates working enviroment and loads R dependencis
```

## Directory Explination
Three directories are present after running setup.R.

### code directory
This directory has the code too run the analysis. Here is where you will running your analysis. The steps are outlined from 1 to 4.

### data directory
This directory is the location of the data you will be using for the analysis. You need 5 files too run the analysis'
1. SNP file with marker information in a space delimited file, where the first column is the IID, and every subsequent column is the marker coded as 0,1,2 with missing values as NA (first column shoudl be IID, and columns after are the SNP names).
2. Map file with information on the SNPs in the SNP files.
3. BOA file with BOA information, with the same coding as the marker file , the columns names in this file and the SNP file should matcH.
4. Map file for BOA file
5. Phenotype file in a comma delimited format.

### results directory  

This directory has the results have an input and output directory. The input has the parameters for the analysis, and the output has the output of the analysis.

## Running Example
Too run the example change into code directory and run_Example.R
``` bash
cd Genomic-Prediction-Pipeline-with-BOA-Information/code
ml R
Rscript run_Example.R
Rscript 1.Import_Genotypes.R
Rscript 2.QC.R
Rscript 3.Matrix_Structure.R
Rscript 4.Run_Model.R
```
This create parameter files and sets up example data directory and runs the analysis set by step for the Thermal Strees Slope phenotype using GLUP.

## Models currently supported
Currectly models are ran using BGLR package;
- GBLUP (using RKHS)
- Bayes A
- Bayes B
- Bayes C
- AI Reproducible Kernel Hilbert Space (RKHS)

## Contributing
Contributions are welcome! For major changes, please open an issue first to discuss what you would like to change.  

## Contact
For support or collaboration, contact gzayas97@ufl.edu
