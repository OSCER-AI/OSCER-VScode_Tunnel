# Steps to Determine Resource Requirements for Slurm Batch Jobs

Following these steps will help you optimize your resource requests, leading to faster queue times and fewer job failures.

### Step 1: Analyze Your Code’s Architecture
Determine if your Python script is designed to use multiple cores or GPUs.
*   **Sequential:** If it’s a standard script, use `nodes=1` and `ntasks=1`.
*   **Multiprocessing/Threading:** If you use `joblib`, `multiprocessing`, or `concurrent.futures`, request multiple `cpus-per-task`.
*   **GPU-Enabled:** Check if your code calls `.cuda()` or `.to('cuda')`. If not, requesting a GPU is a waste of resources.

### Step 2: Run an Interactive Test
Do not submit a long batch script immediately. Start an interactive session to "see" the code run.
1.  Request a temporary interactive node:  
    `srun --partition=sooner_gpu_test --container=el7 --nodes=1 --ntasks=1 --cpus-per-task=4 --mem=16G --time=01:00:00 --pty  $SHELL`
2.  Run your script (or a smaller representative version of it).
3.  Open a second terminal, log into the same node, and run `htop` or `nvidia-smi` to watch the RAM and CPU/GPU usage peaks in real-time.

### Step 3: Use Profiling Tools
Integrate a profiler into your Python script to get exact numbers.
*   **Memory:** Install `memory_profiler`. Add the `@profile` decorator to your main function and run:  
    `python -m memory_profiler your_script.py`
*   **Execution Time:** Use `cProfile` to see which functions take the longest and if adding more CPUs will actually help.

*   OSCER Team has created a script for monitoring CPU, GPU, and memory usage. To use it on the supercomputer, first load the following module:
   `OSCER/0.2.0`
    Then, in your batch script, add the following line before running your code:
    
   `memprofile -o monitor.log`

   This will produce a file named monitor.log that logs resource usage every 5 seconds. The output format is still under development, but it still provides useful insight into resource consumption. You can view additional usage information via:

  `memprofile -h`


### Step 4: Submit a "Pilot" Batch Job
Submit your script with a generous "buffer" (e.g., 20% more RAM and time than you think you need).
```bash
#!/bin/bash
#SBATCH --partition=sooner_gpu_test
#SBATCH --container=el7
#SBATCH --job-name=pilot_test
#SBATCH --output=res_%j.txt
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=02:00:00

python your_script.py
```

### Step 5: Audit Job Efficiency
Once the pilot job finishes, use Slurm accounting tools to see what actually happened.
1.  **Check Efficiency:** Run `seff <JOB_ID>`.  
    *   *Goal:* Aim for >80% efficiency in memory. If your efficiency is 10%, lower your `--mem` request in the next submisson.
2.  **Check Peak Usage:** Run:  
    `sacct -j <JOB_ID> --format=MaxRSS,MaxDiskRead,MaxDiskWrite,Elapsed`  
    *   `MaxRSS` tells you the maximum RAM your job reached before finishing.
  
NOTE: This will be available upon upgrade the SLURM controller (soon)

### Step 6: Refine and Scale
Adjust your `.sh` file based on the `seff` and `sacct` output. 
*   **If the job failed with "Out Of Memory" (OOM):** Double the `--mem` value.
*   **If the job timed out:** Increase the `--time` value.
*   **If CPU efficiency is low:** Decrease `--cpus-per-task`.

