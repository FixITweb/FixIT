import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/theme/theme_event.dart';
import '../../../../core/theme/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Appearance",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text("Theme"),
                      subtitle: Text(themeState.isDarkMode ? "Dark Mode" : "Light Mode"),
                      trailing: Switch(
                        value: themeState.isDarkMode,
                        onChanged: (value) {
                          context.read<ThemeBloc>().add(ToggleTheme());
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.light_mode),
                      title: const Text("Light Mode"),
                      trailing: themeState.isDarkMode ? null : const Icon(Icons.check, color: Colors.teal),
                      onTap: () {
                        if (themeState.isDarkMode) {
                          context.read<ThemeBloc>().add(SetLightTheme());
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text("Dark Mode"),
                      trailing: themeState.isDarkMode ? const Icon(Icons.check, color: Colors.teal) : null,
                      onTap: () {
                        if (!themeState.isDarkMode) {
                          context.read<ThemeBloc>().add(SetDarkTheme());
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "General",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text("Notifications"),
                      subtitle: const Text("Manage notification preferences"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to notification settings
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text("Language"),
                      subtitle: const Text("English"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to language settings
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text("Privacy"),
                      subtitle: const Text("Privacy and security settings"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to privacy settings
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "About",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text("App Version"),
                      subtitle: const Text("1.0.0"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Show app info
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text("Help & Support"),
                      subtitle: const Text("Get help and contact support"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to help
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text("Terms & Conditions"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Show terms
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}