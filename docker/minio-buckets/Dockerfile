FROM minio/mc:RELEASE.2023-09-02T21-28-03Z
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]