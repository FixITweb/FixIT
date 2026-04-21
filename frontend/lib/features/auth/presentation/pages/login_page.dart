import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController(); 
  final passwordController = TextEditingController();
  String loginAs = 'customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            if (state.role == 'worker') {
              Navigator.pushReplacementNamed(context, '/worker-home');
            } else {
              Navigator.pushReplacementNamed(context, '/customer-home');
            }
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
                          onPressed: () =>
                              setState(() => loginAs = 'customer'),
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
                          onPressed: () =>
                              setState(() => loginAs = 'worker'),
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

                  if (state is AuthLoading)
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
                      child: const Text("Login",
                          style: TextStyle(fontSize: 18)),
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