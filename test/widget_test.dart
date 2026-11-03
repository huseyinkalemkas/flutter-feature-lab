import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/media.dart';
import 'package:deep_link_demo/storage.dart';

void main() {
  setUp(AppStorage.resetForTest);
  for (final engine in RouterEngine.values) {
    testWidgets('${engine.name}: müşteri ve proje oluşturulur', (tester) async {
      await tester.pumpWidget(DeepLinkApp(initialEngine: engine));
      await tester.pumpAndSettle();
      expect(find.text('ProjeDosya'), findsOneWidget);
      await tester.tap(find.text('Müşteri ekle').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Müşteri adı'),
        'Atlas Mimarlık',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'İletişim (isteğe bağlı)'),
        'atlas@example.com',
      );
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(WorkspaceStore.customers.single.name, 'Atlas Mimarlık');
      await tester.tap(find.text('Yeni proje').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Proje adı'),
        'Ofis yenileme',
      );
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(WorkspaceStore.projects.single.name, 'Ofis yenileme');
      expect(find.text('Projeye dosya ekle'), findsOneWidget);
      await tester.tap(find.text('Devam ediyor · Tamamla'));
      await tester.pumpAndSettle();
      expect(WorkspaceStore.projects.single.completed, isTrue);
    });
    testWidgets('${engine.name}: dosya notu, favori ve proje filtresi', (
      tester,
    ) async {
      await WorkspaceStore.saveCustomer(const Customer(id: 'c', name: 'Atlas'));
      await WorkspaceStore.saveProject(
        const Project(id: 'p', customerId: 'c', name: 'Ofis'),
      );
      await MediaStore.add(
        MediaAttachment(
          id: 'm',
          name: 'saha.png',
          kind: MediaKind.image,
          bytes: File('web/favicon.png').readAsBytesSync(),
          projectId: 'p',
        ),
      );
      await tester.pumpWidget(
        DeepLinkApp(initialEngine: engine, initialLocation: '/media/m'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Favori'));
      await tester.pumpAndSettle();
      expect(MediaStore.find('m')!.favorite, isTrue);
      await tester.tap(find.byTooltip('Dosya bilgileri'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Dosya adı'),
        'Toplantı',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Not'),
        'Müşteri onayı bekleniyor',
      );
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(MediaStore.find('m')!.name, 'Toplantı.png');
      expect(MediaStore.find('m')!.note, 'Müşteri onayı bekleniyor');
      await tester.tap(find.byTooltip('Projeye dön'));
      await tester.pumpAndSettle();
      final favorites = find.text('Favoriler');
      await tester.scrollUntilVisible(
        favorites,
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(favorites);
      await tester.pumpAndSettle();
      expect(find.text('Toplantı.png'), findsOneWidget);
    });
  }
}
