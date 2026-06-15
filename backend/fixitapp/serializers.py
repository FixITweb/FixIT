from rest_framework import serializers
from .models import JobRequest, Notification, Booking, Rating, User, Service

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username", "password", "role", "phone_number", "latitude", "longitude"]
        extra_kwargs = {
            "password": {"write_only": True}
        }

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data["username"],
            password=validated_data["password"],
            role=validated_data["role"],
            phone_number=validated_data.get("phone_number"),
            latitude=validated_data.get("latitude"),
            longitude=validated_data.get("longitude")
        )
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'role', 'created_at', 'latitude', 'longitude']


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
    service = ServiceSerializer(read_only=True)
    customer = UserProfileSerializer(read_only=True)

    createdAt = serializers.DateTimeField(source="created_at", read_only=True)
    customerPhone = serializers.SerializerMethodField()
    workerPhone = serializers.SerializerMethodField()

    class Meta:
        model = Booking
        fields = [
            "id",
            "status",
            "createdAt",      
            "service",
            "customer",
            "customerPhone",  
            "workerPhone",    
        ]

    def get_customerPhone(self, obj):
        request = self.context.get("request")

        if not request or not request.user.is_authenticated:
            return None

        user = request.user

        if str(getattr(user, "role", "")).strip().lower() == "worker":
            return getattr(obj.customer, "phone_number", None)

        return None


    def get_workerPhone(self, obj):
        request = self.context.get("request")

        if not request or not request.user.is_authenticated:
            return None

        user = request.user
        role = str(getattr(user, "role", "")).strip().lower()

        if role == "customer" and obj.status == "accepted":
            return getattr(obj.service.worker, "phone_number", None)

        if role == "worker":
            return getattr(obj.service.worker, "phone_number", None)

        return None
        
class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rating
        fields = [
            "rating",
            "review",
            "created_at"
        ]