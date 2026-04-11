from rapidfuzz import fuzz
from .models import Service, Notification


def match_services(job_request):

    services = Service.objects.all()

    for service in services:

        score = fuzz.partial_ratio(
            job_request.title.lower(),
            service.title.lower()
        )

        # similarity threshold
        if score > 70:
            Notification.objects.create(
                user=service.provider,
                message=f"New job matches your service: {job_request.title}"
            )

            job_request.status = "matched"
            job_request.save()