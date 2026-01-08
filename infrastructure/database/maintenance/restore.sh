#!/bin/bash

# ------ /!\ ------
# This script will empty database before restoring it.
# Be sure you know what you are doing.
# ------ /!\ ------

log_info() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"; }
log_error() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2; }

if [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    log_error "Environment variables (DB_NAME, USER, PASS) are missing."
    exit 1
fi

backup_file="$1"
db_container_name="lnm3_database"
db_user="${POSTGRES_USER}"
db_name="${POSTGRES_DB}"
db_pass="${POSTGRES_PASSWORD}"

if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
    log_error "Usage: $0 /path/to/backup.sql.gz"
    exit 1
fi

echo -e "\033[31m"
echo "!!!!!!!! /!\ !!!!!!!!"
log_info "YOU ARE ABOUT TO DELETE ALL DATA IN DATABASE $db_name BEFORE RESTORATION."
log_info "Restoration from: $backup_file"
echo "!!!!!!!! /!\ !!!!!!!!"
echo -e "\033[0m"

log_info "Starting in 10 seconds… Press Ctrl+C to cancel."
sleep 10

log_info "Let’s go. Killing connections and dropping database…"

docker exec -e PGPASSWORD="$db_pass" $db_container_name psql -U "$db_user" -d postgres <<EOF
DROP DATABASE IF EXISTS ${POSTGRES_DB} WITH (FORCE);
CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};
EOF

if [ $? -eq 0 ]; then
  log_info "Database $db_name is now empty. Starting restoration…"

  if gunzip -c "$backup_file" | docker exec -i -e PGPASSWORD="$db_pass" $db_container_name psql -U "$db_user" -d "$db_name"; then
      log_info "Restoration successful"
  else
      log_error "Restoration failed"
      exit 1
  fi
else
  log_error "Database reset failed"
  exit 1
fi
