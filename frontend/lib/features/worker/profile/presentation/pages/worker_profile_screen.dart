import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker_profile_bloc.dart';
import '../bloc/worker_profile_event.dart';
import '../bloc/worker_profile_state.dart';
import '../../data/repositories/worker_profile_repository.dart';
import '../../data/datasources/worker_profile_api.dart';
import '../../../../../core/network/api_client.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';
import '../../../../../shared/widgets/theme_toggle_button.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerProfileBloc(
        WorkerProfileRepository(WorkerProfileApi(ApiClient())),
      )..add(LoadWorkerProfile()),
      child: const WorkerProfileView(),
    );
  }
}

class WorkerProfileView extends StatelessWidget {
  const WorkerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: BlocBuilder<WorkerProfileBloc, WorkerProfileState>(
        builder: (context, state) {
          if (state is WorkerProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkerProfileError) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Failed to load profile.', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      state.message.split('\n').first,
                      style: const TextStyle(color: Colors.red),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<WorkerProfileBloc>().add(LoadWorkerProfile()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is WorkerProfileLoaded) {
            final profile = state.profile;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkerProfileBloc>().add(RefreshWorkerProfile());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF14B8A6),
                        child: Text(
                          profile.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        profile.username,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "WORKER • Joined ${_formatDate(profile.createdAt)}",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Worker Stats Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Worker Statistics",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Services",
                                  profile.servicesCount.toString(),
                                  Icons.work,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Rating",
                                  profile.averageRating.toStringAsFixed(1),
                                  Icons.star,
                                  Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Bookings",
                                  profile.bookingsCount.toString(),
                                  Icons.calendar_today,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Earnings",
                                  "\$${profile.totalEarnings.toStringAsFixed(0)}",
                                  Icons.attach_money,
                                  Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Account Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Account Information",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow("Username", profile.username),
                          _buildInfoRow("Email", profile.email),
                          _buildInfoRow("Role", profile.role.toUpperCase()),
                          _buildInfoRow("Member Since", _formatDate(profile.createdAt)),
                          _buildInfoRow("Worker ID", "#${profile.id}"),
                          _buildInfoRow("Completed Jobs", profile.completedJobs.toString()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Divider(),
                  
                  // Menu Items
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text("Manage Services"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(context, '/worker-services');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("My Bookings"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(context, '/worker-bookings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Account Settings"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text("Notifications"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/worker-notifications'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text("View My Ratings"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/worker-ratings',
                        arguments: {
                          'workerId': state.profile.id,
                          'workerName': state.profile.username,
                          'averageRating': state.profile.averageRating,
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text("Help & Support"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support coming soon!')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (route) => false,
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 4),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}