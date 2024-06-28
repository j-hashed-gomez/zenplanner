#!/bin/bash

# Migraciones de Django
/app/venv/bin/python /app/manage.py migrate --noinput

# Recoger archivos estáticos
/app/venv/bin/python /app/manage.py collectstatic --noinput

# Crear directorio para los logs
mkdir -p /var/log/apache2
mkdir -p /app/logs

# Ajustar permisos para el directorio de logs
chown -R www-data:www-data /app/logs

# Iniciar Apache en primer plano
apache2ctl -D FOREGROUND
