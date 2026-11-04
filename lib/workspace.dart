import 'package:flutter/material.dart';

import 'media.dart';
import 'storage.dart';

const ink = Color(0xFF182C36);
const accent = Color(0xFF087F73);

String fileSize(int bytes) => bytes >= 1024 * 1024
    ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
    : '${(bytes / 1024).toStringAsFixed(1)} KB';
IconData mediaIcon(MediaKind kind) => switch (kind) {
  MediaKind.pdf => Icons.picture_as_pdf_outlined,
  MediaKind.audio => Icons.graphic_eq_rounded,
  MediaKind.image => Icons.image_outlined,
};

class WorkspaceScreen extends StatefulWidget {
  final ValueChanged<String> onOpenProject;
  final VoidCallback onSettings;
  final VoidCallback onPagination;
  final VoidCallback onAnimations;
  final VoidCallback onSyncAsync;
  final ValueChanged<String>? onStorageExample;
  final VoidCallback? onNetworkLab;
  const WorkspaceScreen({
    super.key,
    required this.onOpenProject,
    required this.onSettings,
    required this.onPagination,
    required this.onAnimations,
    required this.onSyncAsync,
    this.onStorageExample,
    this.onNetworkLab,
  });
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  String search = '';
  String? customerId;
  bool activeOnly = false;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: AppStorage.changes,
    builder: (context, _, __) {
      final customers = WorkspaceStore.customers;
      final all = WorkspaceStore.projects;
      final projects = all
          .where(
            (p) =>
                (customerId == null || p.customerId == customerId) &&
                (!activeOnly || !p.completed) &&
                '${p.name} ${p.description} ${WorkspaceStore.customer(p.customerId)?.name ?? ''}'
                    .toLowerCase()
                    .contains(search.toLowerCase()),
          )
          .toList()
          .reversed
          .toList();
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ÇALIŞMA ALANINIZ',
                        style: TextStyle(
                          color: Color(0xFF89D4C8),
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Her müşteri. Her proje.\nTüm dosyalar bir arada.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Teklifler, toplantı kayıtları ve saha fotoğrafları için düzenli bir çalışma alanı.',
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Metric(
                      label: 'Müşteri',
                      value: '${customers.length}',
                      icon: Icons.groups_outlined,
                    ),
                    _Metric(
                      label: 'Aktif proje',
                      value: '${all.where((p) => !p.completed).length}',
                      icon: Icons.work_outline,
                    ),
                    _Metric(
                      label: 'Dosya',
                      value: '${MediaStore.all.length}',
                      icon: Icons.description_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sensors, color: accent),
                    title: const Text('Stream / StreamBuilder'),
                    subtitle: const Text('Canlı veri akışı örneğini aç'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: widget.onStorageExample == null
                        ? null
                        : () => widget.onStorageExample!('/stream-example'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.hub_outlined, color: accent),
                    title: const Text('Socket + HTTP Lab'),
                    subtitle: const Text(
                      'TCP soketi üzerinden HTTP isteği gönder',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: widget.onNetworkLab,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Proje veya müşteri ara',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => search = value),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tüm müşteriler'),
                      selected: customerId == null,
                      onSelected: (_) => setState(() => customerId = null),
                    ),
                    for (final customer in customers)
                      ChoiceChip(
                        label: Text(customer.name),
                        selected: customerId == customer.id,
                        onSelected: (_) =>
                            setState(() => customerId = customer.id),
                      ),
                    FilterChip(
                      label: const Text('Sadece aktif'),
                      selected: activeOnly,
                      onSelected: (value) => setState(() => activeOnly = value),
                    ),
                  ],
                ),
                if (customerId != null &&
                    WorkspaceStore.customer(customerId!)!.contact.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'İletişim: ${WorkspaceStore.customer(customerId!)!.contact}',
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Projeleriniz',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (projects.isEmpty)
                  _EmptyState(
                    icon: customers.isEmpty
                        ? Icons.create_new_folder_outlined
                        : Icons.search_off,
                    title: customers.isEmpty
                        ? 'İlk müşterinizle başlayın'
                        : all.isEmpty
                        ? 'İlk projenizi oluşturun'
                        : 'Eşleşen proje bulunamadı',
                    subtitle: customers.isEmpty
                        ? 'Müşteri ekleyin, projesini açın ve dosyalarını düzenlemeye başlayın.'
                        : all.isEmpty
                        ? 'Bir müşteriye bağlı proje açarak PDF, fotoğraf ve ses kayıtlarını ekleyebilirsiniz.'
                        : 'Aramayı veya müşteri filtresini değiştirin.',
                    action: all.isEmpty
                        ? FilledButton(
                            onPressed: () => customers.isEmpty
                                ? showCreateCustomer(context)
                                : showCreateProject(
                                    context,
                                    widget.onOpenProject,
                                  ),
                            child: Text(
                              customers.isEmpty
                                  ? 'İlk müşterini ekle'
                                  : 'Proje oluştur',
                            ),
                          )
                        : null,
                  ),
                LayoutBuilder(
                  builder: (context, constraints) => Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final project in projects)
                        SizedBox(
                          width: constraints.maxWidth >= 760
                              ? (constraints.maxWidth - 16) / 2
                              : constraints.maxWidth,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => widget.onOpenProject(project.id),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.folder_outlined,
                                          color: accent,
                                        ),
                                        const Spacer(),
                                        Text(
                                          project.completed
                                              ? 'Tamamlandı'
                                              : 'Devam ediyor',
                                          style: TextStyle(
                                            color: project.completed
                                                ? Colors.black54
                                                : accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      project.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      WorkspaceStore.customer(
                                            project.customerId,
                                          )?.name ??
                                          '',
                                    ),
                                    if (project.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          project.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 18),
                                    Text(
                                      '${MediaStore.all.where((m) => m.projectId == project.id).length} dosya  ·  Projeyi aç →',
                                      style: const TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bu cihazda saklanır · Hesap veya sunucu bağlantısı gerekmez',
                  style: TextStyle(color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Metric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Metric({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE1E8E4)),
    ),
    child: Row(
      children: [
        Icon(icon, color: accent),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? action;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        Icon(icon, size: 48, color: accent),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

Future<void> showCreateCustomer(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const _EntityDialog(isCustomer: true),
);
Future<void> showCreateProject(
  BuildContext context,
  ValueChanged<String> onCreated,
) async {
  if (WorkspaceStore.customers.isEmpty) {
    await showCreateCustomer(context);
    if (!context.mounted || WorkspaceStore.customers.isEmpty) return;
  }
  if (!context.mounted) return;
  final id = await showDialog<String>(
    context: context,
    builder: (_) => const _EntityDialog(isCustomer: false),
  );
  if (id != null && context.mounted) onCreated(id);
}

class _EntityDialog extends StatefulWidget {
  final bool isCustomer;
  const _EntityDialog({required this.isCustomer});
  @override
  State<_EntityDialog> createState() => _EntityDialogState();
}

class _EntityDialogState extends State<_EntityDialog> {
  final name = TextEditingController();
  final detail = TextEditingController();
  String? customerId;
  String? error;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    detail.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final title = name.text.trim();
    final customer = customerId ?? WorkspaceStore.customers.firstOrNull?.id;
    if (title.isEmpty) {
      setState(() => error = 'Lütfen bir ad yazın.');
      return;
    }
    if (!widget.isCustomer && customer == null) {
      setState(() => error = 'Bir müşteri seçin.');
      return;
    }
    final duplicate = widget.isCustomer
        ? WorkspaceStore.customers.any(
            (c) => c.name.toLowerCase() == title.toLowerCase(),
          )
        : WorkspaceStore.projects.any(
            (p) =>
                p.customerId == customer &&
                p.name.toLowerCase() == title.toLowerCase(),
          );
    if (duplicate) {
      setState(() => error = 'Bu adla bir kayıt zaten var.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final id = WorkspaceStore.newId();
      if (widget.isCustomer) {
        await WorkspaceStore.saveCustomer(
          Customer(id: id, name: title, contact: detail.text.trim()),
        );
      } else {
        await WorkspaceStore.saveProject(
          Project(
            id: id,
            customerId: customer!,
            name: title,
            description: detail.text.trim(),
          ),
        );
      }
      if (mounted) Navigator.pop(context, id);
    } catch (_) {
      if (mounted)
        setState(() {
          error = 'Kayıt saklanamadı. Depolama alanını kontrol edin.';
          saving = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.isCustomer ? 'Müşteri ekle' : 'Yeni proje'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isCustomer) ...[
              DropdownButtonFormField<String>(
                initialValue: WorkspaceStore.customers.firstOrNull?.id,
                decoration: const InputDecoration(labelText: 'Müşteri'),
                items: [
                  for (final customer in WorkspaceStore.customers)
                    DropdownMenuItem(
                      value: customer.id,
                      child: Text(
                        customer.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: saving ? null : (value) => customerId = value,
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: name,
              autofocus: true,
              maxLength: 80,
              enabled: !saving,
              decoration: InputDecoration(
                labelText: widget.isCustomer ? 'Müşteri adı' : 'Proje adı',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detail,
              maxLength: widget.isCustomer ? 160 : 500,
              maxLines: widget.isCustomer ? 1 : 3,
              enabled: !saving,
              decoration: InputDecoration(
                labelText: widget.isCustomer
                    ? 'İletişim (isteğe bağlı)'
                    : 'Proje açıklaması (isteğe bağlı)',
              ),
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        onPressed: saving ? null : save,
        child: Text(saving ? 'Kaydediliyor…' : 'Kaydet'),
      ),
    ],
  );
}

class ProjectScreen extends StatefulWidget {
  final String projectId;
  final Future<void> Function(MediaAttachment) onOpenMedia;
  final VoidCallback onHome, onSettings;
  const ProjectScreen({
    super.key,
    required this.projectId,
    required this.onOpenMedia,
    required this.onHome,
    required this.onSettings,
  });
  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  String search = '';
  MediaKind? kind;
  bool favorites = false;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: AppStorage.changes,
    builder: (context, _, __) {
      final project = WorkspaceStore.project(widget.projectId);
      if (project == null)
        return Scaffold(
          appBar: AppBar(title: const Text('Proje bulunamadı')),
          body: Center(
            child: FilledButton(
              onPressed: widget.onHome,
              child: const Text('Projelere dön'),
            ),
          ),
        );
      final all = MediaStore.all
          .where((m) => m.projectId == project.id)
          .toList();
      final files = all
          .where(
            (m) =>
                (kind == null || m.kind == kind) &&
                (!favorites || m.favorite) &&
                '${m.name} ${m.note}'.toLowerCase().contains(
                  search.toLowerCase(),
                ),
          )
          .toList();
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(project.name),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  WorkspaceStore.customer(project.customerId)?.name ?? '',
                  style: const TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (project.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(project.description),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${all.length} dosya · ${fileSize(all.fold<int>(0, (sum, m) => sum + m.bytes.length))}',
                    ),
                    ActionChip(
                      avatar: Icon(
                        project.completed ? Icons.check_circle : Icons.schedule,
                        size: 18,
                      ),
                      label: Text(
                        project.completed
                            ? 'Tamamlandı · Yeniden aç'
                            : 'Devam ediyor · Tamamla',
                      ),
                      onPressed: () async {
                        try {
                          await WorkspaceStore.saveProject(
                            project.copyWith(completed: !project.completed),
                          );
                        } catch (_) {
                          if (context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proje durumu kaydedilemedi.'),
                              ),
                            );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                MediaPickerCard(
                  onSelected: (media) =>
                      widget.onOpenMedia(media.copyWith(projectId: project.id)),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Dosyalarda veya notlarda ara',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => search = value),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tümü'),
                      selected: kind == null,
                      onSelected: (_) => setState(() => kind = null),
                    ),
                    for (final type in MediaKind.values)
                      ChoiceChip(
                        label: Text(switch (type) {
                          MediaKind.pdf => 'PDF',
                          MediaKind.image => 'Fotoğraf',
                          MediaKind.audio => 'Ses',
                        }),
                        selected: kind == type,
                        onSelected: (_) => setState(() => kind = type),
                      ),
                    FilterChip(
                      label: const Text('Favoriler'),
                      selected: favorites,
                      onSelected: (value) => setState(() => favorites = value),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (files.isEmpty)
                  _EmptyState(
                    icon: Icons.folder_open,
                    title: all.isEmpty
                        ? 'Projenizin ilk dosyasını ekleyin'
                        : 'Eşleşen dosya yok',
                    subtitle: all.isEmpty
                        ? 'Yukarıdaki dosya seçiciyle teklif, fotoğraf veya ses kaydı ekleyebilirsiniz.'
                        : 'Aramayı veya dosya filtresini değiştirin.',
                  ),
                for (final media in files)
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: media.kind == MediaKind.image
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  media.bytes,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image_outlined),
                                ),
                              )
                            : Icon(
                                mediaIcon(media.kind),
                                color: accent,
                                size: 32,
                              ),
                      ),
                      title: Text(
                        media.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${media.label} · ${fileSize(media.bytes.length)}${media.note.isEmpty ? '' : '\n${media.note}'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        media.favorite
                            ? Icons.star_rounded
                            : Icons.chevron_right,
                        color: media.favorite ? Colors.amber.shade700 : null,
                      ),
                      onTap: () => widget.onOpenMedia(media),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> editFile(BuildContext context, MediaAttachment media) =>
    showDialog<void>(
      context: context,
      builder: (_) => _FileEditor(media: media),
    );

class _FileEditor extends StatefulWidget {
  final MediaAttachment media;
  const _FileEditor({required this.media});
  @override
  State<_FileEditor> createState() => _FileEditorState();
}

class _FileEditorState extends State<_FileEditor> {
  late final name = TextEditingController(
    text: widget.media.name.substring(0, widget.media.name.lastIndexOf('.')),
  );
  late final note = TextEditingController(text: widget.media.note);
  String? error;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) {
      setState(() => error = 'Dosya adı boş olamaz.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final extension = widget.media.name.substring(
        widget.media.name.lastIndexOf('.'),
      );
      await MediaStore.add(
        widget.media.copyWith(
          name: '${name.text.trim()}$extension',
          note: note.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        setState(() {
          saving = false;
          error = 'Değişiklikler saklanamadı.';
        });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Dosya bilgileri'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              maxLength: 120,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Dosya adı'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: note,
              maxLength: 2000,
              maxLines: 5,
              enabled: !saving,
              decoration: const InputDecoration(
                labelText: 'Not',
                hintText: 'Bu dosyayla ilgili önemli bilgiler…',
              ),
            ),
            if (error != null) Text(error!),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        onPressed: saving ? null : save,
        child: Text(saving ? 'Kaydediliyor…' : 'Kaydet'),
      ),
    ],
  );
}
