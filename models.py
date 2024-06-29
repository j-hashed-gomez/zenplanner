from django.db import models

class UserInfo(models.Model):
    user_id = models.IntegerField()  # Asumiendo que usas un entero como ID
    email = models.CharField(max_length=50)
    timestamp = models.CharField(max_length=100)  # O considera usar models.DateTimeField
    info = models.CharField(max_length=500)
