import 'package:flutter/material.dart';
import 'package:aquanest/pages/login_page.dart';
import 'package:aquanest/pages/dashboard_page.dart';
import 'package:aquanest/pages/history_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String history = '/history';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    dashboard: (context) => const DashboardPage(),
    history: (context) => const HistoryPage(),
  };
}
