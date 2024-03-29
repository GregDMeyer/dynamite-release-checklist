#!/usr/bin/env bash

set -e

# generic tests
TESTS=(
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --evolve --mult --norm --eigsolve --rdm --check-conserves'
    'mpirun -n 2 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --evolve --mult --norm --eigsolve --rdm --check-conserves'

    # arg tests
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --evolve -t 0.5 --eigsolve --nev 2 --mult --mult_count 10 --rdm --keep 4 --check-conserves'

    # shell tests
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --evolve -t 1 --mult --norm --eigsolve --shell'
    'mpirun -n 2 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --evolve -t 1 --mult --norm --eigsolve --shell'

    # subspace tests
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --mult --subspace full'

    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --mult --subspace parity --which_space even'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --mult --subspace parity --which_space odd'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --mult --subspace spinconserve'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --mult --subspace spinconserve --which_space 4'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H heisenberg --mult --xparity'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H heisenberg --mult --xparity minus'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H heisenberg --mult --subspace spinconserve --xparity'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H heisenberg --mult --subspace spinconserve --xparity minus'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H heisenberg --mult --subspace parity --xparity'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H heisenberg --mult --subspace parity --xparity minus'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --mult --subspace auto --which_space UUUUUUUUDDDDDDDD'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H MBL --mult --subspace nosortauto --which_space UUUUUUUUDDDDDDDD'

    # make sure all the hamiltonians work
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H long_range --mult'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 12 -H SYK --mult'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H ising --mult'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H XX --mult'
    'mpirun -n 1 python /home/dnm/benchmarking/benchmark.py -L 16 -H heisenberg --mult'
)

for ((i = 0; i < ${#TESTS[@]}; i++)); do
    echo
    echo ================
    echo
    echo ${TESTS[$i]}
    eval ${TESTS[$i]}
done
