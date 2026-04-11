from django.urls import path
from .views import job_requests

urlpatterns = [
    path("requests/", job_requests),
]