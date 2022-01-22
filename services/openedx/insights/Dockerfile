ARG REPO_HOST=https://github.com/SkillUpTech
ARG REPO_NAME=edx-analytics-dashboard
ARG REPO_TAG=skt-ironwood/0.1.1
ARG SETTINGS_MODULE=analytics_dashboard.settings.production
ARG UTIL_IMAGE=skt-pub.azurecr.io/analytics-micro/util:latest
ARG EDX_BASE_IMAGE=skt-pub.azurecr.io/analytics-micro/openedx/base

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${UTIL_IMAGE} AS util

###### repo
FROM alpine AS repo
ARG REPO_HOST REPO_NAME REPO_TAG
ENV EDX_PROJECT_NAME=edx_analytics_dashboard
RUN apk add --no-cache git \
    && cd /opt \
    && git clone --depth 1 --branch ${REPO_TAG} ${REPO_HOST}/${REPO_NAME}.git repo \
    && find repo -name '*.pyc' -delete
# FIXME remove .pyc files from repo! ^

###### insights
FROM ${EDX_BASE_IMAGE} AS insights

ENV EDX_PROJECT_NAME=edx_analytics_dashboard
RUN mkdir ${EDX_PROJECT_NAME}
COPY --from=repo --chown=hadoop:hadoop /opt/repo/pyproject.toml ${EDX_PROJECT_NAME}/
COPY --from=repo --chown=hadoop:hadoop /opt/repo/poetry.lock ${EDX_PROJECT_NAME}/

ENV EDX_PROJECT_DIR=${HOME}/${EDX_PROJECT_NAME}
ENV EDX_VENV=${HOME}/venv
RUN cd ${EDX_PROJECT_NAME} && virtualenv ${EDX_VENV} && . ${EDX_VENV}/bin/activate && poetry install

COPY --from=repo --chown=hadoop:hadoop /opt/repo/ ${EDX_PROJECT_NAME}/

ARG SETTINGS_MODULE
ENV DJANGO_SETTINGS_MODULE=${SETTINGS_MODULE}
ENV PATH=${HOME}/nodeenvs/insights/bin:${EDX_VENV}/bin:${PATH}
ENV EDX_APPLICATION=analytics_dashboard
ENV THEME_SCSS=${EDX_PROJECT_DIR}/sass/themes/open-edx.scss
ENV ANALYTICS_DASHBOARD_CFG=${HOME}/insights.yml
ENV CFG_FILE=${ANALYTICS_DASHBOARD_CFG}

COPY ./insights.yml ${CFG_FILE}.template
COPY --from=util --chown=openedx --chmod=700 /usr/local/bin/dockerize /usr/local/bin/

ENV APPLICATION_PORT=8110
EXPOSE ${APPLICATION_PORT}
# ENTRYPOINT [ "/usr/local/bin/launch-edx-server" ]
