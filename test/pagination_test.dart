import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/pagination.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppStorage.resetForTest);
  test('boş liste, son sayfa ve geçersiz URL parametreleri', () {
    final all = List.generate(23, (i) => i);
    final last = PageSlice(all, const PageRequest(page: 999, size: 10));
    expect(last.page, 3);
    expect(last.items, [20, 21, 22]);
    expect(last.start, 21);
    expect(last.end, 23);
    final empty = PageSlice<int>([], const PageRequest(page: 999));
    expect(empty.page, 1);
    expect(empty.start, 0);
    expect(empty.end, 0);
    final invalid = PageRequest.fromRaw(page: '-5', size: '0');
    expect(invalid.page, 1);
    expect(invalid.size, 10);
    expect(PageRequest.fromRaw(view: 'unknown').view, 'list');
    expect(
      Uri.parse(const PageRequest(view: 'grid').location)
          .queryParameters['view'],
      'grid',
    );
    expect(
      Uri.parse(const PageRequest(search: 'Ayşe & Can').location)
          .queryParameters['q'],
      'Ayşe & Can',
    );
  });
  for (final engine in RouterEngine.values) {
    testWidgets('${engine.name}: sonraki sayfa ve arama sayfayı sıfırlar', (
      tester,
    ) async {
      await tester.pumpWidget(
        DeepLinkApp(
          initialEngine: engine,
          initialLocation: '/project-list?demo=true&size=5&page=2',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('6–10 / 53 kayıt'), findsOneWidget);
      await tester.ensureVisible(find.text('Grid'));
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pagination-grid')), findsOneWidget);
      expect(find.text('6–10 / 53 kayıt'), findsOneWidget);
      final scrollable = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Sonraki'),
        250,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sonraki'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('page-range')),
        -250,
        scrollable: scrollable,
      );
      expect(find.text('11–15 / 53 kayıt'), findsOneWidget);
      expect(find.byKey(const Key('pagination-grid')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -250,
        scrollable: scrollable,
      );
      await tester.enterText(find.byType(TextField), '53');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Liste'));
      await tester.tap(find.text('Liste'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pagination-list')), findsOneWidget);
      expect(find.text('11–15 / 53 kayıt'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Ara'),
        -250,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ara'));
      await tester.pumpAndSettle();
      expect(find.text('1–1 / 1 kayıt'), findsOneWidget);
      expect(find.text('Örnek Proje 53'), findsOneWidget);
      expect(WorkspaceStore.projects, isEmpty);
    });
  }
}
