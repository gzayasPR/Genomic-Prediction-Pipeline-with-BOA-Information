#!/bin/bash
#SBATCH --account=mateescu
#SBATCH --job-name=Setup_3.Matrices
#SBATCH --output=Setup_3.Matrices_%j.out
#SBATCH --error=Setup_3.Matrices_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gzayas97@ufl.edu
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=8gb

proj_path=/home/gzayas97/AGR6932/
TRAITS=("Short_Hair" "TSS" "SWG_Area")
# Declare an array with the desired variables
cd ${proj_path}/code/bash_out
for trait in "${TRAITS[@]}"
    do
    sbatch ../Run_Matrices.sh ${proj_path} ${trait}
    sleep 10
done
