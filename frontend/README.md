# FixIT – Flutter Frontend

The mobile frontend for the FixIT service marketplace, built with Flutter/Dart.

## Structure

```
lib/
├── app/            # App entry point & theme (AppTheme, light/dark)
├── core/
│   ├── network/    # ApiClient (Dio-based HTTP client)
│   ├── router/     # AppRouter (named route navigation)
│   ├── theme/      # ThemeBloc, theme switching
│   └── utils/      # Shared utilities
├── features/       # Feature-first architecture
│   ├── auth/           # Login, register, onboarding
│   ├── bookings/        # Customer booking list & management
│   ├── customer/
│   │   ├── ai_guide/    # AI-powered DIY fix guide screen
│   │   ├── home/        # Customer home screen & service feed
│   │   ├── profile/     # Customer profile
│   │   ├── requests/    # Job requests
│   │   └── service_detail/ # Service detail & booking flow
│   ├── notifications/   # Notification centre
│   ├── ratings/         # Worker rating page
│   ├── search/          # Enhanced search screen
│   ├── settings/        # App settings
│   └── worker/          # Worker dashboard, bookings, profile, notifications
└── shared/
    └── widgets/    # Shared UI components (BottomNav, maps, etc.)
```

## Running the App

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test
```
