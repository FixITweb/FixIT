from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import JobRequest
from .serializers import JobRequestSerializer
from .utils import match_services


@api_view(["GET", "POST"])
# @permission_classes([IsAuthenticated])
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