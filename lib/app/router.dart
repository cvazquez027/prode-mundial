import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/auth_repository.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/payment/inscription_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final user = userState.valueOrNull;
      final location = state.matchedLocation;

      // No logueado → login
      if (!isLoggedIn) {
        return location == '/login' ? null : '/login';
      }

      // Logueado pero datos cargando → esperar
      if (user == null) return null;

      // Logueado, no pagó → inscripción
      if (!user.isPaid && location != '/inscription') {
        return '/inscription';
      }

      // Logueado, pagó, quiere ir a login o inscripción → home
      if (user.isPaid && (location == '/login' || location == '/inscription')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/inscription',
        builder: (context, state) => const InscriptionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
