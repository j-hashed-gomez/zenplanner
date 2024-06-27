#!/bin/bash
set -e

# Activar el entorno virtual
source /app/venv/bin/activate

# Ejecutar las tareas de inicialización
echo "Running database migrations..."
if python /app/manage.py migrate; then
  echo "Database migrations completed successfully."
else
  echo "Database migrations failed. Continuing with the startup..."
fi

echo "Collecting static files..."
if python /app/manage.py collectstatic --noinput; then
  echo "Static files collected successfully."
else
  echo "Collecting static files failed. Continuing with the startup..."
fi

# Ejecutar Nginx en segundo plano
nginx

# Ejecutar Gunicorn en primer plano
exec "$@"
