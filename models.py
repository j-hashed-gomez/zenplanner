from django.db import models

class UserInfo(models.Model):
    user_id = models.IntegerField()
    email = models.CharField(max_length=50)
    timestamp = models.CharField(max_length=100)
    info = models.CharField(max_length=500)

    class Meta:
        db_table = 'user_info'  # Especifica el nombre de la tabla correctamente
