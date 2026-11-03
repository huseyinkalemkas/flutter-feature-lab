import 'package:flutter/material.dart';

/// A timeline simulation: waiting for I/O overlaps; CPU work is not parallelized.
class SyncAsyncScreen extends StatefulWidget {
  final VoidCallback onHome;
  const SyncAsyncScreen({super.key, required this.onHome});
  @override
  State<SyncAsyncScreen> createState() => _SyncAsyncScreenState();
}

class _SyncAsyncScreenState extends State<SyncAsyncScreen>
    with SingleTickerProviderStateMixin {
  late final clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  double speed = 1;
  void start() {
    if (clock.value == 1) clock.reset();
    clock.animateTo(
      1,
      duration: Duration(
        milliseconds: ((1 - clock.value) * 6000 / speed).round(),
      ),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  Widget timeline(bool async, double seconds) {
    final total = async ? 3 : 6;
    final color = async ? Colors.deepPurple : Colors.teal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              async ? 'Async — beklerken devam et' : 'Sync — sırayla bekle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              async
                  ? 'Bağımsız istekler birlikte başlatılır.'
                  : 'Bir istek bitmeden sonraki başlamaz.',
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < 3; i++) ...[
              Text(
                [
                  'Kullanıcı · 3 sn',
                  'Fotoğraflar · 2 sn',
                  'Mesajlar · 1 sn',
                ][i],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final begin = async ? 0 : [0, 3, 5][i];
                  final elapsed = (seconds - begin).clamp(0, 3 - i);
                  return Container(
                    height: 28,
                    color: color.withValues(alpha: 0.08),
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: constraints.maxWidth * begin / 6,
                      ),
                      child: Container(
                        width: constraints.maxWidth * elapsed / 6,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
            ],
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('0 sn'), Text('3 sn'), Text('6 sn')],
            ),
            const Divider(height: 30),
            Text(
              '${seconds.clamp(0, total).toStringAsFixed(1)} / $total sn',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              seconds >= total
                  ? 'Tamamlandı'
                  : seconds == 0
                  ? 'Hazır'
                  : 'İstekler işleniyor',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Sync / Async Laboratuvarı'),
    ),
    body: AnimatedBuilder(
      animation: clock,
      builder: (context, _) {
        final seconds = clock.value * 6;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Aynı işler. Farklı akışlar.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Üç ağ isteğinin bekleme sürelerini karşılaştır. Bu bir zaman çizelgesi simülasyonudur.',
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        if (clock.isAnimating) {
                          clock.stop();
                        } else {
                          start();
                        }
                      }),
                      icon: Icon(
                        clock.isAnimating ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(
                        clock.isAnimating
                            ? 'Duraklat'
                            : clock.value == 1
                            ? 'Tekrar oynat'
                            : clock.value == 0
                            ? 'Başlat'
                            : 'Devam et',
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => setState(clock.reset),
                      child: const Text('Sıfırla'),
                    ),
                    DropdownButton<double>(
                      value: speed,
                      items: [0.5, 1.0, 2.0]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text('${v}× hız'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        speed = value!;
                        if (clock.isAnimating) start();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth < 700
                      ? Column(
                          children: [
                            timeline(false, seconds),
                            timeline(true, seconds),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: timeline(false, seconds)),
                            Expanded(child: timeline(true, seconds)),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  seconds >= 3
                      ? 'Async tamamlandı: max(3, 2, 1) = 3 sn. Sync toplamı: 3 + 2 + 1 = 6 sn.'
                      : 'Beklemek, çalışmak değildir. Async akışta bağımsız I/O beklemeleri örtüşür.',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dart ile deneyelim',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const SelectableText(
                  '// Asenkron istekleri sırayla beklemek: 6 sn\nawait istek("Kullanıcı");\nawait istek("Fotoğraflar");\nawait istek("Mesajlar");\n\n// Bağımsız istekleri birlikte başlatmak: 3 sn\nawait Future.wait([\n  istek("Kullanıcı"),\n  istek("Fotoğraflar"),\n  istek("Mesajlar"),\n]);',
                  style: TextStyle(fontFamily: 'monospace', height: 1.7),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Async her zaman paralel veya daha hızlı demek değildir. Ayrı ayrı await edilen asenkron istekler de sırayla yürür; ancak bekleme sırasında olay döngüsünü bloklamaz. CPU işi için async tek başına hız kazandırmaz.',
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
