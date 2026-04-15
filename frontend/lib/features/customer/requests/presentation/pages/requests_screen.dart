import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/requests_bloc.dart';
import '../bloc/requests_event.dart';
import '../bloc/requests_state.dart';
import '../../../home/presentation/widgets/bottom_nav.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RequestsBloc()..add(LoadRequests()),
      child: const RequestsView(),
    );
  }
}

class RequestsView extends StatelessWidget {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-service'),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<RequestsBloc, RequestsState>(
        builder: (context, state) {
          if (state is RequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RequestsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<RequestsBloc>().add(LoadRequests()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is RequestsLoaded) {
            if (state.requests.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No Requests Yet",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("Create a request to get offers from workers"),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return Card(
                  child: ListTile(
                    title: Text(request.toString()), // Replace with proper request model
                    subtitle: const Text("Request details"),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}