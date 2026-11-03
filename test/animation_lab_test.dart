import 'dart:io';
import 'dart:ui' as ui;

import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/motion.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(AppStorage.resetForTest);

  test('yerel Lottie JSON görünür ve farklı kareler üretir', () async {
    final composition = await LottieComposition.fromBytes(
      File('assets/animations/project_ready.json').readAsBytesSync(),
    );
    expect(composition.duration.inMilliseconds, inInclusiveRange(1900, 2100));
    Future<List<int>> render(double progress) async {
      final recorder = ui.PictureRecorder();
      final drawable = LottieDrawable(composition)..setProgress(progress);
      drawable.draw(
        ui.Canvas(recorder),
        const ui.Rect.fromLTWH(0, 0, 320, 240),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(320, 240);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final bytes = data!.buffer.asUint8List().toList();
      image.dispose();
      picture.dispose();
      expect(
        [for (var i = 3; i < bytes.length; i += 4) bytes[i]]
            .any((alpha) => alpha > 0),
        isTrue,
      );
      return bytes;
    }

    final first = await render(0);
    final middle = await render(0.5);
    expect(first, isNot(orderedEquals(middle)));
  });

  testWidgets('controller oynat/duraklat/sıfırla ve Tween ilerlemesi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const DeepLinkApp(initialLocation: '/animation-lab'),
    );
    await tester.pumpAndSettle();
    final scrollable = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Duraklat'),
      250,
      scrollable: scrollable,
    );
    await tester.tap(find.text('Duraklat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sıfırla'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('lab-progress')));
    expect(
      tester.widget<Slider>(find.byKey(const Key('lab-progress'))).value,
      0,
    );
    await tester.ensureVisible(find.text('Oynat'));
    await tester.tap(find.text('Oynat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Duraklat'));
    await tester.pump();
    final progress = tester
        .widget<Slider>(find.byKey(const Key('lab-progress')))
        .value;
    expect(progress, greaterThan(0));
    expect(progress, lessThan(1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.widget<Slider>(find.byKey(const Key('lab-progress'))).value,
      progress,
    );
    await tester.ensureVisible(find.text('Tersine oynat'));
    await tester.tap(find.text('Tersine oynat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Duraklat'));
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byKey(const Key('lab-progress'))).value,
      lessThan(progress),
    );
  });

  for (final engine in RouterEngine.values) {
    for (final effect in ['flip3d', 'cube3d', 'depth3d']) {
      testWidgets('${engine.name}: $effect route açılışı ve geri dönüş', (
        tester,
      ) async {
        await tester.pumpWidget(
          DeepLinkApp(initialEngine: engine, initialLocation: '/animation-lab'),
        );
        await tester.pumpAndSettle();
        final scrollable = find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first;
        final dropdown = find.widgetWithText(
          DropdownButtonFormField<String>,
          '3 boyutlu geçiş',
        );
        await tester.scrollUntilVisible(dropdown, 250, scrollable: scrollable);
        await tester.pumpAndSettle();
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppMotion.labels[effect]!).last);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Geçişi dene'),
          200,
          scrollable: scrollable,
        );
        await tester.tap(find.text('Geçişi dene'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byKey(ValueKey('route-3d-$effect')), findsWidgets);
        await tester.pumpAndSettle();
        expect(find.text('3B geçiş önizlemesi'), findsOneWidget);
        expect(AppMotion.style, effect);
        await tester.tap(find.text('Stüdyoya dön'));
        await tester.pumpAndSettle();
        expect(find.text('Animasyon stüdyosu'), findsOneWidget);
      });
    }
  }
  testWidgets('animasyon azaltma tercihi otomatik oynatımı kapatır', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      const DeepLinkApp(initialLocation: '/animation-lab'),
    );
    await tester.pumpAndSettle();
    final scrollable = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Oynat'),
      250,
      scrollable: scrollable,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Oynat'),
    );
    expect(button.onPressed, isNull);
    expect(
      tester.widget<Slider>(find.byKey(const Key('lab-progress'))).value,
      1,
    );
  });
}
