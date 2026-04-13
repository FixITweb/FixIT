from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404
from django.db.models import Avg

from .models import JobRequest, Notification, Booking, Rating, Service, User
from .serializers import (
    JobRequestSerializer,
    NotificationSerializer,
    BookingSerializer,
    RatingSerializer,
    RegisterSerializer,
    UserProfileSerializer,
    ServiceSerializer
)

from .utils import match_services
from rapidfuzz import fuzz

@api_view(['POST'])
def register(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({"message": "User created successfully"})
    return Response(serializer.errors, status=400)

@api_view(['POST'])
def login(request):
    user = authenticate(
        username=request.data.get('username'),
        password=request.data.get('password')
    )

    if user:
        refresh = RefreshToken.for_user(user)
        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh)
        })

    return Response({"error": "Invalid credentials"}, status=400)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    return Response(UserProfileSerializer(request.user).data)

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def services(request):

    if request.method == 'POST':
        if request.user.role != 'worker':
            return Response({"error": "Only workers can post"}, status=403)

        serializer = ServiceSerializer(data=request.data)
        if serializer.is_valid():
            service = serializer.save(worker=request.user)
            match_services(service)

            return Response(ServiceSerializer(service).data, status=201)

        return Response(serializer.errors, status=400)
    services = Service.objects.all()
    data = []

    for s in services:
        data.append({
            "id": s.id,
            "title": s.title,
            "description": s.description,
            "category": s.category,
            "price": s.price,
            "rating": s.rating,
            "created_at": s.created_at,
            "distance": 0,
            "latitude": s.latitude,
            "longitude": s.longitude,
            "worker": {
                "id": s.worker.id,
                "username": s.worker.username
            }
        })

    return Response(data)

@api_view(['GET'])
def smart_search(request):
    query = request.GET.get('q', '').lower()

    services = Service.objects.all()
    results = []
    suggestions = set()

    for s in services:
        score = fuzz.token_set_ratio(query, s.title.lower())

        if score > 60:
            results.append(ServiceSerializer(s).data)
            suggestions.add(s.category)

    return Response({
        "results": results,
        "suggestions": list(suggestions)
    })

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def job_requests(request):

    if request.method == 'GET':
        requests = JobRequest.objects.filter(customer=request.user)
        return Response(JobRequestSerializer(requests, many=True).data)

    serializer = JobRequestSerializer(data=request.data)
    if serializer.is_valid():
        job_request = serializer.save(customer=request.user)

        # 🔥 match services
        match_services(job_request)

        return Response(JobRequestSerializer(job_request).data, status=201)

    return Response(serializer.errors, status=400)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def notifications_list(request):
    notifications = Notification.objects.filter(user=request.user).order_by("-created_at")
    return Response(NotificationSerializer(notifications, many=True).data)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def mark_as_read(request, id):
    notification = get_object_or_404(Notification, id=id, user=request.user)

    notification.is_read = request.data.get("is_read", True)
    notification.save()

    return Response(NotificationSerializer(notification).data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_booking(request):

    if request.user.role != 'customer':
        return Response({"error": "Only customers can book"}, status=403)

    service = get_object_or_404(Service, id=request.data.get('service_id'))

    booking = Booking.objects.create(
        service=service,
        customer=request.user,
        status='pending'
    )

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

    if request.user.role == 'customer':
        bookings = Booking.objects.filter(customer=request.user)
    else:
        bookings = Booking.objects.filter(service__worker=request.user)

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

    booking = get_object_or_404(Booking, id=id)

    if booking.service.worker != request.user:
        return Response({"error": "Not allowed"}, status=403)

    new_status = request.data.get('status')

    if new_status not in ['accepted', 'completed', 'rejected']:
        return Response({"error": "Invalid status"}, status=400)

    booking.status = new_status
    booking.save()

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

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_rating(request):

    if request.user.role != 'customer':
        return Response({"error": "Only customers can rate"}, status=403)

    worker_id = request.data.get('worker_id')

    if not Booking.objects.filter(
        customer=request.user,
        service__worker_id=worker_id,
        status='completed'
    ).exists():
        return Response({"error": "Complete job first"}, status=400)

    Rating.objects.create(
        worker_id=worker_id,
        customer=request.user,
        rating=request.data.get('rating'),
        review=request.data.get('review')
    )

    avg = Rating.objects.filter(worker_id=worker_id).aggregate(Avg("rating"))["rating__avg"]

    Service.objects.filter(worker_id=worker_id).update(rating=avg)

    return Response({"message": "Rating submitted"})

@api_view(['GET'])
def get_ratings(request, worker_id):
    ratings = Rating.objects.filter(worker_id=worker_id)

    data = []
    for r in ratings:
        data.append({
            "rating": r.rating,
            "review": r.review,
            "created_at": r.created_at
        })

    return Response(data)