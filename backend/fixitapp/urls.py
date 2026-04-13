from django.urls import path
from .views import (
    register,
    login,
    profile,
    job_requests,
    notifications_list,
    mark_as_read,
    create_booking,
    get_bookings,
    update_booking,
    create_rating,
    get_ratings,
    smart_search
)
urlpatterns = [
    path('auth/register/', register),
    path('auth/login/', login),
    path('auth/profile/', profile),
    path('requests/', job_requests),
    path('notifications/', notifications_list),
    path('notifications/<int:id>/', mark_as_read),
    path('bookings/', get_bookings),
    path('bookings/create/', create_booking),
    path('bookings/<int:id>/', update_booking),
    path('ratings/', create_rating),
    path('ratings/<int:worker_id>/', get_ratings),
    path('search/', smart_search),
]