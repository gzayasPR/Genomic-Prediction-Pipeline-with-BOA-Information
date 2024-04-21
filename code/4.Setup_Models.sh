#!/bin/bash
#SBATCH --account=mateescu
#SBATCH --job-name=Setup_AGR_Project
#SBATCH --output=SetupAGR_Project_%j.out
#SBATCH --error=errorfile_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gzayas97@ufl.edu
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=8gb

proj_path=/home/gzayas97/AGR6932/
TRAITS=("Short_Hair" "TSS" "SWG_Area")
# Declare an array with the desired variables
Models=("RKHS" "GBLUP")
cd ${proj_path}/code/bash_out
for trait in "${TRAITS[@]}"
    do 
    echo ${trait}
    # Iterate through the array using a for loop
    for model in "${Models[@]}"
    do
        echo "Processing $model"
        sbatch ../Run_Model.sh ${proj_path} ${trait} ${model}
        sleep 10
    done
done
