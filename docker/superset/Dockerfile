FROM amancevice/superset
USER root

RUN apt-get update && apt-get install -y git python3 python3-setuptools python3-pip

RUN pip3 install sqlalchemy

RUN rm -rf sqlalchemy-drill

RUN git clone https://github.com/JohnOmernik/sqlalchemy-drill && cd sqlalchemy-drill && python3 setup.py install
USER superset
COPY ./superset-init.sh /etc/superset
COPY ./superset_config.py /etc/superset
COPY ./security.py /etc/superset
