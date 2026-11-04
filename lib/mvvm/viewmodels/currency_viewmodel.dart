import 'package:flutter/foundation.dart';

import '../models/currency.dart';

class CurrencyViewModel extends ChangeNotifier {
  CurrencyPeriod period = CurrencyPeriod.week;
  String? selectedCode;
  final currencies = const [
    Currency(
      code: 'USD/TRY',
      name: 'Amerikan Doları',
      rate: 43.12,
      weekChange: 1.8,
      monthChange: 4.2,
      quarterChange: 8.6,
    ),
    Currency(
      code: 'EUR/TRY',
      name: 'Euro',
      rate: 50.34,
      weekChange: 0.9,
      monthChange: 3.8,
      quarterChange: 7.4,
    ),
    Currency(
      code: 'GBP/TRY',
      name: 'İngiliz Sterlini',
      rate: 57.62,
      weekChange: 1.2,
      monthChange: 4.6,
      quarterChange: 9.1,
    ),
    Currency(
      code: 'CHF/TRY',
      name: 'İsviçre Frangı',
      rate: 53.48,
      weekChange: 0.5,
      monthChange: 2.9,
      quarterChange: 6.8,
    ),
    Currency(
      code: 'JPY/TRY',
      name: 'Japon Yeni',
      rate: 0.29,
      weekChange: -0.4,
      monthChange: 1.2,
      quarterChange: 3.3,
    ),
    Currency(
      code: 'CAD/TRY',
      name: 'Kanada Doları',
      rate: 31.18,
      weekChange: 0.7,
      monthChange: 2.5,
      quarterChange: 5.9,
    ),
    Currency(
      code: 'AUD/TRY',
      name: 'Avustralya Doları',
      rate: 28.05,
      weekChange: 1.1,
      monthChange: 3.1,
      quarterChange: 6.2,
    ),
    Currency(
      code: 'SAR/TRY',
      name: 'Suudi Riyali',
      rate: 11.49,
      weekChange: 0.1,
      monthChange: 0.4,
      quarterChange: 1.1,
    ),
    Currency(
      code: 'AED/TRY',
      name: 'BAE Dirhemi',
      rate: 11.74,
      weekChange: 0.2,
      monthChange: 0.6,
      quarterChange: 1.4,
    ),
    Currency(
      code: 'CNY/TRY',
      name: 'Çin Yuanı',
      rate: 5.96,
      weekChange: -0.2,
      monthChange: 1.0,
      quarterChange: 2.7,
    ),
  ];
  void setPeriod(CurrencyPeriod value) {
    period = value;
    notifyListeners();
  }

  void select(String code) {
    selectedCode = code;
    notifyListeners();
  }

  Currency? get selected =>
      currencies.where((item) => item.code == selectedCode).firstOrNull;
}
