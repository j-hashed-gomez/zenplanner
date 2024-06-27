#!/bin/bash
set -e

# Ejecutar las tareas de inicialización
echo "Running database migrations..."
if /app/venv/bin/python /app/manage.py migrate; then
  echo "Database migrations completed successfully."
else
  echo "Database migrations failed. Continuing with the startup..."
fi

echo "Collecting static files..."
if /app/venv/bin/python /app/manage.py collectstatic --noinput; then
  echo "Static files collected successfully."
else
  echo "Collecting static files failed. Continuing with the startup..."
fi

# Ejecutar el servidor Apache en primer plano
exec "$@"
