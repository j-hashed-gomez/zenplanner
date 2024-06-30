from django.urls import path
from .views import index, google_login, google_callback, logout_view, get_reserved_slots, reserve_slot

urlpatterns = [
    path('', index, name='index'),
    path('google-login/', google_login, name='google_login'),
    path('callback/', google_callback, name='google_callback'),
    path('logout/', logout_view, name='logout'),
    path('api/get-reserved-slots/', get_reserved_slots),  # Asegúrate de que esta línea tenga el paréntesis de cierre
]