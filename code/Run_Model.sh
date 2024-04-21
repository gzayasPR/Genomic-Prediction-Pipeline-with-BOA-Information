#!/bin/bash
#SBATCH --account=mateescu
#SBATCH --job-name=AGR_Project
#SBATCH --output=AGR_Project_%j.out
#SBATCH --error=errorfile_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gzayas97@ufl.edu
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=100gb
proj_path=$1
TRAIT=$2
MODEL=$3

cd ${proj_path}/results/4.Running_Models/input/
echo "Running ${MODEL} ${TRAIT}"
sed -e "s/MODEL/${MODEL}/g" 4.${TRAIT}_Running_Models_parameters.R > 4.${TRAIT}_${MODEL}_Running_Models_parameters.R.temp

cd ${proj_path}/code/
ml R
Rscript 4.Run_Model.temp.R 4.${TRAIT}_${MODEL}_Running_Models_parameters.R.temp
cd ${proj_path}/results/4.Running_Models/input/
rm 4.${TRAIT}_${MODEL}_Running_Models_parameters.R.temp
echo "Done"