import 'package:flutter/material.dart';
import 'package:aquanest/pages/login_page.dart';
import 'package:aquanest/pages/dashboard_page.dart';
import 'package:aquanest/pages/history_page.dart';
import 'package:aquanest/pages/riwayat_kekeruhan.dart';
import 'package:aquanest/pages/riwayat_pengurasan.dart';
import 'package:aquanest/pages/profile_page.dart';
import 'package:aquanest/pages/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String pengisian = '/pengisian';
  static const String pengurasan = '/pengurasan';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
    dashboard: (context) => const DashboardPage(),
    history: (context) => const HistoryPage(),
    pengisian: (context) => const RiwayatKekeruhanPage(),
    pengurasan: (context) => const RiwayatPengurasanPage(),
    profile: (context) => const ProfilePage(),
  };
}
