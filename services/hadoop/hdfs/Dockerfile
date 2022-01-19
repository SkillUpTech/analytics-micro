ARG HADOOP_MIRROR=https://dlcdn.apache.org/hadoop/common \
    HADOOP_VERSION=hadoop-3.3.1

###### hadoop-common
FROM skt-pub.azurecr.io/analytics-micro/util AS hadoop-common

RUN apt-get -y update && apt-get -y install gnupg2 wget

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

###### hdfs
FROM skt-pub.azurecr.io/analytics-micro/hadoop/base AS hdfs

RUN useradd --no-log-init --create-home --shell /bin/bash

ARG HADOOP_VERSION
COPY --from=hadoop-common /opt/${HADOOP_VERSION} /home/hdfs/hadoop-common
