# Usar una imagen base ligera de Python
FROM python:3.9-slim

# Establecer variables de entorno
ENV PYTHONUNBUFFERED=1

# Instalar dependencias del sistema
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    apache2 \
    apache2-dev \
    sqlite3 \
    curl \
    bash \
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
RUN pip install --no-cache-dir -r requirements.txt

# Instalar mod_wsgi
RUN pip install mod_wsgi

# Crear el directorio de plantillas
RUN mkdir -p /app/zenplanner/templates

# Copiar los archivos .py al directorio /app/zenplanner/
COPY *.py /app/zenplanner/
COPY manage.py /app/

# Copiar el contenido del directorio templates a /app/zenplanner/templates/
COPY templates/ /app/zenplanner/templates/ 

# Copiar la configuración de Apache
COPY mysite.conf /etc/apache2/sites-available/000-default.conf

# Habilitar mod_wsgi
RUN mod_wsgi-express install-module > /etc/apache2/mods-available/wsgi.load

# Establecer la variable de entorno DJANGO_SECRET_KEY
ARG DJANGO_SECRET_KEY
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}

# Migrar la base de datos para asegurarse de que SQLite está correctamente inicializado
RUN python manage.py migrate

# Exponer el puerto 80
EXPOSE 80

# Comando para ejecutar el servidor Apache en primer plano
CMD ["apachectl", "-D", "FOREGROUND"]

