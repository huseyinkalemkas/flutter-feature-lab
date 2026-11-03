import 'dart:async';

import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/pagination.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppStorage.resetForTest);
  for (final engine in RouterEngine.values) {
    for (final style in ['standard', 'skeleton']) {
      testWidgets('${engine.name}: $style yükleme ve kaydırarak sonraki grup', (
        tester,
      ) async {
        await tester.pumpWidget(
          DeepLinkApp(
            initialEngine: engine,
            initialLocation:
                '/project-list?demo=true&size=5&load=lazy&loading=$style&view=grid',
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.drag(
          find.byKey(const Key('project-scroll')),
          const Offset(0, -450),
        );
        await tester.pump();
        expect(find.byKey(Key('$style-loading')), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
        await tester.drag(
          find.byKey(const Key('project-scroll')),
          const Offset(0, 4000),
        );
        await tester.pumpAndSettle();
        expect(find.text('1–5 / 53 kayıt'), findsOneWidget);
        await tester.drag(
          find.byKey(const Key('project-scroll')),
          const Offset(0, -1800),
        );
        await tester.pump();
        expect(find.byKey(Key('$style-loading')), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
        await tester.drag(
          find.byKey(const Key('project-scroll')),
          const Offset(0, 4000),
        );
        await tester.pumpAndSettle();
        final range = tester
            .widget<Text>(find.byKey(const Key('page-range')))
            .data!;
        final loaded = int.parse(
          RegExp(r'1–(\d+) / 53').firstMatch(range)!.group(1)!,
        );
        expect(loaded, greaterThanOrEqualTo(10));
        expect(loaded, lessThan(53));
        expect(loaded % 5, 0);
        expect(WorkspaceStore.projects, isEmpty);
      });
    }
  }
  testWidgets('eski arama yanıtı yeni sonuçları ezmez', (tester) async {
    final old = Completer<PageSlice<Project>>();
    final current = Completer<PageSlice<Project>>();
    Future<PageSlice<Project>> loader(PageRequest request) =>
        request.search == 'yeni' ? current.future : old.future;
    Widget app(String query) => MaterialApp(
      home: PaginatedProjectsScreen(
        request: PageRequest(search: query),
        loader: loader,
        onNavigate: (_) {},
        onOpenProject: (_) {},
        onHome: () {},
        onSettings: () {},
      ),
    );
    await tester.pumpWidget(app('eski'));
    await tester.pumpWidget(app('yeni'));
    current.complete(
      PageSlice([
        const Project(id: 'new', customerId: 'c', name: 'Yeni sonuç'),
      ], const PageRequest()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Yeni sonuç'), findsOneWidget);
    old.complete(
      PageSlice([
        const Project(id: 'old', customerId: 'c', name: 'Eski sonuç'),
      ], const PageRequest()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Yeni sonuç'), findsOneWidget);
    expect(find.text('Eski sonuç'), findsNothing);
  });
  testWidgets('yükleme hatası yeniden denenebilir', (tester) async {
    var attempts = 0;
    Future<PageSlice<Project>> loader(PageRequest request) async {
      if (attempts++ == 0) throw StateError('load failed');
      return PageSlice([
        const Project(id: 'ok', customerId: 'c', name: 'Proje yüklendi'),
      ], request);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: PaginatedProjectsScreen(
          request: const PageRequest(),
          loader: loader,
          onNavigate: (_) {},
          onOpenProject: (_) {},
          onHome: () {},
          onSettings: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scrollable = find.byKey(const Key('project-scroll'));
    await tester.drag(scrollable, const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yeniden dene'));
    await tester.pumpAndSettle();
    expect(find.text('Proje yüklendi'), findsOneWidget);
  });
}
