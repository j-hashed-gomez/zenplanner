import os
import sys

from django.core.wsgi import get_wsgi_application

# Añadir la ruta de tu proyecto al path
sys.path.append('/app')

# Añadir la ruta al entorno virtual
sys.path.append('/app/venv/lib/python3.9/site-packages')

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'zenplanner.settings')

application = get_wsgi_application()
