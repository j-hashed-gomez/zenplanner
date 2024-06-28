import os
import requests
from django.shortcuts import redirect, render
from django.conf import settings
from django.utils import timezone
from django.db import connections
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.models import User
from django.http import HttpResponse

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
    token_url = "https://oauth2.googleapis.com/token"
    token_data = {
        'code': code,
        'client_id': GOOGLE_CLIENT_ID,
        'client_secret': GOOGLE_CLIENT_SECRET,
        'redirect_uri': GOOGLE_REDIRECT_URI,
        'grant_type': 'authorization_code'
    }
    token_response = requests.post(token_url, data=token_data)
    token_json = token_response.json()
    access_token = token_json.get('access_token')

    user_info_url = "https://www.googleapis.com/oauth2/v1/userinfo"
    user_info_params = {'access_token': access_token}
    user_info_response = requests.get(user_info_url, params=user_info_params)
    user_info = user_info_response.json()

    email = user_info.get('email')
    realname = user_info.get('name')
    current_time = timezone.now()

    # Conectar a la base de datos y actualizar o insertar el registro
    with connections['default'].cursor() as cursor:
        cursor.execute("SELECT id FROM accounts WHERE email = %s", [email])
        row = cursor.fetchone()
        
        if row:
            # El usuario ya existe, actualizar lastlogin
            cursor.execute(
                "UPDATE accounts SET lastlogin = %s WHERE email = %s",
                [current_time, email]
            )
            user_id = row[0]
        else:
            # El usuario no existe, insertar nuevo registro
            cursor.execute(
                "INSERT INTO accounts (email, realname, registered, lastlogin) VALUES (%s, %s, %s, %s)",
                [email, realname, current_time, current_time]
            )
            user_id = cursor.lastrowid

    # Autenticar al usuario y crear una sesión
    user, created = User.objects.get_or_create(username=email, defaults={'first_name': realname})
    if created:
        user.set_unusable_password()
        user.save()

    user = authenticate(request, username=email)
    if user is not None:
        login(request, user)
        response = render(request, 'user_info.html', {'user_info': {'name': realname, 'email': email}})
        response.set_cookie('sessionid', request.session.session_key, httponly=True, secure=True)
        return response
    else:
        return HttpResponse("Authentication failed", status=401)

def logout_view(request):
    logout(request)
    return redirect('index')
