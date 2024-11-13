# Stage 2: Build thundersvm wheel
FROM nvidia/cuda:11.1.1-devel-ubuntu20.04 AS gpu-builder
ARG DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME="/usr/local/cuda-11.1.1"
ENV LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
ENV PATH="$CUDA_HOME/bin:$PATH"

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    git \
    make \
    cmake

WORKDIR /opt
RUN git clone https://github.com/mvdb-enspi/thundersvm.git
WORKDIR /opt/thundersvm
RUN mkdir build && cd build && cmake .. && make -j
