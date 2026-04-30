import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String loginAs = 'customer';
  bool _isUpdatingLocation = false;

  Future<void> _showLocationSettingsDialog() async {
    if (!mounted) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location is blocked in your browser. In Microsoft Edge, click the lock icon near the address bar and allow Location for this site, then refresh.",
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Access"),
        content: const Text(
          "Please enable location services and allow permission to improve nearby service matching.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Skip"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            child: const Text("Open settings"),
          ),
        ],
      ),
    );
  }

  Future<Position?> _requestLocationAfterLogin() async {
    if (kIsWeb) {
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (_) {
        await _showLocationSettingsDialog();
        return null;
      }
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await _showLocationSettingsDialog();
      return null;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationSettingsDialog();
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _captureAndSaveLocationIfMissing() async {
    final repo = context.read<AuthBloc>().repo;
    final profile = await repo.getProfile();
    final hasLocation =
        profile['latitude'] != null && profile['longitude'] != null;

    if (hasLocation) {
      return;
    }

    if (!mounted) return;
    setState(() => _isUpdatingLocation = true);

    try {
      final position = await _requestLocationAfterLogin();
      if (position != null) {
        await repo.updateLocation(position.latitude, position.longitude);
      }
    } catch (_) {
      // Non-blocking: login navigation should continue even if location update fails.
    } finally {
      if (mounted) {
        setState(() => _isUpdatingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _captureAndSaveLocationIfMissing().whenComplete(() {
              if (!mounted) return;
              if (state.role == 'worker') {
                Navigator.pushReplacementNamed(context, '/worker-home');
              } else {
                Navigator.pushReplacementNamed(context, '/customer-home');
              }
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.build, size: 90, color: Color(0xFF14B8A6)),
                  const Text(
                    "FixIT",
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),

                  /// ROLE SWITCH
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: loginAs == 'customer'
                                ? const Color(0xFF14B8A6)
                                : Colors.grey[300],
                          ),
                          onPressed: () => setState(() => loginAs = 'customer'),
                          child: const Text("Customer"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: loginAs == 'worker'
                                ? const Color(0xFF14B8A6)
                                : Colors.grey[300],
                          ),
                          onPressed: () => setState(() => loginAs = 'worker'),
                          child: const Text("Worker"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// USERNAME (NOT EMAIL)
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      hintText: "Enter your username",
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                  ),

                  const SizedBox(height: 40),

                  if (state is AuthLoading || _isUpdatingLocation)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () {
                        final username = usernameController.text.trim();
                        final password = passwordController.text.trim();

                        if (username.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Enter username & password")),
                          );
                          return;
                        }

                        context.read<AuthBloc>().add(
                              LoginEvent(username, password),
                            );
                      },
                      child:
                          const Text("Login", style: TextStyle(fontSize: 18)),
                    ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Create Account"),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
