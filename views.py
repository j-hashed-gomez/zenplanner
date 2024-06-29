import os
import requests
import logging
from django.shortcuts import redirect, render
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.models import User
from django.http import JsonResponse, HttpResponse, HttpResponseBadRequest
from django.db import transaction
from django.contrib.auth.decorators import login_required
from .models import UserInfo  # Asegúrate de que este modelo está correctamente definido

logger = logging.getLogger(__name__)

GOOGLE_CLIENT_ID = os.environ.get('GOOGLE_CLIENT_ID')
GOOGLE_CLIENT_SECRET = os.environ.get('GOOGLE_CLIENT_SECRET')
GOOGLE_REDIRECT_URI = os.environ.get('GOOGLE_REDIRECT_URI')

def index(request):
    return render(request, 'index.html')

def google_login(request):
    scope = "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"
    auth_url = (
        f"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id={GOOGLE_CLIENT_ID}&redirect_uri={GOOGLE_REDIRECT_URI}&scope={scope}&access_type=offline&prompt=consent"
    )
    return redirect(auth_url)

def google_callback(request):
    code = request.GET.get('code')
    if not code:
        return HttpResponseBadRequest("Error: Missing code parameter")
    token_url = "https://oauth2.googleapis.com/token"
    token_data = {
        'code': code,
        'client_id': GOOGLE_CLIENT_ID,
        'client_secret': GOOGLE_CLIENT_SECRET,
        'redirect_uri': GOOGLE_REDIRECT_URI,
        'grant_type': 'authorization_code'
    }
    token_response = requests.post(token_url, data=token_data)
    if token_response.status_code != 200:
        return HttpResponse("Error: Failed to obtain access token", status=token_response.status_code)
    access_token = token_response.json().get('access_token')
    userinfo_url = "https://www.googleapis.com/oauth2/v3/userinfo"
    headers = {'Authorization': f'Bearer {access_token}'}
    userinfo_response = requests.get(userinfo_url, headers=headers)
    email = userinfo_response.json().get('email')
    realname = userinfo_response.json().get('name')
    user, created = User.objects.get_or_create(username=email, defaults={'first_name': realname})
    if created:
        user.set_password('oauth_password')
        user.save()
    user = authenticate(request, username=email, password='oauth_password')
    if user:
        login(request, user)
        return render(request, 'user_info.html', {'user_info': {'name': realname, 'email': email}})
    return HttpResponse("Authentication failed", status=401)

def logout_view(request):
    logout(request)
    return redirect('index')

@login_required
def get_reserved_slots(request):
    selected_date = request.GET.get('date')
    reserved_slots = UserInfo.objects.filter(timestamp__startswith=selected_date).values_list('timestamp', flat=True)
    return JsonResponse({'reserved_slots': list(reserved_slots)})

@login_required
def reserve_slot(request):
    if request.method == 'POST':
        email = request.user.email
        slot_time = request.POST.get('slot_time')
        slot_info = "Reserva confirmada"
        try:
            with transaction.atomic():
                user_id = User.objects.get(email=email).id
                new_reservation = UserInfo(email=email, timestamp=slot_time, info=slot_info)
                new_reservation.save()
                return JsonResponse({'status': 'success', 'message': 'Reserva confirmada.'})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)})
    return JsonResponse({'status': 'error', 'message': 'Invalid request'}, status=400)
