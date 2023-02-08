#!/usr/bin/env bash

TEST='docker run --rm -t -w /home/dnm/work -v $PWD:/home/dnm/work --cap-add=SYS_PTRACE gdmeyer/dynamite:latest python3 run_all_tests.py -L 12'
echo "================"
echo $TEST
echo "================"
eval $TEST

TEST='docker run --rm -t -w /home/dnm/work -v $PWD:/home/dnm/work --cap-add=SYS_PTRACE gdmeyer/dynamite:latest-int64 python3 run_all_tests.py -L 12'
echo "================"
echo $TEST
echo "================"
eval $TEST

TEST='docker run --rm -t --gpus=all -w /home/dnm/work -v $PWD:/home/dnm/work gdmeyer/dynamite:latest-cuda python3 run_all_tests.py -L 12 --mpiexec= --gpu'
echo "================"
echo $TEST
echo "================"
eval $TEST

# test GPU docker image computing on CPU
TEST='docker run --rm -t --gpus=all -w /home/dnm/work -v $PWD:/home/dnm/work gdmeyer/dynamite:latest-cuda python3 run_all_tests.py -L 12 --mpiexec='
echo "================"
echo $TEST
echo "================"
eval $TEST

# TEST='docker run --rm -t --gpus=all -w /home/dnm/work -v $PWD:/home/dnm/work gdmeyer/dynamite:latest-cuda.cc80 python3 run_all_tests.py -L 12 --mpiexec='' --gpu'
# echo "================"
# echo $TEST
# echo "================"
# eval $TEST
