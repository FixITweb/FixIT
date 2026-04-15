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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FixIT',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: const Color(0xFF14B8A6),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF14B8A6)),
            ),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}