#!/usr/bin/env bash

# This script simply runs all of the example scripts with various parameters,
# so you can look at the output and make sure nothing is super broken. It does not:
#  - check for correctness
#  - check the plotting scripts

set -e

mkdir /tmp/scratch

TESTS=(
    'python /home/dnm/examples/scripts/floquet/run_floquet.py -L 14 --Jx 0.4 --h-vec 0.1,0.2,0.3 --alpha 1.12 -T 0.1 --initial-state-dwalls 1 --n-cycles 4 --checkpoint-every 2 --checkpoint-path /tmp/scratch'
    'python /home/dnm/examples/scripts/floquet/run_floquet.py -L 14 --Jx 0.4 --h-vec 0.1,0.2,0.3 --alpha 1.12 -T 0.1 --initial-state-dwalls 1 --n-cycles 4 --checkpoint-every 2 --checkpoint-path /tmp/scratch --shell'
    'python /home/dnm/examples/scripts/kagome/run_kagome.py 18a'
    'python /home/dnm/examples/scripts/kagome/run_kagome.py 18a --shell'
    'python /home/dnm/examples/scripts/kagome/run_kagome.py 18a --no-z2'
    'python /home/dnm/examples/scripts/MBL/run_mbl.py -L 12 --seed 0xB0BACAFE --iters 2 --energy-points 3 --h-points 3 --h-min 1.0 --h-max 5.0 --nev 16'
    'python /home/dnm/examples/scripts/MBL/run_mbl.py -L 12 --iters 1 --energy-points 3 --h-points 1 --h-min 1.0 --h-max 5.0 --nev 8'
    'python /home/dnm/examples/scripts/SYK/run_syk.py -N 20 -b 1.1,2.2 -t 0.1,0.5 --H-iters 2 --state-iters 2 --seed 0xB0BACAFE'
    'python /home/dnm/examples/scripts/SYK/run_syk.py -N 20 -b 1.1 -t 0.2 --H-iters 1 --state-iters 1 --no-shell'
)

for ((i = 0; i < ${#TESTS[@]}; i++)); do
    echo ${TESTS[$i]}
    eval ${TESTS[$i]}
    sleep 0.1
    rm -rf /tmp/scratch/*
    echo

    if command -v mpirun >/dev/null; then
        MPICMD='mpirun -n 2 '${TESTS[$i]}
        echo $MPICMD
        eval $MPICMD
        sleep 0.1
        rm -rf /tmp/scratch/*
        echo
    fi
done
