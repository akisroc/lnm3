#!/bin/sh

set -e

host="$1"
shift
cmd="$@"

until nc -z "$host" 5432; do
  @echo "Postgres ($host) still unavailable – waiting 3s…"
  sleep 3
done

@echo "Postgres is ready - executing command: $cmd"
exec $cmd
