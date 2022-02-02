ARG REGISTRY=sktpub.azurecr.io/analytics-micro

###### util
# Allows us to reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

###### insights
# Allows us to reference the insights image as 'insights' in later stages.
FROM ${REGISTRY}/openedx/insights:latest AS insights

###### api
# Allows us to reference the api image as 'api' in later stages.
FROM ${REGISTRY}/openedx/api:latest AS api

###### nginx
FROM nginx

COPY ./templates/* /etc/nginx/templates/
COPY --chmod=700 ./scripts/wait-then-start /usr/local/bin/
COPY --from=util /usr/local/bin/dockerize /usr/local/bin/

# Gather static assets.
COPY --from=insights /home/openedx/edx_analytics_dashboard/analytics_dashboard/static/ /var/static/insights/static

ENTRYPOINT [ "wait-then-start" ]
CMD [ "nginx", "-g", "daemon off;" ]
VOLUME [ "/etc/ssl/certs", "/etc/ssl/private" ]
