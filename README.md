# homework0-reduce  

## Compiling the code  
A Makefile is given in the directory, simply use ``make`` to compile the code. If you're compiling the code on a M-series Mac, add the ``MXMAC=1`` option:  
```bash
make MXMAC=1  
```
## Running the code  
You can run the code with:  
```bash
./reduce [num_elements] [num_rounds]  
```
If not specified, the default values are ``num_elements=1000000000`` and ``num_rounds=3``.  

## Changing the number of threads  
In your **command line**, set the environment variable ``PARLAY_NUM_THREADS`` using ``export``. For example, set the number of threads to 4:  
```bash
export PARLAY_NUM_THREADS=4  
```

## Adding granularity control  
Edit the the following function in the file``reduce.h``:  
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

