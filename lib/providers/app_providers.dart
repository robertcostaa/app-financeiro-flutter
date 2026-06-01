import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/news_viewmodel.dart';

final authProvider = ChangeNotifierProvider<AuthViewModel>((ref) {
  return AuthViewModel();
});

final dashboardProvider = ChangeNotifierProvider<DashboardViewModel>((ref) {
  return DashboardViewModel();
});

final newsProvider = ChangeNotifierProvider<NewsViewModel>((ref) {
  return NewsViewModel();
});
