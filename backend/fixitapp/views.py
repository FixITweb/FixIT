from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Avg
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404

from .models import JobRequest, Notification, Booking, Rating, Service,User
from .serializers import JobRequestSerializer, NotificationSerializer, BookingSerializer, RatingSerializer,RegisterSerializer, UserProfileSerializer
from .utils import match_services

# REGISTER
@api_view(['POST'])
def register(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({"message": "User created successfully"})
    return Response(serializer.errors, status=400)


# LOGIN
@api_view(['POST'])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')

    user = authenticate(username=username, password=password)

    if user:
        refresh = RefreshToken.for_user(user)
        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh)
        })

    return Response({"error": "Invalid credentials"}, status=400)


# PROFILE
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    serializer = UserProfileSerializer(request.user)
    return Response(serializer.data)

# remember to update these
# trigger 1 for notification
# def match_services(job_request, service):

    # Notification.objects.create(
    #     user=job_request.customer,
    #     service=service,
    #     message=f"Your request '{job_request.title}' matched with a service!"
    # ) 

# trigger 2 for notification
# Notification.objects.create(
#     user=booking.customer,
#     service=booking.service,
#     message="Your booking was successfully created!"
# )

@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def job_requests(request):

    if request.method == "GET":
        requests = JobRequest.objects.filter(customer=request.user)
        serializer = JobRequestSerializer(requests, many=True)
        return Response(serializer.data)

    if request.method == "POST":

        serializer = JobRequestSerializer(data=request.data)

        if serializer.is_valid():
            job_request = serializer.save(customer=request.user)

            match_services(job_request)

            return Response(
                JobRequestSerializer(job_request).data,
                status=status.HTTP_201_CREATED,
            )

        return Response(serializer.errors, status=400)
    

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def notifications_list(request):

    notifications = Notification.objects.filter(user=request.user).order_by("-created_at")
    serializer = NotificationSerializer(notifications, many=True)

    return Response(serializer.data)


@api_view(["PUT"])
@permission_classes([IsAuthenticated])
def mark_as_read(request, id):

    try:
        notification = Notification.objects.get(id=id, user=request.user)
    except Notification.DoesNotExist:
        return Response({"error": "Not found"}, status=404)

    notification.is_read = request.data.get("is_read", True)
    notification.save()

    serializer = NotificationSerializer(notification)
    return Response(serializer.data)


@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def bookings(request):

    if request.method == "GET":
        data = Booking.objects.filter(customer=request.user)
        serializer = BookingSerializer(data, many=True)
        return Response(serializer.data)

    if request.method == "POST":

        service_id = request.data.get("service_id")

        try:
            service = Service.objects.get(id=service_id)
        except Service.DoesNotExist:
            return Response({"error": "Service not found"}, status=404)

        booking = Booking.objects.create(
            service=service,
            customer=request.user,
            status="pending"
        )

        # notification trigger
        Notification.objects.create(
            user=service.provider,
            service=service,
            message=f"New booking request for {service.title}"
        )

        return Response(
            BookingSerializer(booking).data,
            status=201
        )


@api_view(["PUT"])
@permission_classes([IsAuthenticated])
def update_booking(request, id):

    try:
        booking = Booking.objects.get(id=id)
    except Booking.DoesNotExist:
        return Response({"error": "Not found"}, status=404)

    new_status = request.data.get("status")

    if new_status not in ["pending", "accepted", "completed", "rejected"]:
        return Response({"error": "Invalid status"}, status=400)

    booking.status = new_status
    booking.save()

    # notify customer
    Notification.objects.create(
        user=booking.customer,
        service=booking.service,
        message=f"Your booking is now {new_status}"
    )

    return Response(BookingSerializer(booking).data)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def create_rating(request):

    worker_id = request.data.get("worker_id")
    rating_value = request.data.get("rating")
    review = request.data.get("review", "")

    if not worker_id or not rating_value:
        return Response({"error": "worker_id and rating required"}, status=400)

    rating = Rating.objects.create(
        worker_id=worker_id,
        customer=request.user,
        rating=rating_value,
        review=review
    )

    return Response(RatingSerializer(rating).data, status=201)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def worker_ratings(request, worker_id):

    ratings = Rating.objects.filter(worker_id=worker_id).order_by("-created_at")

    serializer = RatingSerializer(ratings, many=True)

    # calculate average rating
    avg = ratings.aggregate(Avg("rating"))["rating__avg"]

    return Response({
        "average_rating": avg or 0,
        "ratings": serializer.data
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_booking(request):
    user = request.user

    if user.role != 'customer':
        return Response({"error": "Only customers can book"}, status=403)

    service_id = request.data.get('service_id')

    try:
        service = Service.objects.get(id=service_id)
    except Service.DoesNotExist:
        return Response({"error": "Service not found"}, status=404)

    booking = Booking.objects.create(
        service=service,
        customer=user,
        status='pending'
    )

    # 🔔 Notify worker
    Notification.objects.create(
        user=service.worker,
        service=service,
        message="You received a new booking request"
    )

    return Response({
        "id": booking.id,
        "status": booking.status,
        "created_at": booking.created_at
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_bookings(request):
    user = request.user

    if user.role == 'customer':
        bookings = Booking.objects.filter(customer=user)
    else:
        bookings = Booking.objects.filter(service__worker=user)

    data = []
    for b in bookings:
        data.append({
            "id": b.id,
            "status": b.status,
            "created_at": b.created_at
        })

    return Response(data)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_booking(request, id):
    user = request.user

    try:
        booking = Booking.objects.get(id=id)
    except Booking.DoesNotExist:
        return Response({"error": "Not found"}, status=404)

    # Only worker can update
    if booking.service.worker != user:
        return Response({"error": "Not allowed"}, status=403)

    new_status = request.data.get('status')

    if new_status not in ['accepted', 'completed', 'rejected']:
        return Response({"error": "Invalid status"}, status=400)

    booking.status = new_status
    booking.save()

    # 🔔 Notify customer
    Notification.objects.create(
        user=booking.customer,
        service=booking.service,
        message=f"Your booking is {new_status}"
    )

    return Response({
        "id": booking.id,
        "status": booking.status,
        "created_at": booking.created_at
    })