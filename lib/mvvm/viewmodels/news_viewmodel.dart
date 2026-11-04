import 'package:flutter/foundation.dart';

import '../models/financial_news.dart';

class NewsViewModel extends ChangeNotifier {
  final news = const [
    FinancialNews(
      title: 'Merkez bankaları faiz kararları öncesi piyasalar temkinli',
      source: 'Finans Gündem',
      time: '12 dk önce',
      category: 'Piyasalar',
    ),
    FinancialNews(
      title: 'Küresel büyüme beklentileri ve emtia fiyatları izleniyor',
      source: 'Ekonomi Ajansı',
      time: '38 dk önce',
      category: 'Ekonomi',
    ),
    FinancialNews(
      title: 'Dolar endeksi yeni haftaya sınırlı yükselişle başladı',
      source: 'Piyasa Haber',
      time: '1 saat önce',
      category: 'Döviz',
    ),
    FinancialNews(
      title: 'Teknoloji hisselerinde bilanço sezonu hareketliliği',
      source: 'Borsa Notları',
      time: '2 saat önce',
      category: 'Borsa',
    ),
  ];
}
