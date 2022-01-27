ARG HADOOP_MIRROR=https://dlcdn.apache.org/hadoop/common
ARG HADOOP_VERSION=hadoop-3.3.1
ARG REGISTRY=skt-pub.azurecr.io/analytics-micro
ARG UID=1001
ARG GID=1001

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

###### hadoop-common
FROM alpine AS hadoop-common

RUN apk add --no-cache gnupg wget tar

ARG HADOOP_MIRROR HADOOP_VERSION
RUN cd /opt \
    && wget --no-verbose ${HADOOP_MIRROR}/KEYS \
    && gpg --import KEYS \
    && tgz=${HADOOP_VERSION}.tar.gz \
    && url=${HADOOP_MIRROR}/${HADOOP_VERSION}/${tgz} \
    && wget --no-verbose ${url} ${url}.asc \
    && gpg --verify ${tgz}.asc ${tgz} \
    && tar -xvzf ${tgz} \
    && rm ${tgz} ${tgz}.asc KEYS

###### hadoop
FROM debian:buster AS hadoop

COPY --from=util /util/cleanshell /usr/local/bin/
SHELL [ "/usr/local/bin/cleanshell" ]

ARG UID GID
RUN addgroup --gid ${GID} hadoop \
    && useradd \
        --no-log-init \
        --create-home \
        --shell /bin/bash \
        --uid ${UID} \
        --gid ${GID} hadoop \
    && chown hadoop:hadoop /usr/local/bin/*

USER hadoop
WORKDIR /home/hadoop

ENV JAVA_HOME=/usr/local/openjdk-8
COPY --from=openjdk:8 ${JAVA_HOME} ${JAVA_HOME}
ENV PATH="$PATH:$JAVA_HOME/bin"

ARG HADOOP_VERSION
ENV HOME=/home/hadoop
ENV HADOOP_HOME=${HOME}/${HADOOP_VERSION}
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

COPY --from=hadoop-common --chown=hadoop:hadoop /opt/${HADOOP_VERSION} ${HADOOP_HOME}

RUN mkdir $HOME/.bashrc.d \
    && echo 'for file in "$HOME"/.bashrc.d/*; do source "${file}"; done' >> "$HOME"/.bashrc

COPY --from=util --chown=hadoop:hadoop --chmod=700 /usr/local/bin/dockerize /usr/local/bin/
COPY --chown=hadoop:hadoop ./env/user_vars /tmp
RUN dockerize -template /tmp/user_vars:$HOME/.bashrc.d/user_vars
COPY --chown=hadoop:hadoop ./config/hadoop-common/* ${HADOOP_HOME}/etc/hadoop/
