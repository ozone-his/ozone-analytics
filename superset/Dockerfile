FROM amancevice/superset
USER root
# RUN pip3 install flask-oidc
USER superset
COPY ./superset-init.sh /etc/superset
COPY ./superset_config.py /etc/superset
COPY ./security.py /etc/superset