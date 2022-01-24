ARG UID=1000
ARG GID=1000

FROM python:2.7

# Applies a patch to the mysql.h header in the mariadb sources for backwards compatibility.
RUN apt-get -y update \
    && apt-get -y install default-mysql-client \
    && sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i.bkp

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

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH=$PATH:$HOME/.poetry/bin 

COPY --chown=openedx:openedx --chmod=700 ./scripts/launch-edx-server /usr/local/bin/

ENV MARKER_DIR=${HOME}/marker
VOLUME ${MARKER_DIR}
ENTRYPOINT [ "launch-edx-server" ]
