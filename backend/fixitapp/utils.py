from rapidfuzz import fuzz
from .models import Service, Notification
from math import radians, cos, sin, asin, sqrt


def match_services(job_request):
    services = Service.objects.all()

    for service in services:
        score = fuzz.partial_ratio(
            job_request.title.lower(),
            service.title.lower()
        )

        if score > 70:
            Notification.objects.create(
                user=job_request.customer,
                service=service,
                message=f"Service matching '{job_request.title}' is now available!"
            )

            job_request.status = "matched"
            job_request.save()


def calculate_distance(lat1, lng1, lat2, lng2):
    R = 6371

    dlat = radians(lat2 - lat1)
    dlng = radians(lng2 - lng1)

    a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng/2)**2
    c = 2 * asin(sqrt(a))

    return R * c


def is_match(text1, text2):
    score = fuzz.ratio(text1.lower(), text2.lower())
    return score > 60