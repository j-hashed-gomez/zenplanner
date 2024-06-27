#!/bin/bash
set -e

# Exportar las variables de entorno desde el archivo config.cfg
export $(grep -v '^#' /app/config/config.cfg | xargs)

# Ejecutar las tareas de inicialización
#echo "Running database migrations..."
#/app/venv/bin/python /app/manage.py migrate

echo "Collecting static files..."
/app/venv/bin/python /app/manage.py collectstatic --noinput

# Ejecutar el servidor Apache en primer plano
exec "$@"
