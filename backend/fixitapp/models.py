from django.db import models
from django.contrib.auth.models import AbstractUser

# USER MODEL
class User(AbstractUser):
    ROLE_CHOICES = (
        ('customer', 'Customer'),
        ('worker', 'Worker'),
    )

    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


# SERVICE MODEL
class Service(models.Model):
    worker = models.ForeignKey(User, on_delete=models.CASCADE, related_name='services')
    title = models.CharField(max_length=255)
    description = models.TextField()
    category = models.CharField(max_length=100)
    price = models.FloatField()
    latitude = models.FloatField()
    longitude = models.FloatField()
    rating = models.FloatField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


# JOB REQUEST MODEL
class JobRequest(models.Model):
    STATUS_CHOICES = (
        ('waiting', 'Waiting'),
        ('matched', 'Matched'),
        ('completed', 'Completed'),
    )

    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='requests')
    title = models.CharField(max_length=255)
    description = models.TextField()
    category = models.CharField(max_length=100)
    budget = models.FloatField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='waiting')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title


# NOTIFICATION MODEL
class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    service = models.ForeignKey(Service, on_delete=models.CASCADE)
    message = models.CharField(max_length=255)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)


# BOOKING MODEL
class Booking(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('completed', 'Completed'),
        ('rejected', 'Rejected'),
    )

    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='bookings')
    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


# RATING MODEL
class Rating(models.Model):
    worker = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_ratings')
    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='given_ratings')
    rating = models.FloatField()
    review = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)