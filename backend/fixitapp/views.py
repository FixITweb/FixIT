from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404
from django.db.models import Avg, Sum, Count
from django.utils.timezone import now
from datetime import timedelta
import os
import google.generativeai as genai
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import JobRequest, Notification, Booking, Rating, Service, User
from .serializers import (
    JobRequestSerializer,
    RegisterSerializer,
    UserProfileSerializer,
    ServiceSerializer,
    BookingSerializer
)
from .utils import match_services, calculate_distance,is_match
from .permissions import IsWorker

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


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def profile(request):
    if request.method == 'PUT':
        latitude = request.data.get('latitude', None)
        longitude = request.data.get('longitude', None)

        if latitude is not None:
            request.user.latitude = latitude

        if longitude is not None:
            request.user.longitude = longitude

        request.user.save(update_fields=['latitude', 'longitude', 'updated_at'])

    return Response(UserProfileSerializer(request.user).data)

@api_view(['GET'])
@permission_classes([IsAuthenticated, IsWorker])
def my_services(request):
    services = Service.objects.filter(worker=request.user)
    serializer = ServiceSerializer(services, many=True)
    return Response(serializer.data)

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def services(request, service_id=None):

    if request.method == 'DELETE' and service_id:
        service = get_object_or_404(Service, id=service_id)
        
        if service.worker != request.user:
            return Response({"error": "Not allowed"}, status=403)

        active_bookings = Booking.objects.filter(
            service=service,
            status__in=['pending', 'accepted']
        ).count()
        
        if active_bookings > 0:
            return Response({
                "error": f"Cannot delete service with {active_bookings} active booking(s)"
            }, status=400)
        
        service_title = service.title
        service.delete()
        
        return Response({
            "message": f"Service '{service_title}' deleted successfully"
        })

    if request.method == 'PUT' and service_id:
        service = get_object_or_404(Service, id=service_id)
        
        if service.worker != request.user:
            return Response({"error": "Not allowed"}, status=403)
        
        serializer = ServiceSerializer(service, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)

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
    search = request.GET.get('search')
    category = request.GET.get('category')
    min_price = request.GET.get('min_price')
    max_price = request.GET.get('max_price')
    rating = request.GET.get('rating')
    date = request.GET.get('date')
    sort = request.GET.get('sort')
    lat = request.GET.get('lat')
    lng = request.GET.get('lng')
    radius = request.GET.get('radius')

    if search:
        services = services.filter(title__icontains=search)

    if category:
        services = services.filter(category=category)

    if min_price:
        services = services.filter(price__gte=min_price)

    if max_price:
        services = services.filter(price__lte=max_price)

    if rating:
        services = services.filter(rating__gte=rating)

    if date == "today":
        services = services.filter(created_at__date=now().date())

    elif date == "this_week":
        services = services.filter(created_at__gte=now() - timedelta(days=7))

    if not lat or not lng:
        lat = getattr(request.user, "latitude", None)
        lng = getattr(request.user, "longitude", None)

    if lat is not None and lng is not None:
        lat = float(lat)
        lng = float(lng)
    else:
        lat = None
        lng = None

    result = []

    for s in services:
        distance = None

        if lat is not None and lng is not None:
            distance = calculate_distance(
                lat, lng,
                s.latitude, s.longitude
            )

        else:
            distance = calculate_distance(
                9, 38.7,
                s.latitude, s.longitude
            )
            
        if radius:
            if distance > float(radius):
                continue

        result.append({
            "id": s.id,
            "title": s.title,
            "description": s.description,
            "category": s.category,
            "price": s.price,
            "rating": s.rating,
            "created_at": s.created_at,
            "distance": distance,
            "latitude": s.latitude,
            "longitude": s.longitude,
            "worker": {
                "id": s.worker.id,
                "username": s.worker.username
            }
        })


    if sort == "distance":
        result = sorted(
            result,
            key=lambda x: float('inf') if x["distance"] is None else x["distance"]
        )

    elif sort == "rating":
        result = sorted(result, key=lambda x: x["rating"], reverse=True)

    elif sort == "newest":
        result = sorted(result, key=lambda x: x["created_at"], reverse=True)

    elif sort == "price_low":
        result = sorted(result, key=lambda x: x["price"])

    elif sort == "price_high":
        result = sorted(result, key=lambda x: x["price"], reverse=True)

    elif sort == "name":
        result = sorted(result, key=lambda x: x["title"].lower())

    return Response(result)

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

    data = Notification.objects.filter(user=request.user)

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

    #GET
    if request.method == 'GET':

        if request.user.role == 'customer':
            bookings_qs = Booking.objects.filter(
                customer=request.user
            ).select_related('service', 'service__worker', 'customer')
        else:
            bookings_qs = Booking.objects.filter(
                service__worker=request.user
            ).select_related('service', 'service__worker', 'customer')

        serializer = BookingSerializer(
            bookings_qs,
            many=True,
            context={"request": request}
        )
        return Response(serializer.data)


    # POST 
    if request.method == 'POST':

        if request.user.role != 'customer':
            return Response({"error": "Only customers can book"}, status=403)

        service_id = request.data.get('service_id') or request.data.get('service')

        if not service_id:
            return Response({"error": "service_id is required"}, status=400)

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

        serializer = BookingSerializer(
            booking,
            context={"request": request}
        )

        return Response(serializer.data, status=201)


