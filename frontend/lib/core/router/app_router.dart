import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/customer/home/presentation/pages/customer_home_screen.dart';
import '../../features/customer/service_detail/presentation/pages/service_detail_screen.dart';
import '../../features/customer/create_request/presentation/pages/create_request_screen.dart';
import '../../features/customer/requests/presentation/pages/requests_screen.dart';
import '../../features/search/presentation/pages/enhanced_search_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/bookings/presentation/pages/bookings_screen.dart';
import '../../features/customer/profile/presentation/pages/profile_screen.dart';
import '../../features/worker/onboarding/presentation/pages/worker_onboarding_screen.dart';
import '../../features/worker/onboarding/presentation/pages/worker_profession_setup_screen.dart';
import '../../features/worker/dashboard/presentation/pages/worker_dashboard_screen.dart';
import '../../features/worker/services/presentation/pages/worker_services_screen.dart';
import '../../features/worker/bookings/presentation/pages/worker_bookings_screen.dart';
import '../../features/worker/notifications/presentation/pages/worker_notifications_screen.dart';
import '../../features/worker/profile/presentation/pages/worker_profile_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/customer-home':
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case '/service-detail':
        final serviceId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(serviceId: serviceId),
        );
      case '/create-service':
        return MaterialPageRoute(builder: (_) => const CreateRequestScreen());
      case '/create-request':
        return MaterialPageRoute(builder: (_) => const CreateRequestScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const EnhancedSearchScreen());
      case '/requests':
        return MaterialPageRoute(builder: (_) => const RequestsScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/bookings':
        return MaterialPageRoute(builder: (_) => const BookingsScreen());
      case '/customer-profile':
        return MaterialPageRoute(builder: (_) => const CustomerProfileScreen());
      case '/worker-onboarding':
        return MaterialPageRoute(builder: (_) => const WorkerOnboardingScreen());
      case '/worker-profession-setup':
        return MaterialPageRoute(builder: (_) => const WorkerProfessionSetupScreen());
      case '/worker-dashboard':
        return MaterialPageRoute(builder: (_) => const WorkerDashboardScreen());
      case '/worker-services':
        return MaterialPageRoute(builder: (_) => const WorkerServicesScreen());
      case '/worker-bookings':
        return MaterialPageRoute(builder: (_) => const WorkerBookingsScreen());
      case '/worker-notifications':
        return MaterialPageRoute(builder: (_) => const WorkerNotificationsScreen());
      case '/worker-profile':
        return MaterialPageRoute(builder: (_) => const WorkerProfileScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}