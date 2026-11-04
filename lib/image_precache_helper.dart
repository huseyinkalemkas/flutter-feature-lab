import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImagePrecacheController extends ChangeNotifier {
  int completed = 0, failed = 0;
  bool running = false;
  String message = 'Hazır';
  ImageProvider? providerFor(String value) {
    if (value.startsWith('data:image/')) {
      final comma = value.indexOf(',');
      if (comma < 0) return null;
      try {
        return MemoryImage(
          Uint8List.fromList(base64Decode(value.substring(comma + 1))),
        );
      } catch (_) {
        return null;
      }
    }
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' ? NetworkImage(value) : null;
  }

  Future<void> precache(BuildContext context, String value) async {
    final provider = providerFor(value);
    if (provider == null) {
      failed++;
      message = 'Geçersiz kaynak';
      notifyListeners();
      return;
    }
    running = true;
    message = 'Arka planda cache’e alınıyor';
    notifyListeners();
    try {
      await precacheImage(
        provider,
        context,
      ).timeout(const Duration(seconds: 20));
      completed++;
      message = 'Önbelleğe alındı';
    } catch (_) {
      failed++;
      message = 'Yüklenemedi';
    } finally {
      running = false;
      notifyListeners();
    }
  }

  void clear() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    completed = failed = 0;
    message = 'Cache temizlendi';
    notifyListeners();
  }
}

class ImagePrecacheHelperPage extends StatefulWidget {
  const ImagePrecacheHelperPage({super.key});
  @override
  State<ImagePrecacheHelperPage> createState() =>
      _ImagePrecacheHelperPageState();
}

class _ImagePrecacheHelperPageState extends State<ImagePrecacheHelperPage> {
  late final ImagePrecacheController controller;
  final source = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller = ImagePrecacheController();
  }

  @override
  void dispose() {
    controller.dispose();
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Image Precache Helper')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Görseli ekranda kullanmadan önce arka planda cache’e alır.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Base64 data URI veya HTTPS/S3 URL girin.'),
          const SizedBox(height: 18),
          TextField(
            controller: source,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Base64 veya HTTPS görsel URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.running
                      ? null
                      : () => controller.precache(context, source.text.trim()),
                  icon: const Icon(Icons.download_for_offline_outlined),
                  label: const Text('Precache'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: controller.clear,
                child: const Text('Temizle'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: Icon(controller.running ? Icons.sync : Icons.memory),
              title: Text(controller.message),
              subtitle: Text(
                'Başarılı: ${controller.completed} · Hatalı: ${controller.failed}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.cloud_outlined),
            title: Text('S3 / CDN'),
            subtitle: Text('Public veya imzalı HTTPS URL kullanılır.'),
          ),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('FTP'),
            subtitle: Text(
              'FTP doğrudan desteklenmez; HTTPS gateway/proxy gerekir.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.speed_outlined),
            title: Text('Performans'),
            subtitle: Text(
              'WebP/AVIF ve küçültülmüş görseller kullanmak takılmayı azaltır.',
            ),
          ),
        ],
      ),
    ),
  );
}
