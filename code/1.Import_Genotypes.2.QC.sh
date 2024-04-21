#!/bin/bash
#SBATCH --account=mateescu
#SBATCH --job-name=Step1_2
#SBATCH --output=Step1_2.Matrices_%j.out
#SBATCH --error=Step1_2.Matrices_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gzayas97@ufl.edu
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=50gb

proj_path=/home/gzayas97/AGR6932/
TRAITS=("Short_Hair" "TSS" "SWG_Area")
cd ${proj_path}/code/
ml R
Rscript 1.Import_Genotypes.R
Rscript 2.QC.R