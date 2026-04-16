from rapidfuzz import fuzz
from .models import Service, Notification, JobRequest
from math import radians, cos, sin, asin, sqrt

def match_services(obj):

    if isinstance(obj, JobRequest):

        services = Service.objects.filter(
            category__iexact=obj.category.strip()
        )

        matched = False

        for service in services:

            score = max(
                fuzz.token_set_ratio(obj.title.lower(), service.title.lower()),
                fuzz.token_set_ratio(obj.category.lower(), service.category.lower())
            )

            category_match = (
                obj.category.strip().lower() ==
                service.category.strip().lower()
            )

            if (category_match and score > 60) or score > 80:

                exists = Notification.objects.filter(
                    user=obj.customer,
                    service=service,
                    message__icontains=obj.title
                ).exists()

                if not exists:
                    Notification.objects.create(
                        user=obj.customer,
                        service=service,
                        message=f"Service matching '{obj.title}' is available!"
                    )

                matched = True

        if matched:
            obj.status = "matched"
            obj.save()

    else:

        requests = JobRequest.objects.filter(status="waiting")

        for req in requests:

            score = max(
                fuzz.token_set_ratio(req.title.lower(), obj.title.lower()),
                fuzz.token_set_ratio(req.category.lower(), obj.category.lower())
            )

            category_match = (
                req.category.strip().lower() ==
                obj.category.strip().lower()
            )

            if (category_match and score > 60) or score > 80:

                exists = Notification.objects.filter(
                    user=req.customer,
                    service=obj,
                    message__icontains=req.title
                ).exists()

                if not exists:
                    Notification.objects.create(
                        user=req.customer,
                        service=obj,
                        message=f"Service matching '{req.title}' is available!"
                    )

                req.status = "matched"
                req.save()

def calculate_distance(lat1, lng1, lat2, lng2):
    R = 6371

    dlat = radians(lat2 - lat1)
    dlng = radians(lng2 - lng1)

    a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng/2)**2
    c = 2 * asin(sqrt(a))

    return R * c


def is_match(query, text):
    query = query.lower()
    text = text.lower()

    return (
        query in text or
        fuzz.partial_ratio(query, text) > 70 or
        fuzz.token_set_ratio(query, text) > 60
    )