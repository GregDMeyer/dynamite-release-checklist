# dynamite release tools

This repository contains a few scripts to help automate creating a new release of dynamite, ensuring that all tests pass etc. You will spend a lot of time waiting for builds/tests to run, so have something else to do while you wait!

Download (or fork!) a copy of this markdown document and check things off by adding an `x` to the markdown checkboxes:

- [ ] empty checkbox. markdown: `- [ ]`
- [x] checked checkbox. markdown: `- [x]`

### 1. Update PETSc/SLEPc version numbers

PETSc and SLEPc should be updated to their latest version before doing anything else, so we can make sure all the tests pass with the latests versions before distributing libraries built with them.

Check for the latest version numbers (I usually look at the latest git tag for [PETSc](https://gitlab.com/petsc/petsc/-/tags) and [SLEPc](https://gitlab.com/slepc/slepc/-/tags)). Once you know the latest version number there are three places that it needs to be updated:

- [ ] `docker/Dockerfile` in the `ARGS` section at the top
- [ ] `docs/install.rst` (make sure to update both PETSc and SLEPc, they are in different places)
- [ ] `pyproject.toml`

### 2. Build and check docs

In a new Python virtual environment, run the following:

```bash
cd docs/
pip install -r requirements.txt
make clean; make html
pip freeze > rtd_requirements.txt
```

(Obviously, pay attention if building the docs emits any warnings or errors and fix them if needed).

- [ ] docs built successfully

Now take a look at the docs by opening `_build/html/index.html`. Poke around, make sure nothing is broken.

- [ ] docs look good

If everything looks good, commit the new `rtd_requirements.txt` to git. This file contains the exact version numbers for every package used by the docs, ensuring that the docs appear on ReadTheDocs exactly as they build on your local machine.

- [ ] `rtd_requirements.txt` is updated in `dev` branch

Once you push those changes to GitHub, if you want you can go to [the dev documentation](dynamite.readthedocs.io/en/dev) and make sure it looks like you expect!

### 3. Build dynamite from source

Follow the build instructions in the docs to build dynamite, both CPU and GPU versions. Do everything fresh (download fresh PETSc/SLEPc copies, etc.) When you install dynamite itself, use `pip install -v ./` to see all of the build output; pay attention to it to see if there were any warnings during the build process.

- [ ] Build CPU dynamite
    - [ ] Run unit tests
    - [ ] Run integration tests
- [ ] GPU dynamite
    - [ ] Run unit tests
    - [ ] Run integration tests

Here, for the integration tests, you can just run them with `L=8`---this is just to check that the build is not broken; we will fully test for dynamite bugs below.

You should also run all the test sets in `tests/integration/test_sets/` to make sure they are not broken. (Minimal options is fine here though, you basically want to make sure all the tests in the test set still exist). For example, in the directory `tests/integration`:

```bash
python run_all_tests.py -L 12 --no-shell --nprocs=1 --test-set test_sets/L30.tests
```

- [ ] Run all test sets

### 4. Update base images in Dockerfile

In `docker/Dockerfile`, update all version numbers if needed:

- [ ] Python (for CPU builds)
- [ ] CUDA (for GPU builds)
- [ ] Ubuntu (for GPU builds)

For Python, just go to the [Python downloads page](https://www.python.org/downloads/) to see the latest release. You should only need to put the major version in the Dockerfile (e.g. 3.11, not 3.11.1). You can look at the [Python docker tags](https://hub.docker.com/_/python/tags) if you want to see options, but it shouldn't be necessary.

To see what combinations of Ubuntu/CUDA version are available, look at the tags [here](https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=runtime-ubuntu) (that link has a filter applied).

It's not critical that these all be the very latest release but we just want to make sure we don't forget to update them occasionally. Sometimes upgrading to too new of a release breaks things like PETSc or [compatibility with drivers on certain compute clusters](https://docs.nvidia.com/deploy/cuda-compatibility/#minor-version-compatibility) so I would maybe stick to still-supported but not bleeding edge releases.

### 5. Build and test debug docker images

With docker installed, run the following command, from the root directory of the docker source:

```bash
python docker/build.py --fresh --debug --target release
```

This will build debug versions of the full set of docker images, with all appropriate combinations of CPU, GPU, and 32/64 bit integers. You may need to adjust the CUDA architecture in that script depending on what GPU you will test on.

Take a glance through the build output in `/tmp/dnm_build_logs` to make sure nothing weird happened.

- [ ] all images built
- [ ] nothing weird happened in the logs

The idea is that we will run the tests on the debug versions first to have bounds checking etc. and make sure there are no issues. **Note that these builds will have the same docker tags as the release builds, so don't accidentally upload the debug ones later!**

To test each of the resulting images, go to the dynamite integration tests directory, and from that directory run the script `run_all_docker_tests.sh` that is in this repository.

- [ ] all tests passed

**Note:** For me (on 2023-02-08), the GPU tests seemed to hang at `python3 test_evolve.py --shell --gpu -v 0 -L 12` with debug builds. I think it's just that running debug on GPU is very slow; I don't expect anything to meaningfully change switching to smaller system sizes so I ran those GPU tests at $L = 8$ and they ran fine.

### 6. Build non-debug docker images

Now build non-debug docker images:

```bash
python docker/build.py
```
(you do not need the `--fresh` flag if docker updated your cache with new base images during the previous step; just make sure it did that!).

- [ ] all images built

Once again I would take a look at the build output in `/tmp/dnm_build_logs` to make sure nothing weird happened.

- [ ] nothing weird happened

I know it is annoying but I would run the integration tests on all of these images too, to make sure there are no heisenbugs. Once again run this script:

```bash
./run_all_docker_tests.sh
```

- [ ] all tests passed

### 7. Check tutorial notebooks

Use the Jupyter docker image to go through each of the Jupyter tutorial notebooks. They are included in the docker image, so just start the Jupyter docker and in JupyterLab go to the `examples/tutorial` directory in the left panel. Here is the command to get JupyterLab going:

```bash
docker run --rm -p 8887:8887 gdmeyer/dynamite:latest-jupyter
```

The goals are to make sure everything runs, and also to make sure that the tutorials don't contain any old leftovers that aren't relevant any more with the new changes in this release.

If you need to change anything in the notebooks, remember that you need to mount the dynamite examples directory as a volume and edit them through that volume mount---changes you make in the `examples` directory of an already-built docker will not be reflected in your dynamite source directory.

- [ ] Jupyter notebooks look good

**Note:** This repository contains a script to automatically run all of the example notebooks. This can be helpful if you want to quickly make sure none of them give errors when all the cells are run. However I recommend doing it manually so you can also read the output and make sure the tutorials are still correct! If you want to use it, run it like so (in this repo's source directory):

```bash
docker run --rm -it -w /home/dnm/work -v $PWD:/home/dnm/work --entrypoint=bash gdmeyer/dynamite:latest-jupyter test_all_examples.sh
```

### 8. Test example scripts

Make sure any example scripts in `examples/scripts` run correctly. Currently we don't have any example scripts in there!

- [ ] Examples look good

### 9. Test benchmarking script

Make sure none of the changes broke the benchmarking script. This repository contains a script to run the benchmarking script will a bunch of different combinations of options, to make sure everything works. (It's worth taking a look at the script to see if anything needs to be added from the new changes in this version!)

The script is `./run_all_benchmark.sh`. You can run it using the docker images by running a command like:

```bash
docker run --rm -t -w /home/dnm/work -v $PWD:/home/dnm/work --cap-add=SYS_PTRACE gdmeyer/dynamite:latest bash run_all_benchmark.sh
```

- [ ] Benchmarks run without errors

### 10. Update version number and changelog

The moment you have been waiting for! Update dynamite's version number by editing the file `VERSION` in the root directory of the dynamite source.

- [ ] version number updated!

You also need to update the header of the changelog to reflect the new version number. Just edit the file `CHANGELOG.md`. I include the new version number and also the date it was released (see previous versions in the changelog for an example). Note that the date is in YYYY-MM-DD format.

- [ ] Changelog updated

Now commit this change. Then, you should tag this commit with the version string (that is, the version preceded by `v`). For example in bash, to just use what is in `VERSION`:

```bash
git tag v$(cat VERSION)
```

- [ ] New version committed
- [ ] New version tagged

### 11. Merge changes into master

Simply run the following to merge everything in `dev` into `master`:

```bash
git checkout master
git merge dev
```

There shouldn't be any merge conflicts unless for some reason there were changes to master during the last release cycle (but that shouldn't happen, unless the changes were also reflected in dev!). If there are, well, sort it out.

- [ ] Merge complete

Look at all that work that went into this release! Wow. Good job.

### 12. Re-build docker images

Now you need to re-build the docker images to use the master branch and include the updated version number. This should be quite quick because docker should have cached all the steps up until installing dynamite.

```bash
python docker/build.py
```

- [ ] docker images rebuilt

### 13. Push docker images

First, it's a good idea to remove old images in your local docker (e.g. those tagged with the previous release). Supposing that `v0.2.3` was the previous release, I run:

```bash
docker images --format "{{.Repository}}:{{.Tag}}" 'gdmeyer/dynamite' | grep 0.2.3 | xargs -n 1 docker rmi
```

Now run `docker images`. Make sure that the tags there are only ones you want to publish, because the next command here will publish all dynamite docker images you have locally onto DockerHub! In particular, all the tags there should have a "creation" date in the last few minutes, because you just rebuilt them.

- [ ] The images I am going to publish are all the ones I really want to publish!

When you are ready, use the following command to push all dynamite docker images to GitHub:

```bash
docker images --format "{{.Repository}}:{{.Tag}}" 'gdmeyer/dynamite' | xargs -n 1 docker push
```

- [ ] All images have been pushed to DockerHub!

### 14. Push to GitHub

Simply run `git push` to push the new version of master to GitHub! Make sure `dev` is updated on GitHub too.

- [ ] master is updated
- [ ] dev is updated

To get the tag you made onto GitHub you need to also do `git push --tags`. Note that this will push *all* tags you have locally, so if you have made some weird tags for yourself or something, be careful to remove them first (or use a less general way of pushing git tags).

- [ ] My new tag is on GitHub

### 15. Make a new release on GitHub

Now you can go to GitHub, make a new release, and select the new tag you made for the release. Note that this step will also trigger a new archive with a new DOI on Zenodo.

Starting at version 0.3.0, I'm just copying the portion of the changelog relevant to the release into the release description.

- [ ] New release completed

You should take a look at Zenodo to make sure the new release shows up too. Also, you usually need to update some of the metadata with the new release because it is automatically generated.

- [ ] New release is on Zenodo
- [ ] Metadata looks correct

### 16. Check that ReadTheDocs build worked

Pushing to master on GitHub should trigger a new build on ReadTheDocs. Just take a look at [dynamite.readthedocs.io](https://dynamite.readthedocs.io/) and make sure everything looks good!

Note that ReadTheDocs might take a minute or two to process the build before the updated documentation appears.

- [ ] Docs look good

Now your release is complete! The rest is just housekeeping.

### 17. Update dynamite on clusters

Now with the new release out, make sure you update the version of dynamite on any compute clusters you manage for the group.

### 18. Submit job to test dynamite at scale on clusters

With the new release installed on the clusters, it might be a good idea to submit a few jobs running the integration tests at larger system sizes that you couldn't reach on your machine, just to make sure everything works at scale. In particular try running with the `--skip-medium` option to `run_all_tests.py` so that you can push to larger `L` on the cluster.
