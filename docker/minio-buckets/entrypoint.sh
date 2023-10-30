#!/bin/sh
/usr/bin/mc config host add myminio http://minio:9099 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
IFS=","
for v in $DEFAULT_BUCKETS
do
/usr/bin/mc mb -p myminio/$v
done
/usr/bin/mc mb -p myminio/${ANALYTICS_BUCKET}
/usr/bin/mc  event add -p myminio/${ANALYTICS_BUCKET} arn:minio:sqs::_:webhook --event put
exit 0;