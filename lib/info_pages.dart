import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'network.dart';

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key});
  @override
  Widget build(BuildContext context) => _InfoScaffold(
    title: 'Device Info',
    icon: Icons.phone_android_outlined,
    future: _deviceInfo(),
  );

  Future<Map<String, String>> _deviceInfo() async {
    final info = DeviceInfoPlugin();
    final data = <String, String>{};
    try {
      final android = await info.androidInfo;
      data.addAll({
        'Platform': 'Android',
        'Model': android.model,
        'Manufacturer': android.manufacturer,
        'Brand': android.brand,
        'Android version': android.version.release,
        'SDK': '${android.version.sdkInt}',
        'Device': android.device,
      });
    } catch (_) {
      try {
        final ios = await info.iosInfo;
        data.addAll({
          'Platform': 'iOS',
          'Model': ios.utsname.machine,
          'Name': ios.name,
          'System version': ios.systemVersion,
          'Identifier': ios.identifierForVendor ?? '—',
        });
      } catch (_) {
        data['Platform'] = 'Web / desteklenmeyen platform';
      }
    }
    return data;
  }
}

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});
  @override
  Widget build(BuildContext context) => _InfoScaffold(
    title: 'App Info',
    icon: Icons.apps_outlined,
    future: _appInfo(),
  );

  Future<Map<String, String>> _appInfo() async {
    final info = await PackageInfo.fromPlatform();
    return {
      'Application': info.appName,
      'Package': info.packageName,
      'Version': info.version,
      'Build number': info.buildNumber,
      'Installer': info.installerStore ?? '—',
    };
  }
}

class NetworkInfoPage extends StatelessWidget {
  const NetworkInfoPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Network Info')),
    body: ListenableBuilder(
      listenable:
          NetworkScope.of(context) ??
          NetworkMonitor(
            checkInternet: () async => false,
            changes: const Stream.empty(),
          ),
      builder: (context, _) {
        final monitor = NetworkScope.of(context);
        final status = monitor?.status ?? NetworkStatus.unknown;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.wifi_find_rounded, size: 64),
            const SizedBox(height: 12),
            _InfoRow(label: 'Internet status', value: status.name),
            _InfoRow(label: 'Checking', value: '${monitor?.checking ?? false}'),
            _InfoRow(
              label: 'Last checked',
              value: monitor?.lastChecked?.toLocal().toString() ?? '—',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: monitor?.checking == true ? null : monitor?.check,
              icon: const Icon(Icons.refresh),
              label: const Text('Check again'),
            ),
          ],
        );
      },
    ),
  );
}

class _InfoScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<Map<String, String>> future;
  const _InfoScaffold({
    required this.title,
    required this.icon,
    required this.future,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: FutureBuilder<Map<String, String>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 16),
            for (final entry in snapshot.data!.entries)
              _InfoRow(label: entry.key, value: entry.value),
          ],
        );
      },
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(title: Text(label), subtitle: SelectableText(value)),
  );
}
