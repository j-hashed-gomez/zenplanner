from django.urls import path
from .views import index, google_login, google_callback, logout_view, get_reserved_slots, reserve_slot

urlpatterns = [
    path('', index, name='index'),
    path('google-login/', google_login, name='google_login'),
    path('callback/', google_callback, name='google_callback'),
    path('logout/', logout_view, name='logout'),
    path('reserve-slot/', reserve_slot, name='reserve_slot'),
    path('api/get-reserved-slots/', get_reserved_slots, name='get_reserved_slots'),
]