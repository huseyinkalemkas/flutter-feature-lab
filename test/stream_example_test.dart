import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/network.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppStorage.resetForTest);
  for (final engine in RouterEngine.values) {
    testWidgets('$engine: stream data, pause, error, done and reset', (
      tester,
    ) async {
      final network = NetworkMonitor(
        checkInternet: () async => true,
        changes: const Stream.empty(),
      );
      addTearDown(network.dispose);
      await network.check();
      await tester.pumpWidget(
        DeepLinkApp(initialEngine: engine, networkMonitor: network),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Stream / StreamBuilder'));
      await tester.tap(find.text('Stream / StreamBuilder'));
      await tester.pumpAndSettle();
      expect(find.text('İlk veri bekleniyor'), findsOneWidget);
      String value() =>
          tester.widget<Text>(find.byKey(const Key('stream-value'))).data!;
      Future<void> tap(String label) async {
        await tester.scrollUntilVisible(
          find.text(label),
          120,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('stream-example-scroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.text(label));
        await tester.pump();
      }

      await tap('Başlat');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(value(), '1');
      await tap('Duraklat');
      await tester.pump(const Duration(seconds: 3));
      expect(value(), '1');
      await tap('Hata gönder');
      expect(find.text('Hata: Örnek bağlantı hatası'), findsOneWidget);
      await tap('Başlat');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(value(), '2');
      expect(find.text('Yeni veri alındı'), findsOneWidget);
      await tap('Akışı bitir');
      expect(find.text('Akış tamamlandı'), findsOneWidget);
      expect(value(), '2');
      await tap('Sıfırla');
      expect(find.text('İlk veri bekleniyor'), findsOneWidget);
      expect(value(), '—');
      await tap('Başlat');
      // Leave while the timer is active: dispose must cancel the producer.
      await tester.ensureVisible(find.byTooltip('Ana sayfa'));
      await tester.tap(find.byTooltip('Ana sayfa'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
