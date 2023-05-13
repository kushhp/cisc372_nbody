#!/bin/bash -l
#SBATCH --job-name=parallel
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gpus=1
#SBATCH --output parallel-job_%j.out
#SBATCH --error parallel-job_%j.err
#SBATCH --partition=gpu-v100

# Start my application
srun parallel