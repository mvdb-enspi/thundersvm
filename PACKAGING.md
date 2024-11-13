# Packaging

This document describes how to build and package a CPU and CUDA 11.1 version of the thundersvm package on Linux.

## Compiling the library 

This is the only step that differs between the CPU and CUDA version.

## CPU

Clone the eigen project and build with CUDA enabled:

```bash
git submodule init eigen && git submodule update
mkdir build && cd build && cmake -DUSE_CUDA=OFF .. && make -j
```

## GPU

The GPU version is built using CUDA 11.1, since CUDA >12 does not compile. The docker image is used to build the library:

```bash
docker build . -t thundersvm:cuda11-1
id=$(docker create thundersvm:cuda11-1)
mkdir build && docker cp $id:/opt/thundersvm/build/lib/ ./build
```

# Building the thundersvm package

Build the thundersvm package with the appropriate DEVICE value (cpu for CPU and cuda11.1 for GPU.). If the DEVICE environment variable is not set, then no device specifier is added to the version.

```bash
DEVICE=<device> python -m build
```

# Upload package

Setup twine and upload directly.

```bash
twine upload dist/*
```
