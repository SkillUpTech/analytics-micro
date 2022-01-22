ARG REPO_HOST=https://github.com/SkillUpTech
ARG REPO_NAME=edx-analytics-data-api
ARG REPO_TAG=skt-ironwood/0.1.2
ARG SETTINGS_MODULE=analytics_api.settings.production
ARG UTIL_IMAGE=skt-pub.azurecr.io/analytics-micro/util:latest
ARG EDX_BASE_IMAGE=skt-pub.azurecr.io/analytics-micro/openedx/base

###### util
# This lets us reference the utility image as 'util' in later stages.
FROM ${UTIL_IMAGE} AS util

###### api
FROM ${EDX_BASE_IMAGE} as api


ARG REPO_HOST REPO_NAME REPO_TAG
RUN git clone --depth 1 --branch ${REPO_TAG} ${REPO_HOST}/${REPO_NAME}.git
ENV EDX_PROJECT_DIR=${HOME}/${REPO_NAME}
COPY ./requirements/poetry.lock ${EDX_PROJECT_DIR}
COPY ./requirements/pyproject.toml ${EDX_PROJECT_DIR}

ENV EDX_VENV=${EDX_PROJECT_DIR}/venv
RUN cd ${REPO_NAME} && virtualenv ${EDX_VENV} && . ${EDX_VENV}/bin/activate && poetry install

ENV ANALYTICS_DASHBOARD_CFG="/edx/etc/insights.yml" \
    THEME_SCSS="${EDX_PROJECT_DIR}/sass/themes/open-edx.scss" \
    DJANGO_SETTINGS_MODULE=${SETTINGS_MODULE} \
    PATH="${HOME}/nodeenvs/insights/bin:${EDX_VENV}/bin:${PATH}" \
    EDX_APPLICATION=analytics_dashboard
