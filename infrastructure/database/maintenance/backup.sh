#!/bin/bash

log_info() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"; }
log_error() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2; }


if [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$REMOTE_BACKUP_BUCKET" ]; then
    log_error "Environment variables (POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD, REMOTE_BACKUP_BUCKET) are missing."
    exit 1
fi

db_container_name="lnm3_database"
db_user="${POSTGRES_USER}"
db_name="${POSTGRES_DB}"
db_pass="${POSTGRES_PASSWORD}"
backup_path="/opt/lnm3/backups"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
filename="backup_${db_name}_${timestamp}.sql.gz"
backup_bucket="${REMOTE_BACKUP_BUCKET}"

mkdir -p $backup_path

log_info "Starting database backup [$(date)]"

if [ "$(docker inspect -f '{{.State.Running}}' $db_container_name 2>/dev/null)" != "true" ]; then
    log_error "Container $db_container_name is not running."
    exit 1
fi

log_info "Generating database dump…"
docker exec -e PGPASSWORD="$db_pass" $db_container_name pg_dump -U "$db_user" "$db_name" | gzip > "${backup_path}"/"${filename}"

if [ "${PIPESTATUS[0]}" -eq 0 ] && [ "${PIPESTATUS[1]}" -eq 0 ]; then
  log_info "Database dump generated: ${filename}"
  find $backup_path -type f -mtime +30 -name "*.sql.gz" -delete

  log_info "Cloning database dump on remote bucket…"
  rclone copy ${backup_path}/"${filename}" remote:"${backup_bucket}"

  if [ $? -eq 0 ]; then
    log_info "Database dump cloned on $backup_bucket"
  else
    log_error "Rclone copy failed"
    exit 1
  fi
else
  log_error "Database dump generation failed"
  rm -f "${backup_path}/${filename}"
  exit 1
fi
