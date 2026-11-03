import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:deep_link_demo/storage.dart';
import 'package:deep_link_demo/media.dart';
import 'package:deep_link_demo/motion.dart';

void main() {
  test(
    'müşteri, proje, dosya ve not depo kapatılıp açılınca korunur',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'proje-dosya-test-',
      );
      try {
        await AppStorage.initialize(directory: directory.path);
        await WorkspaceStore.saveCustomer(
          const Customer(id: 'c', name: 'Atlas', contact: 'atlas@example.com'),
        );
        await AppMotion.setStyle('fade');
        await WorkspaceStore.saveProject(
          const Project(id: 'p', customerId: 'c', name: 'Ofis'),
        );
        await MediaStore.add(
          MediaAttachment(
            id: 'm',
            name: 'saha.png',
            kind: MediaKind.image,
            bytes: Uint8List.fromList([1, 2, 3]),
            projectId: 'p',
            note: 'Kontrol edilecek',
            favorite: true,
          ),
        );
        await AppStorage.close();
        await AppStorage.initialize(directory: directory.path);
        expect(WorkspaceStore.customer('c')!.contact, 'atlas@example.com');
        expect(AppMotion.style, 'fade');
        expect(WorkspaceStore.project('p')!.customerId, 'c');
        expect(MediaStore.find('m')!.bytes, [1, 2, 3]);
        expect(MediaStore.find('m')!.note, 'Kontrol edilecek');
        expect(MediaStore.find('m')!.favorite, isTrue);
        await MediaStore.remove('m');
        await AppStorage.close();
        await AppStorage.initialize(directory: directory.path);
        expect(MediaStore.find('m'), isNull);
      } finally {
        await AppStorage.close();
        // Yalnız bu testin oluşturduğu dosyaları, tek tek temizle.
        for (final file in directory.listSync().whereType<File>()) {
          await file.delete();
        }
        await directory.delete();
      }
    },
  );
}
