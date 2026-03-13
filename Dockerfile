FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    samtools \
    tabix \
    python \
    python-pip \
    r-base \
    libcurl4-openssl-dev \
    build-essential \
    gfortran \
    libxml2-dev \
    zlib1g-dev \
    libssl-dev \
 && rm -rf /var/lib/apt/lists/*

RUN R -q -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/sequenza/sequenza_2.1.2.tar.gz", repos=NULL, type="source")'

RUN pip install sequenza-utils

COPY scripts/sequenza-command.sh \
     scripts/sequenza-command.R \
     /opt/

RUN chmod +x /opt/sequenza-command.sh && \
    Rscript -e 'library(sequenza); packageVersion("sequenza")'