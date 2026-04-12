from django.urls import path
from .views import job_requests, mark_as_read, notifications_list, bookings, update_booking, create_rating, worker_ratings, register, login, profile

urlpatterns = [
    path('auth/register/', register),
    path('auth/login/', login),
    path('auth/profile/', profile),
    path("requests/", job_requests),
    path("notifications/", notifications_list),
    path("notifications/<int:id>/", mark_as_read),
    path("bookings/", bookings),
    path("bookings/<int:id>/", update_booking),
    path("ratings/", create_rating),
    path("ratings/<int:worker_id>/", worker_ratings),
]