#!/bin/bash

# Migraciones de Django
/app/venv/bin/python /app/manage.py migrate --noinput

# Recoger archivos estáticos
/app/venv/bin/python /app/manage.py collectstatic --noinput

# Crear directorio para los logs
mkdir -p /var/log/nginx
mkdir -p /app/logs

# Iniciar Nginx en segundo plano
nginx

# Iniciar Gunicorn con logging
exec gunicorn --workers 3 --bind unix:/app/zenplanner.sock zenplanner.wsgi:application --access-logfile /app/logs/gunicorn_access.log --error-logfile /app/logs/gunicorn_error.log --log-level debug
