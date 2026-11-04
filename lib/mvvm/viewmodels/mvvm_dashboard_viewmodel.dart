import 'package:flutter/foundation.dart';

import 'currency_viewmodel.dart';
import 'news_viewmodel.dart';

class MvvmDashboardViewModel extends ChangeNotifier {
  final CurrencyViewModel currencies = CurrencyViewModel();
  final NewsViewModel news = NewsViewModel();
  bool showDetails = true;
  MvvmDashboardViewModel() {
    currencies.addListener(notifyListeners);
    news.addListener(notifyListeners);
  }
  void toggleDetails() {
    showDetails = !showDetails;
    notifyListeners();
  }

  @override
  void dispose() {
    currencies.dispose();
    news.dispose();
    super.dispose();
  }
}
