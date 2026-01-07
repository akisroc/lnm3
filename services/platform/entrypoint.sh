#!/bin/sh
set -e

echo "==> Starting Platform service..."

# Create and migrate database
echo "==> Running database migrations..."
bin/platform eval "Platform.Release.migrate()"

# Seed database
echo "==> Running database seeds..."
bin/platform eval "Platform.Release.seed()"

echo "==> Database ready!"
echo "==> Starting Phoenix server..."

# Start the application
exec bin/platform start
