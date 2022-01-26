ARG REGISTRY=skt-pub.azurecr.io/analytics-micro
ARG HIVE_MIRROR=https://dlcdn.apache.org/hive 
ARG HIVE_VERSION=hive-2.3.9

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

###### hive-server
FROM ${REGISTRY}/hadoop/base:latest AS hive-server

# Add hive
ARG HIVE_VERSION
ENV HIVE_HOME=${HOME}/${HIVE_VERSION}
ENV PATH=$PATH:${HIVE_HOME}/bin
COPY --from=hive-bin --chown=hadoop:hadoop /opt/apache-${HIVE_VERSION}-bin ${HIVE_HOME}

ENV HIVE_SITE_XML=${HIVE_HOME}/conf/hive-site.xml
COPY --chown=hadoop:hadoop ./config/hive-site.xml ${HIVE_SITE_XML}.template

COPY --chown=hadoop:hadoop --chmod=700 ./scripts/start-hive-server /usr/local/bin/

ENTRYPOINT [ "start-hive-server" ]
EXPOSE 10000
