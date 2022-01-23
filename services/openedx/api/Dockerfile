ARG REPO_HOST=https://github.com/SkillUpTech
ARG REPO_NAME=edx-analytics-data-api
ARG REPO_TAG=skt-ironwood/0.1.2
ARG SETTINGS_MODULE=analytics_api.settings.production
ARG UTIL_IMAGE=skt-pub.azurecr.io/analytics-micro/util:latest
ARG EDX_BASE_IMAGE=skt-pub.azurecr.io/analytics-micro/openedx/base

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${UTIL_IMAGE} AS util

###### repo
FROM alpine AS repo
ARG REPO_HOST REPO_NAME REPO_TAG
RUN apk add --no-cache git \
    && cd /opt \
    && git clone --depth 1 --branch ${REPO_TAG} ${REPO_HOST}/${REPO_NAME}.git repo \
    && find repo -name '*.pyc' -delete
# FIXME remove .pyc files from repo! ^

COPY ./requirements/* /opt/repo/
# FIXME Correct pyproject.toml in repo

###### api
FROM ${EDX_BASE_IMAGE} AS api

ENV EDX_PROJECT_NAME=edx_analytics_api
RUN mkdir ${EDX_PROJECT_NAME}
COPY --from=repo --chown=hadoop:hadoop /opt/repo/pyproject.toml ${EDX_PROJECT_NAME}/
COPY --from=repo --chown=hadoop:hadoop /opt/repo/poetry.lock ${EDX_PROJECT_NAME}/

ENV EDX_PROJECT_DIR=${HOME}/${EDX_PROJECT_NAME}
ENV EDX_VENV=${HOME}/venv
RUN cd ${EDX_PROJECT_NAME} && virtualenv ${EDX_VENV} && . ${EDX_VENV}/bin/activate && poetry install

COPY --from=repo --chown=hadoop:hadoop /opt/repo/ ${EDX_PROJECT_NAME}/

ARG SETTINGS_MODULE
ENV DJANGO_SETTINGS_MODULE=${SETTINGS_MODULE}
ENV PATH=${HOME}/nodeenvs/analytics_api/bin:${EDX_VENV}/bin:${PATH}
# TODO Node + Static assets

ENV EDX_APPLICATION=analytics_dashboard
ENV THEME_SCSS=${EDX_PROJECT_DIR}/sass/themes/open-edx.scss
ENV ANALYTICS_API_CFG=${HOME}/analytics_api.yml
ENV CFG_FILE=${ANALYTICS_DASHBOARD_CFG}

COPY ./analytics_api.yml ${CFG_FILE}.template
COPY --from=util --chown=openedx --chmod=700 /usr/local/bin/dockerize /usr/local/bin/

ENV APPLICATION_PORT=8100
EXPOSE ${APPLICATION_PORT}
