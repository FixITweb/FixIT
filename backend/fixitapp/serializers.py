from rest_framework import serializers
from .models import JobRequest, Notification, Booking, Rating, User, Service


# class RegisterSerializer(serializers.ModelSerializer):
#     password = serializers.CharField(write_only=True)

#     role = serializers.ChoiceField(
#         choices=User.ROLE_CHOICES,
#         required=True
#     )

#     class Meta:
#         model = User
#         fields = ['username', 'password', 'role']

#     def create(self, validated_data):
#         return User.objects.create_user(**validated_data)

# class RegisterSerializer(serializers.ModelSerializer):
#     password = serializers.CharField(write_only=True)
#     phone_number = serializers.CharField(required=False, allow_blank=True)

#     role = serializers.ChoiceField(choices=User.ROLE_CHOICES)

#     class Meta:
#         model = User
#         fields = ['username', 'password', 'role', 'phone_number']

#     def create(self, validated_data):
#         password = validated_data.pop('password')

#         # FIX HERE 
#         phone = validated_data.pop('phone_number', None)

#         user = User(**validated_data)
#         user.set_password(password)

#         if phone:
#             user.phone_number = phone

#         user.save()
#         return user
class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username", "password", "role", "phone_number"]
        extra_kwargs = {
            "password": {"write_only": True}
        }

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data["username"],
            password=validated_data["password"],
            role=validated_data["role"],
            phone_number=validated_data.get("phone_number")
        )
        return user


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
    service = ServiceSerializer(read_only=True)
    customer = UserProfileSerializer(read_only=True)

    customer_phone = serializers.SerializerMethodField()
    worker_phone = serializers.SerializerMethodField()

    class Meta:
        model = Booking
        fields = [
            "id",
            "status",
            "created_at",
            "service",
            "customer",
            "customer_phone",
            "worker_phone"
        ]

    def get_customer_phone(self, obj):
        request = self.context.get("request")

        print("USER:", request.user)
        print("ROLE:", request.user.role)
        print("SERVICE WORKER:", obj.service.worker)

        if request.user.role == "worker":
            return obj.customer.phone_number

        return None

    def get_worker_phone(self, obj):
        request = self.context.get("request")

        if not request:
            return None

        if (
            request.user.role == "customer"
            and obj.customer == request.user
            and obj.status == "accepted"
        ):
            return obj.service.worker.phone_number

        return None
        
class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rating
        fields = [
            "rating",
            "review",
            "created_at"
        ]