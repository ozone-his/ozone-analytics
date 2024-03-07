#!/usr/bin/env bash
set -e
MYDIR="$(dirname "$(readlink -f "$0")")"
source $MYDIR/utils.sh
exportEnvs
usage="$(basename "$0") [-h] [-m OpenMRS dump path] [-d Odoo dump path] [-l Location tag e.g. h1] [-out Export file output directory]
where:
    -h  show this help text
    -o  OpenMRS dump path
    -d  Odoo dump path
    -l  Location tag e.g. h1
    -o  Absolute path to the directory where the export files will be saved"

options=':hm:d:l:o:'
while getopts $options option; do
  case "$option" in
    h) echo "$usage"; exit;;
    m) OPENMRS_DUMP_PATH=$OPTARG;;
    d) ODOO_DUMP_PATH=$OPTARG;;
    l) EXPORT_OUTPUT_TAG=$OPTARG;;
    o) EXPORT_OUTPUT_PATH=$OPTARG;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
  esac
done

# mandatory arguments
if [ ! "$OPENMRS_DUMP_PATH" ] || [ ! "$ODOO_DUMP_PATH" ]; then
  echo "arguments -openmrs and odoo must be provided"
  echo "$usage" >&2; exit 1
fi
echo "$INFO CD to Docker folder..."
cd $MYDIR/../docker

echo "$INFO Cleaning MySQL and PostgreSQL..."
docker compose -f docker-compose-db.yaml down -v

echo "$INFO Starting MySQL and PostgreSQL..."
docker compose -f docker-compose-db.yaml up -d --remove-orphans

echo "$INFO Pausing for 10 seconds to allow  MySQL and PostgreSQL to start..."
sleep 10

echo "$INFO Restoring OpenMRS dump..."
docker compose -f docker-compose-db.yaml cp $OPENMRS_DUMP_PATH mysql:/tmp/dump.sql
docker compose -f docker-compose-db.yaml exec mysql sh -c 'mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD  --database=openmrs -v < /tmp/dump.sql'

echo "$INFO Applying Appointment Boolean type Workaround..."
docker compose -f docker-compose-db.yaml exec mysql sh -c 'mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD  --database=openmrs -e "ALTER TABLE appointment_service MODIFY COLUMN voided TINYINT(1);ALTER TABLE appointment_service_type MODIFY COLUMN voided TINYINT(1);ALTER TABLE patient_appointment_provider MODIFY COLUMN voided TINYINT(1);ALTER TABLE patient_appointment MODIFY COLUMN voided TINYINT(1);"'

echo "$INFO Restoring Odoo dump..."
docker compose -f docker-compose-db.yaml cp $ODOO_DUMP_PATH postgresql:/tmp/dump.sql
docker compose -f docker-compose-db.yaml exec postgresql sh -c 'PGPASSWORD=$ODOO_DB_PASSWORD psql -U $ODOO_DB_USER -d odoo < /tmp/dump.sql'

echo "$INFO Delete conditions.sql and encounter_diagnoses.sql to workaround an incompatibility with the OpenMRS version Bahmni is using..."
rm -f $ANALYTICS_QUERIES_PATH/conditions.sql
rm -f $ANALYTICS_QUERIES_PATH/encounter_diagnoses.sql

echo "$INFO Running batch ETL, this takes some time..."
docker compose -f docker-compose-batch-etl.yaml -f docker-compose-migration.yaml up

echo "$INFO Exporting flattened tables to files..."
docker compose -f docker-compose-export.yaml up
