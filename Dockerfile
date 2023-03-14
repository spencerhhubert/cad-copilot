ARG UBUNTU_VERSION=20.04
ARG CUDA_VERSION=11.6.0
#need devel version for nvcc compiler. bitsandbytes only works if compile from source
ARG BASE_IMAGE=nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

FROM ${BASE_IMAGE} as base

ENV TORCH_VERSION=1.13.0
ENV CUDA_VERSION_SHORT=cu116
ENV PYTHON_VERSION=3.8

SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential ca-certificates ccache cmake curl git libjpeg-dev libgl1-mesa-glx \
        libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 \
        libxi6 libxtst6 wget libpng-dev p7zip-rar neovim tmux \
        libglib2.0-0 libsm6 libxrender1 libxext6 unzip \
        libappindicator3-1 && \
    rm -rf /var/lib/apt/lists/*
RUN /usr/sbin/update-ccache-symlinks

RUN apt-get update && apt-get install -y python${PYTHON_VERSION} python3-pip
RUN ln -sf /usr/bin/python3.8 /usr/local/bin/python
RUN alias pip=pip3

RUN pip install numpy
RUN pip install torch==${TORCH_VERSION}+${CUDA_VERSION_SHORT} torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION_SHORT}
#RUN pip install -r requirements.txt

WORKDIR /
RUN git clone https://github.com/TimDettmers/bitsandbytes
WORKDIR /bitsandbytes
RUN CUDA_VERSION=116 make cuda11x

WORKDIR /
RUN git clone https://github.com/tloen/llama-int8
WORKDIR /llama-int8
RUN pip install -r requirements.txt
WORKDIR /

RUN echo "alias v=nvim" >> /root/.bashrc
RUN echo "set +e" >> /root/.bashrc

#when running with utils/docker/run_container.sh, this gets linked with the root nexus directory
RUN mkdir cad-copilot
WORKDIR cad-copilot
