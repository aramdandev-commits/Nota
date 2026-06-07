import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/l10n/app_localizations.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/settings/settings_tile.dart';
import '../../widgets/settings/settings_card.dart';
import '../../widgets/settings/section_title.dart';
import '../../widgets/settings/user_card.dart';
import '../../widgets/home/bottom_navigation.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_provider.dart';
import '../../controllers/locale_provider.dart';
import '../../controllers/auth_provider.dart';

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
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 28),
              ),

              const SizedBox(height: 24),

              /// 👤 User Card
              const UserCard(),

              const SizedBox(height: 32),

              /// ⚙️ Preferences
              SectionTitle(AppLocalizations.of(context)!.preferences),
              const SizedBox(height: 16),

              SettingsCard(children: [
                GestureDetector(
                  onTap: () => context.read<LocaleProvider>().toggleLocale(),
                  child: SettingsTile(
                    icon: Icons.language,
                    iconBgColor: Colors.blue.withValues(alpha: 0.15),
                    iconColor: Colors.blue,
                    title: AppLocalizations.of(context)!.language,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        localeProvider.isArabic ? 'العربية' : 'English',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(indent: 60),
                GestureDetector(
                  onTap: () {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                  child: SettingsTile(
                    icon: themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    iconBgColor: Colors.purple.withOpacity(0.15),
                    iconColor: Colors.purple,
                    title: AppLocalizations.of(context)!.appearance,
                    trailing: Text(
                      themeProvider.isDarkMode
                          ? AppLocalizations.of(context)!.dark
                          : AppLocalizations.of(context)!.light,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 32),

              /// 🔔 Notifications
              SectionTitle(AppLocalizations.of(context)!.notifications),
              const SizedBox(height: 16),

              SettingsCard(children: [
                SettingsTile(
                  icon: Icons.notifications,
                  iconBgColor: Colors.purple.withOpacity(0.15),
                  iconColor: Colors.purple,
                  title: AppLocalizations.of(context)!.emailNotifications,
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
                  title: AppLocalizations.of(context)!.pushNotifications,
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
              SectionTitle(AppLocalizations.of(context)!.security),
              const SizedBox(height: 16),

              SettingsCard(children: [
                SettingsTile(
                  icon: Icons.security,
                  iconBgColor: Colors.green.withOpacity(0.15),
                  iconColor: Colors.green,
                  title: AppLocalizations.of(context)!.twoFactorAuthentication,
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

              const SizedBox(height: 32),

              /// 🚪 Logout
              GestureDetector(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text(
                        AppLocalizations.of(context)!.logout,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.logoutConfirm,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(color: Color(0xFF9810FA))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(AppLocalizations.of(context)!.logout,
                              style: const TextStyle(color: Color(0xFFDB2777))),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/auth');
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDB2777).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFDB2777).withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: Color(0xFFDB2777), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.logout,
                        style: const TextStyle(
                          color: Color(0xFFDB2777),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
