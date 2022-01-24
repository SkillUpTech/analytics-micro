ARG EDX_BASE_IMAGE=skt-pub.azurecr.io/analytics-micro/openedx/base
ARG INSIGHTS_IMAGE=skt-pub.azurecr.io/analytics-micro/openedx/insights
ARG API_IMAGE=skt-pub.azurecr.io/analytics-micro/openedx/api

###### database-worker
FROM ${EDX_BASE_IMAGE} AS database-worker

COPY --from=util --chown=openedx --chmod=700 /usr/local/bin/dockerize /usr/local/bin/

COPY --from=insights ${HOME} ${HOME}/insights
COPY --from=api ${HOME} ${HOME}/api

ENV INIT_DB_TEMPLATE=${HOME}/init_db.sql
COPY ./templates/init_db.sql ${INIT_DB_TEMPLATE}

COPY --chown=openedx --chmod=700 ./scripts/init-mysql /usr/local/bin/
ENTRYPOINT [ "init-mysql" ]
