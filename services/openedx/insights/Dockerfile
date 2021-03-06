ARG REPO_HOST=https://github.com/SkillUpTech
ARG REPO_NAME=edx-analytics-dashboard
ARG REPO_TAG=skt-ironwood/0.1.1
ARG REGISTRY=sktpub.azurecr.io/analytics-micro

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${REGISTRY}/util:latest AS util

###### repo
FROM alpine:latest AS repo
ARG REPO_HOST REPO_NAME REPO_TAG
RUN apk add --no-cache git \
    && cd /opt \
    && git clone --depth 1 --branch ${REPO_TAG} ${REPO_HOST}/${REPO_NAME}.git repo \
    && find repo -name '*.pyc' -delete
# FIXME remove .pyc files from repo! ^

###### insights
FROM ${REGISTRY}/openedx/base:latest AS insights

ENV EDX_PROJECT_NAME=edx_analytics_dashboard
RUN mkdir ${EDX_PROJECT_NAME}
COPY --chown=openedx:openedx ./requirements/pyproject.toml ${EDX_PROJECT_NAME}/
COPY --chown=openedx:openedx ./requirements/poetry.lock ${EDX_PROJECT_NAME}/

ENV EDX_PROJECT_DIR=${HOME}/${EDX_PROJECT_NAME}
ENV EDX_VENV=${HOME}/venv

RUN cd ${EDX_PROJECT_NAME} \
    && virtualenv ${EDX_VENV} \
    && . ${EDX_VENV}/bin/activate \
    && poetry install

COPY --chown=openedx:openedx ./requirements/package.json ${EDX_PROJECT_NAME}/
COPY --chown=openedx:openedx ./requirements/package-lock.json ${EDX_PROJECT_NAME}/
COPY --chown=openedx:openedx ./requirements/Makefile ${EDX_PROJECT_NAME}/
COPY --chown=openedx:openedx --chmod=700 ./requirements/npm-post-install.sh ${EDX_PROJECT_NAME}/


RUN source "${HOME}"/.bashrc.d/nvm \
    && cd ${EDX_PROJECT_NAME} \
    && make requirements.js

COPY --from=repo --chown=openedx:openedx /opt/repo/ ${EDX_PROJECT_NAME}/
ENV PATH=${HOME}/nodeenvs/insights/bin:${EDX_VENV}/bin:${PATH}

RUN source "${HOME}"/.bashrc.d/nvm && cd ${EDX_PROJECT_NAME} && make static

ENV EDX_APPLICATION=analytics_dashboard
ENV THEME_SCSS=${EDX_PROJECT_DIR}/sass/themes/open-edx.scss
ENV ANALYTICS_DASHBOARD_CFG=${HOME}/insights.yml
ENV CFG_FILE=${ANALYTICS_DASHBOARD_CFG}

COPY --chown=openedx:openedx ./templates/insights.yml ${CFG_FILE}.template
COPY --chown=openedx:openedx ./settings/analytics_micro.py ${EDX_PROJECT_NAME}/${EDX_APPLICATION}/settings/
COPY --from=util --chown=openedx:openedx --chmod=700 /usr/local/bin/dockerize /usr/local/bin/
COPY --from=util --chown=openedx:openedx --chmod=700 /util/marker/* /usr/local/bin/

ENV DJANGO_SETTINGS_MODULE=analytics_dashboard.settings.analytics_micro
ENV APPLICATION_PORT=8110
EXPOSE 8110
