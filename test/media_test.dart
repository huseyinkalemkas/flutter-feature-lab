import 'dart:io';

import 'package:deep_link_demo/main.dart';
import 'package:deep_link_demo/media.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deep_link_demo/storage.dart';

class TestFilePicker extends FilePicker {
  final PlatformFile file;
  TestFilePicker(this.file);
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    expect(withReadStream, isTrue);
    return FilePickerResult([file]);
  }
}

void main() {
  setUp(AppStorage.resetForTest);
  tearDown(MediaStore.clear);
  test('bytes ve yol olmadan tarayıcı dosya akışı okunur', () async {
    final file = PlatformFile(
      name: 'ornek.png',
      size: 4,
      readStream: Stream.fromIterable([
        [1, 2],
        [3, 4],
      ]),
    );
    expect(await readMediaBytes(file, maxBytes: 10), [1, 2, 3, 4]);
  });
  test('boyutu eksik bildirilmiş akış da sınırlandırılır', () async {
    final file = PlatformFile(
      name: 'ornek.png',
      size: 0,
      readStream: Stream.fromIterable([
        [1, 2],
        [3, 4],
      ]),
    );
    await expectLater(readMediaBytes(file, maxBytes: 3), throwsFormatException);
  });
  test('dosya türleri ve tüm dosyaların arşivde korunması', () async {
    expect(MediaAttachment.kindForName('rapor.PDF'), MediaKind.pdf);
    expect(MediaAttachment.kindForName('ses.mp3'), MediaKind.audio);
    expect(MediaAttachment.kindForName('resim.webp'), MediaKind.image);
    expect(MediaAttachment.kindForName('program.exe'), isNull);
    final bytes = File('web/favicon.png').readAsBytesSync();
    for (var i = 0; i < 6; i++) {
      await MediaStore.add(
        MediaAttachment(
          id: '$i',
          name: 'resim.png',
          kind: MediaKind.image,
          bytes: bytes,
        ),
      );
    }
    expect(MediaStore.find('0'), isNotNull);
    expect(MediaStore.find('5'), isNotNull);
  });

  for (final engine in RouterEngine.values) {
    testWidgets(
      '${engine.name}: seçilen fotoğraf route ile taşınır ve motor değişiminde kalır',
      (tester) async {
        await WorkspaceStore.saveCustomer(
          const Customer(id: 'c', name: 'Test müşteri'),
        );
        await WorkspaceStore.saveProject(
          const Project(id: 'p', customerId: 'c', name: 'Test proje'),
        );
        final bytes = File('web/favicon.png').readAsBytesSync();
        FilePicker.platform = TestFilePicker(
          PlatformFile(
            name: 'ornek.png',
            size: bytes.length,
            readStream: Stream.value(bytes),
          ),
        );
        await tester.pumpWidget(
          DeepLinkApp(initialEngine: engine, initialLocation: '/projects/p'),
        );
        await tester.pumpAndSettle();
        final scrollable = find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first;
        final pickButton = find.text('Dosya seç ve aç');
        await tester.scrollUntilVisible(
          pickButton,
          200,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();
        await tester.tap(pickButton);
        await tester.pumpAndSettle();
        expect(find.text('ornek.png'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        await tester.tap(find.byTooltip('Ayarlar'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(
            engine == RouterEngine.autoRoute ? 'go_router' : 'auto_route',
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('ornek.png'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      },
    );
    testWidgets('${engine.name}: yenilenmiş medya adresi yeniden seçim sunar', (
      tester,
    ) async {
      final auto = engine == RouterEngine.autoRoute
          ? createRouter(initialLocation: '/media/yok')
          : null;
      final go = engine == RouterEngine.goRouter
          ? createGoRouter(initialLocation: '/media/yok')
          : null;
      addTearDown(() {
        auto?.dispose();
        go?.dispose();
      });
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: auto?.configuration ?? go!),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Dosya bu cihazın arşivinde bulunamadı'),
        findsOneWidget,
      );
      expect(find.text('Dosya seç ve aç'), findsOneWidget);
    });
  }
}
