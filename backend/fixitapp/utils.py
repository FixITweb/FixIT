from rapidfuzz import fuzz
from .models import Service, Notification, JobRequest
from math import radians, cos, sin, asin, sqrt



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