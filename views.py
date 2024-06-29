import os
import requests
import logging
from django.shortcuts import redirect, render
from django.utils import timezone
from django.db import connections
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.models import User
from django.http import JsonResponse, HttpResponse, HttpResponseBadRequest

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
        logger.error("Missing code parameter")
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
    logger.debug(f"Token response status: {token_response.status_code}, body: {token_response.text}")
    if token_response.status_code != 200:
        logger.error(f"Failed to obtain access token: {token_response.text}")
        return HttpResponse("Error: Failed to obtain access token", status=token_response.status_code)

    token_json = token_response.json()
    access_token = token_json.get('access_token')
    if not access_token:
        logger.error("No access token returned")
        return HttpResponseBadRequest("Error: No access token returned")

    userinfo_url = "https://www.googleapis.com/oauth2/v3/userinfo"
    headers = {'Authorization': f'Bearer {access_token}'}
    userinfo_response = requests.get(userinfo_url, headers=headers)
    userinfo_json = userinfo_response.json()
    email = userinfo_json.get('email')
    realname = userinfo_json.get('name')

    # Authenticate and create session
    user, created = User.objects.get_or_create(username=email, defaults={'first_name': realname})
    if created:
        logger.info(f"Created new user: {email}")
        user.set_password('oauth_password')  # Set a fixed password
        user.save()

    logger.debug(f"Authenticating user: {email}")
    user = authenticate(request, username=email, password='oauth_password')
    if user is not None:
        login(request, user)
        response = render(request, 'user_info.html', {'user_info': {'name': realname, 'email': email}})
        response.set_cookie('sessionid', request.session.session_key, httponly=True, secure=True)
        logger.info(f"User authenticated and session created: {email}")
        return response
    else:
        logger.error(f"Authentication failed for user: {email}")
        return HttpResponse("Authentication failed", status=401)

def logout_view(request):
    logout(request)
    return redirect('index')

def reserve_slot(request):
    if request.method == 'POST':
        user_id = request.POST.get('user_id')
        email = request.POST.get('email')
        timestamp = request.POST.get('timestamp')
        
        if request.user.is_authenticated and request.user.email == email:
            new_reservation = UserInfo(user_id=user_id, email=email, timestamp=timestamp)
            new_reservation.save()
            return JsonResponse({'status': 'success', 'message': 'Slot reservado con éxito.'})
        else:
            return JsonResponse({'status': 'error', 'message': 'No autenticado o email no coincide.'}, status=403)
    return JsonResponse({'status': 'error', 'message': 'Método no permitido'}, status=405)
