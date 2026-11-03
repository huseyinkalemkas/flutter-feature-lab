import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'storage.dart';

enum MediaKind { image, pdf, audio }

class MediaAttachment {
  final String id, name;
  final MediaKind kind;
  final Uint8List bytes;
  final String? projectId;
  final String note;
  final bool favorite;
  final DateTime createdAt;
  MediaAttachment({
    required this.id,
    required this.name,
    required this.kind,
    required this.bytes,
    this.projectId,
    this.note = '',
    this.favorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MediaAttachment copyWith({
    String? name,
    String? projectId,
    String? note,
    bool? favorite,
  }) => MediaAttachment(
    id: id,
    name: name ?? this.name,
    kind: kind,
    bytes: bytes,
    projectId: projectId ?? this.projectId,
    note: note ?? this.note,
    favorite: favorite ?? this.favorite,
    createdAt: createdAt,
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'kind': kind.index,
    'bytes': bytes,
    'projectId': projectId,
    'note': note,
    'favorite': favorite,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
  factory MediaAttachment.fromMap(Map<String, dynamic> map) => MediaAttachment(
    id: map['id'] as String,
    name: map['name'] as String,
    kind: MediaKind.values[map['kind'] as int],
    bytes: map['bytes'] is Uint8List
        ? map['bytes'] as Uint8List
        : Uint8List.fromList((map['bytes'] as List).cast<int>()),
    projectId: map['projectId'] as String?,
    note: map['note'] as String? ?? '',
    favorite: map['favorite'] as bool? ?? false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
  );

  static MediaKind? kindForName(String name) {
    final extension = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension))
      return MediaKind.image;
    if (extension == 'pdf') return MediaKind.pdf;
    if (['mp3', 'wav', 'm4a', 'ogg'].contains(extension))
      return MediaKind.audio;
    return null;
  }

  String get label => switch (kind) {
    MediaKind.image => 'Fotoğraf',
    MediaKind.pdf => 'PDF',
    MediaKind.audio => 'Ses',
  };
  String get mimeType => switch (name.split('.').last.toLowerCase()) {
    'mp3' => 'audio/mpeg',
    'wav' => 'audio/wav',
    'm4a' => 'audio/mp4',
    'ogg' => 'audio/ogg',
    _ => 'application/octet-stream',
  };
}

class MediaStore {
  static Future<void> add(MediaAttachment media) =>
      AppStorage.put('media:${media.id}', media.toMap());
  static MediaAttachment? find(String id) {
    final map = AppStorage.get('media:$id');
    return map == null ? null : MediaAttachment.fromMap(map);
  }

