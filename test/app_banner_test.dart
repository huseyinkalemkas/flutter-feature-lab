import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/motion.dart';
import 'package:deep_link_demo/network.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppStorage.resetForTest);
  for (final engine in RouterEngine.values) {
    testWidgets('${engine.name}: mobil üst bant, network ve menüler', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var checks = 0;
      final network = NetworkMonitor(
        checkInternet: () async {
          checks++;
          return false;
        },
        changes: const Stream.empty(),
      );
      addTearDown(network.dispose);
      await network.check();
      await tester.pumpWidget(
        DeepLinkApp(
          initialEngine: engine,
          networkMonitor: network,
          initialLocation: '/project-list?demo=true',
        ),
      );
      await tester.pumpAndSettle();
      final banner = find.byKey(const Key('app-control-banner'));
      expect(banner, findsOneWidget);
      expect(find.text('Çevrimdışı'), findsOneWidget);
      final position = tester.getTopLeft(banner);
      await tester.drag(
        find.byKey(const Key('project-scroll')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(banner), position);
      await tester.tap(find.byTooltip('Bağlantıyı kontrol et'));
      await tester.pumpAndSettle();
      expect(checks, 2);
      await tester.ensureVisible(find.text('Animasyon'));
      await tester.tap(find.text('Animasyon'));
      await tester.pumpAndSettle();
      expect(find.text('Animasyon stüdyosu'), findsOneWidget);
      final router = find.byKey(const Key('banner-router'));
      await tester.ensureVisible(router);
      await tester.tap(router);
      await tester.pumpAndSettle();
      final other = engine == RouterEngine.autoRoute
          ? 'go_router'
          : 'auto_route';
      await tester.tap(find.text(other).last);
      await tester.pumpAndSettle();
      expect(tester.widget<DropdownButton<String>>(router).value, other);
      expect(find.text('Animasyon stüdyosu'), findsOneWidget);
      final effect = find.byKey(const Key('banner-effect'));
      await tester.ensureVisible(effect);
      await tester.tap(effect);
      await tester.pumpAndSettle();
      await tester.tap(find.text('3B derinlik').last);
      await tester.pumpAndSettle();
      expect(AppMotion.style, 'depth3d');
      await tester.ensureVisible(find.text('Müşteri ekle'));
      await tester.tap(find.text('Müşteri ekle'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Müşteri adı'),
        'Üst bant müşterisi',
      );
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(WorkspaceStore.customers.single.name, 'Üst bant müşterisi');
    });
  }
}
