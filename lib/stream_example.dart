import 'dart:async';

import 'package:flutter/material.dart';

/// Akış build içinde oluşturulmaz; StreamBuilder aynı akışı dinler.
class StreamExampleScreen extends StatefulWidget {
  const StreamExampleScreen({super.key});

  @override
  State<StreamExampleScreen> createState() => _StreamExampleScreenState();
}

class _StreamExampleScreenState extends State<StreamExampleScreen> {
  late StreamController<int> controller;
  late Stream<int> stream;
  Timer? timer;
  int count = 0;
  int generation = 0;
  bool running = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    createStream();
  }

  void createStream() {
    controller = StreamController<int>();
    stream = controller.stream;
  }

  void start() {
    if (running || finished) return;
    setState(() => running = true);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Veri değişimi için setState gerekmez; StreamBuilder olayı dinler.
      controller.add(++count);
    });
  }

  void pause() {
    timer?.cancel();
    timer = null;
    setState(() => running = false);
  }

  void finish() {
    pause();
    setState(() => finished = true);
    unawaited(controller.close());
  }

  void reset() {
    timer?.cancel();
    unawaited(controller.close());
    setState(() {
      count = 0;
      running = false;
      finished = false;
      generation++;
      createStream();
    });
  }

  void showError() {
    pause();
    controller.addError('Örnek bağlantı hatası');
  }

  @override
  void dispose() {
    timer?.cancel();
    unawaited(controller.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Stream ve StreamBuilder'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          key: const Key('stream-example-scroll'),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Stream zaman içinde birden fazla veri gönderir. StreamBuilder bu akışı dinler ve yeni veri geldikçe ekranı günceller.',
              ),
              const SizedBox(height: 20),
              StreamBuilder<int>(
                key: ValueKey(generation),
                stream: stream,
                builder: (context, snapshot) {
                  final state = snapshot.connectionState;
                  final status = snapshot.hasError
                      ? 'Hata: ${snapshot.error}'
                      : state == ConnectionState.done
                      ? 'Akış tamamlandı'
                      : state == ConnectionState.waiting
                      ? 'İlk veri bekleniyor'
                      : 'Yeni veri alındı';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status, key: const Key('stream-status')),
                          const SizedBox(height: 12),
                          Text(
                            snapshot.hasData ? '${snapshot.data}' : '—',
                            key: const Key('stream-value'),
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 12),
                          Text('connectionState: ${state.name}'),
                          Text(
                            'hasData: ${snapshot.hasData} · hasError: ${snapshot.hasError}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                finished
                    ? 'Üretici kapatıldı.'
                    : running
                    ? 'Her saniye bir sayı gönderiliyor.'
                    : 'Üretici duruyor; yeni veri gönderilmiyor.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: running || finished ? null : start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Başlat'),
                  ),
                  OutlinedButton(
                    onPressed: running ? pause : null,
                    child: const Text('Duraklat'),
                  ),
                  OutlinedButton(
                    onPressed: finished ? null : showError,
                    child: const Text('Hata gönder'),
                  ),
                  OutlinedButton(
                    onPressed: finished ? null : finish,
                    child: const Text('Akışı bitir'),
                  ),
                  TextButton(onPressed: reset, child: const Text('Sıfırla')),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Deneyin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Başlat ile sayıları izleyin. Duraklat veri üretimini durdurur; StreamBuilder dinlemeye devam eder. Hata gönder ile hata durumunu görün; Başlat ile yeni veri gelince hata temizlenir. Akışı bitir sonrasında yeni veri gönderilemez. Sıfırla yeni bir akış oluşturur.',
              ),
              const SizedBox(height: 24),
              const Text(
                'Temel kullanım',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const SelectableText('''// State içinde, build dışında oluştur:
final controller = StreamController<int>();

// Veriyi gönder:
controller.add(1);
controller.addError('Örnek hata');

// Widget içinde dinle:
StreamBuilder<int>(
  stream: controller.stream,
  builder: (context, snapshot) {
    if (snapshot.hasError) return Text('Hata oluştu');
    if (snapshot.connectionState == ConnectionState.done) {
      return Text('Akış tamamlandı');
    }
    if (!snapshot.hasData) return Text('Veri bekleniyor');
    return Text('\${snapshot.data}');
  },
);

// dispose içinde kaynakları temizle:
timer?.cancel();
controller.close();
// StreamBuilder kendi aboneliğini otomatik iptal eder.'''),
            ],
          ),
        ),
      ),
    ),
  );
}
