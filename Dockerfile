FROM mambaorg/micromamba:2.5.0

COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1

USER root
COPY scripts/sequenza-command.sh scripts/sequenza-command.R /opt/
RUN chmod +x /opt/sequenza-command.sh

RUN Rscript -e 'library(sequenza); packageVersion("sequenza")'
RUN python -c 'import sequenza'
RUN bash -lc 'which samtools && which tabix && which sequenza-utils'

USER $MAMBA_USER
RUN Rscript -e 'library(iotools); packageVersion("iotools"); library(sequenza); packageVersion("sequenza")'
