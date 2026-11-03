import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'motion.dart';
import 'workspace.dart';

class AnimationLabScreen extends StatefulWidget {
  final VoidCallback onHome, onSettings;
  final Future<void> Function(String effect) onPreview;
  const AnimationLabScreen({
    super.key,
    required this.onHome,
    required this.onSettings,
    required this.onPreview,
  });
  @override
  State<AnimationLabScreen> createState() => _AnimationLabScreenState();
}

class _AnimationLabScreenState extends State<AnimationLabScreen>
    with TickerProviderStateMixin {
  static const curves = <String, Curve>{
    'easeInOutCubic': Curves.easeInOutCubic,
    'linear': Curves.linear,
    'elasticOut': Curves.elasticOut,
  };
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final lottieController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  late CurvedAnimation curved;
  late Animation<double> rotation, scale, lift;
  String curveName = 'easeInOutCubic';
  String effect = 'flip3d';
  double speed = 1;
  bool containerExpanded = false;
  bool loop = false,
      reduced = false,
      initialized = false,
      shouldPlay = true,
      reversed = false,
      previewBusy = false;
  Duration lottieDuration = const Duration(seconds: 2);
  @override
  void initState() {
    super.initState();
    configureCurve();
  }

  void configureCurve() {
    curved = CurvedAnimation(
      parent: controller,
      curve: curves[curveName]!,
      reverseCurve: curves[curveName],
    );
    rotation = Tween<double>(begin: 0, end: math.pi * 2).animate(curved);
    scale = Tween<double>(begin: 0.85, end: 1.05).animate(curved);
    lift = Tween<double>(begin: 12, end: -12).animate(curved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      controller.stop();
      lottieController.stop();
      controller.value = 1;
      lottieController.value = 1;
    } else if (!initialized) {
      controller.forward();
    }
    initialized = true;
  }

  @override
  void dispose() {
    curved.dispose();
    controller.dispose();
    lottieController.dispose();
    super.dispose();
  }

  void play() {
    if (reduced) return;
    shouldPlay = true;
    reversed = false;
    if (loop) {
      controller.repeat(reverse: true);
      lottieController.repeat();
    } else {
      controller.forward(from: controller.value == 1 ? 0 : null);
      lottieController.forward(from: lottieController.value == 1 ? 0 : null);
    }
  }

  void pause() {
    shouldPlay = false;
    controller.stop();
    lottieController.stop();
  }

  void reverse() {
    if (reduced) return;
    setState(() => loop = false);
    shouldPlay = true;
    reversed = true;
    controller.reverse(from: controller.value == 0 ? 1 : null);
    lottieController.reverse(from: lottieController.value == 0 ? 1 : null);
  }

  void reset() {
    pause();
    controller.value = 0;
    lottieController.value = 0;
    setState(() => loop = false);
  }

  void changeSpeed(double value) {
    final running = controller.isAnimating || lottieController.isAnimating;
    final backwards = reversed;
    setState(() => speed = value);
    controller.duration = Duration(milliseconds: (1800 / speed).round());
    lottieController.duration = Duration(
      microseconds: (lottieDuration.inMicroseconds / speed).round(),
    );
    if (running) {
      if (backwards && !loop)
        reverse();
      else
        play();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Animasyon stüdyosu'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Hareketi sen yönet.',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              '3 boyutlu dönüş, zaman eğrileri ve yerel Lottie JSON animasyonu.',
            ),
            if (reduced)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Sistemin animasyon azaltma tercihi etkin. Otomatik oynatma kapalı.',
                ),
              ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: constraints.maxWidth >= 800
                        ? (constraints.maxWidth - 20) / 2
                        : constraints.maxWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AnimationController + Tween',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 260,
                              child: AnimatedBuilder(
                                animation: controller,
                                builder: (context, _) {
                                  final back = math.cos(rotation.value) < 0;
                                  return Center(
                                    child: Transform(
                                      alignment: Alignment.center,
                                      key: const Key('lab-3d-transform'),
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.0018)
                                        ..setTranslationRaw(0, lift.value, 0)
                                        ..rotateX(-0.12)
                                        ..rotateY(rotation.value)
                                        ..scaleByDouble(
                                          scale.value,
                                          scale.value,
                                          scale.value,
                                          1,
                                        ),
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.rotationY(
                                          back ? math.pi : 0,
                                        ),
                                        child: Container(
                                          width: 250,
                                          height: 180,
                                          padding: const EdgeInsets.all(22),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: back
                                                  ? [
                                                      const Color(0xFF415C87),
                                                      ink,
                                                    ]
                                                  : [accent, ink],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x33203333),
                                                blurRadius: 22,
                                                offset: Offset(0, 14),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                back
                                                    ? Icons.auto_awesome
                                                    : Icons
                                                          .folder_copy_outlined,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                              const Spacer(),
                                              Text(
                                                back
                                                    ? 'Arka yüz'
                                                    : 'ProjeDosya',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 23,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                back
                                                    ? 'Perspektif + rotateY'
                                                    : '3 boyutlu kart',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Text(
                              'Tween<double>(begin: 0, end: 2π)\nCurvedAnimation(parent: controller, curve: …)',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth >= 800
                        ? (constraints.maxWidth - 20) / 2
                        : constraints.maxWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lottie · Yerel JSON',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 272,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/animations/project_ready.json',
                                  key: const Key('lab-lottie'),
                                  controller: lottieController,
                                  fit: BoxFit.contain,
                                  onLoaded: (composition) {
                                    lottieDuration = composition.duration;
                                    lottieController.duration = Duration(
                                      microseconds:
                                          (lottieDuration.inMicroseconds /
                                                  speed)
                                              .round(),
                                    );
                                    if (!reduced && shouldPlay) {
                                      if (loop)
                                        lottieController.repeat();
                                      else if (reversed)
                                        lottieController.reverse(from: 1);
                                      else
                                        lottieController.forward();
                                    }
                                  },
                                  errorBuilder: (_, __, ___) => const Text(
                                    'JSON animasyonu yüklenemedi.',
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'project_ready.json\nAnimationController ile oynatılır.',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Oynatma kontrolü',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: reduced ? null : play,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Oynat'),
                        ),
                        OutlinedButton.icon(
                          onPressed: pause,
                          icon: const Icon(Icons.pause),
                          label: const Text('Duraklat'),
                        ),
                        OutlinedButton.icon(
                          onPressed: reduced ? null : reverse,
                          icon: const Icon(Icons.replay),
                          label: const Text('Tersine oynat'),
                        ),
                        TextButton(
                          onPressed: reset,
                          child: const Text('Sıfırla'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) => Column(
                        children: [
                          Slider(
                            key: const Key('lab-progress'),
                            value: controller.value,
                            label: '${(controller.value * 100).round()}%',
                            onChanged: (value) {
                              pause();
                              setState(() => loop = false);
                              controller.value = value;
                              lottieController.value = value;
                            },
                          ),
                          Text(
                            'İlerleme: ${(controller.value * 100).round()}%',
                            key: const Key('lab-progress-label'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: curveName,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'CurvedAnimation eğrisi',
                      ),
                      items: [
                        for (final name in curves.keys)
                          DropdownMenuItem(value: name, child: Text(name)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        final old = curved;
                        setState(() {
                          curveName = value;
                          configureCurve();
                        });
                        old.dispose();
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Hız: ${speed.toStringAsFixed(1)}x'),
                    Slider(
                      key: const Key('lab-speed'),
                      value: speed,
                      min: 0.5,
                      max: 2,
                      divisions: 3,
                      label: '${speed.toStringAsFixed(1)}x',
                      onChanged: changeSpeed,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Döngü'),
                      value: loop,
                      onChanged: reduced
                          ? null
                          : (value) {
                              setState(() => loop = value);
                              if (value)
                                play();
                              else
                                pause();
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('AnimatedContainer'),
                      subtitle: const Text(
                        'Boyut, renk ve köşe yuvarlaklığı birlikte değişir.',
                      ),
                      value: containerExpanded,
                      onChanged: (value) =>
                          setState(() => containerExpanded = value),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: AnimatedContainer(
                        key: const Key('implicit-animation'),
                        duration: reduced
                            ? Duration.zero
                            : const Duration(milliseconds: 650),
                        curve: curves[curveName]!,
                        width: containerExpanded ? 240 : 150,
                        height: containerExpanded ? 140 : 80,
                        decoration: BoxDecoration(
                          color: containerExpanded ? ink : accent,
                          borderRadius: BorderRadius.circular(
                            containerExpanded ? 32 : 10,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gerçek route geçişini dene',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: effect,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '3 boyutlu geçiş',
                      ),
                      items: [
                        for (final id in ['flip3d', 'cube3d', 'depth3d'])
                          DropdownMenuItem(
                            value: id,
                            child: Text(AppMotion.labels[id]!),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => effect = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Seçilen efekt uygulama tercihi olarak kaydedilir ve ayrı bir önizleme sayfası açılır.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: previewBusy
                          ? null
                          : () async {
                              setState(() => previewBusy = true);
                              pause();
                              try {
                                await widget.onPreview(effect);
                              } catch (_) {
                                if (context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Önizleme açılamadı.'),
                                    ),
                                  );
                              } finally {
                                if (mounted)
                                  setState(() => previewBusy = false);
                              }
                            },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Geçişi dene'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AnimationPreviewScreen extends StatelessWidget {
  final VoidCallback onBack;
  const AnimationPreviewScreen({super.key, required this.onBack});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(
      backgroundColor: ink,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: const Text('3B geçiş önizlemesi'),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.view_in_ar_rounded,
              size: 90,
              color: Color(0xFF89D4C8),
            ),
            const SizedBox(height: 28),
            Text(
              AppMotion.labels[AppMotion.style] ?? '3B geçiş',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu, iki router ile de çalışan ayrı bir route. Geri dönerken efekt ters yönde oynar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: onBack, child: const Text('Stüdyoya dön')),
          ],
        ),
      ),
    ),
  );
}
