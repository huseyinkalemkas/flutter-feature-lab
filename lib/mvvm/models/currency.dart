class Currency {
  final String code;
  final String name;
  final double rate;
  final double weekChange;
  final double monthChange;
  final double quarterChange;
  const Currency({
    required this.code,
    required this.name,
    required this.rate,
    required this.weekChange,
    required this.monthChange,
    required this.quarterChange,
  });
  double change(CurrencyPeriod period) => switch (period) {
    CurrencyPeriod.week => weekChange,
    CurrencyPeriod.month => monthChange,
    CurrencyPeriod.quarter => quarterChange,
  };
}

enum CurrencyPeriod { week, month, quarter }
