from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404
from django.db.models import Avg
from django.utils.timezone import now
from datetime import timedelta

from .models import JobRequest, Notification, Booking, Rating, Service, User
from .serializers import (
    JobRequestSerializer,
    RegisterSerializer,
    UserProfileSerializer,
    ServiceSerializer
)
from .utils import match_services, calculate_distance,is_match


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



@api_view(['GET'])
def smart_search(request):
    query = request.GET.get('q', '').lower()

    if not query:
        return Response({
            "results": [],
            "suggestions": []
        })

    services = Service.objects.all()

    results = []
    suggestions = set()

    for s in services:
        if is_match(query, s.title):
            results.append(ServiceSerializer(s).data)
            suggestions.add(s.category)

    return Response({
        "results": results,
        "suggestions": list(suggestions)
    })

#JOB REQUEST
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def job_requests(request):

    if request.method == 'GET':
        data = JobRequest.objects.filter(customer=request.user)
        return Response(JobRequestSerializer(data, many=True).data)

    serializer = JobRequestSerializer(data=request.data)
    if serializer.is_valid():
        job_request = serializer.save(customer=request.user)

        match_services(job_request)

        return Response(JobRequestSerializer(job_request).data, status=201)

    return Response(serializer.errors, status=400)

# NOTIFICATIONS
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def notifications_list(request):

    data = Notification.objects.all()

    return Response([
        {
            "id": n.id,
            "user": n.user.username,
            "message": n.message
        }
        for n in data
    ])
 
@api_view(['PUT']) 
@permission_classes([IsAuthenticated]) 
def mark_as_read(request, id): 
    notification = get_object_or_404(Notification, id=id, user=request.user) 
    notification.is_read = True 
    notification.save() 
    return Response({"message": "Marked as read"})

# BOOKINGS 
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def bookings(request):

    if request.method == 'GET':
        if request.user.role == 'customer':
            data = Booking.objects.filter(customer=request.user)
        else:
            data = Booking.objects.filter(service__worker=request.user)

        return Response([
            {
                "id": b.id,
                "status": b.status,
                "created_at": b.created_at
            } for b in data
        ])

    if request.method == 'POST':
        if request.user.role != 'customer':
            return Response({"error": "Only customers can book"}, status=403)

        service_id = request.data.get('service_id')
        service = get_object_or_404(Service, id=service_id)

        booking = Booking.objects.create(
            service=service,
            customer=request.user
        )

        Notification.objects.create(
            user=service.worker,
            service=service,
            message="New booking request"
        )

        return Response({
            "id": booking.id,
            "status": booking.status,
            "created_at": booking.created_at
        }, status=201)
    
# UPDATE BOOKINGS
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
        message=f"Booking {new_status}"
    )

    return Response({
        "id": booking.id,
        "status": booking.status
    })


# RATINGS 
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_rating(request):

    if request.user.role != 'customer':
        return Response({"error": "Only customers can rate"}, status=403)

    worker_id = request.data.get('worker_id')
    rating_value = request.data.get('rating')
    review = request.data.get('review', '')

    if not worker_id or not rating_value:
        return Response({"error": "worker_id and rating required"}, status=400)

    rating_value = float(rating_value)

    if rating_value < 1 or rating_value > 5:
        return Response({"error": "Rating must be 1-5"}, status=400)

    completed_bookings = Booking.objects.filter(
        customer=request.user,
        service__worker_id=worker_id,
        status='completed',
    )

    if not completed_bookings.exists():
        return Response({"error": "No unrated completed jobs"}, status=400)

    booking = completed_bookings.first()

    Rating.objects.create(
        worker_id=worker_id,
        customer=request.user,
        rating=rating_value,
        review=review
    )

    booking.is_rated = True
    booking.save()

    avg = Rating.objects.filter(worker_id=worker_id).aggregate(
        Avg("rating")
    )["rating__avg"]

    Service.objects.filter(worker_id=worker_id).update(rating=avg)

    return Response({
        "message": "Rating submitted",
        "average_rating": avg
    }, status=201)

#GET RATINGS
@api_view(['GET'])
def get_ratings(request, worker_id):

    ratings = Rating.objects.filter(worker_id=worker_id).order_by("-created_at")

    avg = ratings.aggregate(Avg("rating"))["rating__avg"]

    return Response({
        "average_rating": avg or 0,
        "ratings": [
            {
                "rating": r.rating,
                "review": r.review,
                "created_at": r.created_at
            } for r in ratings
        ]
    })