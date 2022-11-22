FROM apache/superset:1.5.2
# Switching to root to install the required packages
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    unixodbc-dev \
    unixodbc \
    libpq-dev \
    git
RUN SETUPTOOLS_USE_DISTUTILS=stdlib pip install git+https://github.com/JohnOmernik/sqlalchemy-drill.git pyodbc jpype1 sqlalchemy_trino
# Switching back to using the `superset` user
USER superset
