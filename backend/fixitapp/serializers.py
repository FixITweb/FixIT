from rest_framework import serializers
from .models import JobRequest, Notification, Booking, Rating,User,Service

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


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields=['username','password','role']

        def create(self, validated_data):
            user = User.objects.create_user(
                username=validated_data['username'],
                password=validated_data['password'],
                role=validated_data['role']
            )
            return user

class ServiceSerializer(serializers.ModelSerializer):
    worker = serializers.SerializerMethodField()

    class Meta:
        model = Service
        fields = '__all__'

    def get_worker(self, obj):
        return {
            "id": obj.worker.id,
            "username": obj.worker.username
        }
    

class JobRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = JobRequest
        fields = '__all__'