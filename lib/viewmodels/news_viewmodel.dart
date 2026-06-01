import 'package:flutter/material.dart';

import '../models/news_model.dart';
import '../repositories/news_repository.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsRepository _repository = NewsRepository();

  List<NewsModel> news = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadNews() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      news = await _repository.getFinancialNews();
    } catch (e) {
      errorMessage =
          'Não foi possível carregar os indicadores financeiros. Verifique sua conexão.';
    }

    isLoading = false;
    notifyListeners();
  }
}
