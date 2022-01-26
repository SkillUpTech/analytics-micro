ARG REGISTRY=skt-pub.azurecr.io/analytics-micro
ARG UID=1000
ARG GID=1000

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

###### openedx-base
FROM python:2.7 AS openedx-base

COPY --from=util --chown=openedx:openedx --chmod=700 /util/cleanshell /usr/local/bin/
SHELL [ "cleanshell" ]

# Applies a patch to the mysql.h header in the mariadb sources for backwards compatibility.
RUN apt-get -y update \
    && apt-get -y install \
        default-mysql-client \
        nodejs \
        npm \
    && sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i.bkp

SHELL [ "sh", "-c" ]

# Configure the openedx user.
ARG UID GID
RUN addgroup --gid ${GID} openedx \
    && useradd \
        --no-log-init \
        --create-home \
        --shell /bin/bash \
        --uid ${UID} \
        --gid ${GID} openedx

ENV HOME=/home/openedx
USER openedx
WORKDIR ${HOME}

# Add poetry.
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH=$PATH:$HOME/.poetry/bin 

# Add entrypoint
COPY --chown=openedx:openedx --chmod=700 ./scripts/launch-edx-server /usr/local/bin/

ENTRYPOINT [ "launch-edx-server" ]
