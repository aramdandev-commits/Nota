import 'package:go_router/go_router.dart';
import 'package:nota/screens/accountcreated_screen.dart';
import 'package:nota/screens/auth_screen.dart';
import 'package:nota/screens/resetpassword_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/new_note_screen.dart';
import '../screens/ai_analyze_screen.dart';
import '../screens/import_pdf_screen.dart';
import '../screens/collaborate_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/ai_screen.dart';
import '../screens/spaces_screen.dart';
import '../screens/settings_screen.dart';

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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            OnboardingScreen(), // Keep exactly as it was
      ),
      GoRoute(
        path: '/new-note',
        builder: (context, state) {
          final noteId = state.extra as String?;
          return NewNoteScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/ai-analyze',
        builder: (context, state) => const AIAnalyzeScreen(),
      ),
      GoRoute(
        path: '/import-pdf',
        builder: (context, state) => const ImportPDFScreen(),
      ),
      GoRoute(
        path: '/collaborate',
        builder: (context, state) => const CollaborateScreen(),
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AIScreen(),
      ),
      GoRoute(
        path: '/spaces',
        builder: (context, state) => const SpacesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/account-created',
        builder: (context, state) => const AccountCreatedScreen(),
      ),
    ],
  );
}
