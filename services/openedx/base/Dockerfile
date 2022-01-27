ARG REGISTRY=skt-pub.azurecr.io/analytics-micro
ARG UID=1000
ARG GID=1000

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

###### openedx-base
FROM python:2.7 AS openedx-base

COPY --from=util /util/cleanshell /usr/local/bin/
SHELL [ "cleanshell" ]

# Applies a patch to the mysql.h header in the mariadb sources for backwards compatibility.
RUN apt-get -y update \
    && apt-get -y install default-mysql-client \
    && sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i.bkp

# Configure the openedx user.
ARG UID GID
ENV HOME=/home/openedx
RUN addgroup --gid ${GID} openedx \
    && useradd \
        --no-log-init \
        --create-home \
        --shell /bin/bash \
        --uid ${UID} \
        --gid ${GID} openedx
RUN chown openedx:openedx /usr/local/bin/*
USER openedx
WORKDIR ${HOME}
RUN mkdir -p "${HOME}"/.bashrc.d \
    && echo 'for f in "${HOME}"/.bashrc.d/*; do source ${f}; done' >> "${HOME}"/.bashrc

# Install nvm.
ENV NVM_DIR=$HOME/.nvm
ENV NODE_VERSION=14.17.4
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && echo '. "${NVM_DIR}"/nvm.sh' >> "${HOME}"/.bashrc.d/nvm \
    && . "${HOME}"/.bashrc.d/nvm \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default
ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/v$NODE_VERSION/bin:$PATH

# Install poetry.
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH=$PATH:$HOME/.poetry/bin 

# Add entrypoint
COPY --chown=openedx:openedx --chmod=700 ./scripts/launch-edx-server /usr/local/bin/

ENTRYPOINT [ "launch-edx-server" ]
