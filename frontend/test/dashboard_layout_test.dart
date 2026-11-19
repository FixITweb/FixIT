import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_bloc.dart';
import 'package:frontend/features/bookings/data/datasources/booking_api.dart';
import 'package:frontend/features/bookings/data/models/booking_model.dart';
import 'package:frontend/features/bookings/data/repositories/booking_repository.dart';
import 'package:frontend/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:frontend/features/bookings/presentation/bloc/booking_event.dart';
import 'package:frontend/features/bookings/presentation/pages/bookings_screen.dart';
import 'package:frontend/features/customer/ai_guide/presentation/screens/ai_guide_screen.dart';
import 'package:frontend/features/customer/home/presentation/bloc/home_bloc.dart';
import 'package:frontend/features/customer/home/presentation/bloc/home_event.dart';
import 'package:frontend/features/customer/home/presentation/pages/customer_home_screen.dart';
import 'package:frontend/features/services/data/datasources/services_api.dart';
import 'package:frontend/features/services/data/models/service_model.dart';
import 'package:frontend/features/services/data/repositories/services_repository.dart';
import 'package:frontend/features/worker/dashboard/data/datasources/worker_dashboard_api.dart';
import 'package:frontend/features/worker/dashboard/data/models/worker_dashboard_model.dart';
import 'package:frontend/features/worker/dashboard/data/repositories/worker_dashboard_repository.dart';
import 'package:frontend/features/worker/dashboard/presentation/bloc/worker_dashboard_bloc.dart';
import 'package:frontend/features/worker/dashboard/presentation/bloc/worker_dashboard_event.dart';
import 'package:frontend/features/worker/dashboard/presentation/pages/worker_dashboard_screen.dart';

class _FakeServiceRepository extends ServiceRepository {
  _FakeServiceRepository() : super(ServiceApi(ApiClient()));

  @override
  Future<List<ServiceModel>> getServices({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? rating,
    double? lat,
    double? lng,
    double? radius,
    String? date,
    String? sort,
  }) async {
    return [
      ServiceModel(
        id: 1,
        title: 'Emergency plumbing repair for a kitchen sink',
        description: 'Residential plumbing service',
        category: 'Home maintenance and plumbing',
        price: 1200,
        rating: 4.8,
        createdAt: DateTime(2026, 1, 1),
        latitude: 9.0,
        longitude: 38.0,
        distance: 2.4,
        worker: WorkerModel(
          id: 1,
          username: 'A very long worker name',
        ),
      ),
    ];
  }

  @override
  Future<List<String>> getCategories() async => ['Plumbing', 'Cleaning'];
}

class _FakeWorkerDashboardRepository extends WorkerDashboardRepository {
  _FakeWorkerDashboardRepository() : super(WorkerDashboardApi(ApiClient()));

  @override
  Future<WorkerDashboardModel> getWorkerDashboard() async {
    return WorkerDashboardModel(
      username: 'Alex',
      averageRating: 4.8,
      totalEarnings: 1800,
      bookingsCount: 2,
      completedJobs: 12,
      servicesCount: 3,
    );
  }
}

class _FakeBookingRepository extends BookingRepository {
  _FakeBookingRepository() : super(BookingApi(ApiClient()));

  @override
  Future<List<BookingModel>> getBookings() async => [];
}

void main() {
  testWidgets('customer home stays within a compact phone width',
      (tester) async {
    _setCompactPhoneSize(tester);
    final homeBloc = HomeBloc(_FakeServiceRepository())..add(LoadServices());
    final themeBloc = ThemeBloc();
    addTearDown(() async {
      await homeBloc.close();
      await themeBloc.close();
    });

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>.value(value: homeBloc),
            BlocProvider<ThemeBloc>.value(value: themeBloc),
          ],
          child: MaterialApp(
            theme: theme,
            home: const CustomerHomeView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Find Services'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Find Services')).style,
        theme.appBarTheme.titleTextStyle,
      );
      expect(find.text('Post request'), findsOneWidget);
      expect(
        find.text('Emergency plumbing repair for a kitchen sink'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('AI guide fits a compact phone with the shared primary button',
      (tester) async {
    _setCompactPhoneSize(tester);

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const AIGuideScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('AI Guide'),
        ),
        findsOneWidget,
      );
      expect(find.text('Get AI Fix Guide'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('customer bookings fits a compact phone with the shared header',
      (tester) async {
    _setCompactPhoneSize(tester);
    final bookingsBloc = BookingBloc(_FakeBookingRepository())
      ..add(LoadBookings());
    addTearDown(bookingsBloc.close);

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        BlocProvider<BookingBloc>.value(
          value: bookingsBloc,
          child: MaterialApp(
            theme: theme,
            home: const BookingsView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('No Bookings Yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('worker dashboard stays within a compact phone width',
      (tester) async {
    _setCompactPhoneSize(tester);
    final dashboardBloc = WorkerDashboardBloc(_FakeWorkerDashboardRepository())
      ..add(const LoadWorkerDashboard());
    final themeBloc = ThemeBloc();
    addTearDown(() async {
      await dashboardBloc.close();
      await themeBloc.close();
    });

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<WorkerDashboardBloc>.value(value: dashboardBloc),
            BlocProvider<ThemeBloc>.value(value: themeBloc),
          ],
          child: MaterialApp(
            theme: theme,
            home: const WorkerDashboardView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

void _setCompactPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
