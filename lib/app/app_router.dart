import 'package:flutter/material.dart';
import '../navigation/route_names.dart';
import '../navigation/main_navigation_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../core/widgets/error_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.mainNavigation:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case RouteNames.wardrobe:
        // Placeholder or actual depending on project
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text("Wardrobe"))),
        );
      // Add other routes here as they are implemented
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: ErrorView(
              message: 'Route not found: ${settings.name}',
              onRetry: () {},
            ),
          ),
        );
    }
  }
}
