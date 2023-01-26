# homework0-reduce  

## Environment setting in local machine

### Compiler
Both g++ and clang work. The version should at least support C++ 17.
### Copy the code from github
```bash
git clone 
```
### Compiling the code 
A Makefile is given in the directory, simply use ``make`` to compile the code. If you're compiling the code on a M-series Mac, add the ``MXMAC=1`` option:  
```bash
make MXMAC=1  
```
### Running the code  
You can run the code with:  
```bash
./reduce [num_elements] [num_rounds]  
```
If not specified, the default values are ``num_elements=1000000000`` and ``num_rounds=3``.  

### Changing the number of threads  
In your **command line**, set the environment variable ``PARLAY_NUM_THREADS`` using ``export``. For example, set the number of threads to 4:  
```bash
export PARLAY_NUM_THREADS=4  
```
## Environment setting in HPC cluster
### Accessing Zaratan
In your **command line**, 
```bash
ssh directid@login.zaratan.umd.edu
```
NOTE: Zaratan requires multifactor authentication (MFA) using the standard campus DUO MFA system. Either you must be on the standard campus VPN (which requires MFA to authenticate), or when you ssh you will get prompted to enter your passcode or a single digit to send a "push" to a phone after entering your password.    
  
You can find more information of Zaratan [Here](https://hpcc.umd.edu/hpcc/help/basics.html)
### Rules in Zaratan
If you have already connected to Zaratan, then you should be in the login node. People are only allowed to edit and compile code in the login node. The experiments should be done in the computing nodes which we will talk about it later. Never run a time-consuming program in the login node otherwise there may be penalty from univeristy.
### Copy the code from github
Once login, try:
```bash
git clone 
```
### Compiling the code 
A Makefile is given in the directory, simply use ``make`` to compile the code. 
### Submit job to the computing node
One job is descripted by a script file. A sample script ``submit.sh`` is provided in the directory. The first line indicates the type of shell:
```bash
#! /bin/bash
```
The next line indicates the number of nodes we are applying. Since we only run algorithm in a single multicore machine, the value should always be 1:
```bash
#SBATCH -N 1
```
After that, we need to indicate the number of physical cores we want in total. Each node has at most 128 cores. By default, each core can be allocated along with 4GB memory. You need to make sure the total of allocated memory is enough for your program. 
```bash
#SBATCH --ntasks-per-node=128
```
To avoid wasting of computing resource, the cluster will terminate the job who seems never stop. We need to estimate the execution time of our program and provide it in this script. In this example, our program is supposed to finish within 1 minute. If it takes more than 1 min, it will be terminated:
```bash
#SBATCH -t 01:00
```
You can run the executable file multiple times in one job. For example, I want to see the speedup of the parallel reduce algorithm when using 128 cores. I can add the following two lines into this script:
```bash
export PARLAY_NUM_THREADS=1 && ./reduce 1000000000 3
export PARLAY_NUM_THREADS=128 && ./reduce 1000000000 3
```
Now we can submit this script by:
```bash
sbatch submit.sh
```
Then the job will join the job queue. 
### Check the waiting status
To check if the submitted job is still waiting in the job queue. In the **command line**, type:
```bash
squeue -u directid
```
This will list all your waiting jobs.
### Check the result
You can refresh your directory, then you will see a file named slurm-*.out. All the standart output will be redirected into this file.
## Applying parallelism
Parallelize a for-loop:  
```C++
// sequential version  
for(int i = 0; i < n; i++) {
  f(i);
}
// parallel version  
parallel_for(0, n, [&] {
  f(i);
});
```

Parallelize two statements:  
```C++
// sequential version
a += b;
c += d;
// parallel version
auto f1 = [&]() { a += b; };
auto f2 = [&]() { c += d; };
par_do(f1, f2);
```


## Adding granularity control  
Edit the the following function in the file ``reduce.h``:  
```C++
template <class T>
T reduce(T *A, size_t n) {
  if (n == 0) {
    return 0;
  } else if (n == 1) {
    return A[0];
  } else {
    T v1, v2;
    auto f1 = [&]() { v1 = reduce(A, n / 2); };
    auto f2 = [&]() { v2 = reduce(A + n / 2, n - n / 2); };
    par_do(f1, f2);
    return v1 + v2;
  }
}
```
when $n$ is small enough, add the sum iteratively in sequential instead of dividing the tasks and computing the sum in parallel.  

## Benchmark
To test the performance of above reduce function, you can use parlay::timer:
```C++
parlay::timer t;
sum = reduce(A,1000000000);
t.stop();
std::cout << "The running time for the reduce function is " << t.total_time() << std::endl;
```
The timer has been included in the reduce.cpp. But you can also use it to test any part of the code as you like.

