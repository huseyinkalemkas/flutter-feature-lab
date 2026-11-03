import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum NetworkStatus { unknown, online, offline }

class NetworkMonitor extends ChangeNotifier with WidgetsBindingObserver {
  final Future<bool> Function() checkInternet;
  final Stream<bool> changes;
  final Future<void> Function()? closeConnection;
  NetworkMonitor({
    required this.checkInternet,
    required this.changes,
    this.closeConnection,
  });
  factory NetworkMonitor.live() {
    final connection = InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 5),
    );
    return NetworkMonitor(
      checkInternet: () => connection.hasInternetAccess,
      changes: connection.onStatusChange.map(
        (status) => status == InternetStatus.connected,
      ),
      closeConnection: connection.dispose,
    );
  }

  StreamSubscription<bool>? subscription;
  NetworkStatus status = NetworkStatus.unknown;
  bool checking = true, started = false, closed = false;
  DateTime? lastChecked;
  int generation = 0;
  void start() {
    if (started || closed) return;
    started = true;
    WidgetsBinding.instance.addObserver(this);
    subscribe();
  }

  void subscribe() {
    if (closed || subscription != null) return;
    subscription = changes.listen(
      (connected) {
        if (closed) return;
        generation++;
        status = connected ? NetworkStatus.online : NetworkStatus.offline;
        checking = false;
        lastChecked = DateTime.now();
        notifyListeners();
      },
      onError: (Object _) {
        if (closed) return;
        generation++;
        checking = false;
        status = NetworkStatus.unknown;
        notifyListeners();
      },
    );
  }

  Future<void> check() async {
    if (closed) return;
    final token = ++generation;
    checking = true;
    notifyListeners();
    try {
      final connected = await checkInternet().timeout(
        const Duration(seconds: 7),
      );
      if (closed || token != generation) return;
      status = connected ? NetworkStatus.online : NetworkStatus.offline;
    } catch (_) {
      if (closed || token != generation) return;
      status = NetworkStatus.unknown;
    }
    checking = false;
    lastChecked = DateTime.now();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      generation++;
      unawaited(subscription?.cancel() ?? Future<void>.value());
      subscription = null;
    } else if (state == AppLifecycleState.resumed && started && !closed) {
      if (subscription == null)
        subscribe();
      else
        unawaited(check());
    }
  }

  @override
  void dispose() {
    closed = true;
    generation++;
    if (started) WidgetsBinding.instance.removeObserver(this);
    unawaited(subscription?.cancel() ?? Future<void>.value());
    final close = closeConnection;
    if (close != null) unawaited(close());
    super.dispose();
  }
}

class NetworkScope extends InheritedWidget {
  final NetworkMonitor? monitor;
  const NetworkScope({super.key, required this.monitor, required super.child});
  static NetworkMonitor? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NetworkScope>()?.monitor;
  @override
  bool updateShouldNotify(NetworkScope oldWidget) =>
      monitor != oldWidget.monitor;
}

class NetworkBannerHost extends StatefulWidget {
  final NetworkMonitor? monitor;
  final Widget child;
  final Widget? header;
  const NetworkBannerHost({
    super.key,
    required this.monitor,
    required this.child,
    this.header,
  });
  @override
  State<NetworkBannerHost> createState() => _NetworkBannerHostState();
}

class _NetworkBannerHostState extends State<NetworkBannerHost> {
  Timer? hideTimer;
  bool visible = true;
  @override
  void initState() {
    super.initState();
    widget.monitor?.addListener(changed);
    scheduleHide();
  }

  @override
  void didUpdateWidget(NetworkBannerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monitor != widget.monitor) {
      oldWidget.monitor?.removeListener(changed);
      widget.monitor?.addListener(changed);
      visible = true;
      scheduleHide();
    }
  }

  void scheduleHide() {
    hideTimer?.cancel();
    if (widget.monitor?.status == NetworkStatus.online &&
        widget.monitor?.checking == false) {
      hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => visible = false);
      });
    }
  }

  void changed() {
    if (!mounted) return;
    setState(() => visible = true);
    scheduleHide();
  }

  void dismiss() {
    hideTimer?.cancel();
    setState(() => visible = false);
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    widget.monitor?.removeListener(changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monitor = widget.monitor;
    if (monitor == null && widget.header == null)
      return NetworkScope(monitor: null, child: widget.child);
    final online = monitor?.status == NetworkStatus.online;
    final checking = monitor?.checking ?? false;
    final showBanner = monitor != null && visible;
    final message = checking
        ? 'İnternet bağlantısı kontrol ediliyor…'
        : online
        ? 'İnternet bağlantısı doğrulandı.'
        : monitor?.status == NetworkStatus.offline
        ? 'İnternet erişimi doğrulanamadı. Yerel müşteri, proje ve dosyalarınızı kullanabilirsiniz.'
        : 'Bağlantı durumu kontrol edilemedi. Yerel kayıtlar kullanılabilir.';
    return NetworkScope(
      monitor: monitor,
      child: Column(
        children: [
          if (widget.header != null) widget.header!,
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: showBanner
                ? SafeArea(
                    top: widget.header == null,
                    bottom: false,
                    child: MaterialBanner(
                      key: const Key('network-banner'),
                      backgroundColor: checking
                          ? const Color(0xFFEEF2F5)
                          : online
                          ? const Color(0xFFDDF3E7)
                          : const Color(0xFFFFF0D5),
                      leading: checking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: 'Ağ kontrolü',
                              ),
                            )
                          : Icon(
                              online
                                  ? Icons.wifi_rounded
                                  : Icons.wifi_off_rounded,
                              color: online
                                  ? const Color(0xFF087F73)
                                  : const Color(0xFF805313),
                            ),
                      content: Semantics(
                        liveRegion: true,
                        child: Text(message),
                      ),
                      forceActionsBelow: widget.header == null,
                      actions: [
                        if (!online || checking || widget.header == null)
                          TextButton(
                            onPressed: checking ? null : monitor.check,
                            child: Text(
                              checking ? 'Kontrol ediliyor' : 'Tekrar dene',
                            ),
                          ),
                        if (online && !checking)
                          TextButton(
                            onPressed: dismiss,
                            child: const Text('Kapat'),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: widget.header != null || showBanner,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class NetworkSettingsTile extends StatelessWidget {
  final NetworkMonitor monitor;
  const NetworkSettingsTile({super.key, required this.monitor});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: monitor,
    builder: (context, _) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        monitor.status == NetworkStatus.online ? Icons.wifi : Icons.wifi_off,
      ),
      title: const Text('İnternet bağlantısı'),
      subtitle: Text(
        monitor.checking
            ? 'Kontrol ediliyor…'
            : switch (monitor.status) {
                NetworkStatus.online => 'İnternet erişimi var',
                NetworkStatus.offline => 'İnternet erişimi doğrulanamadı',
                NetworkStatus.unknown => 'Durum bilinmiyor',
              },
      ),
      trailing: IconButton(
        tooltip: 'Bağlantıyı kontrol et',
        onPressed: monitor.checking ? null : monitor.check,
        icon: const Icon(Icons.refresh),
      ),
    ),
  );
}
