import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/helper/router.dart';
import 'package:provider/provider.dart';
import 'package:nota/controllers/note_provider.dart';
import 'package:nota/controllers/spaces_provider.dart';
import 'package:nota/controllers/space_details_provider.dart';
import 'package:nota/controllers/theme_provider.dart';
import 'package:nota/helper/app_theme.dart';

late final GoRouter router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  router = createRouter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => SpacesProvider()),
        ChangeNotifierProvider(create: (_) => SpaceDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nota App',
      routerConfig: router,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
