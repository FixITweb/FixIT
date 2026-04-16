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
)

urlpatterns = [
    # AUTH
    path('auth/register/', register),
    path('auth/login/', login),
    path('auth/profile/', profile),


    # SMART SEARCH
    path('search/', smart_search),

    # JOB REQUESTS
    path('requests/', job_requests),

    # NOTIFICATIONS

    path('notifications/<int:id>/', mark_as_read),

    # BOOKINGS 
    
    path('bookings/<int:id>/', update_booking),

    # RATINGS
    path('ratings/', create_rating),
    
]