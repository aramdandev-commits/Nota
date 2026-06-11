import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/helper/router.dart';
import 'package:provider/provider.dart';
import 'package:nota/controllers/note_provider.dart';
import 'package:nota/controllers/spaces_provider.dart';
import 'package:nota/controllers/space_details_provider.dart';
import 'package:nota/controllers/theme_provider.dart';
import 'package:nota/controllers/locale_provider.dart';
import 'package:nota/controllers/auth_provider.dart';
import 'package:nota/controllers/notification_provider.dart';
import 'package:nota/helper/app_theme.dart';

late final GoRouter router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  router = createRouter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProxyProvider<NotificationProvider, NoteProvider>(
          create: (context) => NoteProvider(
              Provider.of<NotificationProvider>(context, listen: false)),
          update: (context, notificationProvider, previous) =>
              previous ?? NoteProvider(notificationProvider),
        ),
        ChangeNotifierProvider(create: (_) => SpacesProvider()),
        ChangeNotifierProvider(create: (_) => SpaceDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nota App',
      routerConfig: router,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'AE'),
      ],
    );
  }
}
