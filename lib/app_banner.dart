import 'package:flutter/material.dart';

import 'motion.dart';
import 'network.dart';
import 'storage.dart';
import 'workspace.dart';

/// Router ilk kurulurken de bildirim gönderebilir; başlık güvenli karede yenilenir.
class BannerRouteListener extends StatefulWidget {
  final Listenable listenable;
  final WidgetBuilder builder;
  const BannerRouteListener({
    super.key,
    required this.listenable,
    required this.builder,
  });
  @override
  State<BannerRouteListener> createState() => _BannerRouteListenerState();
}

class _BannerRouteListenerState extends State<BannerRouteListener> {
  bool scheduled = false;
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(changed);
  }

  @override
  void didUpdateWidget(BannerRouteListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(changed);
      widget.listenable.addListener(changed);
    }
  }

  void changed() {
    if (scheduled || !mounted) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  void dispose() {
    widget.listenable.removeListener(changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

class AppControlBanner extends StatelessWidget {
  final String currentPath, engine, backTooltip;
  final NetworkMonitor? network;
  final ValueChanged<String> onNavigate, onEngineChanged;
  final VoidCallback onSettings, onNewProject, onAddCustomer, onBack;
  const AppControlBanner({
    super.key,
    required this.currentPath,
    required this.engine,
    required this.onNavigate,
    required this.onEngineChanged,
    required this.onSettings,
    required this.onNewProject,
    required this.onAddCustomer,
    required this.onBack,
    required this.backTooltip,
    this.network,
  });

  static const destinations = [
    ('/', 'Projeler', 'Projeler', Icons.folder_outlined),
    ('/project-list', 'Sayfalama', 'Sayfalı liste', Icons.view_list_outlined),
    ('/animation-lab', 'Animasyon', 'Animasyon stüdyosu', Icons.animation),
    (
      '/sync-async',
      'Sync / Async',
      'Sync / Async Laboratuvarı',
      Icons.timeline,
    ),
    (
      '/hive-example',
      'Hive CE · Notlar',
      'Hive CE · Notlar',
      Icons.note_alt_outlined,
    ),
    (
      '/preferences-example',
      'Shared Preferences · Tercihler',
      'Shared Preferences · Tercihler',
      Icons.tune,
    ),
    (
      '/sqlite-example',
      'sqflite · Görevler',
      'sqflite · Görevler',
      Icons.checklist,
    ),
    (
      '/stream-example',
      'Stream / StreamBuilder',
      'Stream / StreamBuilder',
      Icons.sensors,
    ),
    (
      '/network-lab',
      'Socket + HTTP',
      'TCP soketi ve HTTP laboratuvarı',
      Icons.hub_outlined,
    ),
    (
      '/device-info',
      'Device Info',
      'Cihaz bilgileri',
      Icons.phone_android_outlined,
    ),
    ('/app-info', 'App Info', 'Uygulama bilgileri', Icons.apps_outlined),
    ('/network-info', 'Network Info', 'Ağ bilgileri', Icons.wifi_find_rounded),
    (
      '/mvvm-dashboard',
      'MVVM Finans',
      'MVVM para birimi ve haber örneği',
      Icons.dashboard_customize_outlined,
    ),
    (
      '/image-precache',
      'Image Precache',
      'Base64, S3 ve görsel cache yardımcısı',
      Icons.image_search_outlined,
    ),
    ('/demo', 'Route örnekleri', 'Route örnekleri', Icons.science_outlined),
    ('/profile/ayse', 'Profil', 'Profil', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) => Material(
    key: const Key('app-control-banner'),
    color: ink,
    elevation: 2,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder_copy_outlined,
                  color: Color(0xFF89D4C8),
                  size: 23,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'ProjeDosya',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _NetworkPill(monitor: network),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Ayarlar',
                  onPressed: onSettings,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  tooltip: backTooltip,
                  onPressed: currentPath == '/' ? null : onBack,
                  icon: Icon(
                    Icons.arrow_back,
                    color: currentPath == '/' ? Colors.white30 : Colors.white,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    key: const Key('banner-navigation'),
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      for (final destination in destinations)
                        Tooltip(
                          message: destination.$3,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  currentPath == destination.$1 ||
                                      (destination.$1 == '/' &&
                                          currentPath.startsWith('/projects/'))
                                  ? accent
                                  : null,
                            ),
                            onPressed: () => onNavigate(destination.$1),
                            icon: Icon(destination.$4, size: 18),
                            label: Text(destination.$2),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              key: const Key('banner-actions'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: onNewProject,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Yeni proje'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                    ),
                    onPressed: onAddCustomer,
                    icon: const Icon(Icons.person_add_alt, size: 18),
                    label: const Text('Müşteri ekle'),
                  ),
                  const SizedBox(width: 16),
                  _HeaderDropdown(
                    label: 'Router',
                    child: DropdownButton<String>(
                      key: const Key('banner-router'),
                      value: engine,
                      underline: const SizedBox.shrink(),
                      dropdownColor: ink,
                      iconEnabledColor: Colors.white70,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: const [
                        DropdownMenuItem(
                          value: 'auto_route',
                          child: Text('auto_route'),
                        ),
                        DropdownMenuItem(
                          value: 'go_router',
                          child: Text('go_router'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null && value != engine)
                          onEngineChanged(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ListenableBuilder(
                    listenable: AppStorage.changes,
                    builder: (context, _) => _HeaderDropdown(
                      label: 'Efekt',
                      child: DropdownButton<String>(
                        key: const Key('banner-effect'),
                        value: AppMotion.style,
                        underline: const SizedBox.shrink(),
                        dropdownColor: ink,
                        iconEnabledColor: Colors.white70,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        items: [
                          for (final effect in AppMotion.labels.entries)
                            DropdownMenuItem(
                              value: effect.key,
                              child: Text(effect.value),
                            ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          try {
                            await AppMotion.setStyle(value);
                          } catch (_) {
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Efekt tercihi kaydedilemedi.'),
                                ),
                              );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HeaderDropdown extends StatelessWidget {
  final String label;
  final Widget child;
  const _HeaderDropdown({required this.label, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        child,
      ],
    ),
  );
}

class _NetworkPill extends StatelessWidget {
  final NetworkMonitor? monitor;
  const _NetworkPill({this.monitor});
  @override
  Widget build(BuildContext context) {
    Widget content() {
      final m = monitor;
      final online = m?.status == NetworkStatus.online;
      final checking = m?.checking ?? false;
      final label = m == null
          ? 'Yerel mod'
          : checking
          ? 'Kontrol…'
          : online
          ? 'Çevrimiçi'
          : m.status == NetworkStatus.offline
          ? 'Çevrimdışı'
          : 'Belirsiz';
      final color = m == null || checking
          ? Colors.white70
          : online
          ? const Color(0xFF89D4C8)
          : const Color(0xFFFFD48A);
      return Tooltip(
        message: m == null ? 'Ağ kontrolü kapalı' : 'Bağlantıyı kontrol et',
        child: InkWell(
          onTap: m == null || checking ? null : m.check,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (checking)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                else
                  Icon(
                    online ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: color,
                  ),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    return monitor == null
        ? content()
        : ListenableBuilder(
            listenable: monitor!,
            builder: (context, _) => content(),
          );
  }
}
