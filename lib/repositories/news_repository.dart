import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_model.dart';

class NewsRepository {
  Future<List<NewsModel>> getFinancialNews() async {
    final uri = Uri.parse(
      'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL',
    );

    final response = await http.get(uri).timeout(
          const Duration(seconds: 12),
        );

    if (response.statusCode != 200) {
      throw Exception('Erro na API: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final indicators = <NewsModel>[];

    if (data.containsKey('USDBRL')) {
      final usd = data['USDBRL'] as Map<String, dynamic>;

      indicators.add(
        NewsModel(
          title: 'Dólar comercial',
          description:
              'Cotação atual: R\$ ${usd['bid']} • Alta: R\$ ${usd['high']} • Baixa: R\$ ${usd['low']}',
          url: '',
          source: 'AwesomeAPI',
        ),
      );
    }

    if (data.containsKey('EURBRL')) {
      final eur = data['EURBRL'] as Map<String, dynamic>;

      indicators.add(
        NewsModel(
          title: 'Euro',
          description:
              'Cotação atual: R\$ ${eur['bid']} • Alta: R\$ ${eur['high']} • Baixa: R\$ ${eur['low']}',
          url: '',
          source: 'AwesomeAPI',
        ),
      );
    }

    if (data.containsKey('BTCBRL')) {
      final btc = data['BTCBRL'] as Map<String, dynamic>;

      indicators.add(
        NewsModel(
          title: 'Bitcoin',
          description:
              'Cotação atual: R\$ ${btc['bid']} • Alta: R\$ ${btc['high']} • Baixa: R\$ ${btc['low']}',
          url: '',
          source: 'AwesomeAPI',
        ),
      );
    }

    return indicators;
  }
}
