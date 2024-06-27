#!/bin/bash
set -e

# Ejecutar las tareas de inicialización
echo "Running database migrations..."
/app/venv/bin/python /app/manage.py migrate

echo "Collecting static files..."
/app/venv/bin/python /app/manage.py collectstatic --noinput

# Ejecutar el servidor Apache en primer plano
exec "$@"