# UPDATE BOOKING
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

    serializer = BookingSerializer(
        booking,
        context={"request": request}
    )
    return Response(serializer.data)

#Delete Booking
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_booking(request, id):

    booking = get_object_or_404(Booking, id=id)

    if booking.customer != request.user:
        return Response({"error": "Not allowed"}, status=403)

    if booking.status == 'accepted':
        return Response({"error": "Cannot delete accepted booking"}, status=400)

    booking.delete()

    return Response({"message": "Booking deleted successfully"}, status=200)

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
                "id": r.id,
                "rating": r.rating,
                "review": r.review,
                "customer_id": r.customer.id if r.customer else None,
                "customer_name": r.customer.username if r.customer else "Anonymous",
                "created_at": r.created_at
            } for r in ratings
        ]
    })

@api_view(['GET'])
def categories(request):
    categories = (
        Service.objects
        .exclude(category__isnull=True)
        .exclude(category__exact='')
        .values_list('category', flat=True)
        .distinct()
        .order_by('category')
    )
    return Response(categories)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def worker_dashboard(request):

    user = request.user

    if user.role != "worker":
        return Response({"error": "Only workers can access dashboard"}, status=403)
    services = Service.objects.filter(worker=user)

    total_services = services.count()

    bookings = Booking.objects.filter(service__worker=user)
    active_bookings = bookings.filter(status__in=["pending", "accepted"]).count()
    completed_bookings = bookings.filter(status="completed").count()

    total_earnings = bookings.filter(status="completed").aggregate(
        total=Sum("service__price")
    )["total"] or 0

    ratings_qs = Rating.objects.filter(worker=user)

    rating_data = ratings_qs.aggregate(
        avg_rating=Avg("rating"),
        total_ratings=Count("id")
    )

    return Response({
        "username": user.username,
        "rating": rating_data["avg_rating"] or 0,
        "total_ratings": rating_data.get("total_ratings", 0),
        "total_earnings": total_earnings,
        "active_bookings": active_bookings,
        "completed_bookings": completed_bookings,
        "total_services": total_services,
    })

# ... (existing views) ...

@api_view(['POST'])
def ai_guide(request):
    user_prompt = request.data.get('user_prompt')
    if not user_prompt:
        return Response({"status": "error", "message": "user_prompt is required"}, status=400)

    try:
        # Assumes GEMINI_API_KEY is available in your environment variables
        genai.configure(api_key=os.environ.get("GEMINI_API_KEY", ""))
        model = genai.GenerativeModel('gemini-1.5-pro')

        system_instruction = "You are an expert DIY repair assistant. The user will provide a household or electronic issue. You must respond strictly with a step-by-step checklist to fix the problem safely. Use Markdown bullet points or numbered lists. Do NOT include long conversational introductions or conclusions. If the fix is highly dangerous (like high-voltage electrical work), make step 1 a strong warning."
        final_prompt = system_instruction + "\n\nUser Issue: " + user_prompt

        response = model.generate_content(final_prompt)
        
        return Response({
            "status": "success", 
            "guide": response.text
        })
    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=500)

