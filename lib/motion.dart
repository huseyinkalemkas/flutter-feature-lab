import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'storage.dart';

class AppMotion {
  static const labels = {
    'slide': 'Kayma + solma',
    'fade': 'Solma',
    'flip3d': '3B kart dönüşü',
    'cube3d': '3B küp geçişi',
    'depth3d': '3B derinlik',
    'none': 'Efekt yok',
  };
  static String get style =>
      AppStorage.get('settings:motion')?['style'] as String? ?? 'slide';
  static Future<void> setStyle(String style) =>
      AppStorage.put('settings:motion', {'style': style});
  static Widget transition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (style == 'none' || MediaQuery.disableAnimationsOf(context))
      return child;
    final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    final fading = FadeTransition(opacity: curved, child: child);
    if (style == 'fade') return fading;
    if (['flip3d', 'cube3d', 'depth3d'].contains(style)) {
      return AnimatedBuilder(
        animation: Listenable.merge([animation, secondaryAnimation]),
        child: child,
        builder: (context, child) {
          final t = Curves.easeInOutCubic.transform(animation.value);
          final outgoing = Curves.easeInOutCubic.transform(
            secondaryAnimation.value,
          );
          final matrix = Matrix4.identity()..setEntry(3, 2, 0.0012);
          var alignment = Alignment.center;
          if (style == 'flip3d') {
            matrix.rotateY((1 - t) * -math.pi / 2 - outgoing * math.pi / 8);
          } else if (style == 'cube3d') {
            final width = MediaQuery.sizeOf(context).width;
            matrix.setTranslationRaw(
              width * (1 - t - outgoing),
              0,
              -90 * ((1 - t) + outgoing),
            );
            matrix.rotateY((1 - t - outgoing) * math.pi / 2);
            alignment = t < 1 ? Alignment.centerLeft : Alignment.centerRight;
          } else {
            matrix.setTranslationRaw(0, 0, -450 * (1 - t) - 100 * outgoing);
            matrix.rotateX((1 - t) * 0.22);
          }
          return Transform(
            key: ValueKey('route-3d-$style'),
            alignment: alignment,
            transform: matrix,
            child: Opacity(opacity: t.clamp(0, 1), child: child),
          );
        },
      );
    }
    return SlideTransition(
      position: curved.drive(
        Tween(begin: const Offset(0.06, 0), end: Offset.zero),
      ),
      child: fading,
    );
  }
}

class LoadingPlaceholder extends StatefulWidget {
  final String style, view;
  final int count;
  const LoadingPlaceholder({
    super.key,
    required this.style,
    required this.view,
    this.count = 4,
  });
  @override
  State<LoadingPlaceholder> createState() => _LoadingPlaceholderState();
}

class _LoadingPlaceholderState extends State<LoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.style == 'skeleton' &&
        !MediaQuery.disableAnimationsOf(context)) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget bar({double? width, double height = 14}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFDCE5E1),
      borderRadius: BorderRadius.circular(7),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (widget.style != 'skeleton')
      return const Padding(
        key: Key('standard-loading'),
        padding: EdgeInsets.all(36),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(semanticsLabel: 'Kayıtlar yükleniyor'),
              SizedBox(height: 12),
              Text('Kayıtlar yükleniyor…'),
            ],
          ),
        ),
      );
    return Semantics(
      label: 'Kayıtlar yükleniyor',
      liveRegion: true,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Opacity(
            opacity: 0.55 + controller.value * 0.45,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = widget.view == 'grid'
                    ? (constraints.maxWidth >= 900
                          ? 3
                          : constraints.maxWidth >= 600
                          ? 2
                          : 1)
                    : 1;
                return Wrap(
                  key: const Key('skeleton-loading'),
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < widget.count; i++)
                      SizedBox(
                        width:
                            (constraints.maxWidth - (columns - 1) * 16) /
                            columns,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: widget.view == 'grid'
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    bar(width: 40, height: 32),
                                    const SizedBox(height: 20),
                                    bar(),
                                    const SizedBox(height: 12),
                                    bar(width: 120),
                                  ],
                                )
                              : Row(
                                  children: [
                                    bar(width: 40, height: 40),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          bar(),
                                          const SizedBox(height: 12),
                                          bar(width: 110),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
