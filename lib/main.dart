import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newstudent/ui/screens/auth/auth.dart';
import 'package:newstudent/utils/Setting.dart';
import 'ui/screens/auth/pages/login_page.dart';
import 'ui/screens/auth/pages/signup_page.dart';
import 'ui/screens/splash/splash.dart';
import 'ui/screens/home/home.dart';
import 'ui/screens/home/pages/news/news_detail_page.dart';
import 'ui/screens/home/pages/my_publications/my_publications_page.dart';
import 'ui/screens/home/pages/programs/programs_page.dart';
import 'utils/const/colors/colors.dart';

void main() async {
  await Setting.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CCC Étudiants',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashUI()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/auth', page: () => const AuthUI()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/home', page: () => const HomeUI()),
        GetPage(name: '/news/detail', page: () => const NewsDetailPage()),
        GetPage(
          name: '/my-publications',
          page: () => const MyPublicationsPage(),
        ),
        GetPage(name: '/programs', page: () => const ProgramsPage()),
      ],
    );
  }
}
