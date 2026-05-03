import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/helper/router.dart';
import 'package:provider/provider.dart';
import 'package:nota/controllers/note_provider.dart';

late final GoRouter router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  router = createRouter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nota App',
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        canvasColor: const Color(0xFF0F111A),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
