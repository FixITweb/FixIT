import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/services_bloc.dart';
import '../bloc/services_event.dart';
import '../bloc/services_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixIT Services'),
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServiceInitial) {
            // Trigger loading when the screen is first built
            context.read<ServiceBloc>().add(LoadServices());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServiceLoaded) {
            if (state.services.isEmpty) {
              return const Center(child: Text("No services available"));
            }
            return ListView.builder(
              itemCount: state.services.length,
              itemBuilder: (context, index) {
                final s = state.services[index];
                return ListTile(
                  title: Text(s.title),
                  subtitle: Text(s.category),
                  trailing: Text("\$${s.price}"),
                );
              },
            );
          }

          if (state is ServiceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${state.message}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ServiceBloc>().add(LoadServices());
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("No data"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ServiceBloc>().add(LoadServices());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}