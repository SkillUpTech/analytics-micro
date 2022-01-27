ARG REGISTRY=skt-pub.azurecr.io/analytics-micro
ARG REPO_HOST=https://github.com/SkillUpTech
ARG REPO_NAME=edx-analytics-pipeline
ARG REPO_TAG=skt-ironwood
ARG HADOOP_VERSION=hadoop-3.3.1
ARG HIVE_VERSION=hive-2.3.9

###### util
# Lets us reference the utililty image as 'util'
FROM ${REGISTRY}/util:latest AS util

###### hadoop-base
# Lets us reference the hadoop base image as 'hadoop-base'
FROM ${REGISTRY}/hadoop/base:latest AS hadoop-base

###### hive-server
# Lets us reference the Hive server image as 'hive-server'
FROM ${REGISTRY}/hadoop/hive-server:latest AS hive-server

###### repo
FROM alpine:latest AS repo
ARG REPO_HOST REPO_NAME REPO_TAG
RUN apk add --no-cache git \
    && cd /opt \
    && git clone --depth 1 --branch ${REPO_TAG} ${REPO_HOST}/${REPO_NAME}.git repo 

###### pipeline
FROM python:2.7 AS pipeline

# Set up hadoop user
COPY --from=hadoop-base /etc/passwd /etc/passwd
ENV HOME=/home/hadoop
USER hadoop
WORKDIR ${HOME}
COPY --from=hadoop-base ${HOME} ${HOME}

# Install poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH=$PATH:$HOME/.poetry/bin 

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

# Add Java
ENV JAVA_HOME=/usr/local/openjdk-8
COPY --from=openjdk:8 ${JAVA_HOME} ${JAVA_HOME}
ARG HADOOP_VERSION
ENV HADOOP_HOME=${HOME}/${HADOOP_VERSION}

ARG HIVE_VERSION
ENV HIVE_HOME=${HOME}/${HIVE_VERSION}
# Add beeline
COPY --from=hive-server ${HIVE_HOME} ${HIVE_HOME}
ENV PATH="$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$JAVA_HOME/bin"

COPY --from=util --chown=hadoop:hadoop /usr/local/bin/dockerize /usr/local/bin/

COPY --chown=hadoop:hadoop ./templates/override.cfg $HOME/templates/

COPY --chown=hadoop:hadoop --chmod=700 ./scripts/update-insights /usr/local/bin/
ENTRYPOINT [ "update-insights" ]

USER root
