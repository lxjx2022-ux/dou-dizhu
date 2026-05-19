import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

class DouDiZhuApp extends StatelessWidget {
  const DouDiZhuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.tableGreen,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryButton,
          secondary: AppColors.secondaryButton,
          surface: AppColors.glassBackground,
          onPrimary: AppColors.textDark,
          onSecondary: AppColors.textPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
