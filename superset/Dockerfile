FROM amancevice/superset:1.5.1
USER root

RUN apt-get update && apt-get install -y git python3 python3-setuptools python3-pip

RUN pip3 install sqlalchemy sqlalchemy-drill

USER superset
COPY ./superset-init.sh /etc/superset
COPY ./superset_config.py /etc/superset
COPY ./security.py /etc/superset
