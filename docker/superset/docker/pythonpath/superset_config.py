import logging
import os

from cachelib import RedisCache

logger = logging.getLogger()


def get_env_variable(var_name, default=None):
    """Get the environment variable or raise exception."""
    try:
        return os.environ[var_name]
    except KeyError:
        if default is not None:
            return default
        else:
            error_msg = "The environment variable {} was missing, abort...".format(
                var_name
            )
            raise EnvironmentError(error_msg)


DATABASE_DIALECT = get_env_variable("DATABASE_DIALECT")
DATABASE_USER = get_env_variable("DATABASE_USER")
DATABASE_PASSWORD = get_env_variable("DATABASE_PASSWORD")
DATABASE_HOST = get_env_variable("DATABASE_HOST")
DATABASE_PORT = get_env_variable("DATABASE_PORT")
DATABASE_DB = get_env_variable("DATABASE_DB")


# Misc variables
# PUBLIC_ROLE_LIKE_GAMMA = get_env_variable('PUBLIC_ROLE_LIKE_GAMMA')
# MAPBOX_API_KEY = get_env_variable("MAPBOX_API_KEY")
ENABLE_PROXY_FIX = get_env_variable("ENABLE_PROXY_FIX")

# The SQLAlchemy connection string.
SQLALCHEMY_DATABASE_URI = "%s://%s:%s@%s:%s/%s" % (
    DATABASE_DIALECT,
    DATABASE_USER,
    DATABASE_PASSWORD,
    DATABASE_HOST,
    DATABASE_PORT,
    DATABASE_DB,
)


REDIS_HOST = get_env_variable("REDIS_HOST")
REDIS_PORT = get_env_variable("REDIS_PORT")
REDIS_CELERY_DB = get_env_variable("REDIS_CELERY_DB", 0)
REDIS_RESULTS_DB = get_env_variable("REDIS_CELERY_DB", 1)


# RESULTS_BACKEND = FileSystemCache("/app/superset_home/sqllab")
RESULTS_BACKEND = RedisCache(host=REDIS_HOST, port=REDIS_PORT, key_prefix='superset_results')

class CeleryConfig(object):
    BROKER_URL = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_CELERY_DB}"
    CELERY_IMPORTS = ("superset.sql_lab",)
    CELERY_RESULT_BACKEND = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_RESULTS_DB}"
    CELERY_ANNOTATIONS = {"tasks.add": {"rate_limit": "10/s"}}
    CELERY_TASK_PROTOCOL = 1


CELERY_CONFIG = CeleryConfig
SQLLAB_CTAS_NO_LIMIT = True

CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': 'redis',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 1,
    'CACHE_REDIS_URL': f"redis://{REDIS_HOST}:{REDIS_PORT}/1"
}

FILTER_STATE_CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_filter_',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 2,
    'CACHE_REDIS_URL': f"redis://{REDIS_HOST}:{REDIS_PORT}/2"
}

EXPLORE_FORM_DATA_CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_form_data_',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 3,
    'CACHE_REDIS_URL': f"redis://{REDIS_HOST}:{REDIS_PORT}/3"
}
SECRET_KEY = get_env_variable("SECRET_KEY", 'thisISaSECRET_1234')


#
# Optionally import superset_config_docker.py (which will have been included on
# the PYTHONPATH) in order to allow for local settings to be overridden
#
try:
    import superset_config_docker
    from superset_config_docker import *  # noqa

    logger.info(
        f"Loaded your Docker configuration at " f"[{superset_config_docker.__file__}]"
    )
except ImportError:
    logger.info("Using default Docker config...")
