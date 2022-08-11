FROM  alpine/curl:3.14
COPY setup-connect.sh /opt/
COPY wait-for-it.sh /opt/
RUN chmod +x /opt/wait-for-it.sh
ENTRYPOINT ["/bin/sh","/opt/setup-connect.sh"]