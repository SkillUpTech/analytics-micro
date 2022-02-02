ARG REGISTRY=sktpub.azurecr.io/analytics-micro

###### hive-server
FROM ${REGISTRY}/hadoop/base:latest AS hive-server

ENV HIVE_SITE_XML=${HIVE_HOME}/conf/hive-site.xml
ENV CORE_SITE_XML=${HADOOP_HOME}/conf/core-site.xml
COPY --chown=hadoop:hadoop ./config/hive-site.xml ${HIVE_SITE_XML}.template
COPY --chown=hadoop:hadoop ./config/hive-log4j2.properties ${HIVE_HOME}/conf/
COPY --chown=hadoop:hadoop --chmod=700 ./scripts/start-hive-server /usr/local/bin/

USER hadoop
ENTRYPOINT [ "start-hive-server" ]
EXPOSE 10000

