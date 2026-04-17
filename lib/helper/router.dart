import 'package:go_router/go_router.dart';
import 'package:nota/screens/next.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splashScreen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
    ],
  );
}