  static List<MediaAttachment> get all =>
      AppStorage.records('media:').map(MediaAttachment.fromMap).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  static Future<void> remove(String id) => AppStorage.remove('media:$id');
  static Future<void> clear() async {
    for (final item in all) {
      await remove(item.id);
    }
  }
}

class MediaPickerCard extends StatefulWidget {
  final Future<void> Function(MediaAttachment) onSelected;
  const MediaPickerCard({super.key, required this.onSelected});
  @override
  State<MediaPickerCard> createState() => _MediaPickerCardState();
}

class _MediaPickerCardState extends State<MediaPickerCard> {
  bool loading = false;
  String? error;
  Future<void> pick() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'webp',
          'gif',
          'mp3',
          'wav',
          'm4a',
          'ogg',
        ],
        allowMultiple: false,
        withData: false,
        withReadStream: true,
      );
      if (result == null || !mounted) return;
      final file = result.files.single;
      const maxBytes = 20 * 1024 * 1024;
      if (file.size > maxBytes)
        throw const FormatException('En fazla 20 MB dosya seçebilirsiniz.');
      final kind = MediaAttachment.kindForName(file.name);
      if (kind == null)
        throw const FormatException('Bu dosya türü desteklenmiyor.');
      final bytes = await readMediaBytes(file, maxBytes: maxBytes);
      if (bytes.isEmpty || bytes.length > maxBytes)
        throw const FormatException('Dosya boş veya 20 MB sınırını aşıyor.');
      if (!mounted) return;
      await widget.onSelected(
        MediaAttachment(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: file.name,
          kind: kind,
          bytes: bytes,
        ),
      );
    } catch (exception) {
      if (mounted)
        setState(
          () => error = exception is FormatException
              ? exception.message
              : 'Dosya okunamadı. Başka bir dosya seçin.',
        );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projeye dosya ekle',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'PDF, fotoğraf ve ses kayıtlarını projenizde bir arada tutun.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : pick,
            icon: const Icon(Icons.attach_file),
            label: Text(loading ? 'Dosya okunuyor…' : 'Dosya seç ve aç'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dosya başına en fazla 20 MB. Dosyalar bu cihazda saklanır.',
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<Uint8List> readMediaBytes(
  PlatformFile file, {
  required int maxBytes,
}) async {
  if (file.size > maxBytes)
    throw const FormatException('En fazla 20 MB dosya seçebilirsiniz.');
  if (file.bytes != null) {
    if (file.bytes!.length > maxBytes)
      throw const FormatException('Dosya 20 MB sınırını aşıyor.');
    return file.bytes!;
  }
  final stream = file.readStream;
  if (stream != null) {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      if (builder.length + chunk.length > maxBytes) {
        throw const FormatException('Dosya 20 MB sınırını aşıyor.');
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }
  // Web'de PlatformFile.xFile, bytes boşken kullanılamaz.
  throw const FormatException(
    'Dosya içeriği alınamadı. Dosyayı yeniden seçin.',
  );
}

class MediaViewer extends StatelessWidget {
  final MediaAttachment media;
  const MediaViewer({super.key, required this.media});
  @override
  Widget build(BuildContext context) => switch (media.kind) {
    MediaKind.image => InteractiveViewer(
      minScale: 0.5,
      maxScale: 5,
      child: Center(
        child: Image.memory(
          media.bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Text(
              'Fotoğraf açılamadı. Dosya bozuk veya biçimi desteklenmiyor.',
            ),
          ),
        ),
      ),
    ),
    MediaKind.pdf => PdfViewer.data(
      media.bytes,
      sourceName: media.id,
      params: PdfViewerParams(
        errorBannerBuilder: (_, __, ___, ____) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'PDF açılamadı. Dosya bozuk veya parola korumalı olabilir. Başka bir dosya seçin.',
            ),
          ),
        ),
      ),
    ),
    MediaKind.audio => AudioViewer(media: media),
  };
}

class AudioViewer extends StatefulWidget {
  final MediaAttachment media;
  const AudioViewer({super.key, required this.media});
  @override
  State<AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<AudioViewer> {
  final player = AudioPlayer();
  String? error;
  bool busy = false;
  Future<void> action(Future<void> Function() callback) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await callback();
    } catch (_) {
      if (mounted)
        setState(
          () => error = 'Ses oynatılamadı. Dosya biçimini kontrol edin.',
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String time(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.graphic_eq, size: 80),
          const SizedBox(height: 20),
          Text(widget.media.name, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          StreamBuilder<Duration>(
            stream: player.onDurationChanged,
            initialData: Duration.zero,
            builder: (context, duration) => StreamBuilder<Duration>(
              stream: player.onPositionChanged,
              initialData: Duration.zero,
              builder: (context, position) =>
                  Text('${time(position.data!)} / ${time(duration.data!)}'),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<PlayerState>(
            stream: player.onPlayerStateChanged,
            initialData: PlayerState.stopped,
            builder: (context, state) => Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => action(() async {
                          if (state.data == PlayerState.playing) {
                            await player.pause();
                          } else if (state.data == PlayerState.paused) {
                            await player.resume();
                          } else {
                            await player.play(
                              BytesSource(
                                widget.media.bytes,
                                mimeType: widget.media.mimeType,
                              ),
                            );
                          }
                        }),
                  icon: Icon(
                    state.data == PlayerState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    state.data == PlayerState.playing ? 'Duraklat' : 'Oynat',
                  ),
                ),
                OutlinedButton(
                  onPressed: busy ? null : () => action(player.stop),
                  child: const Text('Durdur'),
                ),
              ],
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(error!),
            ),
        ],
      ),
    ),
  );
}
