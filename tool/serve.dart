import 'dart:io';

Future<void> main(List<String> arguments) async {
  final root = Directory('build/web').absolute;
  if (!File.fromUri(root.uri.resolve('index.html')).existsSync()) {
    stderr.writeln('Önce .\\flutter.ps1 build web --release çalıştırın.');
    exitCode = 1;
    return;
  }
  const port = 7357;
  const url = 'http://localhost:$port';
  late HttpServer server;
  try {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  } on SocketException {
    stderr.writeln(
      '$port bağlantı noktası kullanımda. Açık ProjeDosya oturumunu kontrol edin.',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln('ProjeDosya hazır: $url\nDurdurmak için Ctrl+C.');
  if (!arguments.contains('--no-open')) {
    try {
      if (Platform.isWindows) {
        const edge =
            r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe';
        if (File(edge).existsSync()) {
          await Process.start(edge, [
            '--app=$url',
          ], mode: ProcessStartMode.detached);
        } else {
          await Process.start('explorer.exe', [
            url,
          ], mode: ProcessStartMode.detached);
        }
      } else {
        await Process.start(Platform.isMacOS ? 'open' : 'xdg-open', [
          url,
        ], mode: ProcessStartMode.detached);
      }
    } catch (_) {
      stdout.writeln('Tarayıcınızda $url adresini açın.');
    }
  }
  const types = {
    'html': 'text/html; charset=utf-8',
    'js': 'application/javascript; charset=utf-8',
    'json': 'application/json; charset=utf-8',
    'css': 'text/css; charset=utf-8',
    'wasm': 'application/wasm',
    'png': 'image/png',
    'svg': 'image/svg+xml',
    'ico': 'image/x-icon',
    'woff2': 'font/woff2',
    'ttf': 'font/ttf',
  };
  await for (final request in server) {
    try {
      if (request.method != 'GET' && request.method != 'HEAD') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
        continue;
      }
      final segments = request.uri.pathSegments;
      if (segments.any(
        (segment) =>
            segment == '..' || segment.contains('\\') || segment.contains('/'),
      )) {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
        continue;
      }
      final relative = segments
          .where((segment) => segment.isNotEmpty)
          .join('/');
      final file = File.fromUri(
        root.uri.resolve(relative.isEmpty ? 'index.html' : relative),
      );
      if (!file.existsSync()) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        continue;
      }
      request.response.headers.set(
        HttpHeaders.contentTypeHeader,
        types[file.path.split('.').last] ?? 'application/octet-stream',
      );
      request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
      request.response.contentLength = await file.length();
      if (request.method == 'GET')
        await request.response.addStream(file.openRead());
      await request.response.close();
    } catch (_) {
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }
}
