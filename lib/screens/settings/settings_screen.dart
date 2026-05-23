import 'package:flutter/material.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/settings/settings_tile.dart';
import '../../widgets/settings/settings_card.dart';
import '../../widgets/settings/section_title.dart';
import '../../widgets/settings/user_card.dart';
import '../../widgets/home/bottom_navigation.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final controller = SettingsController();

  @override
  void initState() {
    super.initState();
    controller.fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 28),
              ),

              const SizedBox(height: 24),

              /// 👤 User Card
              const UserCard(),

              const SizedBox(height: 32),

              /// ⚙️ Preferences
              const SectionTitle('PREFERENCES'),
              const SizedBox(height: 16),

              SettingsCard(children: [
                SettingsTile(
                  icon: Icons.language,
                  iconBgColor: Colors.blue.withOpacity(0.15),
                  iconColor: Colors.blue,
                  title: 'Language',
                  trailing: Text(
                    settings.language,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
                const Divider(indent: 60),
                GestureDetector(
                  onTap: () {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                  child: SettingsTile(
                    icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    iconBgColor: Colors.purple.withOpacity(0.15),
                    iconColor: Colors.purple,
                    title: 'Appearance',
                    trailing: Text(
                      themeProvider.isDarkMode ? 'Dark Theme' : 'Light Theme',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 32),

              /// 🔔 Notifications
              const SectionTitle('NOTIFICATIONS'),
              const SizedBox(height: 16),

              SettingsCard(children: [
                SettingsTile(
                  icon: Icons.notifications,
                  iconBgColor: Colors.purple.withOpacity(0.15),
                  iconColor: Colors.purple,
                  title: 'Email Notifications',
                  trailing: Switch(
                    value: settings.emailNotifications,
                    onChanged: (val) {
                      setState(() {
                        settings.emailNotifications = val;
                      });
                      controller.updateSettings(settings);
                    },
                  ),
                ),
                const Divider(indent: 60),
                SettingsTile(
                  icon: Icons.notifications_active,
                  iconBgColor: Colors.pink.withOpacity(0.15),
                  iconColor: Colors.pink,
                  title: 'Push Notifications',
                  trailing: Switch(
                    value: settings.pushNotifications,
                    onChanged: (val) {
                      setState(() {
                        settings.pushNotifications = val;
                      });
                      controller.updateSettings(settings);
                    },
                  ),
                ),
              ]),

              const SizedBox(height: 32),

              /// 🔐 Security
              const SectionTitle('SECURITY'),
              const SizedBox(height: 16),

              SettingsCard(children: [
                SettingsTile(
                  icon: Icons.security,
                  iconBgColor: Colors.green.withOpacity(0.15),
                  iconColor: Colors.green,
                  title: '2FA Authentication',
                  trailing: Switch(
                    value: settings.is2FAEnabled,
                    onChanged: (val) {
                      setState(() {
                        settings.is2FAEnabled = val;
                      });
                      controller.updateSettings(settings);
                    },
                  ),
                ),
              ]),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      /// 🔻 Bottom Navigation (الموحد)
      bottomNavigationBar: const BottomNavigation(selectedIndex: 4),
    );
  }
}
