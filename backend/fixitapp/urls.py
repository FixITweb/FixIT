from django.urls import path
from .views import (
    register,
    login,
    profile,
    services,
    smart_search,
    job_requests,
    notifications_list,
    mark_as_read,
    bookings,
    update_booking,
    create_rating,
    get_ratings,
    categories
)

urlpatterns = [
    # AUTH
    path('auth/register/', register),
    path('auth/login/', login),
    path('auth/profile/', profile),

    # SERVICES
    path('services/', services),
    path('categories/', categories),
    # SMART SEARCH
    path('search/', smart_search),

    # JOB REQUESTS
    path('requests/', job_requests),

    # NOTIFICATIONS 
    path('notifications/', notifications_list),

    path('notifications/<int:id>/', mark_as_read),

    # BOOKINGS
    path('bookings/', bookings),
    path('bookings/<int:id>/', update_booking),

    # RATINGS
    path('ratings/', create_rating),
    path('ratings/<int:worker_id>/', get_ratings),
]