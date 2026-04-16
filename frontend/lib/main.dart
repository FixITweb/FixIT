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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authApi = AuthApi(apiClient);

  try {
    
    final registerRes = await authApi.register(
      "john",       // change if you want
      "123456",     // change if you want
      "worker",     // or "customer"
    );

    print("REGISTER SUCCESS: $registerRes");

   
    final loginRes = await authApi.login("john", "123456");

    print("LOGIN SUCCESS: $loginRes");


    final token = await apiClient.getToken();
    print("TOKEN SAVED: $token");

    // 👤 TEST PROTECTED API
    final profile = await authApi.getProfile();
    print("PROFILE: $profile");

  } catch (e) {
    print("ERROR: $e");
  }

  runApp(FixITApp(apiClient: apiClient));
}

class FixITApp extends StatelessWidget {
  final ApiClient apiClient;

  const FixITApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
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