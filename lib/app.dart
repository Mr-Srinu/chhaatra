import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/screens/signin_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/jobs/presentation/screens/job_screen.dart';
import 'features/practice/presentation/screens/practice_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Chhaatra',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.textPrimary,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const MyHomePage(title: "Chhaatra"),
        '/splash': (context) => const SplashScreen(),
        '/homeScreen': (context) => const HomeScreen(),
        '/problem': (context) => const PracticeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signin': (context) => const SigninScreen(),
        '/jobs': (context) => const JobScreen(),
      },
      initialRoute: '/splash',
    );
  }
}
