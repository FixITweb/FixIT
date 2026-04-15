import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/services/presentation/bloc/services_bloc.dart';
import 'features/services/data/repositories/services_repository.dart';
import 'features/services/data/datasources/services_api.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/datasources/auth_api.dart';
import 'features/bookings/presentation/bloc/booking_bloc.dart';
import 'features/bookings/data/repositories/booking_repository.dart';
import 'features/bookings/data/datasources/booking_api.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/data/datasources/profile_api.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_bloc.dart';
import 'core/theme/theme_event.dart';
import 'core/theme/theme_state.dart';

void main() {
  runApp(const FixITApp());
}

class FixITApp extends StatelessWidget {
  const FixITApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc()..add(LoadTheme()),
        ),
        BlocProvider(
          create: (context) => ServiceBloc(
            ServiceRepository(ServiceApi(apiClient)),
          ),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            AuthRepository(AuthApi(apiClient)),
          ),
        ),
        BlocProvider(
          create: (context) => BookingBloc(
            BookingRepository(BookingApi(apiClient)),
          ),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            ProfileRepository(ProfileApi(apiClient)),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FixIT',
            theme: themeState.themeData,
            initialRoute: '/',
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}