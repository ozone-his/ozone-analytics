#!/bin/sh
#
# Lets each application user create tables in the public schema of its own database.
#
# PostgreSQL 15 stopped granting that to everyone, and "GRANT ALL PRIVILEGES ON DATABASE" does not
# cover it. Without it Liquibase and Superset fail with "permission denied for schema public".
# The database init scripts cannot be relied on for this: they run only once, on an empty data
# directory, and a deployment may mount its own copies of them. This runs on every start instead
# and is safe to repeat.
#
# Arguments are database/user pairs: grant_schema.sh <database> <user> [<database> <user> ...]
# A pair whose database or user does not exist is skipped.
set -eu

while [ "$#" -ge 2 ]; do
    database=$1; user=$2; shift 2
    if [ -z "$database" ] || [ -z "$user" ]; then continue; fi
    found=$(psql -d postgres -tAc "SELECT count(*) FROM pg_database d, pg_roles r WHERE d.datname = '$database' AND r.rolname = '$user'")
    if [ "$found" != "1" ]; then
        echo "skipping '$database': the database or the user '$user' does not exist"
        continue
    fi
    psql -v ON_ERROR_STOP=1 -q -d "$database" -c "GRANT ALL ON SCHEMA public TO \"$user\""
    echo "granted '$user' use of the public schema in '$database'"
done
