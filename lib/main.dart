import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/helper/router.dart';

late final GoRouter router;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  router = createRouter();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
