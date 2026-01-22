import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/phone_login_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  // Delivery Boy App Routes
  static const String initial = '/';
  static const String splash = '/splash';
  static const String phoneLogin = '/phone-login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    phoneLogin: (context) => const PhoneLoginScreen(),
    home: (context) => const HomeScreen(),
  };
}
