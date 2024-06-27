#!/bin/bash
set -e

# Leer secretos de Docker Secrets
export DB_HOST=$(cat /run/secrets/db_host)
export DB_PASSWORD=$(cat /run/secrets/db_password)
export DB_PORT=$(cat /run/secrets/db_port)
export DB_USER=$(cat /run/secrets/db_user)
export DJANGO_SECRET_KEY=$(cat /run/secrets/django_secret_key)
export GOOGLE_CLIENT_ID=$(cat /run/secrets/google_client_id)
export GOOGLE_CLIENT_SECRET=$(cat /run/secrets/google_client_secret)
export GOOGLE_REDIRECT_URI=$(cat /run/secrets/google_redirect_uri)

# Ejecutar las tareas de inicialización
echo "Running database migrations..."
/app/venv/bin/python /app/manage.py migrate

echo "Collecting static files..."
/app/venv/bin/python /app/manage.py collectstatic --noinput

# Ejecutar el servidor Apache en primer plano
exec "$@"
