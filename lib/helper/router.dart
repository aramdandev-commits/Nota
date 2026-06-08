import 'package:go_router/go_router.dart';
import 'package:nota/screens/auth/accountcreated_screen.dart';
import 'package:nota/screens/auth/auth_screen.dart';
import 'package:nota/screens/auth/resetpassword_screen.dart';
import 'package:nota/screens/start/splashScreen.dart';
import '../screens/start/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/note/new_note_screen.dart';
import '../screens/AI/ai_analyze_screen.dart';
import '../screens/pdf/import_pdf_screen.dart';
import '../screens/note/notes_screen.dart';
import '../screens/spa/spaces_screen.dart';
import 'package:provider/provider.dart';
import '../controllers/note_provider.dart';
import '../model/note_model.dart';
import '../screens/settings/settings_screen.dart';
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
          final extra = state.extra;
          NoteModel? note;
          
          if (extra is String) {
            try {
              note = Provider.of<NoteProvider>(context, listen: false)
                  .notes
                  .firstWhere((n) => n.id == extra);
            } catch (_) {}
          } else if (extra is NoteModel) {
            note = extra;
          }
          
          return NewNoteScreen(note: note);
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
        path: '/notes',
        builder: (context, state) => const NotesScreen(),
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
