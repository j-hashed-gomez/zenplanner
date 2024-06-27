import os
import sys

# Ruta al entorno virtual
venv_path = '/app/venv'

# Añadir la ruta del entorno virtual al sys.path
sys.path.append(venv_path + '/lib/python3.9/site-packages')

# Añadir la ruta de tu proyecto al sys.path
sys.path.append('/app')

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'zenplanner.settings')

application = get_wsgi_application()
