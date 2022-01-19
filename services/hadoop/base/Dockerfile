FROM ubuntu:bionic

COPY --from=skt-pub.azurecr.io/analytics-micro/util /usr/local/bin /usr/local/bin
SHELL [ "/usr/local/bin/cleanshell" ]

ENV JAVA_HOME=/usr/local/openjdk-8
COPY --from=openjdk:8 ${JAVA_HOME} ${JAVA_HOME}
ENV PATH="$PATH:$JAVA_HOME/bin"
RUN useradd --create-home --no-log-init --shell /bin/bash hdfs
