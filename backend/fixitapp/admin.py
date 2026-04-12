from django.contrib import admin
from . import models

# Register your models here.
admin.site.register(models.User)
admin.site.register(models.Service)
admin.site.register(models.Booking)
admin.site.register(models.JobRequest)
admin.site.register(models.Notification)
admin.site.register(models.Rating)