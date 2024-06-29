from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('google-login/', views.google_login, name='google_login'),
    path('callback/', views.google_callback, name='google_callback'),
    path('logout/', views.logout_view, name='logout'),
    path('reserve/', views.reserve_slot, name='reserve_slot'),
]

# Añadir configuración para servir archivos estáticos en modo desarrollo
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
