import 'dart:io';

import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() {
  for (final engine in RouterEngine.values) {
    testWidgets('$engine: Hive note survives leaving and reopening page', (
      tester,
    ) async {
      AppStorage.resetForTest();
      late Directory directory;
      await tester.runAsync(() async {
        directory = await Directory.systemTemp.createTemp('storage_examples_');
        Hive.init(directory.path);
        await Hive.openBox<String>('example_notes');
      });
      try {
        await tester.pumpWidget(DeepLinkApp(initialEngine: engine));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Hive CE · Notlar'));
        await tester.tap(find.text('Hive CE · Notlar'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Kalıcı not');
        await tester.ensureVisible(find.text('Not ekle'));
        await tester.runAsync(() async {
          await tester.tap(find.text('Not ekle'));
          await Hive.box<String>('example_notes').flush();
          await Future<void>.delayed(Duration.zero);
        });
        await tester.pumpAndSettle();
        expect(find.text('Kalıcı not'), findsOneWidget);
        await tester.tap(find.byTooltip('Ana sayfa'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Hive CE · Notlar'));
        await tester.tap(find.text('Hive CE · Notlar'));
        await tester.pumpAndSettle();
        expect(find.text('Kalıcı not'), findsOneWidget);
        await tester.runAsync(() async {
          await tester.tap(find.byTooltip('Notu sil'));
          await Hive.box<String>('example_notes').flush();
          await Future<void>.delayed(Duration.zero);
        });
        await tester.pumpAndSettle();
        expect(find.text('Henüz not yok.'), findsOneWidget);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(() async {
          await Hive.close();
          for (final file in directory.listSync().whereType<File>()) {
            await file.delete();
          }
          await directory.delete();
        });
      }
    });
  }
}
