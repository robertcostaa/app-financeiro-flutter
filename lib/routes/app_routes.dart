import 'package:flutter/material.dart';
import '../views/auth_view.dart';
import '../views/register_view.dart';
import '../views/dashboard_view.dart';
import '../views/analysis_view.dart';

class AppRoutes {
  static const auth = '/';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const analysis = '/analysis';

  static Map<String, WidgetBuilder> routes = {
    auth: (_) => const AuthView(),
    register: (_) => const RegisterView(),
    dashboard: (_) => const DashboardView(),
    analysis: (_) => AnalysisView(),
  };
}
