from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from .models import Booking, JobRequest, Service


class BookingRequestStatusTests(APITestCase):
    def setUp(self):
        user_model = get_user_model()
        self.customer = user_model.objects.create_user(
            username="customer",
            password="test-password",
            role="customer",
        )
        self.worker = user_model.objects.create_user(
            username="worker",
            password="test-password",
            role="worker",
        )
        self.service = Service.objects.create(
            worker=self.worker,
            title="Plumbing repair",
            description="Home plumbing service",
            category="Plumbing",
            price=50,
            latitude=9.0,
            longitude=38.0,
        )
        self.client.force_authenticate(user=self.customer)

    def create_request(self, customer, title, category):
        return JobRequest.objects.create(
            customer=customer,
            title=title,
            description="Please help",
            category=category,
            budget=100,
        )

    def test_booking_matches_the_best_relevant_customer_request(self):
        matching_request = self.create_request(
            self.customer, "Repair a leaking sink", "Plumbing"
        )
        other_request = self.create_request(
            self.customer, "Install a new light", "Electrical"
        )
        another_customer_request = self.create_request(
            get_user_model().objects.create_user(
                username="another-customer",
                password="test-password",
                role="customer",
            ),
            "Repair a leaking sink",
            "Plumbing",
        )

        response = self.client.post(
            "/api/bookings/",
            {"service_id": self.service.id},
            format="json",
        )

        self.assertEqual(response.status_code, 201)
        matching_request.refresh_from_db()
        other_request.refresh_from_db()
        another_customer_request.refresh_from_db()
        self.assertEqual(matching_request.status, "matched")
        self.assertEqual(other_request.status, "waiting")
        self.assertEqual(another_customer_request.status, "waiting")

    def test_unrelated_booking_does_not_change_request_status(self):
        job_request = self.create_request(
            self.customer, "Repair a leaking sink", "Plumbing"
        )
        unrelated_service = Service.objects.create(
            worker=self.worker,
            title="Yoga instruction",
            description="Fitness service",
            category="Fitness",
            price=50,
            latitude=9.0,
            longitude=38.0,
        )

        response = self.client.post(
            "/api/bookings/",
            {"service_id": unrelated_service.id},
            format="json",
        )

        self.assertEqual(response.status_code, 201)
        job_request.refresh_from_db()
        self.assertEqual(job_request.status, "waiting")

    def test_loading_requests_matches_a_previously_created_booking(self):
        job_request = self.create_request(
            self.customer, "Repair a leaking sink", "Plumbing"
        )
        Booking.objects.create(service=self.service, customer=self.customer)

        response = self.client.get("/api/requests/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data[0]["status"], "matched")
        job_request.refresh_from_db()
        self.assertEqual(job_request.status, "matched")
