from rest_framework import serializers
from .models import JobRequest, Notification, Booking, Rating

class JobRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = JobRequest
        fields = [
            "id",
            "title",
            "description",
            "category",
            "budget",
            "status",
            "created_at",
        ]
        read_only_fields = ['customer', 'created_at', 'updated_at']

class NotificationSerializer(serializers.ModelSerializer):

    class Meta:
        model = Notification
        fields = [
            "id",
            "message",
            "is_read",
            "created_at",
            "service",
        ]
        
class BookingSerializer(serializers.ModelSerializer):

    class Meta:
        model = Booking
        fields = [
            "id",
            "service",
            "status",
            "created_at",
        ]
        read_only_fields = ["status", "created_at"]

class RatingSerializer(serializers.ModelSerializer):

    class Meta:
        model = Rating
        fields = [
            "id",
            "worker",
            "rating",
            "review",
            "created_at",
        ]
        read_only_fields = ["created_at"]


