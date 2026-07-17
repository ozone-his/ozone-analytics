#!/bin/sh
# Creates the buckets the analytics stack expects, including the Flink checkpoint/savepoint store.
#
# `set -e` matters here: this script previously ended in `exit 0`, so a failure was silent. The
# first symptom was Flink failing every checkpoint with NoSuchBucket while the job still reported
# RUNNING, because tolerable-failed-checkpoints masks it.
set -e

# `mc config host add` was removed from newer mc releases in favour of `mc alias set`. The old form
# fails, which is exactly how the buckets came to be missing.
/usr/bin/mc alias set myminio http://minio:9099 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"

IFS=","
for v in $DEFAULT_BUCKETS
do
  /usr/bin/mc mb -p "myminio/$v"
done
unset IFS

/usr/bin/mc mb -p myminio/analytics
/usr/bin/mc event add -p myminio/analytics arn:minio:sqs::_:webhook --event put
