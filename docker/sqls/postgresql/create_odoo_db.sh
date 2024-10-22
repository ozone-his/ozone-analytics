#!/bin/bash

set -eu

function create_user_and_database() {
	local database=$1
	local user=$2
	local password=$3
	echo "  Creating '$user' user and '$database' database..."
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" $POSTGRES_DB <<-EOSQL
	    CREATE USER $user WITH  PASSWORD '$password';
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
EOSQL
}
create_user_and_database ${ODOO_DB_NAME} ${ODOO_DB_USER} ${ODOO_DB_PASSWORD}
