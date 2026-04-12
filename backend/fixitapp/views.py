from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Avg
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken

from .models import JobRequest, Notification, Booking, Rating, Service,User
from .serializers import JobRequestSerializer, NotificationSerializer, BookingSerializer, RatingSerializer,RegisterSerializer,ServiceSerializer
from .utils import match_services,is_match
from datetime import timedelta
from django.utils import timezone
from django.db.models import Q


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




# =========================
# REGISTER
# =========================
@api_view(['POST'])
def register(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({"message": "User created successfully"})
    return Response(serializer.errors, status=400)


# =========================
# LOGIN
# =========================
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


# =========================
# PROFILE
# =========================
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    user = request.user

    return Response({
        "id": user.id,
        "username": user.username,
        "role": user.role,
        "created_at": user.created_at
    })


def is_spam(user, title, category):
    last_service = Service.objects.filter(worker=user, category=category).order_by('-created_at').first()

    if last_service:
        if timezone.now() - last_service.created_at < timedelta(hours=12):
            return True

        if title.lower() in last_service.title.lower() or last_service.title.lower() in title.lower():
            return True

    return False

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_service(request):
    user = request.user

    # 🔒 Only worker can post
    if user.role != 'worker':
        return Response({"error": "Only workers can post services"}, status=403)

    title = request.data.get('title')
    category = request.data.get('category')

    # 🚫 Anti-spam check
    if is_spam(user, title, category):
        return Response({
            "error": "You already posted this service. Please edit your existing one."
        }, status=400)

    serializer = ServiceSerializer(data=request.data)

    if serializer.is_valid():
        # ✅ SAVE SERVICE
        service = serializer.save(worker=user)

        # 🔥 ADD THIS (DO NOT REMOVE ANYTHING ABOVE)
        match_requests(service)

        return Response(serializer.data)

    return Response(serializer.errors, status=400)

@api_view(['GET'])
def get_services(request):
    services = Service.objects.all()

    # search
    search = request.GET.get('search')
    if search:
        services = services.filter(
            Q(title__icontains=search) |
            Q(description__icontains=search)
        )

    # category
    category = request.GET.get('category')
    if category:
        services = services.filter(category=category)

    # price
    min_price = request.GET.get('min_price')
    max_price = request.GET.get('max_price')

    if min_price:
        services = services.filter(price__gte=min_price)
    if max_price:
        services = services.filter(price__lte=max_price)

    #  rating
    rating = request.GET.get('rating')
    if rating:
        services = services.filter(rating__gte=rating)

    # date
    date = request.GET.get('date')
    if date == "today":
        from datetime import date as d
        services = services.filter(created_at__date=d.today())
    elif date == "this_week":
        from datetime import timedelta
        services = services.filter(created_at__gte=timezone.now() - timedelta(days=7))

    # location
    lat = request.GET.get('lat')
    lng = request.GET.get('lng')
    radius = request.GET.get('radius')

    result = []
    for service in services:
        data = ServiceSerializer(service).data

        if lat and lng:
            distance = calculate_distance(
                float(lat), float(lng),
                service.latitude, service.longitude
            )
            data['distance'] = round(distance, 2)

            if radius and distance > float(radius):
                continue
        else:
            data['distance'] = None

        result.append(data)

    # sorting
    sort = request.GET.get('sort')
    if sort == "distance":
        result.sort(key=lambda x: x['distance'] if x['distance'] else 999)
    elif sort == "rating":
        result.sort(key=lambda x: x['rating'], reverse=True)
    elif sort == "newest":
        result.sort(key=lambda x: x['created_at'], reverse=True)

    return Response(result)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_request(request):
    user = request.user

    if user.role != 'customer':
        return Response({"error": "Only customers can post requests"}, status=403)

    serializer = JobRequestSerializer(data=request.data)

    if serializer.is_valid():
        serializer.save(customer=user)
        return Response(serializer.data)

    return Response(serializer.errors, status=400)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_requests(request):
    user = request.user

    if user.role == 'customer':
        requests = JobRequest.objects.filter(customer=user)
    else:
        requests = JobRequest.objects.all()

    serializer = JobRequestSerializer(requests, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_notifications(request):
    notifications = Notification.objects.filter(user=request.user)

    data = []
    for n in notifications:
        data.append({
            "id": n.id,
            "message": n.message,
            "service_id": n.service.id,
            "created_at": n.created_at,
            "is_read": n.is_read
        })

    return Response(data)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def mark_notification(request, id):
    try:
        n = Notification.objects.get(id=id, user=request.user)
        n.is_read = True
        n.save()
        return Response({"message": "Updated"})
    except:
        return Response({"error": "Not found"}, status=404)