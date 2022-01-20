ARG HADOOP_MIRROR=https://dlcdn.apache.org/hadoop/common
ARG HADOOP_VERSION=hadoop-3.3.1
ARG UTIL_IMAGE=skt-pub.azurecr.io/analytics-micro/util:latest

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${UTIL_IMAGE} AS util

###### hadoop-common
FROM alpine AS hadoop-common

RUN apk add --no-cache gnupg wget tar

ARG HADOOP_MIRROR HADOOP_VERSION
RUN cd /opt \
    && wget --no-verbose https://dlcdn.apache.org/hadoop/common/KEYS \
    && gpg --import KEYS \
    && tgz=${HADOOP_VERSION}.tar.gz \
    && url=${HADOOP_MIRROR}/${HADOOP_VERSION}/${tgz} \
    && wget --no-verbose ${url} ${url}.asc \
    && gpg --verify ${tgz}.asc ${tgz} \
    && tar -xvzf ${tgz} \
    && rm ${tgz} ${tgz}.asc KEYS

###### hadoop
FROM ubuntu:bionic AS hadoop

COPY --from=util /util/cleanshell /usr/local/bin/
SHELL [ "/usr/local/bin/cleanshell" ]

RUN useradd --no-log-init --create-home --shell /bin/bash hadoop \
    && chown hadoop:hadoop /usr/local/bin/*

USER hadoop
WORKDIR /home/hadoop

ENV JAVA_HOME=/usr/local/openjdk-8
COPY --from=openjdk:8 ${JAVA_HOME} ${JAVA_HOME}
ENV PATH="$PATH:$JAVA_HOME/bin"

ARG HADOOP_VERSION
ENV HOME=/home/hadoop \
    HADOOP_HOME=/home/hadoop/${HADOOP_VERSION}
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin
COPY --from=hadoop-common --chown=hadoop:hadoop /opt/${HADOOP_VERSION} ${HADOOP_HOME}

RUN mkdir $HOME/.bashrc.d \
    && echo 'for file in "$HOME"/.bashrc.d/*; do source "${file}"; done' >> "$HOME"/.bashrc
COPY --chown=hadoop:hadoop ./env/user_vars $HOME/.bashrc.d/

COPY --from=util --chown=hadoop:hadoop /util/link-conf /usr/local/bin/
RUN mkdir ${HOME}/config \
    && link-conf ${HADOOP_HOME}/etc/hadoop hadoop-common

COPY --chown=hadoop:hadoop ./config/hadoop-common/* $HOME/config/hadoop-common/
