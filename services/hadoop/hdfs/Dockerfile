ARG UTIL_IMAGE=skt-pub.azurecr.io/analytics-micro/util

###### util
# Allows us to reference the utility image as 'util' in later stages.
FROM ${UTIL_IMAGE} AS util

###### hdfs
FROM skt-pub.azurecr.io/analytics-micro/hadoop/base AS hdfs

USER hadoop
SHELL [ "/bin/sh", "-c" ]

ENV HDFS_DATA_ROOT=$HOME/var
RUN mkdir -p "$HDFS_DATA_ROOT"/datanode "$HDFS_DATA_ROOT"/namenode

COPY --from=util --chown=hadoop:hadoop /util/sync-configs /usr/local/bin
COPY --chown=hadoop:hadoop --chmod=700 ./scripts/hdfs-entrypoint.sh /usr/local/bin/

VOLUME [ "/home/hadoop/var" ]
