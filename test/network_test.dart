import 'dart:async';

import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/network.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(AppStorage.resetForTest);
  test('ağ değişimleri izlenir ve dispose aboneliği kapatır', () async {
    final source = StreamController<bool>.broadcast(sync: true);
    final monitor = NetworkMonitor(
      checkInternet: () async => true,
      changes: source.stream,
    )..start();
    source.add(false);
    expect(monitor.status, NetworkStatus.offline);
    source.add(true);
    expect(monitor.status, NetworkStatus.online);
    monitor.dispose();
    source.add(false);
    expect(monitor.status, NetworkStatus.online);
    await source.close();
  });
  test('eski kontrol yeni ağ durumunu ezmez', () async {
    final old = Completer<bool>();
    final recent = Completer<bool>();
    var attempts = 0;
    final monitor = NetworkMonitor(
      checkInternet: () => attempts++ == 0 ? old.future : recent.future,
      changes: const Stream.empty(),
    );
    final first = monitor.check();
    final second = monitor.check();
    recent.complete(true);
    await second;
    old.complete(false);
    await first;
    expect(monitor.status, NetworkStatus.online);
    expect(monitor.checking, isFalse);
    monitor.dispose();
  });
  for (final engine in RouterEngine.values) {
    testWidgets(
      '${engine.name}: offline banner, tekrar dene ve geri gelen bağlantı',
      (tester) async {
        var connected = false;
        final monitor = NetworkMonitor(
          checkInternet: () async => connected,
          changes: const Stream.empty(),
        );
        addTearDown(monitor.dispose);
        await monitor.check();
        await tester.pumpWidget(
          DeepLinkApp(initialEngine: engine, networkMonitor: monitor),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MaterialBanner), findsOneWidget);
        expect(
          find.textContaining('İnternet erişimi doğrulanamadı.'),
          findsOneWidget,
        );
        expect(find.text('ProjeDosya'), findsOneWidget);
        connected = true;
        await tester.tap(find.text('Tekrar dene'));
        await tester.pumpAndSettle();
        expect(find.text('İnternet bağlantısı doğrulandı.'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(find.byType(MaterialBanner), findsNothing);
        expect(find.text('ProjeDosya'), findsOneWidget);
        await monitor.check();
        await tester.pumpAndSettle();
        expect(find.byType(MaterialBanner), findsOneWidget);
        await tester.tap(find.text('Kapat'));
        await tester.pumpAndSettle();
        expect(find.byType(MaterialBanner), findsNothing);
      },
    );
  }
  testWidgets('uzayan ağ kontrolü zaman aşımında belirsiz duruma geçer', (
    tester,
  ) async {
    final response = Completer<bool>();
    final monitor = NetworkMonitor(
      checkInternet: () => response.future,
      changes: const Stream.empty(),
    );
    addTearDown(monitor.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: NetworkBannerHost(
          monitor: monitor,
          child: const Scaffold(body: Text('Yerel içerik')),
        ),
      ),
    );
    final checking = monitor.check();
    await tester.pump();
    expect(find.text('İnternet bağlantısı kontrol ediliyor…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 8));
    await checking;
    await tester.pumpAndSettle();
    expect(monitor.status, NetworkStatus.unknown);
    expect(
      find.textContaining('Bağlantı durumu kontrol edilemedi.'),
      findsOneWidget,
    );
    expect(find.text('Yerel içerik'), findsOneWidget);
  });
}
