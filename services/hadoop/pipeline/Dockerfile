ARG REGISTRY=skt-pub.azurecr.io/analytics-micro
ARG REPO_HOST=https://github.com/SkillUpTech
ARG REPO_NAME=edx-analytics-pipeline
ARG REPO_TAG=skt-ironwood

###### repo
FROM alpine:latest AS repo
ARG REPO_HOST REPO_NAME REPO_TAG
RUN apk add --no-cache git \
    && cd /opt \
    && git clone --depth 1 --branch ${REPO_TAG} ${REPO_HOST}/${REPO_NAME}.git repo 

###### pipeline
FROM ${REGISTRY}/hadoop/base:latest AS pipeline

RUN apt-get -y update && apt-get -y install python python-virtualenv python-pip && rm -rf /var/lib/apt/lists/*

ENV HOME=/home/hadoop
USER hadoop
# Install poetry
RUN pip install --user poetry

ARG REPO_NAME
ENV PIPELINE_REPO=${HOME}/${REPO_NAME}
COPY --from=repo --chown=hadoop:hadoop /opt/repo ${PIPELINE_REPO}
COPY --chown=hadoop:hadoop ./requirements/* ${PIPELINE_REPO}/

ENV PIPELINE_VENV=${HOME}/venv
RUN cd ${PIPELINE_REPO} \
    && virtualenv ${PIPELINE_VENV} \
    && . ${PIPELINE_VENV}/bin/activate \
    && poetry install \
    && make bootstrap

# Replace the luigi snakebite client in the virtualenv.
# TODO we should probably make a proper fork for this.
COPY --chown=hadoop:hadoop ./misc/patched_snakebite_client.py \
    ${PIPELINE_VENV}/src/luigi/luigi/contrib/hdfs/snakebite_client.py
# Remove the compiled file so it can be regenerated from the new source.
RUN rm -f ${PIPELINE_VENV}/src/luigi/luigi/contrib/hdfs/snakebite_client.pyc

COPY --chown=hadoop:hadoop ./templates/override.cfg $HOME/templates/

COPY --chown=hadoop:hadoop --chmod=700 ./scripts/update-insights /usr/local/bin/
ENTRYPOINT [ "update-insights" ]

