ARG HADOOP_MIRROR=https://dlcdn.apache.org/hadoop/common
ARG HADOOP_VERSION=hadoop-3.3.1
ARG REGISTRY=skt-pub.azurecr.io/analytics-micro
ARG UID=1001
ARG GID=1001
ARG HIVE_MIRROR=https://dlcdn.apache.org/hive 
ARG HIVE_VERSION=hive-2.3.9

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

###### hive-bin
FROM alpine:latest AS hive-bin

RUN apk add --no-cache gnupg wget tar

ARG HIVE_MIRROR HIVE_VERSION
RUN cd /opt \
    && wget --no-verbose ${HIVE_MIRROR}/KEYS \
    && gpg --import KEYS \
    && tgz=apache-${HIVE_VERSION}-bin.tar.gz \
    && url=${HIVE_MIRROR}/${HIVE_VERSION}/${tgz} \
    && wget --no-verbose ${url} ${url}.asc \
    && gpg --verify ${tgz}.asc ${tgz} \
    && tar -xvzf ${tgz} \
    && rm ${tgz} ${tgz}.asc KEYS

###### hadoop
FROM python:2.7-buster AS hadoop

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
RUN apt-get -y update && apt-get -y install libmariadb-java procps

WORKDIR /home/hadoop
ENV HOME=/home/hadoop
RUN mkdir $HOME/.bashrc.d \
    && echo 'for file in "$HOME"/.bashrc.d/*; do source "${file}"; done' >> "$HOME"/.bashrc \
    && chown -R hadoop:hadoop "$HOME"/.bashrc "$HOME"/.bashrc.d

# - Add Hadoop - #
ARG HADOOP_VERSION
ENV HADOOP_HOME=${HOME}/${HADOOP_VERSION}
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin
COPY --from=hadoop-common --chown=hadoop:hadoop /opt/${HADOOP_VERSION} ${HADOOP_HOME}
COPY --from=util --chown=hadoop:hadoop --chmod=700 /usr/local/bin/dockerize /usr/local/bin/
COPY --chown=hadoop:hadoop ./config/hadoop-common/* ${HADOOP_HOME}/etc/hadoop/ 

# This template is rendered during the build since it relies only on variables available at build-time.
# This way other images can grab this installation without needing to replicate the environment.
COPY --chown=hadoop:hadoop ./env/user_vars /tmp
RUN dockerize -template /tmp/user_vars:$HOME/.bashrc.d/user_vars

# - Add Hive - #
ARG HIVE_VERSION
ENV HIVE_HOME=${HOME}/${HIVE_VERSION}
COPY --from=hive-bin --chown=hadoop:hadoop /opt/apache-${HIVE_VERSION}-bin ${HIVE_HOME}
RUN cd ${HIVE_HOME}/lib && ln -s /usr/share/java/mariadb-java-client.jar mariadb-java-client.jar
ENV PATH=$PATH:${HIVE_HOME}/bin

# - Add Java + Spark from the official bitnami image - #
ENV OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/java/bin:/opt/bitnami/spark/bin:/opt/bitnami/spark/sbin:/opt/bitnami/common/bin:$PATH" \
    BITNAMI_APP_NAME="spark" \
    BITNAMI_IMAGE_VERSION="3.2.0-debian-10-r88" \
    JAVA_HOME="/opt/bitnami/java" \
    LD_LIBRARY_PATH="/opt/bitnami/python/lib/:/opt/bitnami/spark/venv/lib/python3.8/site-packages/numpy.libs/:$LD_LIBRARY_PATH" \
    LIBNSS_WRAPPER_PATH="/opt/bitnami/common/lib/libnss_wrapper.so" \
    NSS_WRAPPER_GROUP="/opt/bitnami/spark/tmp/nss_group" \
    NSS_WRAPPER_PASSWD="/opt/bitnami/spark/tmp/nss_passwd" \
    SPARK_HOME="/opt/bitnami/spark"
COPY --from=bitnami/spark:3-debian-10 --chown=hadoop:hadoop /opt/bitnami /opt/bitnami
