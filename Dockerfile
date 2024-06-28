# Usar una imagen base ligera de Python
FROM python:3.9-slim

# Establecer variables de entorno
ENV PYTHONUNBUFFERED=1

# Instalar dependencias del sistema, Apache y mod_wsgi
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nginx \
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

# Instalar las dependencias de Python, incluyendo mysqlclient y mod_wsgi
RUN /app/venv/bin/pip install --upgrade pip setuptools wheel
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt
RUN /app/venv/bin/pip install --no-cache-dir mysqlclient==2.2.4 mod_wsgi

# Crear los directorios necesarios para el proyecto y logs
RUN mkdir -p /app/zenplanner/templates
RUN mkdir -p /app/static
RUN mkdir -p /app/zenplanner/static
RUN mkdir -p /app/logs

# Copiar los archivos del proyecto al directorio de trabajo
COPY *.py /app/zenplanner/
COPY manage.py /app/
COPY entrypoint.sh /app/

# Copiar el contenido del directorio templates a /app/zenplanner/templates/
COPY templates/ /app/zenplanner/templates/

# Copiar el contenido del directorio static a /app/static/
COPY static/ /app/static/

# Copiar la configuración de Apache
COPY mysite.conf /etc/apache2/sites-available/000-default.conf

# Establecer los permisos adecuados para el directorio de trabajo y los archivos
RUN chmod -R 755 /app
RUN chown -R www-data:www-data /app
RUN chmod +x /app/entrypoint.sh

# Exponer el puerto 80
EXPOSE 80

# Usar el script de inicialización como punto de entrada
ENTRYPOINT ["/app/entrypoint.sh"]

# Comando para ejecutar Apache en primer plano
CMD ["apache2-foreground"]
