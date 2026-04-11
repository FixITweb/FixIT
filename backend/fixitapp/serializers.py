from rest_framework import serializers
from .models import JobRequest

class JobRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = JobRequest
        fields = [
            "id",
            "title",
            "description",
            "category",
            "budget",
            "status",
            "created_at",
        ]
        read_only_fields = ['customer', 'created_at', 'updated_at']
