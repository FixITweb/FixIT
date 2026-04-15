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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String loginAs = 'customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate based on role
            if (state.role == 'worker') {
              Navigator.pushReplacementNamed(context, '/worker-dashboard');
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
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.build, size: 90, color: Color(0xFF14B8A6)),
                const Text(
                  "FixIT",
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
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
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Username/Email",
                    hintText: "Try 'customer@test.com' or 'worker@test.com'",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Any password works for demo",
                  ),
                ),
                const SizedBox(height: 40),
                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        LoginEvent(
                          emailController.text.isEmpty 
                            ? '$loginAs@test.com' 
                            : emailController.text,
                          passwordController.text.isEmpty 
                            ? 'demo123' 
                            : passwordController.text,
                        ),
                      );
                    },
                    child: const Text("Login", style: TextStyle(fontSize: 18)),
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}