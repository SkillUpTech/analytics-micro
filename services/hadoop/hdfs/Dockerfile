ARG REGISTRY=sktpub.azurecr.io/analytics-micro

###### util
# Allows us to reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

###### hdfs
FROM ${REGISTRY}/hadoop/base:latest AS hdfs

USER hadoop
SHELL [ "/bin/sh", "-c" ]

ENV HDFS_DATA_ROOT=$HOME/var
RUN mkdir -p "$HDFS_DATA_ROOT"/datanode "$HDFS_DATA_ROOT"/namenode

COPY --from=util --chown=hadoop:hadoop /util/marker/* /usr/local/bin/
COPY --from=util --chown=hadoop:hadoop /usr/local/bin/dockerize /usr/local/bin/
COPY --chown=hadoop:hadoop --chmod=700 ./scripts/hdfs-entrypoint.sh /usr/local/bin/

VOLUME [ "/home/hadoop/var" ]
ENTRYPOINT [ "hdfs-entrypoint.sh" ]
