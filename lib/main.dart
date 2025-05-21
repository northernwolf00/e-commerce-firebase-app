import 'package:flutter/material.dart';
import 'package:grocery/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/on_generate_route.dart';
import 'core/themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce',
      theme: AppTheme.defaultTheme,
      onGenerateRoute: RouteGenerator.onGenerate,
      home: const AuthChecker(), // Determines the initial route dynamically
    );
  }
}


class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Show loading indicator
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.hasData) {
            Navigator.pushReplacementNamed(context, AppRoutes.entryPoint); // User logged in
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding); // User not logged in
          }
        });

        // Return an empty container while navigation is happening
        return const SizedBox.shrink();
      },
    );
  }

  Future<User?> _getInitialRoute() async {
    return FirebaseAuth.instance.currentUser; // Check if user is logged in
  }
}
