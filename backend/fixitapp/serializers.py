from rest_framework import serializers
from .models import JobRequest, Notification, Booking, Rating, User, Service


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    role = serializers.ChoiceField(
        choices=User.ROLE_CHOICES,
        required=True
    )

    class Meta:
        model = User
        fields = ['username', 'password', 'role']

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'role', 'created_at']


class ServiceSerializer(serializers.ModelSerializer):
    worker = serializers.SerializerMethodField()

    class Meta:
        model = Service
        fields = [
            "id",
            "title",
            "description",
            "category",
            "price",
            "rating",
            "created_at",
            "latitude",
            "longitude",
            "worker"
        ]

    def get_worker(self, obj):
        return {
            "id": obj.worker.id,
            "username": obj.worker.username
        }


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
            "created_at"
        ]


class NotificationSerializer(serializers.ModelSerializer):
    service_id = serializers.IntegerField(source='service.id')

    class Meta:
        model = Notification
        fields = [
            "id",
            "message",
            "service_id",
            "created_at",
            "is_read"
        ]


class BookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = [
            "id",
            "status",
            "created_at"
        ]


class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rating
        fields = [
            "rating",
            "review",
            "created_at"
        ]