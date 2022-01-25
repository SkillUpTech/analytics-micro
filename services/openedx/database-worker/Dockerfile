ARG REGISTRY=skt-pub.azurecr.io/analytics-micro

###### util
# Allows us to reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util AS util

###### database-worker
FROM ${REGISTRY}/openedx/base AS database-worker

ARG REGISTRY
COPY --from=util --chown=openedx --chmod=700 /usr/local/bin/dockerize /usr/local/bin/

ENV INIT_DB_TEMPLATE=${HOME}/init_db.sql
COPY ./templates/init_db.sql ${INIT_DB_TEMPLATE}

COPY --chown=openedx --chmod=700 ./scripts/init-mysql /usr/local/bin/
ENTRYPOINT [ "init-mysql" ]
