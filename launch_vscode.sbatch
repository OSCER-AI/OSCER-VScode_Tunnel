#!/bin/bash
#SBATCH --partition=disc
#SBATCH --container=el7
#SBATCH --gres=gpu:1
#SBATCH --output=vscode_%J_stdout.txt
#SBATCH --error=vscode_%J_stderr.txt
#SBATCH --ntasks=1
#SBATCH --mem=16G
#SBATCH --time=4:00:00

module load Python/3.11.5-GCCcore-13.2.0
module load cuDNN/8.6.0.163-CUDA-11.8.0
module load CUDA/11.8.0

source /reza/myenv1/bin/activate

rm -rf ~/.vscode
rm -rf ~/.vscode-server

export PATH=/reza/myenv1/bin:$PATH


rm -rf ~/.local/share/jupyter/runtime/*
rm -rf ~/.vscode-server/bin/*

export TUNNELNAME=$USER-$(hostname -s)
$HOME/code tunnel --accept-server-license-terms --name=$TUNNELNAME


