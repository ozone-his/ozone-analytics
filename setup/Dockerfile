FROM liquibase/liquibase:4.4.3
USER root
RUN apt-get update \
    && apt-get -y install curl \
    && rm -rf /var/lib/apt/lists/*
COPY run.sh /opt
COPY setup-connect.sh /opt/
COPY wait-for-it.sh /opt/
RUN chmod +x /opt/wait-for-it.sh
ENTRYPOINT ["/bin/bash","/opt/run.sh"]