from django.urls import path
from .views import index, google_login, google_callback

urlpatterns = [
    path('', index, name='index'),
    path('google-login/', google_login, name='google_login'),
    path('callback/', google_callback, name='google_callback'),  # Actualiza la ruta del callback
]
