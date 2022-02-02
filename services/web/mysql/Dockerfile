ARG REGISTRY=sktpub.azurecr.io/analytics-micro

###### util
# Allows us to reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

FROM mysql:8

COPY --from=util --chown=mysql:mysql /usr/local/bin/dockerize /usr/local/bin/
COPY --chown=mysql:mysql ./templates/init_db.sql /var/init_db.sql.template
COPY --chown=mysql:mysql --chmod=700 ./scripts/render-then-start /usr/local/bin/

ENTRYPOINT [ "render-then-start" ]
CMD [ "mysqld" ]
