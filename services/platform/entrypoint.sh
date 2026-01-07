#!/bin/sh
set -e

echo "==> Starting Platform service..."

# Create and migrate database
echo "==> Running database setup (create + migrate)..."
bin/platform eval "Platform.Release.migrate()"

echo "==> Database ready!"
echo "==> Starting Phoenix server..."

# Start the application
exec bin/platform start
