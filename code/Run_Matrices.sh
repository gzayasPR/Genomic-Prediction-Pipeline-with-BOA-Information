#!/bin/bash
#SBATCH --account=mateescu
#SBATCH --job-name=Matrices
#SBATCH --output=Matrices_%j.out
#SBATCH --error=Matrices_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gzayas97@ufl.edu
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=100gb
proj_path=$1
TRAIT=$2

cd ${proj_path}/results/3.Matrices/input/
echo "Matrices ${TRAIT}"
sed -e "s/MODEL/${MODEL}/g" 3.${TRAIT}_Matrix_Structure_parameters.R > 3.${TRAIT}_Matrix_Structure_parameters.R.temp

cd ${proj_path}/code/
ml R
Rscript 3.Matrix_Structure.temp.R 3.${TRAIT}_Matrix_Structure_parameters.R.temp
cd ${proj_path}/results/3.Matrices/input/
rm 3.${TRAIT}_Matrix_Structure_parameters.R.temp
echo "Done"