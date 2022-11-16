FROM apache/superset:1.5.2
# Switching to root to install the required packages
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    unixodbc-dev \
    unixodbc \
    libpq-dev 
RUN pip install git+https://github.com/JohnOmernik/sqlalchemy-drill.git
RUN pip install pyodbc jpype1 sqlalchemy_trino
RUN pip install --force-reinstall git+https://github.com/benoitc/gunicorn.git@master
# Switching back to using the `superset` user
USER superset
