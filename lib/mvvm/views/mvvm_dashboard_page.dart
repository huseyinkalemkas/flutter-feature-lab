import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../viewmodels/mvvm_dashboard_viewmodel.dart';

class MvvmDashboardPage extends StatefulWidget {
  const MvvmDashboardPage({super.key});
  @override
  State<MvvmDashboardPage> createState() => _MvvmDashboardPageState();
}

class _MvvmDashboardPageState extends State<MvvmDashboardPage> {
  late final MvvmDashboardViewModel vm;
  @override
  void initState() {
    super.initState();
    vm = MvvmDashboardViewModel()..currencies.select('USD/TRY');
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: vm,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('MVVM Finans Dashboard')),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ChangeNotifier ile MVVM örneği',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tek ana ViewModel, üç bağımsız alt ViewModel’i yönetir.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.currency_exchange),
                  text: 'Para Birimleri',
                ),
                Tab(icon: Icon(Icons.newspaper_outlined), text: 'Haberler'),
                Tab(
                  icon: Icon(Icons.analytics_outlined),
                  text: 'Seçili Varlık',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [_currenciesView(), _newsView(), _assetView()],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _currenciesView() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _sectionTitle('1 · Para Birimleri', Icons.currency_exchange),
      SegmentedButton<CurrencyPeriod>(
        segments: const [
          ButtonSegment(value: CurrencyPeriod.week, label: Text('Haftalık')),
          ButtonSegment(value: CurrencyPeriod.month, label: Text('Aylık')),
          ButtonSegment(value: CurrencyPeriod.quarter, label: Text('3 aylık')),
        ],
        selected: {vm.currencies.period},
        onSelectionChanged: (value) => vm.currencies.setPeriod(value.first),
      ),
      const SizedBox(height: 12),
      ...vm.currencies.currencies.map((item) => _currencyTile(item)),
    ],
  );

  Widget _newsView() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _sectionTitle('2 · Finansal Haberler', Icons.newspaper_outlined),
      ...vm.news.news.map(
        (item) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(item.category[0])),
            title: Text(item.title),
            subtitle: Text('${item.source} · ${item.time}'),
          ),
        ),
      ),
    ],
  );

  Widget _assetView() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _sectionTitle('3 · Seçili Varlık', Icons.analytics_outlined),
      Card(
        child: ListTile(
          title: Text(vm.currencies.selected?.name ?? 'Bir para birimi seçin'),
          subtitle: Text(
            vm.currencies.selected == null
                ? 'Yukarıdaki listeden seçim yapın.'
                : '${vm.currencies.selected!.code} · ${vm.currencies.selected!.rate.toStringAsFixed(2)} TRY',
          ),
          trailing: Switch(
            value: vm.showDetails,
            onChanged: (_) => vm.toggleDetails(),
          ),
        ),
      ),
      if (vm.showDetails && vm.currencies.selected != null)
        _detailCard(vm.currencies.selected!),
    ],
  );

  Widget _currencyTile(Currency item) {
    final change = item.change(vm.currencies.period);
    return Card(
      child: ListTile(
        onTap: () => vm.currencies.select(item.code),
        selected: vm.currencies.selectedCode == item.code,
        leading: Text(
          item.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        title: Text(item.name),
        subtitle: Text('${item.rate.toStringAsFixed(2)} TRY'),
        trailing: Text(
          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
          style: TextStyle(
            color: change >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _detailCard(Currency item) => Card(
    color: const Color(0xFFE7F4F1),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Model katmanı: Currency\nViewModel katmanı: CurrencyViewModel\nGüncel dönem: ${vm.currencies.period.name}\nHaftalık: ${item.weekChange}% · Aylık: ${item.monthChange}% · 3 aylık: ${item.quarterChange}%',
      ),
    ),
  );
  Widget _sectionTitle(String text, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF087F73)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
