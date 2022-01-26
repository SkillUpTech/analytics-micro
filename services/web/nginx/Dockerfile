ARG REGISTRY=skt-pub.azurecr.io/analytics-micro

###### util
# Allows us to reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

###### nginx
FROM nginx

COPY ./templates/* /etc/nginx/templates/
COPY ./scripts/wait-then-start /usr/local/bin/
COPY --from=util /usr/local/bin/dockerize /usr/local/bin
ENTRYPOINT [ "wait-then-start" ]
VOLUME [ "/etc/ssl/certs", "/etc/ssl/private" ]
