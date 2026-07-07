# VS Code Slurm Tunnel Guide

This repository contains a Slurm batch script designed to launch a **VS Code Remote Tunnel** on a high-performance computing (HPC) cluster. This allows you to use the VS Code interface on your local laptop while leveraging the cluster's GPUs and memory.

For general information including creating an account, connecting to OSCER, etc. please visit **[HERE](https://www.ou.edu/oscer/getting-started)**

## The Script Overview

The script is divided into three main sections: **Resource Allocation**, **Environment Setup**, and **Launching the Tunnel**.

### 1. Resource Request (`#SBATCH`)
These lines tell the cluster's scheduler (Slurm) what hardware to reserve for you:
* **Partition & Container**: Uses the `gpu` partition and an `el9hw` environment. more info about partitions **[HERE](https://www.ou.edu/oscer/using-the-cluster/partitions)**
* **GPU**: Requests **1 GPU** (`--gres=gpu:1`).
* **Nodes & Tasks**: If your code is not explicitly parallelized (e.g., using MPI or Multiprocessing), always set (`--nodes=1`) and (`--ntasks=1`).
* **Memory & Time**: Allocates **4GB of RAM** for a duration of **2 hours**.
* **Logs**: Standard output and errors are saved to `vscode_%J_stdout.txt` and `vscode_%J_stderr.txt` (where `%J` is your Job ID).

### 2. Environment Setup
Before starting VS Code, the script prepares your software stack:

*Note: this setting has been tested on **A100 GPU*** [this requires your partition to be set to `gpu_A100`] 

* **Modules**: Loads specific versions of **Python 3.13.5**, **cuDNN 9.5.1.17** with **CUDA 12.6** to ensure your GPU code runs correctly. more info. **[HERE](https://www.ou.edu/oscer/applications/software-list#Python)**
  ```bash
  module load Python/3.13.5-GCCcore-14.3.0 
  module load cuDNN/9.5.1.17-CUDA-12.6.0 
  ``` 
* **Virtual Environment**: Activates your private Python environment located at `/$HOME/myenv1/`.
* **Cleanup**: Automatically deletes old `.vscode-server` files. This is a "housekeeping" step to prevent connection errors and clear out old cache files from previous sessions.

### 3. The Tunnel Launch
This is the final step that connects the cluster to your local machine:
* It creates a unique **Tunnel Name** based on your username and the specific node you are assigned.
* It runs the `$HOME/code tunnel` command to start the secure bridge.
* Make sure you follow the steps as described **[HERE](https://www.ou.edu/oscer/applications/vs-code)**
---

## How to Use This Script

1. **Upload the script**: Place your `.sbatch` file on the cluster (e.g., `launch_vscode.sbatch`).
2. **Submit the Job**:
   ```bash
   sbatch launch_vscode.sbatch
   ```
   - Details **[HERE](https://www.ou.edu/oscer/using-the-cluster/submitting-jobs)**

3. **Get the Link**:
   Wait about 30 seconds for the job to start, then check your output log:
   ```bash
   cat vscode_*_stdout.txt
   ```
   - Note: the `*` will be your job# for example: `vscode_3139831_stdout.txt`
4. **Login**: 
   Look for a URL in the log that looks like `https://vscode.dev...`. 
   * Copy and paste that link into your browser.
   * Follow the prompts to authenticate with your GitHub or Microsoft account.

## Troubleshooting
* **Permission Denied**: Ensure the script is executable by running `chmod +x launch_vscode.sbatch`.
* **Job Pending**: If the job stays in `PD` (Pending) status, the cluster might be full. Use `squeue -u $USER` to check your status.
* **Old Processes**: If the tunnel fails to start, the script already includes `rm -rf` commands to clear the most common cache issues.


