# Usar una imagen base ligera de Python 3.10
FROM python:3.10-slim

# Establecer variables de entorno
ENV PYTHONUNBUFFERED=1

# Instalar dependencias del sistema, Apache y otras herramientas necesarias
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    sqlite3 \
    curl \
    bash \
    default-libmysqlclient-dev \
    gcc \
    python3-dev \
    musl-dev \
    pkg-config \
    libssl-dev \
    libmariadb-dev-compat \
    libmariadb-dev \
    apache2 \
    apache2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear un directorio de trabajo
WORKDIR /app

# Crear y activar un entorno virtual
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copiar los archivos de requerimientos
COPY requirements.txt /app/

# Instalar las dependencias de Python
RUN /app/venv/bin/pip install --upgrade pip setuptools wheel
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Instalar mod_wsgi usando pip
RUN /app/venv/bin/pip install mod_wsgi
RUN /app/venv/bin/mod_wsgi-express install-module | tee /etc/apache2/mods-available/wsgi.load
RUN a2enmod wsgi

# Crear los directorios necesarios para el proyecto y logs
RUN mkdir -p /app/zenplanner/accounts \
    && mkdir -p /app/zenplanner/templates \
    && mkdir -p /app/zenplanner/static/css/ \
    && mkdir -p /app/zenplanner/static/images/ \
    && mkdir -p /app/logs

# Copiar los archivos del proyecto al directorio de trabajo
COPY manage.py /app/
COPY wsgi.py /app/zenplanner/
COPY urls.py /app/zenplanner/
COPY settings.py /app/zenplanner/
COPY views.py /app/zenplanner/
COPY custom_auth_backend.py /app/zenplanner/accounts/
COPY entrypoint.sh /app/
COPY __init__.py /app/zenplanner/
COPY __init__.py /app/zenplanner/accounts/


# Copiar el contenido del directorio templates a /app/zenplanner/templates/
COPY templates/ /app/zenplanner/templates/

# Copiar el contenido del directorio static a /app/zenplanner/static/
COPY static/ /app/static/

# Copiar la configuración de Apache
COPY mysite.conf /etc/apache2/sites-available/000-default.conf

# Establecer los permisos adecuados para el directorio de trabajo y los archivos
RUN chmod -R 755 /app \
    && chown -R www-data:www-data /app \
    && chmod +x /app/entrypoint.sh

# Exponer el puerto 80
EXPOSE 80

# Usar el script de inicialización como punto de entrada
ENTRYPOINT ["/app/entrypoint.sh"]

# Comando para ejecutar Apache en primer plano
CMD ["apache2-foreground"]

