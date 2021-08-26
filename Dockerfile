FROM nvidia/cuda:11.0-base-ubuntu18.04
# FROM directive resets ARGS, so we specify again (the value is retained if
# previously set).
ARG CUDA=11.0
 
# Use bash to support string substitution.
SHELL ["/bin/bash", "-c"]
 
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y  && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
      cuda-command-line-tools-${CUDA/./-} \
      curl bzip2 wget unzip\
    && rm -rf /var/lib/apt/lists/*
 
# Install Miniconda package manger.
RUN curl -qsSLkO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
&& bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 \
&& rm Miniconda3-latest-Linux-x86_64.sh
RUN /opt/miniconda3/bin/conda update conda && /opt/miniconda3/bin/conda update --all
 
COPY . /app/RoseTTAFold
WORKDIR /app/RoseTTAFold
 
# While the code is licensed under the MIT License, the trained weights and data for RoseTTAFold are made available for non-commercial use only # under the terms of the Rosetta-DL Software license. You can find details at https://files.ipd.uw.edu/pub/RoseTTAFold/Rosetta-DL_LICENSE.txt
RUN curl -s https://files.ipd.uw.edu/pub/RoseTTAFold/weights.tar.gz | tar -xzf -
RUN ./install_dependencies.sh
 
# Install conda packages.
ENV PATH="/opt/miniconda3/bin:$PATH"
RUN conda env create -f RoseTTAFold-linux.yml \
    && conda env create -f folding-linux.yml
 
# Weights
# TODO pyrosetta (LTS 18.04 and python3.7)
