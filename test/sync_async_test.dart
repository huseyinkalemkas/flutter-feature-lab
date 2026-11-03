import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppStorage.resetForTest);
  for (final engine in RouterEngine.values) {
    testWidgets('$engine opens timeline, pauses and resets', (tester) async {
      await tester.pumpWidget(
        DeepLinkApp(initialEngine: engine, initialLocation: '/sync-async'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sync / Async Laboratuvarı'), findsOneWidget);
      await tester.tap(find.text('Başlat'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('Duraklat'));
      await tester.pump();
      expect(find.text('Tamamlandı'), findsOneWidget);
      expect(find.text('İstekler işleniyor'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Tamamlandı'), findsOneWidget);
      await tester.tap(find.text('Sıfırla'));
      await tester.pump();
      expect(find.text('Hazır'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Ana sayfaya dön'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sync / Async Laboratuvarı'));
      await tester.pumpAndSettle();
      expect(find.text('Başlat'), findsOneWidget);
    });
  }
}
