"""Production settings and globals."""

import sys

from os import environ

# Normally you should not import ANYTHING from Django directly
# into your settings, but ImproperlyConfigured is an exception.
from django.core.exceptions import ImproperlyConfigured

import yaml

from analyticsdataserver.settings.base import *

def get_env_setting(setting):
    """Get the environment setting or return exception."""
    try:
        return environ[setting]
    except KeyError:
        error_msg = "Set the %s env variable" % setting
        raise ImproperlyConfigured(error_msg)

########## HOST CONFIGURATION
# See: https://docs.djangoproject.com/en/1.5/releases/1.5/#allowed-hosts-required-in-production
ALLOWED_HOSTS = ['*']
########## END HOST CONFIGURATION

CONFIG_FILE=get_env_setting('ANALYTICS_API_CFG')

with open(CONFIG_FILE) as f:
  config_from_yaml = yaml.load(f)

REPORT_DOWNLOAD_BACKEND = config_from_yaml.pop('REPORT_DOWNLOAD_BACKEND', {})

JWT_AUTH_CONFIG = config_from_yaml.pop('JWT_AUTH', {})
JWT_AUTH.update(JWT_AUTH_CONFIG)

vars().update(config_from_yaml)
vars().update(REPORT_DOWNLOAD_BACKEND)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'standard': {
            'format': '%(asctime)s %(levelname)s %(process)d '
                        '[%(name)s] %(filename)s:%(lineno)d - %(message)s',
        }
    },
    'handlers': {
        'console': {
            'level': CONTAINER_LOG_LEVEL,
            'class': 'logging.StreamHandler',
            'formatter': 'standard',
            'stream': sys.stdout,
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'propagate': True,
            'level': CONTAINER_LOG_LEVEL
        },
        '': {
            'handlers': ['console'],
            'level': CONTAINER_LOG_LEVEL,
            'propagate': False
        },
    }
}


DB_OVERRIDES = dict(
    PASSWORD=environ.get('DB_MIGRATION_PASS', DATABASES['default']['PASSWORD']),
    ENGINE=environ.get('DB_MIGRATION_ENGINE', DATABASES['default']['ENGINE']),
    USER=environ.get('DB_MIGRATION_USER', DATABASES['default']['USER']),
    NAME=environ.get('DB_MIGRATION_NAME', DATABASES['default']['NAME']),
    HOST=environ.get('DB_MIGRATION_HOST', DATABASES['default']['HOST']),
    PORT=environ.get('DB_MIGRATION_PORT', DATABASES['default']['PORT']),
)

for override, value in DB_OVERRIDES.iteritems():
    DATABASES['default'][override] = value
