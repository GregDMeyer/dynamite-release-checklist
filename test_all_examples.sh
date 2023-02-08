#!/usr/bin/env bash

for fname in $(ls /home/dnm/examples/tutorial/*.ipynb); do
    jupyter-nbconvert $fname --to html --execute --output /home/dnm/examples/tutorial/$(basename $fname)
done
