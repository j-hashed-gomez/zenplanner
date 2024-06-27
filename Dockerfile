# Usar una imagen base ligera de Python
FROM python:3.9-slim

# Establecer variables de entorno
ENV PYTHONUNBUFFERED=1

# Instalar dependencias del sistema, mod_wsgi para Apache, y mysqlclient
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    apache2 \
    apache2-dev \
    sqlite3 \
    curl \
    bash \
    libapache2-mod-wsgi-py3 \
    default-libmysqlclient-dev \
    gcc \
    python3-dev \
    musl-dev \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear un directorio de trabajo
WORKDIR /app

# Crear y activar un entorno virtual
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copiar los archivos de requerimientos
COPY requirements.txt /app/

# Instalar las dependencias de Python, incluyendo mysqlclient
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt
RUN /app/venv/bin/pip install mysqlclient

# Crear los directorios necesarios para el proyecto
RUN mkdir -p /app/zenplanner/templates
RUN mkdir -p /app/static
RUN mkdir -p /app/zenplanner/static
RUN mkdir -p /app/config

# Copiar los archivos del proyecto al directorio de trabajo
COPY *.py /app/zenplanner/
COPY manage.py /app/

# Copiar el contenido del directorio templates a /app/zenplanner/templates/
COPY templates/ /app/zenplanner/templates/

# Copiar el contenido del directorio static a /app/static/
COPY static/ /app/static/

# Copiar la configuración de Apache
COPY mysite.conf /etc/apache2/sites-available/000-default.conf

# Habilitar mod_wsgi en Apache
RUN a2enmod wsgi

# Establecer variables de entorno para Google OAuth y DB
ARG GOOGLE_CLIENT_ID
ARG GOOGLE_CLIENT_SECRET
ARG GOOGLE_REDIRECT_URI

ENV GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
ENV GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET
ENV GOOGLE_REDIRECT_URI=$GOOGLE_REDIRECT_URI

# Establecer los permisos adecuados para el directorio de trabajo y los archivos
RUN chmod -R 755 /app
RUN chown -R www-data:www-data /app

# Configurar fstab
RUN echo "tmpfs /app/config tmpfs defaults,size=100M 0 0" >> /etc/fstab

# Exponer el puerto 80
EXPOSE 80

# Comando para ejecutar el servidor Apache en primer plano
CMD ["apachectl", "-D", "FOREGROUND"]
