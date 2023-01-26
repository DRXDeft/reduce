#! /bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=128
#SBATCH -t 01:00

export PARLAY_NUM_THREADS=1 && ./reduce 10000000 3
export PARLAY_NUM_THREADS=128 && ./reduce 10000000 3

