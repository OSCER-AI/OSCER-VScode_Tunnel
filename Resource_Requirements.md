# Steps to Determine Resource Requirements for Slurm Batch Jobs

Following these steps will help you optimize your resource requests, leading to faster queue times and fewer job failures.


### Step 1: Analyze Your Code’s Architecture
Determine if your Python script is designed to use multiple cores or GPUs.
*   **Sequential:** If it’s a standard single-process script, use `nodes=1` and `ntasks=1`.
*   **Multiprocessing/Threading:** If your code used libraries such as `joblib`, `multiprocessing`, or `concurrent.futures`, request multiple `cpus-per-task` to match the level of parallelism.
*   **GPU-Enabled:** Verify that your code actually uses a GPU by checking for calls such as `.cuda()` or `.to('cuda')`. If it doesn't, requesting a GPU will waste compute resources.
<br><br>

### Step 2: Run an Interactive Test
Before submitting a long-running batch job, start an interactive session to observe how your application uses system resources.
1.  Request a temporary interactive node:  
    `srun --partition=normal --container=el9hw --nodes=1 --ntasks=1 --cpus-per-task=4 --mem=16G --time=01:00:00 --pty  $SHELL`
2.  Run your script (or a smaller representative version of it).
3.  Open a second terminal and launch another shell on the same allocated compute node without requesting additional resources:<br>
    `srun --jobid=<jobID> --container=el9hw --container=el9hw --overlap --pty $SHELL` <br>
    Then run `htop` or `nvidia-smi` to mointor the RAM and CPU/GPU usage peaks in real-time.
<br><br>

### Step 3: Use Profiling Tools
Integrate a profiling tool to measure your application's resource usage rather than relying on estimates.
*   **Memory:** Install `memory_profiler`, add the `@profile` decorator to your main function and run:  
    `python -m memory_profiler your_script.py`
    
*   **Execution Time:** Use `cProfile` to identify the functions that consume the most execution time and if requesting additional CPUs are likely to improve performance.

*   The OSCER Team provides a utility for monitoring CPU, GPU, and memory usage during job execution. To use it in a batch job, add the following lines to your batch script before launching your application:<br>
   `module load OSCER/0.2.0`<br>
   `memprofile -o monitor.log`

This creates a file named monitor.log that records CPU, memory, and GPU utilization every 5 seconds. The output format is still under development, but it still provides useful insight into resource consumption. For additional options and usage information, run the following command after loading the OSCER module:
  `memprofile -h`
<br><br>

### Step 4: Submit a "Pilot" Batch Job
Submit your script with a generous "buffer" (e.g., 20% more RAM and time than you think you need).
```bash
#!/bin/bash

#SBATCH --partition=normal
#SBATCH --container=el9hw
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --job-name=pilot_test
#SBATCH --output=test_%J_stdout.txt
#SBATCH --error=test_%J_stderr.txt

# Load modules and set environment
module purge
module load Python/3.13.5-GCCcore-14.3.0

# Display the node where the job is running
echo "Job started at: $(date) on $(hostname)"

# Run your python script
python your_script.py
```
<br>

### Step 5: Audit Job Efficiency
Once the pilot job finishes, use Slurm accounting tools to analyze the resources your job actually used.
1.  **Check Efficiency:** Run:<br>
    `seff <jobID>`
    *   *Goal:* Aim for >80% efficiency in memory. If the job only a small fraction of the requested efficiency (for example, 10% efficiency), reduce the `--mem` request in future submissons.
      
3.  **Check Peak Usage:** Run:  
    `sacct -j <jobID> --format=MaxRSS,MaxDiskRead,MaxDiskWrite,Elapsed`  
    *   `MaxRSS` reports the maximum RAM used by the job during execution.
  
    NOTE: This will be available upon upgrade the SLURM controller (soon)
<br><br>

### Step 6: Refine and Scale
Use the `seff` and `sacct` results to adjust your batch script and optimize resource requests.
*   **If the job failed with "Out Of Memory" (OOM):** Double the `--mem` value.
*   **If the job timed out:** Increase the `--time` value.
*   **If CPU efficiency is low:** Reduce `--cpus-per-task`.

