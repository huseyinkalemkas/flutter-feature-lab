import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class NetworkLabScreen extends StatefulWidget {
  final VoidCallback? onHome;
  const NetworkLabScreen({super.key, this.onHome});
  @override
  State<NetworkLabScreen> createState() => _NetworkLabScreenState();
}

class _NetworkLabScreenState extends State<NetworkLabScreen> {
  final host = TextEditingController(text: 'example.com');
  final port = TextEditingController(text: '80');
  String status = 'Hazır';
  String output = 'TCP soketi açıp HTTP GET isteği gönderebilirsiniz.';
  bool busy = false;

  @override
  void dispose() {
    host.dispose();
    port.dispose();
    super.dispose();
  }

  Future<void> runRequest() async {
    if (busy) return;
    setState(() {
      busy = true;
      status = 'Bağlanıyor…';
      output = '';
    });
    Socket? socket;
    try {
      final target = host.text.trim();
      final targetPort = int.tryParse(port.text.trim()) ?? 80;
      socket = await Socket.connect(
        target,
        targetPort,
        timeout: const Duration(seconds: 8),
      );
      setState(() => status = 'TCP bağlı — HTTP isteği gönderiliyor');
      socket.write(
        'GET / HTTP/1.1\r\nHost: $target\r\nConnection: close\r\n\r\n',
      );
      final data = <int>[];
      await for (final chunk in socket) {
        data.addAll(chunk);
      }
      final text = utf8.decode(data, allowMalformed: true);
      if (!mounted) return;
      setState(() {
        status = 'Tamamlandı (${data.length} byte)';
        output = text;
      });
    } catch (error) {
      if (mounted)
        setState(() {
          status = 'Hata';
          output = '$error';
        });
    } finally {
      socket?.destroy();
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Socket + HTTP Lab'),
      leading: widget.onHome == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onHome,
            ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'TCP soketi üzerinden HTTP çıkışı',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Bu demo, ham TCP bağlantısı açar ve HTTP/1.1 GET isteğini doğrudan sokete yazar.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: host,
                decoration: const InputDecoration(
                  labelText: 'Host',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextField(
                controller: port,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: busy ? null : runRequest,
          icon: const Icon(Icons.send),
          label: Text(busy ? 'Çalışıyor…' : 'HTTP isteği gönder'),
        ),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: Icon(
              status == 'Hata' ? Icons.error_outline : Icons.lan_outlined,
            ),
            title: const Text('Durum'),
            subtitle: Text(status),
          ),
        ),
        const SizedBox(height: 12),
        SelectableText(
          output,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ],
    ),
  );
}
