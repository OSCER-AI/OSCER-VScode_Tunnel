#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --container=el9hw
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --output=vscode_%J_stdout.txt
#SBATCH --error=vscode_%J_stderr.txt

# Load modules and activate environment
module purge
module load Python/3.13.5-GCCcore-14.3.0
module load cuDNN/9.5.1.17-CUDA-12.6.0
source /$HOME/myenv1/bin/activate

# Remove VS Code server files to avoid startup conflicts
rm -rf ~/.vscode
rm -rf ~/.vscode-server

# Use scratch storage for temp files to prevent /tmp space issues
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Create a unique tunnel name
export TUNNELNAME=$USER-$(hostname -s)
echo Tunnel Name: $TUNNELNAME

# Start VS Code tunnel and accept the service license terms
$HOME/code tunnel --accept-server-license-terms --name=$TUNNELNAME


