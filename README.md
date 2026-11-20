

# FixIT – Smart Local Service Marketplace

<p align="center">
	<img src="frontend/assets/splash-screen.png" alt="FixIT Splash Screen" width="250" />
</p>

![Status](https://img.shields.io/badge/status-In%20Development-blue)
**Last Updated:** November 2026

---

## 🚀 Overview

FixIT is a smart, full-stack local service marketplace platform that connects customers with local service providers. It includes a DIY AI repair guide, a complete booking lifecycle, smart search, and role-based dashboards for both customers and workers.

- **Flutter Frontend:** Feature-rich mobile app (Android/iOS)
- **Django Backend:** Secure REST API with JWT authentication, powered by OpenRouter AI

---

## 🎯 Key Features

### Customer Side
- **Authentication:** JWT-based register/login, role-based navigation
- **Service Marketplace:** Browse, search, filter, and book services
- **AI Guide:** Ask an AI assistant for step-by-step DIY fix instructions (powered by OpenRouter)
- **Smart Job Requests:** Post requests for services not yet listed
- **Booking System:** Full booking lifecycle with status tracking and cancellation
- **Rating System:** Rate and review workers after a completed job
- **Real-Time Notifications:** Service and booking alerts
- **Profile Management:** View and edit customer profile
- **Google Maps Integration:** Visual location pins on service cards

### Worker Side
- **Worker Dashboard:** Stats overview (earnings, bookings, ratings)
- **My Services:** Create and manage offered services
- **Booking Management:** Accept/reject incoming bookings
- **Notifications:** Job request and booking alerts
- **Worker Profile & Ratings:** Public-facing profile with reviews

### General
- **Enhanced Search:** Fuzzy search with suggestions (RapidFuzz)
- **Theme System:** Light/dark mode toggle
- **Responsive Design:** Adapts to all screen sizes

---

## 🏗️ Architecture

```
FixIT/
├── backend/                  # Django REST API
│   ├── manage.py
│   ├── requirements.txt
│   ├── .env.example          # Copy to .env and fill in secrets
│   ├── config/               # Django settings & root URL config
│   │   ├── settings.py
│   │   └── urls.py
│   └── fixitapp/             # Main Django app
│       ├── models.py
│       ├── views.py
│       ├── serializers.py
│       └── urls.py
└── frontend/                 # Flutter app
    ├── lib/
    │   ├── app/              # App entry & theme
    │   ├── core/             # Router, network client, utils
    │   ├── features/         # Feature modules (auth, bookings, search, etc.)
    │   └── shared/           # Shared widgets
    └── pubspec.yaml
```

---

## ⚙️ Environment Setup

### Backend — `.env` file

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env   # Linux/macOS
copy .env.example .env  # Windows
```

Required variables:

```env
SECRET_KEY=your-django-secret-key
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=your_db_host
DB_PORT=5432

OPENROUTER_API_KEY=your_openrouter_api_key   # Get one free at openrouter.ai
```

> **Render deployment:** Set all these as Environment Variables in your Render service dashboard instead of a `.env` file.

---

## 🚀 Quick Start

### 1. Backend (Django)

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate        # Windows
# source .venv/bin/activate   # macOS/Linux
pip install -r requirements.txt
cp .env.example .env          # then fill in your values
python manage.py migrate
python manage.py runserver
```

### 2. Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

---

## 🌐 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `auth/register/` | Register a new user |
| POST | `auth/login/` | Login and get JWT tokens |
| GET/PUT | `auth/profile/` | Get or update profile |
| POST | `auth/forgot-password/` | Request password reset |
| GET/POST | `services/` | List or create services |
| GET/PUT/DELETE | `services/<id>/` | Get, update, or delete a service |
| GET | `my-services/` | Worker's own services |
| GET | `search/` | Smart fuzzy search |
| GET/POST | `requests/` | List or create job requests |
| GET/POST | `bookings/` | List or create bookings |
| PATCH | `bookings/<id>/` | Update booking status |
| DELETE | `booking/delete/<id>/` | Cancel a booking |
| POST | `ratings/` | Submit a worker rating |
| GET | `ratings/<worker_id>/` | Get ratings for a worker |
| GET | `categories/` | List service categories |
| GET | `notifications/` | List notifications |
| PATCH | `notifications/<id>/` | Mark notification as read |
| GET | `worker/dashboard/` | Worker stats |
| POST | `ai-guide/` | Get AI-generated DIY fix steps |

---

## 🧪 Testing

```bash
# Backend
cd backend && python manage.py test

# Frontend
cd frontend && flutter test
```

---

## 🏆 Status

| Area | Completion | Notes |
|------|-----------|-------|
| Frontend | ~95% | All critical screens implemented |
| Backend | ~95% | All critical endpoints live |
| Integration | 100% | Real API calls, no mock data |
| AI Guide | ✅ | Powered by OpenRouter (gpt-4o-mini) |
| Maps | ✅ | Google Maps on service/location cards |

---

## ❓ FAQ

**Q: How do I report a bug or request a feature?**
A: Please open an issue or pull request in the repository.

**Q: What AI model powers the AI Guide?**
A: `openai/gpt-4o-mini` via OpenRouter. You can swap the model in `backend/fixitapp/views.py`.

**Q: What platforms are supported?**
A: Android and iOS (primary). Flutter also supports Web, Windows, macOS, and Linux.

**Q: How do I reset the backend database?**
A: Run `python manage.py flush` in the backend directory (deletes all data).

---

## 🙏 Credits

- **Frontend:** Flutter / Dart
- **Backend:** Django / Python / Django REST Framework
- **AI:** OpenRouter API
- **Search:** RapidFuzz

